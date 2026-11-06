# Vaaradhi

> AI made code cheap to write. Vaaradhi makes it cheap to trust.

Hackathon: **Flip the Switch** (WeMakeDevs x Switch AI)
Deadline: **7 Nov 2026, 11:59 PM IST**
Tracks: **Track 1: Best Business Workflow**, plus **Code with Wispr** and **Best Blog**
Direction locked: **5 Nov 2026, 5:35 PM IST**

---

## Strict rules (apply to every session)

1. **Never run git commands.** The user runs all git commands. If a step needs git, write the exact command for the user and stop.
2. **Check the switch-docs MCP server before claiming anything about how Switch works.** If the docs do not say it, write `NOT CONFIRMED IN DOCS` instead of guessing.
3. **After every step, say how to verify it and what the expected output is.**
4. **Keep everything Windows-compatible:** PowerShell commands and Windows paths (for example `C:\Projects\vaaradhi`).
5. **Never deploy.** The user deploys. Give the exact command and stop.
6. **Never open `docs/CHANGES_ANSWER_KEY.md`.** It is for the humans running the demo. An agent that reads it has invalidated the demo.

---

## Problem (locked)

AI coding agents made code cheap to write, but **review and verification became the bottleneck**.

Evidence from Oct and Nov 2026 (supplied by the user; add source links before they go in the README or blog):

- **Harvard study of about 700 firms:** 30 percent more code and 23 percent more pull requests, but no more finished work. Review time went up 49 percent.
- **Qodo 2026 report:** reviewing AI-generated code is the top bottleneck for both developers and engineering leaders.
- **Faros AI:** median review takes five times longer.
- **InfoQ:** 35 percent of generated code reaches production before the team understands it.

## Solution

**Vaaradhi is a Switch room where reviewers check proof instead of reading diffs.**

For each AI-written change:

1. **vaaradhi-evidence** (Claude Code) runs the change, deploys a preview, takes mobile and desktop screenshots, runs the tests, and explains the change in plain language with a risk level.
2. **vaaradhi-breaker** (Codex, a different vendor) independently tries to break it.
3. The **human** sees one evidence card and ships or blocks the change.

**What we measure:** human seconds per change, and how many broken changes were caught.

## Architecture

| Part | What it is |
| --- | --- |
| `vaaradhi-evidence` | Switch agent, provider Claude Code |
| `vaaradhi-breaker` | Switch agent, provider Codex |
| Human approver | Approves in Mattermost through a Switch permission request |
| Phone approval | Same approval from Telegram |
| Incoming changes | Prepared in advance in `changes/` for reliability. A live author agent is optional. |
| Demo app | **ShipFest 2026**, a fictional hackathon website in `demo-seed/` |

Switch facts behind this (from `docs/SWITCH_NOTES.md`; re-check against switch-docs before building):

- Codex is a supported agent provider. Confirmed in docs.
- An agent's permission request in a room offers **Allow once**, **Allow for this session**, or **Decline**. A reply of just `yes` or `no` also works, and Switch records who answered. Confirmed in docs.
- Whether that request renders as a "card" in Mattermost and in Telegram: **NOT CONFIRMED IN DOCS.**
- A ship or block gate that isn't tied to a tool permission: **NOT CONFIRMED IN DOCS.**

## Repository layout

| Path | Purpose |
| --- | --- |
| `demo-seed/` | Clean ShipFest 2026 site (`index.html`, `styles.css`, `app.js`) and `tests/` (Node 22 `node --test`). Never edited by the demo. |
| `demo-site/` | Working copy the agents change. Recreated by `reset-demo.ps1`. |
| `changes/PR-1`, `PR-2`, `PR-3` | Incoming AI-written changes. Each holds only its modified files, as full-file replacements based on `demo-seed`, plus `PR.md`. |
| `reset-demo.ps1` | Deletes `demo-site/` and copies `demo-seed/` to `demo-site/`. Touches nothing else. |
| `docs/` | Project notes. `docs/CHANGES_ANSWER_KEY.md` is off-limits to agents (rule 6). |

**Agent working directories:** don't point `vaaradhi-evidence` or `vaaradhi-breaker` at this project root. An agent can read every file in its working directory, which includes the answer key. Use a folder that contains only `demo-site/` and the PR under review.

## Judging criteria to optimise for

- **Use of Switch:** Switch must be central to the workflow.
- **Technical execution:** judges must be able to clone the repo and reproduce the setup.
- **Creativity and impact.**
- **Presentation:** demo video under 3 minutes, plus a README.

## Cut list (do NOT build)

- Dashboards
- Our own diff viewer
- GitHub integration in Phase 1
- Extra chat platforms beyond Telegram and Mattermost
- Security layers

## Laptop constraint

- HP laptop, Windows 11, 13.9 GB usable RAM, **no NVIDIA GPU**.
- **No local LLMs.** Everything uses cloud agents.
- Docker is capped at **6 GB RAM** (via `.wslconfig`).

---

## Verified state (as of 5 Nov 2026, 2:20 AM IST)

| Item | State |
| --- | --- |
| Git | 2.49 installed |
| Node | 22 installed (v22.16.0) |
| VS Code | 1.144 installed |
| Claude Code | 2.1.318, native install at `%USERPROFILE%\.local\bin\claude.exe`, signed in, tested |
| WSL | 3.0.3 installed |
| Docker Desktop | 29.9.2, per-user, WSL 2 backend, memory limited to 6 GB via `.wslconfig`, `hello-world` passed |
| Switch Console | 0.40.1 installed (per-user) |
| Switch server | Local Switch server 0.31.0 running on this computer |
| Mattermost | Running at `localhost:52043`, user signed in |
| First agent | `switch-buddy-admin` (powered by Claude Code) replied live in Mattermost Town Square when mentioned |
| switch-docs MCP | Connected in this project |

**Operational note:** Switch Console must stay open for agents and Mattermost to run.
(See `docs/SWITCH_NOTES.md`, section h, for a docs nuance about managed agents.)

## Preflight results (details in `docs/PREFLIGHT.md`)

| Check | Status |
| --- | --- |
| Docker `hello-world` | DONE 5 Nov 2026 |
| Switch Console installed | DONE 5 Nov 2026 |
| Local Switch server running | DONE 5 Nov 2026 |
| Mattermost sign-in | DONE 5 Nov 2026 |
| Claude Code agent replies in a room | DONE 5 Nov 2026 |
| Breaker agent on Codex (`C:\VaaradhiAgents\breaker`) | TODO |
| Evidence agent and shipper agent (`C:\VaaradhiAgents\team`) | TODO |
| Telegram bridge connected | TODO |
| Demo site deploys to a free host with a live URL | TODO |
| Headless browser screenshot works on this laptop | DONE 5 Nov 2026 (`shot.js`) |
| Wispr Flow dictation works | TODO |

---

## Project docs

- `docs/PREFLIGHT.md`: checklist of what is proven working and what is still TODO.
- `docs/BUILD_LOG.md`: dated log of what was tried, what broke, and how it was fixed.
- `docs/SWITCH_NOTES.md`: Switch facts researched from the switch-docs MCP server, with page sources.
- `docs/CHANGES_ANSWER_KEY.md`: **humans only** (rule 6).
