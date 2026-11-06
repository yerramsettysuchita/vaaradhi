\# Run 2 room log



Room: vaaradhi-run2 (private Mattermost channel via Switch)

Date: 6 Nov 2026, times in IST

Copied from the room as text. Attachments are listed by file name.



\---



System · 2:15 PM

@admin joined the channel.

You and 3 others were added to the channel by @admin.



vaaradhi-evidence (BOT) · 2:15 PM

Hello! I'm ready — just tag @vaaradhi-evidence when you need me.



vaaradhi-shipper (BOT) · 2:15 PM

Hello! Tag @vaaradhi-shipper to loop me in.



vaaradhi-breaker (BOT) · 2:15 PM

Hey there! Tag @vaaradhi-breaker if you need me.



user · 2:17 PM

!list-agents

(1 reply)



System · 2:17 PM

@Switch added to the channel by @admin.



\---



\## PR-1



user · 2:18 PM

@vaaradhi-evidence review PR-1



vaaradhi-evidence (BOT) · 2:18 PM

Starting a session to handle this — one moment.



vaaradhi-evidence (BOT) · 2:18 PM

On it — reviewing PR-1.



vaaradhi-evidence (BOT) · 2:20 PM

Preview deployed and screenshots taken. Checking the before/after images now, then I'll post the evidence card.



vaaradhi-evidence (BOT) · 2:20 PM

EVIDENCE · PR-1 · Make the hero "Submit Project" button full-width and easy to tap on mobile

Claims: Hero Submit button becomes full-width with a 52px tap target on mobile; unchanged look on tablet/desktop. CSS only.

What actually changed: On phones the big "Submit Project" button now stretches across the screen with "Read the rules" centred below it; on desktop it looks the same as before. Matches the PR text.

Files touched: styles.css

Tests: 12 passed, 0 failed

Preview: https://shipfest-2026-dfb70namr-yerramsettysuchitas-projects.vercel.app

Production: https://shipfest-2026.vercel.app

Screenshots: before/after, mobile and desktop (attached)

Risk: LOW — only hero button styling changed, and tests pass.

Time taken: 01:24 (requested 6 Nov 2026, 14:18:54 IST)

Attachments: before-mobile.png, after-mobile.png, before-desktop.png, after-desktop.png



vaaradhi-evidence (BOT) · 2:20 PM

@vaaradhi-breaker please try to break PR-1. Preview: https://shipfest-2026-dfb70namr-yerramsettysuchitas-projects.vercel.app. Production: https://shipfest-2026.vercel.app



vaaradhi-breaker (BOT) · 2:20 PM

Worked for 3m 27s. 15 tool calls. 13 done, 2 failed.



vaaradhi-breaker (BOT) · 2:20 PM

Starting a session to handle this — one moment.



vaaradhi-breaker (BOT) · 2:24 PM

PR-1 QA screenshots: preview and production at mobile/desktop, timezone comparisons, and ja-JP preview.

Attachments: preview-mobile-UTC-en-US.png, prod-mobile-UTC-en-US.png, preview-desktop-UTC-en-US.png, prod-desktop-UTC-en-US.png, preview-mobile-Asia-Kolkata-en-US.png, prod-mobile-Asia-Kolkata-en-US.png, preview-mobile-America-New\_York-en-US.png, prod-mobile-America-New\_York-en-US.png, preview-mobile-UTC-ja-JP.png



vaaradhi-breaker (BOT) · 2:24 PM

SAFE · PR-1 · The mobile hero button is full-width in preview; desktop remains auto-width, with no breakage found.

Claim: PR.md claims a 52px full-width mobile "Submit Project" button and the normal auto-width layout from 640px upward.

Evidence: Attached preview/prod mobile and desktop screenshots show the intended difference only on mobile; timezone screenshots retain the same deadline/countdown; ja-JP preview remains readable.

Who is affected: Mobile visitors get the larger tap target; desktop layout is unchanged.

Checks run:

\- Viewports: compared preview and production at 390×844 and 1440×900; no overflow or overlap seen.

\- Timezones: compared both sites at the same frozen instant in UTC, Asia/Kolkata, and America/New\_York; countdown stays consistent.

\- Locale: preview ja-JP screenshot; layout and displayed numbers remain legible.

\- Forms: n.a. — CSS-only hero action change.

Minor notes: none.

Time taken: 02:46



user · 2:26 PM

@vaaradhi-shipper ship PR-1

(4 replies)



vaaradhi-shipper (BOT) · 2:26 PM

Starting a session to handle this — one moment.



vaaradhi-shipper (BOT) · 2:27 PM

SHIPPED · PR-1

Live: https://shipfest-2026.vercel.app

Review requested 6 Nov 2026, 14:18:54 IST → live 6 Nov 2026, 14:27:25 IST (total 0:08:31)

Human decision time: 139 s (breaker verdict → human "ship PR-1")

Production deploy was approved by a human through the Switch approval request.



\---



\## PR-2



user · 2:29 PM

@vaaradhi-evidence review PR-2



vaaradhi-evidence (BOT) · 2:29 PM

On it — reviewing PR-2.



vaaradhi-evidence (BOT) · 2:30 PM

PR-2 preview is up and tested. I found a problem and am posting the evidence card now.



vaaradhi-breaker (BOT) · 2:31 PM

Worked for 1m 55s. 12 tool calls.



vaaradhi-evidence (BOT) · 2:31 PM

EVIDENCE · PR-2 · Fix the countdown so it shows the right time

Claims: Countdown deadline is rebuilt with new Date(2026, 10, 7, 23, 59, 0) so it matches 7 Nov 2026, 11:59 PM; "one-line constant change".

What actually changed: The deadline used to be a fixed moment (11:59 PM India time). It is now 11:59 PM in each visitor's own timezone, so people outside India see a different deadline than the page says (it still says "close 7 Nov 2026, 11:59 PM IST"). In IST nothing changes. Claim does not match the behaviour.

Evidence: at 18:29 UTC on 7 Nov (the real deadline moment), a New York visitor sees "Submissions are closed" on production (correct) but 10h 30m left on the preview (wrong).

Files touched: app.js

Tests: 12 passed, 0 failed (tests run in the default zone and don't cover this)

Preview: https://shipfest-2026-mew1bysj9-yerramsettysuchitas-projects.vercel.app

Production: https://shipfest-2026.vercel.app

Screenshots: before/after, mobile and desktop (attached), plus New York-timezone before/after

Risk: HIGH — misleads users about the deadline; someone outside IST could submit late or give up early.

Time taken: 01:03 (requested 6 Nov 2026, 14:29:41 IST)

Attachments: before-mobile.png, after-mobile.png, before-desktop.png, after-desktop.png, before-mobile-newyork.png, after-mobile-newyork.png



vaaradhi-evidence (BOT) · 2:31 PM

@vaaradhi-breaker please try to break PR-2. Preview: https://shipfest-2026-mew1bysj9-yerramsettysuchitas-projects.vercel.app. Production: https://shipfest-2026.vercel.app



user · 2:32 PM

@vaaradhi-shipper ship PR-2

(1 reply)



vaaradhi-breaker (BOT) · 2:33 PM

PR-2 QA screenshots. All frozen at 2026-11-07 18:29 UTC, the stated IST deadline; New York preview still shows 10h30m remaining while production is closed.

Attachments: preview-mobile-UTC-en-US.png, prod-mobile-UTC-en-US.png, preview-desktop-UTC-en-US.png, prod-desktop-UTC-en-US.png, preview-mobile-Asia-Kolkata-en-US.png, prod-mobile-Asia-Kolkata-en-US.png, preview-mobile-America-New\_York-en-US.png, prod-mobile-America-New\_York-en-US.png, preview-mobile-UTC-de-DE.png



vaaradhi-breaker (BOT) · 2:33 PM

BROKEN · PR-2 · At the stated IST deadline, New York visitors still see 10h30m left and can be misled into submitting late.

Claim: PR.md says the countdown matches the official 7 Nov 2026, 11:59 PM deadline.

Evidence: Attached preview-mobile-America-New\_York-en-US.png shows 10h30m remaining at 2026-11-07 18:29 UTC; prod-mobile-America-New\_York-en-US.png says submissions are closed. IST screenshots show both closed.

Who is affected: Visitors whose device timezone is outside India; they may rely on the incorrect countdown and miss the real deadline.

Steps to reproduce:

1\. Open the preview in a New York timezone at 2026-11-07 18:29 UTC (11:59 PM IST).

2\. Compare the countdown with production or the page's stated IST deadline.

3\. Preview shows 10h30m remaining while production says submissions are closed.

Checks run: viewports ✓ timezones ✓ locale ✓ forms n.a.

Time taken: 01:29



vaaradhi-shipper (BOT) · 2:33 PM

Not shipping PR-2. The breaker's latest verdict is BROKEN: "At the stated IST deadline, New York visitors still see 10h30m left and can be misled into submitting late." The change has to be fixed and reviewed again before it can ship.



\---



\## PR-3



user · 2:34 PM

@vaaradhi-evidence review PR-3



vaaradhi-evidence (BOT) · 2:34 PM

On it — reviewing PR-3.



vaaradhi-evidence (BOT) · 2:35 PM

PR-3 preview and tests are done. Posting the evidence card now.



vaaradhi-evidence (BOT) · 2:35 PM

EVIDENCE · PR-3 · Allow teams of exactly 4 members (fix off-by-one in member count validation)

Claims: Teams of 4 were wrongly rejected; the upper limit becomes inclusive and a regression test is added.

What actually changed: The form now accepts a team of 4 people, which the rules already allow. Before, a full team of 4 got an error and couldn't submit. 5 or more is still rejected. Matches the PR text.

Files touched: app.js, tests/validation.test.js

Tests: 13 passed, 0 failed (includes the new 4-member test)

Preview: https://shipfest-2026-pc2bwpoih-yerramsettysuchitas-projects.vercel.app

Production: https://shipfest-2026.vercel.app

Screenshots: before/after, mobile and desktop (attached); the page looks identical, since the change is form logic, not layout

Risk: MEDIUM — changes validation logic users rely on, though the change is one comparison and is covered by a test.

Time taken: 00:40 (requested 6 Nov 2026, 14:34:22 IST)

Attachments: before-mobile.png, after-mobile.png, before-desktop.png, after-desktop.png



vaaradhi-evidence (BOT) · 2:35 PM

@vaaradhi-breaker please try to break PR-3. Preview: https://shipfest-2026-pc2bwpoih-yerramsettysuchitas-projects.vercel.app. Production: https://shipfest-2026.vercel.app



vaaradhi-breaker (BOT) · 2:35 PM

Worked for 2m 18s. 7 tool calls.



vaaradhi-breaker (BOT) · 2:37 PM

PR-3 QA screenshots: preview/production mobile and desktop, three timezone comparisons at one fixed instant, and de-DE preview. Form is shown in its initial state.

Attachments: preview-mobile-UTC-en-US.png, prod-mobile-UTC-en-US.png, preview-desktop-UTC-en-US.png, prod-desktop-UTC-en-US.png, preview-mobile-Asia-Kolkata-en-US.png, prod-mobile-Asia-Kolkata-en-US.png, preview-mobile-America-New\_York-en-US.png, prod-mobile-America-New\_York-en-US.png, preview-mobile-UTC-de-DE.png



vaaradhi-breaker (BOT) · 2:37 PM

SAFE · PR-3 · The inclusive member limit matches the stated four-person maximum; no user-facing break found.

Claim: PR.md says the form accepts exactly 4 members while continuing to reject counts outside 1–4.

Evidence: Attached preview/prod form screenshots show matching mobile and desktop layouts and the "Up to 4 people" hint; visual layout is unchanged by this validation-only change.

Who is affected: Teams of 4 can now submit; other counts remain constrained.

Checks run:

\- Viewports: compared preview and production at 390×844 and 1440×900; no overflow or overlap.

\- Timezones: compared both sites at the same frozen time in UTC, Asia/Kolkata and America/New\_York; countdown matches.

\- Locale: preview de-DE screenshot; layout and numbers remain legible.

\- Forms: reasoned from changed code and form constraints (not typed): 1 and 4 pass; 0, 5, empty, spaces, nonnumeric and non-integer decimals fail. 4.0 is numerically 4; number input sanitizes nonnumeric text; novalidate means min/max/step do not block JS. Team-name maxlength is 60; email/URL validation is unchanged.

Minor notes: none.

Time taken: 01:42



user · 2:38 PM

@vaaradhi-shipper ship PR-3

(4 replies)



vaaradhi-shipper (BOT) · 2:39 PM

SHIPPED · PR-3

Live: https://shipfest-2026.vercel.app

Review requested 6 Nov 2026, 14:34:22 IST → live 6 Nov 2026, 14:39:35 IST (total 0:05:13)

Human decision time: 72 s (breaker verdict → human "ship PR-3")

Production deploy was approved by a human through the Switch approval request.

