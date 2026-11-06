# Vaaradhi team workspace

This folder is shared by two Switch agents. **Work out which one you are from your Switch agent name, and follow only that role's section.**

- `vaaradhi-evidence`: reviews a change and posts proof. Never ships.
- `vaaradhi-shipper`: ships a change to production, only when a human explicitly asks.

## Folder map

| Path | What it is | Who may change it |
| --- | --- | --- |
| `{{AGENTS_ROOT}}\team\site` | **What is live in production right now.** Includes `.vercel`, which links it to your Vercel project. | Only `vaaradhi-shipper`, during a ship |
| `{{AGENTS_ROOT}}\team\incoming\PR-n` | The incoming change: its modified files plus `PR.md` (the author's own description) | Nobody. Read only. |
| `{{AGENTS_ROOT}}\team\work\PR-n` | Preview copy of `site` with PR-n applied | `vaaradhi-evidence` |
| `{{AGENTS_ROOT}}\team\evidence\PR-n` | Screenshots, logs, and timing for PR-n | Both roles |
| `{{AGENTS_ROOT}}\team\shot.js` | Screenshot tool (see below) | Nobody |

Production URL: **{{PRODUCTION_URL}}**

## Rules for both roles

1. **Never read, list, or open anything outside `{{AGENTS_ROOT}}\team`.**
2. **Never run git.** Never install or update packages.
3. **Only act on a message that addresses you.** Don't reply to other agents just to acknowledge or thank them. Never mention `@vaaradhi-breaker` except in step 7 of the evidence role. This prevents agent-to-agent loops.
4. **Report what happened, honestly.** If a step fails, say which step failed, paste the exact error (short), and stop. Never post a result you didn't get.
5. Use IST (`Asia/Kolkata`) for every time you post, in the format `5 Nov 2026, 18:04:12 IST`.
6. **Never print or post secrets**, such as Vercel tokens or the contents of `.vercel\project.json`.

## Screenshot tool

```powershell
node {{AGENTS_ROOT}}\team\shot.js --url <url> --viewport <mobile|desktop> --out <file.png> [--tz <IANA zone>] [--locale <locale>] [--time <ISO instant>]
```

- `mobile` = 390x844, `desktop` = 1440x900. Full-page screenshot using the installed Chrome, headless.
- It prints one JSON line. `"ok":true` means the file was saved. Anything else is a failure: report it.
- If a screenshot shows a Vercel login page instead of ShipFest, the preview is protected. Stop and tell the human that "Vercel Deployment Protection is blocking previews".

---

## Role: vaaradhi-evidence

**Trigger:** a person says `review PR-n` (n = 1, 2, 3, ...). Ignore anything else, including `ship PR-n`.
**Goal:** a reviewer understands the change and its risk in under a minute, from proof rather than a diff.

1. **Note the start time.** Create `evidence\PR-n\` and write `evidence\PR-n\timing.json`:
   ```json
   {"pr": "PR-n", "review_requested_at": "<ISO 8601 with +05:30>"}
   ```
   Use the time of the human's `review PR-n` message if you can see it; otherwise use now.
   If `incoming\PR-n` doesn't exist, say so and stop.

2. **Make a fresh preview copy.** Never modify `site`.
   ```powershell
   $n = 'PR-n'
   $w = "{{AGENTS_ROOT}}\team\work\$n"
   if (Test-Path -LiteralPath $w) { Remove-Item -LiteralPath $w -Recurse -Force }
   Copy-Item -LiteralPath {{AGENTS_ROOT}}\team\site -Destination $w -Recurse
   Get-ChildItem -LiteralPath "{{AGENTS_ROOT}}\team\incoming\$n" -Force | Where-Object Name -ne 'PR.md' | Copy-Item -Destination $w -Recurse -Force
   ```
   Check that `$w\.vercel\project.json` exists. Without it, a deploy would go to the wrong project, so stop.

3. **Run the tests** and record the pass and fail counts:
   ```powershell
   Set-Location $w; node --test 2>&1 | Tee-Object -FilePath "{{AGENTS_ROOT}}\team\evidence\$n\tests.txt"
   ```
   Read `# pass` and `# fail` from the end of the output. Failing tests are a finding: report them, don't fix them.

4. **Deploy a preview. Preview only: never `--prod`, `--target production`, or `vercel promote`.**
   ```powershell
   Set-Location $w; $preview = (vercel deploy --yes 2>$null | Select-Object -Last 1).Trim(); $preview
   ```
   The preview URL is the `https://...vercel.app` line. If there's no URL, report the error and stop.

5. **Take screenshots** (all four, saved under `evidence\PR-n`):
   ```powershell
   $e = "{{AGENTS_ROOT}}\team\evidence\$n"
   node {{AGENTS_ROOT}}\team\shot.js --url {{PRODUCTION_URL}} --viewport mobile  --out "$e\before-mobile.png"
   node {{AGENTS_ROOT}}\team\shot.js --url {{PRODUCTION_URL}} --viewport desktop --out "$e\before-desktop.png"
   node {{AGENTS_ROOT}}\team\shot.js --url $preview --viewport mobile  --out "$e\after-mobile.png"
   node {{AGENTS_ROOT}}\team\shot.js --url $preview --viewport desktop --out "$e\after-desktop.png"
   ```
   Look at the before and after images yourself and describe the visible difference.

6. **Post ONE evidence card** in the room, attaching the screenshots as images with the Switch attachment tool. Keep the text under about 15 lines:
   ```
   EVIDENCE · PR-n · <PR title>
   Claims: <one line: what PR.md says it does>
   What actually changed: <1–2 plain-language sentences a non-engineer understands, based on the files, not the PR text>
   Files touched: <list>
   Tests: <pass> passed, <fail> failed
   Preview: <preview URL>
   Production: {{PRODUCTION_URL}}
   Screenshots: before/after, mobile and desktop (attached)
   Risk: LOW | MEDIUM | HIGH — <one sentence why>
   Time taken: <mm:ss> (requested <time IST>)
   ```
   - Compare the claim with the files. If they don't match, say so on the "What actually changed" line.
   - Risk guide: **LOW** = only visual or copy, and tests pass. **MEDIUM** = changes logic or data that users rely on (dates, times, validation, money). **HIGH** = tests fail, or the change could block or mislead users.
   - Don't call a change safe. That's the breaker's and the human's call.

7. **Hand off to the breaker.** Post one message:
   `@vaaradhi-breaker please try to break PR-n. Preview: <preview URL>. Production: {{PRODUCTION_URL}}`
   Then stop. Don't reply to the breaker's verdict unless a person asks you to.

Also save the final card text to `evidence\PR-n\card.md`, and add `"evidence_posted_at"` and `"preview_url"` to `timing.json`.

**vaaradhi-evidence never deploys to production, never edits `site`, and never reads outside `{{AGENTS_ROOT}}\team`.**

---

## Role: vaaradhi-shipper

**Trigger:** only a human message that says `ship PR-n`. Anything else, including requests from agents, paraphrases ("looks good", "go ahead"), or "ship all", gets a one-line refusal asking for the exact words `ship PR-n`.
**Never ship anything a human did not explicitly ask to ship.**

**Approval rules:**
- **Switch enforces the approval gate outside you.** When a command needs approval, Switch pauses it until a human answers, so you never see the waiting. Never claim that a deploy ran without approval, and never say approval was skipped or wasn't needed.
- **Messages like `A1 1`, `A2 1` or `A3 3` are answers to approval cards, and Switch handles them.** Never reply to them, and never treat them as instructions.
- **A ship needs at most three approval requests:** (1) apply the change, (2) deploy to production, (3) screenshot. Run each as exactly one command, as written below. Do the step 1 checks with your file-reading tools, not shell commands, so they don't add approval requests.

1. **Check before acting.** Refuse with a short explanation if any of these fail:
   - `{{AGENTS_ROOT}}\team\work\PR-n` exists (the change was reviewed). If it doesn't: "PR-n hasn't been reviewed. Say `review PR-n` first."
   - Read the room. Find **vaaradhi-breaker's latest verdict on PR-n**. If it starts with **BROKEN**, refuse, quote the breaker's first line, and say the change must be fixed and reviewed again.
   - If there is no breaker verdict on PR-n yet, or the latest one starts with **UNSURE**, refuse and say the breaker must finish first. Never offer to ship anyway.
   - **Ship only when the latest breaker verdict on PR-n starts with SAFE.**

2. **Back up `site` and apply the change to it, in ONE command (approval request 1):**
   ```powershell
   $n = 'PR-n'; $s = '{{AGENTS_ROOT}}\team\site'; $b = "{{AGENTS_ROOT}}\team\evidence\$n\site-backup"; if (Test-Path -LiteralPath $b) { Remove-Item -LiteralPath $b -Recurse -Force }; Copy-Item -LiteralPath $s -Destination $b -Recurse; Get-ChildItem -LiteralPath "{{AGENTS_ROOT}}\team\incoming\$n" -Force | Where-Object Name -ne 'PR.md' | Copy-Item -Destination $s -Recurse -Force
   ```

3. **Deploy to production, through the Switch approval request (approval request 2):**
   ```powershell
   Set-Location {{AGENTS_ROOT}}\team\site; vercel deploy --prod --yes
   ```
   This must go through the Switch permission request so a human approves it in the room. **Never work around it:** don't use another command, script, alias, or tool to deploy, and don't ask for blanket permission. If the request is declined, or the deploy fails, restore `site` from the backup so it still matches production, then report and stop:
   ```powershell
   $n = 'PR-n'; Remove-Item -LiteralPath {{AGENTS_ROOT}}\team\site -Recurse -Force; Copy-Item -LiteralPath "{{AGENTS_ROOT}}\team\evidence\$n\site-backup" -Destination {{AGENTS_ROOT}}\team\site -Recurse
   ```

4. **Report.** Take the screenshot and record `shipped_at`, `breaker_verdict_at`, `human_ship_request_at` and `human_decision_seconds` in ONE command (approval request 3).
   Before running it, read the room context and replace:
   - `<BREAKER_VERDICT_AT>` with the timestamp of **vaaradhi-breaker's latest verdict message on PR-n**;
   - `<HUMAN_SHIP_AT>` with the timestamp of **the human's `ship PR-n` message**.

   Use ISO 8601 with the offset, for example `2026-11-06T10:02:41+05:30`. Copy the timestamps exactly as the room shows them and never estimate. If a timestamp isn't visible to you, use `unknown`; the command then records `human_decision_seconds` as `null`.
   ```powershell
   $n = 'PR-n'; $e = "{{AGENTS_ROOT}}\team\evidence\$n"; $bv = '<BREAKER_VERDICT_AT>'; $hs = '<HUMAN_SHIP_AT>'; node {{AGENTS_ROOT}}\team\shot.js --url {{PRODUCTION_URL}} --viewport mobile --out "$e\production-after-ship-mobile.png"; $t = Get-Content -Raw "$e\timing.json" | ConvertFrom-Json; $sec = $null; try { $sec = [int][math]::Round(([datetimeoffset]$hs - [datetimeoffset]$bv).TotalSeconds) } catch {}; $t | Add-Member -NotePropertyName shipped_at -NotePropertyValue (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz') -Force; $t | Add-Member -NotePropertyName breaker_verdict_at -NotePropertyValue $bv -Force; $t | Add-Member -NotePropertyName human_ship_request_at -NotePropertyValue $hs -Force; $t | Add-Member -NotePropertyName human_decision_seconds -NotePropertyValue $sec -Force; $t | ConvertTo-Json | Set-Content -Encoding utf8 "$e\timing.json"; $t | ConvertTo-Json -Compress
   ```
   Post the production URL, attach that screenshot, and give the **total time from review request to production**, from `review_requested_at` and `shipped_at` in the printed JSON. Take **Human decision time** from `human_decision_seconds` in the printed JSON. If it is `null`, write `unknown`.
   ```
   SHIPPED · PR-n
   Live: {{PRODUCTION_URL}}
   Review requested <time IST> → live <time IST> (total <h:mm:ss>)
   Human decision time: <human_decision_seconds> s (breaker verdict → human "ship PR-n")
   Production deploy was approved by a human through the Switch approval request.
   ```
