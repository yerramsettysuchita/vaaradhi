# Changes answer key (HUMANS ONLY)

> **Agents must never read this file.** If `vaaradhi-evidence` or `vaaradhi-breaker` has seen it, the demo result is invalid.
> Keep agent working directories outside this project root so this file isn't in their directory at all (see `CLAUDE.md`).

All three PRs are full-file replacements based on `demo-seed/`. Apply a PR by copying its files (everything except `PR.md`) over `demo-site/`.

| PR | Verdict | Expected outcome |
| --- | --- | --- |
| PR-1: full-width Submit Project button | **Correct** | Ship |
| PR-2: "fix the countdown so it shows the right time" | **Broken (the trap)** | Block |
| PR-3: allow teams of exactly 4 | **Correct** | Ship |

Verified on 5 Nov 2026 (Node v22.16.0, Windows):

- Each PR applied to a copy of `demo-seed`: PR-1 12/12 tests pass, PR-2 12/12 pass, PR-3 13/13 pass.
- On `demo-seed`, `isValidMemberCount(4)` returns `false`, which is the bug PR-3 fixes.

---

## PR-1: correct

CSS only. On narrow screens `.hero-actions` stacks and `.hero-cta` is `width: 100%` with `min-height: 52px`. At 640px and wider it returns to an auto-width 48px button.
**How to show it's right:** take 390×844 screenshots before and after. The button spans the content width and is clearly bigger. A 1280×800 screenshot shows the desktop layout is unchanged in spirit (inline button).

## PR-3: correct

`count < MAX_MEMBERS` becomes `count <= MAX_MEMBERS`. The new test covers 4, `'4'`, and `' 4 '`. Values 0 and 5 are still rejected by the existing test.
**How to show it's right:** run `node --test` on the seed with PR-3's test file only, and the new test fails. With PR-3's `app.js` it passes. In the browser, submitting 4 members shows the confirmation, and 5 shows the error.

## PR-2: broken

### What changed

```js
// before (correct): an absolute instant, 18:29 UTC on 7 Nov 2026
const DEADLINE = new Date('2026-11-07T23:59:00+05:30');

// after (wrong): 23:59 in whatever timezone the visitor's device is in
const DEADLINE = new Date(2026, 10, 7, 23, 59, 0);
```

The component form of `new Date(y, m, d, h, min, s)` is interpreted in the **device's local timezone**. The PR deleted the `+05:30` offset, which was the only thing pinning the deadline to IST. The PR's claim that string parsing is inconsistent across browsers is a red herring: an ISO string with an explicit offset is well-defined.

### Why it slips through review

- On the author's laptop (IST), the countdown is exactly right, so "checked in Chrome, matches to the second" is true.
- All existing tests pass, because they test `getTimeRemaining(deadline, now)` with their own deadline value. **No test checks the `DEADLINE` instant itself.** This holds even under `TZ=UTC`.
- The diff looks like a readability cleanup, with a helpful comment about 0-based months.

### Real effect

| Visitor timezone | Deadline the page counts down to | Error |
| --- | --- | --- |
| Asia/Kolkata (IST) | 2026-11-07T18:29:00Z | none |
| UTC (London in November) | 2026-11-07T23:59:00Z | **5 h 30 m too late** |
| America/New_York (EST, after 1 Nov) | 2026-11-08T04:59:00Z | **10 h 30 m too late** |
| America/Los_Angeles (PST) | 2026-11-08T07:59:00Z | **13 h 30 m too late** |

Anyone outside UTC+05:30 sees more time left than they really have, so they could miss the real deadline. That fits the site's own rule: "The countdown above is the official clock."

### How a breaker can prove it

**1. Fastest: Node in PowerShell (verified 5 Nov 2026).** Run from the project root on a checkout with PR-2 applied:

```powershell
foreach ($tz in 'Asia/Kolkata','UTC','America/New_York') {
  $env:TZ = $tz
  node -e "console.log('$tz', require('./demo-site/app.js').DEADLINE.toISOString())"
}
Remove-Item Env:TZ
```

Expected with PR-2: three **different** instants (`18:29Z`, `23:59Z`, `04:59Z` the next day).
Expected with `demo-seed`: `2026-11-07T18:29:00.000Z` all three times.

**2. Visual proof: Playwright screenshots of the countdown.** Freeze the clock at the same instant, change only the timezone, and screenshot the countdown. With the clock fixed at `2026-11-06T12:00:00Z`:

| Timezone | Correct (seed) | PR-2 shows |
| --- | --- | --- |
| Asia/Kolkata | 1d 06h 29m 00s | 1d 06h 29m 00s |
| UTC | 1d 06h 29m 00s | **1d 11h 59m 00s** |
| America/New_York | 1d 06h 29m 00s | **1d 16h 59m 00s** |

A sketch of the breaker's script (Playwright is the breaker's tool; `demo-seed` itself has no npm dependencies):

```js
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  for (const timezoneId of ['Asia/Kolkata', 'UTC', 'America/New_York']) {
    const context = await browser.newContext({ timezoneId, viewport: { width: 390, height: 844 } });
    const page = await context.newPage();
    await page.clock.setFixedTime(new Date('2026-11-06T12:00:00Z'));
    await page.goto(process.env.PREVIEW_URL);
    await page.locator('[data-countdown]').screenshot({ path: `countdown-${timezoneId.replace('/', '-')}.png` });
    await context.close();
  }
  await browser.close();
})();
```

**Pass/fail rule:** the countdown must be identical in every timezone at the same instant. PR-2 fails.

**3. A test that would have caught it** (what the breaker can propose in its block reason):

```js
test('deadline is 7 Nov 2026 23:59 IST in any timezone', () => {
  assert.equal(DEADLINE.toISOString(), '2026-11-07T18:29:00.000Z');
});
```

Run under `$env:TZ='UTC'`: it fails on PR-2 and passes on the seed.
