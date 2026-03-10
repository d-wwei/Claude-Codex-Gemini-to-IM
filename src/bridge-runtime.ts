// Re-export bridge modules for use by session-command-support and voice-reply.
// These are imported directly from source since the claude-to-im package
// is bundled by esbuild at build time.
export { getBridgeContext, initBridgeContext } from 'claude-to-im/src/lib/bridge/context.js';
export * as router from 'claude-to-im/src/lib/bridge/channel-router.js';
export { escapeHtml } from 'claude-to-im/src/lib/bridge/adapters/telegram-utils.js';
