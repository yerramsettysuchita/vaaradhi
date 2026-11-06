# Build log

Newest entries at the bottom. One entry per problem.

## Template (copy for each new entry)

```markdown
### YYYY-MM-DD HH:MM IST: <short title>

- **What I tried:**
- **What broke:**
- **Exact error:**
  ```
  <paste error text here>
  ```
- **How I fixed it:**
- **Time taken:**
```

---

## 2026-11-05: Environment setup

### 2026-11-05: Claude Code was an old npm install

- **What I tried:** Running Claude Code for the project.
- **What broke:** The installed Claude Code was the old npm version (`claude.ps1`, v2.1.78).
- **Exact error:** None. The version was outdated.
- **How I fixed it:** Uninstalled it with npm, then reinstalled with the native installer. That gave `claude.exe` v2.1.318 at `%USERPROFILE%\.local\bin\claude.exe`.
- **Time taken:** _fill in_

### 2026-11-05: Native installer did not add Claude Code to PATH

- **What I tried:** Running `claude` after the native install.
- **What broke:** `%USERPROFILE%\.local\bin` was not on PATH, so `claude` was not found.
- **Exact error:** _fill in (PowerShell "not recognized as the name of a cmdlet" message)_
- **How I fixed it:** Added `%USERPROFILE%\.local\bin` to the user PATH with PowerShell. The old terminal still could not find `claude`; opening a new terminal window fixed it.
- **Time taken:** _fill in_

### 2026-11-05: winget not available

- **What I tried:** Installing Docker Desktop with winget.
- **What broke:** winget was not available on this laptop.
- **Exact error:** _fill in_
- **How I fixed it:** Downloaded and installed Docker Desktop from the official website.
- **Time taken:** _fill in_

### 2026-11-05: WSL was not installed

- **What I tried:** Running Docker Desktop.
- **What broke:** WSL was not installed. The Switch docs say you don't need WSL (`/switch-rooms/getting-started/index`), but Docker Desktop on Windows with the WSL 2 backend needs it.
- **Exact error:** _fill in_
- **How I fixed it:** Ran `wsl --install --no-distribution` and rebooted.
- **Time taken:** _fill in_

### 2026-11-05: Limited Docker memory

- **What I tried:** Running Docker alongside everything else.
- **What broke:** Nothing broke yet, but the laptop has 13.9 GB usable RAM and was already at 76 percent use.
- **Exact error:** None (preventive).
- **How I fixed it:** Capped Docker (WSL 2) at 6 GB RAM with `.wslconfig`.
- **Time taken:** _fill in_

### 2026-11-05: Switch Console onboarding

- **What I tried:** Switch Console first-run onboarding.
- **What broke:** Nothing. It detected Claude Code as already signed in.
- **Exact error:** None.
- **How I fixed it:** Not needed. Onboarding created `switch-buddy-admin`, and it answered in Mattermost Town Square when mentioned.
- **Time taken:** _fill in_

---

## 2026-11-05: Agents and the first evaluation run

### 2026-11-05: Codex sandbox blocked the breaker's headless browser

- **What I tried:** Running `shot.js` (Playwright, installed Chrome) as `vaaradhi-breaker` under Codex.
- **What broke:** Codex's `workspace-write` sandbox has network access **off** by default, so the page never loaded. Writes outside the working directory, including temp files, are also blocked.
- **Exact error:**
  ```
  page.goto: net::ERR_NETWORK_ACCESS_DENIED at https://shipfest-2026.vercel.app/
  ```
- **How I fixed it:** Proved it first with `codex sandbox -c 'sandbox_mode="workspace-write"' -c 'sandbox_workspace_write.network_access=true' -- node shot.js ...`. It printed `"ok":true` with network on, and `ERR_NETWORK_ACCESS_DENIED` with it off. Then added `sandbox_mode = "workspace-write"` and `[sandbox_workspace_write]` `network_access = true` to `%USERPROFILE%\.codex\config.toml`. Note: the setting is global, so every Codex session on this laptop now has network access. Keep everything the breaker writes inside `C:\VaaradhiAgents\breaker`.
- **Time taken:** _fill in_

### 2026-11-05: Switch server slow to come back after a Switch Console restart

- **What I tried:** Restarting Switch Console and immediately addressing agents.
- **What broke:** The local Switch server takes a few minutes to come back after a Console restart, so early messages got no reply.
- **Exact error:** None. Silence.
- **How I fixed it:** The ready check is now **`!list-agents` replying in the room**. Switch answers that command itself, so a reply means the server is up. Only address agents after it replies.
- **Time taken:** _fill in_

### 2026-11-05: Stale session lock after Console quit (Windows reused the process number)

- **What I tried:** Addressing `vaaradhi-evidence` after Switch Console had been quit and reopened.
- **What broke:** A session lock note was left behind. Windows had reused the old process number (PID) for another process, so the lock looked alive. `vaaradhi-evidence` never started a new session and silently retried every 2 minutes.
- **Exact error:** None visible in the room. Silent retries every 2 minutes.
- **How I fixed it:** `switch-buddy` renamed the stale lock note, and the next retry started a session. Lesson: if an agent is silent after a Console restart, suspect a stale lock before re-adding the agent.
- **Time taken:** _fill in_ (this incident is included in PR-3's review-to-live time in `docs/EVAL.md`)

### 2026-11-05: Shipper believed the approval gate was skipped

- **What I tried:** `ship PR-n` with `vaaradhi-shipper` (Auto mode off).
- **What broke:** Switch enforces the approval gate outside the agent, so the agent never sees the wait. It wrongly concluded that the production deploy had run without approval, and said so.
- **Exact error:** None. A wrong claim in the agent's message.
- **How I fixed it:** Added approval rules to the shipper section of `C:\VaaradhiAgents\team\CLAUDE.md`:
  - The gate is enforced outside the agent.
  - Never claim a deploy ran without approval.
  - The SHIPPED message states that a human approved it.
  - Never reply to approval-card answers like `A1 1`.
  - At most three approval requests per ship (apply, deploy, screenshot).
- **Time taken:** _fill in_

### 2026-11-05: Breaker v1 flagged PR-3 BROKEN on an unrealistic input

- **What I tried:** `vaaradhi-breaker` review of PR-3 (allow teams of exactly 4).
- **What broke:** Breaker v1 returned BROKEN because of a 17-digit decimal member count (floating-point precision). No real user would type that, and the number input with `step="1"` already signals whole numbers.
- **Exact error:** A BROKEN verdict based on a theoretical edge case.
- **How I fixed it:** Updated `C:\VaaradhiAgents\breaker\AGENTS.md` (v2):
  - **A severity rubric.** BROKEN only for realistic failures that cause harm. Theoretical edge cases go on a `Minor notes:` line under SAFE. UNSURE only when a check couldn't run.
  - **The forms check reads `index.html` input constraints first** (`type`, `min`, `max`, `step`, `required`), and also `novalidate` on the form. Breaker v2 returned SAFE.
- **Time taken:** _fill in_
