# Vaaradhi evaluation

## Run 1: 5 Nov 2026

**Sources:** only `C:\VaaradhiAgents\team\evidence\PR-1`, `PR-2`, `PR-3` (`timing.json` and `card.md`), plus the breaker verdicts and outcomes recorded by the user.

**Setup:** `vaaradhi-evidence` (Claude Code), `vaaradhi-breaker` (Codex), `vaaradhi-shipper` (Claude Code, Auto mode off), room `vaaradhi-review` (Mattermost). Demo app: ShipFest 2026 at https://shipfest-2026.vercel.app.

| PR | Tests | Evidence risk | Evidence time | Breaker verdict | Breaker time | Outcome | Review to live |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PR-1 | 12 passed, 0 failed | LOW | 02:30 ¹ | SAFE | 02:10 ² | Shipped | 14:02 |
| PR-2 | 12 passed, 0 failed | HIGH | 04:29 | BROKEN | 08:00 | Blocked: shipper refused | not shipped |
| PR-3 | 13 passed, 0 failed | MEDIUM | 16:16 | v1 BROKEN, then v2 SAFE | 01:50 (v2) | Shipped | 41:08 ³ |

**Times are mm:ss.** Evidence time runs from `review_requested_at` to `evidence_posted_at`. Review to live runs from `review_requested_at` to `shipped_at`.

### Raw timestamps (IST, from `timing.json`)

| PR | Review requested | Evidence posted | Shipped |
| --- | --- | --- | --- |
| PR-1 | 18:34:43 | 18:37:13 | 18:48:45 |
| PR-2 | 18:55:13 | 18:59:42 | n/a |
| PR-3 | 19:33:06 | 19:49:22 | 20:14:14 |

## Notes

1. **PR-1's evidence time doesn't match its card.** The card's "Time taken" line says 02:10, but `timing.json` gives 02:30. The table uses `timing.json`. The cards for PR-2 (04:28) and PR-3 (16:15) are within one second of `timing.json`.
2. **PR-1's breaker time (02:10) is the same as PR-1's evidence card time (02:10).** **Confirmed:** 02:10 is the breaker's own reported time for PR-1, not a copy of the card's time. It came from the user's notes, not from a file.
3. **PR-3's total time includes a stuck-session incident.** A stale session lock (Windows reused the process number after Switch Console quit) made `vaaradhi-evidence` silently retry every 2 minutes until `switch-buddy` renamed the lock note. PR-3's review-to-live time also includes the breaker v1 BROKEN verdict and the v2 re-run. See `docs/BUILD_LOG.md`, 5 Nov 2026. The 16:16 evidence time and 41:08 review-to-live time aren't representative of normal runs.
4. **Broken changes caught: 1 of 1.** PR-2 passed all 12 tests but was rated HIGH by evidence and BROKEN by the breaker, and the shipper refused to ship it. This was **before** the breaker severity rubric was added.
5. **False alarms: 1.** Breaker v1 flagged PR-3 BROKEN on an unrealistic 17-digit decimal. After the severity rubric (v2) it returned SAFE. **Only PR-3 has been reviewed by breaker v2.** Re-run PR-1 and PR-2 with v2 to confirm the rubric doesn't weaken the PR-2 catch.
6. **Human seconds per change is not measured in Run 1.** No file records when the human read the card or answered approval requests. To measure it in Run 2, log the time of each human message (`review PR-n`, `ship PR-n`, and each approval answer).

---

## Run 2: 6 Nov 2026

**Sources:** `C:\VaaradhiAgents\team\evidence\PR-1`, `PR-2`, `PR-3` `timing.json`, plus the breaker verdicts, breaker times, and outcomes recorded by the user.

**Setup:** a fresh room, `vaaradhi-run2` (Mattermost). `vaaradhi-evidence` and `vaaradhi-shipper` ran Claude Code on **Sonnet**. `vaaradhi-breaker` ran Codex with the **v2 severity rubric**. The shipper recorded the human decision timestamps (`breaker_verdict_at`, `human_ship_request_at`, `human_decision_seconds`) in `timing.json`.

| PR | Tests | Evidence risk | Evidence time | Breaker verdict | Breaker time ¹ | Outcome | Human decision ² | Review to live | Approvals per ship |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PR-1 | 12 passed, 0 failed | LOW | 01:24 | SAFE | 02:46 | Shipped | 139 s | 08:31 | |
| PR-2 | 12 passed, 0 failed | HIGH | 01:03 | BROKEN | 01:29 | Blocked: shipper refused, production unchanged | n/a | not shipped | n/a |
| PR-3 | 13 passed, 0 failed | MEDIUM | 00:40 | SAFE (no false alarm) | 01:42 | Shipped | 72 s | 05:13 | |

**Times are mm:ss.** Evidence time runs from `review_requested_at` to `evidence_posted_at`. Review to live runs from `review_requested_at` to `shipped_at`. Human decision runs from `breaker_verdict_at` to `human_ship_request_at`.

**PR-2 evidence finding:** at the real deadline, production correctly says submissions are closed, but a visitor in New York sees **10h 30m left** on the PR-2 preview.

### Raw timestamps (IST, from `timing.json`)

| PR | Review requested | Evidence posted | Breaker verdict | Human "ship" | Shipped |
| --- | --- | --- | --- | --- | --- |
| PR-1 | 14:18:54 | 14:20:18 | 14:24:21 | 14:26:40 | 14:27:25 |
| PR-2 | 14:29:41 | 14:30:44 | not recorded | n/a | n/a |
| PR-3 | 14:34:22 | 14:35:02 | 14:37:51 | 14:39:03 | 14:39:35 |

### Run 2 notes

1. **Breaker time is the breaker's self-reported working time.** The gap in `timing.json` from evidence posted to breaker verdict is longer: 04:03 for PR-1 and 02:49 for PR-3. That gap includes the handoff and session start. PR-2's verdict time wasn't recorded, because the shipper only writes these fields when it ships.
2. **Human decision time includes reading the evidence card and the breaker verdict,** not only typing `ship PR-n`. It measures how long a human needed to trust the change from proof.
3. **In Run 2 PR-1, the breaker hit the Playwright temp-folder permission error twice and worked around it itself.** This is part of PR-1's breaker time. It was fixed permanently afterwards: `C:\VaaradhiAgents\breaker\shot.js` now writes temp files to `shots\.tmp`.
4. **Approvals per ship** is left blank for the user to fill in from the room.

---

## Run 1 vs Run 2

| Measure | Run 1 (5 Nov) | Run 2 (6 Nov) |
| --- | --- | --- |
| Evidence time PR-1 / PR-2 / PR-3 | 02:30 / 04:29 / 16:16 | 01:24 / 01:03 / 00:40 |
| Breaker time PR-1 / PR-2 / PR-3 (self-reported) | 02:10 / 08:00 / 01:50 (v2) | 02:46 / 01:29 / 01:42 |
| Review to live PR-1 / PR-3 | 14:02 / 41:08 | 08:31 / 05:13 |
| Human decision PR-1 / PR-3 | not measured | 139 s / 72 s |
| Broken changes caught | 1 of 1 (PR-2) | 1 of 1 (PR-2) |
| Broken changes shipped | 0 | 0 |
| False alarms | 1 (PR-3, breaker v1) | 0 |
| Tests that caught PR-2 | 0 of 12 | 0 of 12 |

### Comparison notes

- **The rubric didn't weaken the catch.** Breaker v2 still marked PR-2 BROKEN, which answers Run 1 note 5. It also returned SAFE for PR-1 and PR-3 with no false alarm.
- **Run 1's PR-3 numbers include a stuck-session incident and a breaker re-run** (Run 1 note 3). So the drop from 41:08 to 05:13 overstates the normal improvement.
- **Several things changed between the runs:**
  - Run 2 used Sonnet for evidence and shipper. Run 1's model wasn't recorded.
  - Run 2 used a fresh room.
  - The breaker used the v2 rubric.
  - The shipper instructions and `shot.js` were improved between runs.

  These effects can't be separated with two runs.
- **The test suite never caught PR-2 in either run.** The evidence card and the breaker caught it.
