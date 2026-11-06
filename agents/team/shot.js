#!/usr/bin/env node
/*
 * shot.js: full-page screenshot of a URL using the laptop's installed Chrome
 * (Playwright channel "chrome", headless). No browser download needed.
 *
 * Usage:
 *   node shot.js --url <url> --viewport <mobile|desktop> --out <file.png>
 *                [--tz <IANA timezone>] [--locale <BCP 47 locale>]
 *                [--time <ISO instant>] [--wait <ms>]
 *
 *   --viewport mobile   390x844, touch, device scale 2
 *   --viewport desktop  1440x900
 *   --tz       e.g. Asia/Kolkata, UTC, America/New_York (default: this computer's)
 *   --locale   e.g. en-IN, de-DE, ja-JP (default: en-US)
 *   --time     freeze the page clock at this instant, e.g. 2026-11-06T12:00:00Z,
 *              so screenshots taken at different moments are comparable
 *   --wait     extra settle time after load, in ms (default: 800)
 *
 * Prints one JSON line describing the result. Exit code 0 on success, 1 on failure.
 */
'use strict';

const fs = require('node:fs');
const path = require('node:path');

// Keep Playwright and Chrome temp files inside the workspace: the Codex sandbox
// blocks writes to the Windows Temp folder (EPERM on mkdtemp).
const LOCAL_TMP = path.join(__dirname, '.tmp');
fs.mkdirSync(LOCAL_TMP, { recursive: true });
process.env.TEMP = LOCAL_TMP;
process.env.TMP = LOCAL_TMP;
process.env.TMPDIR = LOCAL_TMP;

const { chromium } = require('playwright');

const VIEWPORTS = {
  mobile: { viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true },
  desktop: { viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1, isMobile: false, hasTouch: false },
};

function usage(message) {
  if (message) console.error(`Error: ${message}`);
  console.error('Usage: node shot.js --url <url> --viewport <mobile|desktop> --out <file.png> [--tz <zone>] [--locale <locale>] [--time <ISO>] [--wait <ms>]');
  process.exit(1);
}

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    const key = argv[i];
    if (key === '--help' || key === '-h') usage();
    if (!key.startsWith('--')) usage(`unexpected argument "${key}"`);
    const value = argv[i + 1];
    if (value === undefined || value.startsWith('--')) usage(`missing value for ${key}`);
    args[key.slice(2)] = value;
    i++;
  }
  return args;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.url) usage('--url is required');
  if (!args.out) usage('--out is required');
  const preset = VIEWPORTS[args.viewport];
  if (!preset) usage('--viewport must be "mobile" or "desktop"');
  try {
    new URL(args.url);
  } catch {
    usage(`not a valid URL: ${args.url}`);
  }
  let frozenTime = null;
  if (args.time) {
    frozenTime = new Date(args.time);
    if (Number.isNaN(frozenTime.getTime())) usage(`not a valid ISO time: ${args.time}`);
  }
  const waitMs = args.wait ? Number(args.wait) : 800;
  if (!Number.isFinite(waitMs) || waitMs < 0) usage('--wait must be a number of milliseconds');

  const outPath = path.resolve(args.out);
  fs.mkdirSync(path.dirname(outPath), { recursive: true });

  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  try {
    const context = await browser.newContext({
      ...preset,
      locale: args.locale || 'en-US',
      ...(args.tz ? { timezoneId: args.tz } : {}),
    });
    const page = await context.newPage();
    if (frozenTime) await page.clock.setFixedTime(frozenTime);

    const response = await page.goto(args.url, { waitUntil: 'load', timeout: 45000 });
    await page.waitForLoadState('networkidle', { timeout: 15000 }).catch(() => {});
    await page.evaluate(() => document.fonts && document.fonts.ready).catch(() => {});
    await page.waitForTimeout(waitMs);

    await page.screenshot({ path: outPath, fullPage: true });

    const pageInfo = await page.evaluate(() => ({
      title: document.title,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      locale: navigator.language,
      now: new Date().toISOString(),
    }));

    console.log(JSON.stringify({
      ok: true,
      out: outPath,
      url: args.url,
      status: response ? response.status() : null,
      viewport: `${args.viewport} ${preset.viewport.width}x${preset.viewport.height}`,
      ...pageInfo,
    }));
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  console.log(JSON.stringify({ ok: false, error: String(error && error.message ? error.message : error) }));
  process.exit(1);
});
