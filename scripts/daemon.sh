#!/usr/bin/env bash
set -euo pipefail
CTI_HOME="$HOME/.claude-to-im"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="$CTI_HOME/runtime/bridge.pid"
STATUS_FILE="$CTI_HOME/runtime/status.json"
LOG_FILE="$CTI_HOME/logs/bridge.log"

ensure_dirs() { mkdir -p "$CTI_HOME"/{data,logs,runtime,data/messages}; }

case "${1:-help}" in
  start)
    ensure_dirs
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Bridge already running (PID: $(cat "$PID_FILE"))"
      cat "$STATUS_FILE" 2>/dev/null
      exit 1
    fi
    nohup node "$SKILL_DIR/dist/daemon.mjs" >> "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    sleep 2
    if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Bridge started (PID: $(cat "$PID_FILE"))"
      cat "$STATUS_FILE" 2>/dev/null
    else
      echo "Failed to start bridge. Check logs: $LOG_FILE"
      tail -20 "$LOG_FILE"
      exit 1
    fi
    ;;
  stop)
    if [ ! -f "$PID_FILE" ]; then echo "No bridge running"; exit 0; fi
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID"
      for i in $(seq 1 10); do
        kill -0 "$PID" 2>/dev/null || break
        sleep 1
      done
      kill -0 "$PID" 2>/dev/null && kill -9 "$PID"
      echo "Bridge stopped"
    else
      echo "Bridge was not running (stale PID file)"
    fi
    rm -f "$PID_FILE"
    ;;
  status)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Bridge is running (PID: $(cat "$PID_FILE"))"
      cat "$STATUS_FILE" 2>/dev/null
    else
      echo "Bridge is not running"
      [ -f "$PID_FILE" ] && rm -f "$PID_FILE"
    fi
    ;;
  logs)
    N="${2:-50}"
    tail -n "$N" "$LOG_FILE" 2>/dev/null | sed -E 's/(token|secret|password)(["\x27]?\s*[:=]\s*["\x27]?)[^ "]+/\1\2*****/gi'
    ;;
  *)
    echo "Usage: daemon.sh {start|stop|status|logs [N]}"
    ;;
esac
