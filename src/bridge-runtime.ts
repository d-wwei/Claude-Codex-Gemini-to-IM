import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
const packageEntry = fileURLToPath(import.meta.resolve('claude-to-im'));
const packageRoot = path.resolve(path.dirname(packageEntry), '../../..');

async function importBridgeModule(relativePath: string) {
  const resolved = path.join(packageRoot, relativePath);
  return import(pathToFileURL(resolved).href);
}

const contextModule = await importBridgeModule('dist/lib/bridge/context.js');
const channelRouterModule = await importBridgeModule('dist/lib/bridge/channel-router.js');
const telegramUtilsModule = await importBridgeModule('dist/lib/bridge/adapters/telegram-utils.js');

export const { getBridgeContext, initBridgeContext } = contextModule;
export const router = channelRouterModule;
export const { escapeHtml } = telegramUtilsModule;
