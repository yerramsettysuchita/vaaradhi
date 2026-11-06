# Preflight checklist

Rule for every TODO: **Time limit: 2 hours, then switch approach.** Log the attempt in `docs/BUILD_LOG.md` either way.

## DONE

- [x] **Docker hello-world passes.** DONE 5 Nov 2026
- [x] **Switch Console installed** (0.40.1, per-user). DONE 5 Nov 2026
- [x] **Local Switch server running** (0.31.0). DONE 5 Nov 2026
- [x] **Mattermost sign-in** (`localhost:52043`). DONE 5 Nov 2026
- [x] **Claude Code agent replies in a room** (`switch-buddy-admin` answered in Town Square). DONE 5 Nov 2026
- [x] **Headless browser screenshot works on this laptop.** DONE 5 Nov 2026. `C:\VaaradhiAgents\team\shot.js` (Playwright 1.64.1, installed Chrome, headless) saved a 390x844 full-page screenshot of https://shipfest-2026.vercel.app (HTTP 200). RAM use while running was not measured.

## TODO

- [ ] **Breaker agent on a second provider (Codex)**
  - Agent `vaaradhi-breaker`, provider **Codex**, Directory `C:\VaaradhiAgents\breaker` (instructions in `AGENTS.md` there). Switch supports Claude Code, OpenCode, Codex, Cursor, and Antigravity (source: `/switch-rooms/getting-started/set-up-agent-providers`).
  - How to verify: in Switch Console, go to **Settings > Agent providers**. Codex's line reads **Signed in** and its card reads **CLI installed**. Then, in the room, post `@vaaradhi-breaker what is your job?` and get a reply that describes breaking changes and the SAFE/BROKEN/UNSURE verdict.
  - Time limit: 2 hours, then switch approach (fallback: run the breaker as a Claude Code agent with the same `AGENTS.md` copied to `CLAUDE.md`; this loses the "different vendor" point).

- [ ] **Evidence agent set up**
  - Agent `vaaradhi-evidence`, provider Claude Code, Directory `C:\VaaradhiAgents\team`, Auto mode on.
  - How to verify: post `review PR-1` addressed to it. It posts one evidence card with 4 screenshots and a preview URL, then mentions `@vaaradhi-breaker`.
  - Time limit: 2 hours, then switch approach.

- [ ] **Shipper agent set up**
  - Agent `vaaradhi-shipper`, provider Claude Code, Directory `C:\VaaradhiAgents\team`, **Auto mode off** and **Bypass permissions off** (so `vercel deploy --prod` triggers a Switch permission request), Who can talk to your agent: **Only me**.
  - How to verify: (1) post `@vaaradhi-shipper ship PR-9`: it refuses because PR-9 wasn't reviewed. (2) After a reviewed PR gets a non-BROKEN verdict, `ship PR-n` shows an approval request in the room before any production deploy. Decline once to check that it restores `site` and stops.
  - Time limit: 2 hours, then switch approach.

- [ ] **Telegram bridge connected**
  - How to verify: the Telegram connection is listed under **Messaging apps** on the server's **Home** page with no error. The Telegram group appears under **Your Rooms**. Typing `/` in the group lists Switch commands. `!list-agents` in the group lists the agents. Source: `/switch-rooms/deploy/messaging-apps/telegram` ("Confirm it worked").
  - Time limit: 2 hours, then switch approach.

- [ ] **Demo site deploys to a free host with a live URL**
  - How to verify: open the preview URL and the production URL on your phone (mobile data, not Wi-Fi). Both load the demo site.
  - Time limit: 2 hours, then switch approach.

- [ ] **Wispr Flow dictation works**
  - How to verify: dictate one sentence into VS Code (or Claude Code) with Wispr Flow and the text appears correctly at the cursor.
  - Time limit: 2 hours, then switch approach.
