# Vaaradhi evaluation

## Method

- **Source of every Run 1 and Run 2 timing:** Switch server and session logs on this computer, read (read only) by switch-buddy on 6 Nov 2026. All times are IST. Run 3 timings are agent-reported and not log-verified (see Run 3).
  - **Room inbox (server time):** the review and ship messages from the human.
  - **Agent session logs:** the time each agent's post to the room completed. The server time is a fraction of a second earlier.
- **Calculation:** durations are computed by script and rounded to the nearest second.
- **Definitions:**
  - **Evidence time:** EVIDENCE card minus review message.
  - **Card to verdict:** breaker verdict post minus EVIDENCE card. This replaces the breaker's self-reported working time (see note 1 under Run 1 vs Run 2).
  - **Human decision:** ship message minus the final SAFE verdict it acted on.
  - **Review to live:** SHIPPED post minus review message.
- **Why we re-derived them:** the clock times the agents wrote into `timing.json` were approximate.
  - **Run 2:** they differed from the server logs by 4.8 to 27.9 seconds, in both directions. Example: PR-1's review was recorded at 14:18:54, but the server shows 14:18:26.386.
  - **Run 1:** recorded evidence times were up to 42.9 seconds early.
- **Why Run 2's agent-recorded human decision times were nearly right (139 s and 72 s):** both ends of each interval carried the same offset. The verdict and ship times were both recorded about 27 seconds late, so the offset cancelled out.
- **The superseded agent-recorded values** are kept at the end of this file for transparency.

## Run 1: 5 Nov 2026

**Setup:** `vaaradhi-evidence` (Claude Code), `vaaradhi-breaker` (Codex), `vaaradhi-shipper` (Claude Code, Auto mode off), room `vaaradhi-review` (Mattermost). Demo app: ShipFest 2026 at https://shipfest-2026.vercel.app.

| PR | Tests | Evidence risk | Evidence time | Breaker verdict | Card to verdict | Outcome | Human decision | Review to live |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PR-1 | 12 passed, 0 failed | LOW | 03:09 | SAFE | 03:29 | Shipped | 188 s | 14:13 |
| PR-2 | 12 passed, 0 failed | HIGH | 05:11 | BROKEN | 08:59 | Blocked: shipper refused | n/a | not shipped |
| PR-3 | 13 passed, 0 failed | MEDIUM | 16:24 | v1 BROKEN (03:38), then v2 SAFE | 22:33 (v2) | Shipped | 74 s | 41:14 |

**Times are mm:ss**, except human decision, which is in seconds.

### Run 1 notes

1. **PR-3's times include a stuck-session incident and a breaker re-run.**
   - A stale session lock (Windows reused the process number after Switch Console quit) made `vaaradhi-evidence` silently retry every 2 minutes until `switch-buddy` renamed the lock note.
   - Breaker v1 returned BROKEN at 03:38 after the card. After the severity rubric, v2 returned SAFE at 22:33 after the card. See `docs/BUILD_LOG.md`, 5 Nov 2026.
   - PR-3's evidence time, card to verdict and review to live aren't representative of normal runs.
2. **The human asked to ship PR-2 before any verdict existed.**
   - The first `ship PR-2` message was at 19:03:26.573, and the breaker's BROKEN verdict came at 19:09:23.370.
   - The shipper held at 19:03:45.841 because there was no verdict yet.
   - It refused after the BROKEN verdict.
   - PR-2 got no approval request and was not shipped.
3. **Broken changes caught: 1 of 1.** PR-2 passed all 12 tests but was rated HIGH by evidence and BROKEN by the breaker, and the shipper refused to ship it. This was **before** the breaker severity rubric was added.
4. **False alarms: 1.** Breaker v1 flagged PR-3 BROKEN on an unrealistic 17-digit decimal. After the severity rubric (v2) it returned SAFE.

### Run 1 log timestamps (IST)

| PR | Review | EVIDENCE card | Verdict | Ship message | Deploy approval answered | SHIPPED |
| --- | --- | --- | --- | --- | --- | --- |
| PR-1 | 18:34:43.849 | 18:37:53.101 | 18:41:21.655 (SAFE) | 18:44:29.850 | 18:48:13.350 | 18:48:57.201 |
| PR-2 | 18:55:13.874 | 19:00:24.862 | 19:09:23.370 (BROKEN) | 19:03:26.573, 19:13:25.827, 19:14:32.519, 19:19:45.065, 19:23:28.630, 19:27:34.201 | none | not shipped |
| PR-3 | 19:33:06.403 | 19:49:30.308 | 19:53:08.226 (v1 BROKEN), 20:12:02.917 (v2 SAFE) | 20:13:16.461 | 20:13:47.876 | 20:14:20.782 |

**PR-2 shipper log:** held with no verdict yet at 19:03:45.841. Refused at 19:32:13.546, 19:32:52.359, 19:33:22.296, 19:33:45.541 and 19:34:04.326.

---

## Run 2: 6 Nov 2026

**Setup:** a fresh room, `vaaradhi-run2` (Mattermost). `vaaradhi-evidence` and `vaaradhi-shipper` ran Claude Code on **Sonnet**. `vaaradhi-breaker` ran Codex with the **v2 severity rubric**.

| PR | Tests | Evidence risk | Evidence time | Breaker verdict | Card to verdict | Outcome | Human decision | Review to live | Approvals per ship ¹ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PR-1 | 12 passed, 0 failed | LOW | 01:56 | SAFE | 03:31 | Shipped | 140 s | 09:08 | 3 |
| PR-2 | 12 passed, 0 failed | HIGH | 01:34 | BROKEN | 01:54 | Blocked: shipper refused, production unchanged | n/a | not shipped | 0 |
| PR-3 | 13 passed, 0 failed | MEDIUM | 00:57 | SAFE (no false alarm) | 02:16 | Shipped | 72 s | 05:29 | 3 |

**Times are mm:ss**, except human decision, which is in seconds.

**PR-2 evidence finding:** at the real deadline, production correctly says submissions are closed, but a visitor in New York sees **10h 30m left** on the PR-2 preview.

### Run 2 notes

1. **Approvals per ship (¹).** Source: switch-buddy reading `vaaradhi-shipper`'s own log in `vaaradhi-run2` on 6 Nov 2026.
   - **`ship PR-1`:** exactly 3 approval requests (back up site and apply PR-1, deploy site to production, screenshot production and record timing). All were answered Allow once by the owner, at 2:26:42, 2:26:57 and 2:27:18 PM IST.
   - **`ship PR-3`:** exactly 3, request ids A4, A5 and A6, for the same three steps. All were answered Allow once by the owner, at 2:38:56, 2:39:08 and 2:39:26 PM IST.
   - **None** was Allow for this session, and none was declined.
   - **`ship PR-2`:** 0 approval requests, because the shipper refused.
   - **Each approval** was answered 6 to 9 seconds after it was raised.
2. **The breaker posted its screenshots and its verdict as two separate posts.** The room shows the verdict text as the second post, so card to verdict uses the verdict post time.
3. **Human decision time includes reading** the evidence card and the breaker verdict, not only typing `ship PR-n`.
4. **In Run 2 PR-1, the breaker hit the Playwright temp-folder permission error twice and worked around it itself.** It was fixed permanently afterwards: `C:\VaaradhiAgents\breaker\shot.js` now writes temp files to `shots\.tmp`.

### Run 2 log timestamps (IST)

| PR | Review | EVIDENCE card | Breaker screenshots post | Verdict post | Ship message | Deploy approval answered | SHIPPED |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PR-1 | 14:18:26.386 | 14:20:22.823 | 14:23:47.482 | 14:23:53.352 (SAFE) | 14:26:12.923 | 14:26:57.782 | 14:27:34.347 |
| PR-2 | 14:29:16.087 | 14:30:49.776 | 14:32:33.216 | 14:32:43.838 (BROKEN) | 14:33:00.413 | none | not shipped (refused 14:33:12.140) |
| PR-3 | 14:34:10.481 | 14:35:07.279 | 14:37:06.664 | 14:37:23.140 (SAFE) | 14:38:35.608 | 14:39:08.394 | 14:39:39.846 |

---

## Run 3: 7 Nov 2026

**Setup:** a fresh room, `vaaradhi-run3`. The same agents as Run 2, unchanged. PR-1 was not run in Run 3.

**Timings are agent-reported and not log-verified.** They were not re-derived from Switch logs because of time. In Run 2, agent-recorded clock times were off by up to 27.9 seconds, so treat these as approximate.

| PR | Tests | Evidence risk | Evidence time (agent-reported) | Breaker verdict | Breaker working time (self-reported) | Outcome | Human decision (agent-reported) | Review to live (agent-reported) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PR-1 | not run | | | | | | | |
| PR-2 | 12 passed, 0 failed | HIGH | 01:41 | BROKEN | 01:40 | Blocked: shipper refused | n/a | not shipped |
| PR-3 | 13 passed, 0 failed | MEDIUM | 01:07 | SAFE (Minor notes: none) | 02:10 | Shipped | 70 s | 06:25 |

### Run 3 notes

1. **PR-2 evidence finding:** at 8:00 PM IST, a New York visitor sees 3h 59m on production and 14h 29m on the PR-2 preview.
2. **PR-2 breaker verdict:** BROKEN. At the same frozen instant, it showed the New York preview at 14h 29m versus production at 3h 59m, and the UTC preview at 9h 29m.
3. **`ship PR-2`:** refused by the shipper, quoting the BROKEN verdict.
4. **PR-3:** the evidence card found that the claim matches the change. The breaker said SAFE with Minor notes: none, and PR-3 shipped.
5. **No failed tool calls:** the breaker's room summaries in Run 3 show none, unlike PR-1 in Run 2. This supports the `shots\.tmp` temp-folder fix.

---

## Run 1 vs Run 2

| Measure | Run 1 (5 Nov) | Run 2 (6 Nov) |
| --- | --- | --- |
| Evidence time PR-1 / PR-2 / PR-3 | 03:09 / 05:11 / 16:24 | 01:56 / 01:34 / 00:57 |
| Card to verdict PR-1 / PR-2 / PR-3 | 03:29 / 08:59 / 22:33 (v2) | 03:31 / 01:54 / 02:16 |
| Human decision PR-1 / PR-3 | 188 s / 74 s | 140 s / 72 s |
| Review to live PR-1 / PR-3 | 14:13 / 41:14 | 09:08 / 05:29 |
| Broken changes caught | 1 of 1 (PR-2) | 1 of 1 (PR-2) |
| Broken changes shipped | 0 | 0 |
| False alarms | 1 (PR-3, breaker v1) | 0 |
| Tests that caught PR-2 | 0 of 12 | 0 of 12 |

### Comparison notes

1. **Card to verdict replaces the breaker's self-reported working time.** For transparency, the breaker reported working times of 02:10 / 08:00 / 01:50 (v2) in Run 1, and 02:46 / 01:29 / 01:42 in Run 2. Card to verdict is longer because it also includes the handoff and the breaker's session starting.
2. **The rubric didn't weaken the catch.** Breaker v2 still marked PR-2 BROKEN. It also returned SAFE for PR-1 and PR-3, with no false alarm.
3. **Run 1's PR-3 numbers include a stuck-session incident and a breaker re-run,** so the drop from 41:14 to 05:29 overstates the normal improvement.
4. **Several things changed between the runs:**
   - Run 2 used Sonnet for evidence and shipper. Run 1's model wasn't recorded.
   - Run 2 used a fresh room.
   - The breaker used the v2 rubric.
   - The shipper instructions and `shot.js` were improved between runs.

   These effects can't be separated with two runs.
5. **The test suite never caught PR-2 in any run.** It passed all 12 tests in Runs 1, 2 and 3. The evidence card and the breaker caught it.
6. **Run 3 used the same agents with no changes.** The evidence agent found the PR-2 bug at a different moment than in Run 2 (8:00 PM IST instead of the deadline itself), which shows the check is not scripted.

---

## Superseded: agent-recorded values

These came from `timing.json` and the agents' own messages before the timings were re-derived from Switch logs. They are kept for transparency only. Use the tables above.

| Run | PR | Evidence time | Breaker time (self-reported) | Human decision | Review to live |
| --- | --- | --- | --- | --- | --- |
| Run 1 | PR-1 | 02:30 (card said 02:10) | 02:10 | not recorded | 14:02 |
| Run 1 | PR-2 | 04:29 | 08:00 | n/a | not shipped |
| Run 1 | PR-3 | 16:16 | 01:50 (v2) | not recorded | 41:08 |
| Run 2 | PR-1 | 01:24 | 02:46 | 139 s | 08:31 |
| Run 2 | PR-2 | 01:03 | 01:29 | n/a | not shipped |
| Run 2 | PR-3 | 00:40 | 01:42 | 72 s | 05:13 |

Agent-recorded clock times, IST:

| Run | PR | Review requested | Evidence posted | Breaker verdict | Human "ship" | Shipped |
| --- | --- | --- | --- | --- | --- | --- |
| Run 1 | PR-1 | 18:34:43 | 18:37:13 | not recorded | not recorded | 18:48:45 |
| Run 1 | PR-2 | 18:55:13 | 18:59:42 | not recorded | not recorded | n/a |
| Run 1 | PR-3 | 19:33:06 | 19:49:22 | not recorded | not recorded | 20:14:14 |
| Run 2 | PR-1 | 14:18:54 | 14:20:18 | 14:24:21 | 14:26:40 | 14:27:25 |
| Run 2 | PR-2 | 14:29:41 | 14:30:44 | not recorded | n/a | n/a |
| Run 2 | PR-3 | 14:34:22 | 14:35:02 | 14:37:51 | 14:39:03 | 14:39:35 |
