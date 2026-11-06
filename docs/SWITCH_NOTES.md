# Switch notes for Vaaradhi

Researched on 5 Nov 2026, **only** from the switch-docs MCP server. Each answer names its page; page paths are relative to the Switch docs site.
Anything the docs did not say is marked **NOT CONFIRMED IN DOCS**.

Versions in use: Switch Console 0.40.1, Switch server 0.31.0.
The docs' changelog lists Console 0.40.0 and server 0.31.0. **The docs say nothing specific to 0.40.1.**

---

## a) Create an agent and a room in Switch Console

### Create (onboard) an agent
Sources: `/switch-rooms/getting-started/onboard-your-agents`, `/switch-rooms/getting-started/add-a-second-agent`

1. In the sidebar, select **Your Agents**, then the **dashed card with a plus**.
2. **Name** (required). Use lowercase letters, digits, `.`, `-`, `_`, and start with a letter or digit. No spaces or capitals. **It can't be changed later.** It must be unique on the server. The docs suggest the `job.owner` pattern, e.g. `bug-fixer.jsmith`.
3. **Description** (required). **Agent instructions** (optional) are standing instructions for every session.
4. **Run location**: leave it on **This computer**. **It can't be changed later.**
5. **Directory**: the working directory. The agent can read its files, and any instruction files in it (e.g. `CLAUDE.md`) become default behaviour. For an agent Switch Console runs, **this can't be changed later**.
6. **Agent provider**: e.g. Claude Code. Providers that aren't ready are dimmed.
7. Leave **Advanced configuration** alone (model, tools, permission mode, etc.).
8. Expand **Settings**: **Auto mode** (on by default) and **Bypass permissions** (off by default). See section e.
9. **Who can talk to your agent**: the default is **Me and my agents**. See section d.
10. Select **Add agent**.

Verify: the agent appears under **Your Agents** as a card showing e.g. **Claude Code · this computer**. Then invite it to a room and mention it.
Switch Console writes the agent's credentials to `.switch/agents/<name>.json` in the working directory, with a `.gitignore` containing `*` (`/switch-rooms/internals/connectors-and-runtime`). **Never commit that folder.**

### Create a room
Source: `/switch-rooms/getting-started/create-a-room`

1. Sidebar: **Your Rooms**, then **Create room** (you must be signed in to the server).
2. Choose the **Messaging app**.
3. Give it a **Name** (named after the work) and a **Description**.
4. Optionally add an agent you onboarded in this Switch Console.
5. Write the **Instructions**. Every agent that connects sees them.
6. Submit.

Other ways:
- **Mattermost:** adding one of your agents to a channel automatically creates the room. Each agent has its own bot account.
- **Telegram:** create the group in Telegram and add the bot. Telegram bots can't create groups, so Switch Console can't create Telegram rooms.
- Invite an agent from inside the channel with `!invite-agent @agent-name`, or from the agent's page with **Add to room**.
- Set a short name inside one room with `!set-alias @full-name @short`.

Verify: the room appears under **Your Rooms**, grouped by messaging app.

---

## b) Templates

Sources: `/switch-rooms/administer/room-templates`, `/switch-rooms/getting-started/create-a-room`

- **Template types:** **Room** (one room; the agents it names must already exist), **Agent** (creates one agent), and **Group** (more than one room and/or agent).
- **Fields** are blanks that the person running the template fills in. A field replaces its value everywhere in the template (case-sensitive). To let users pick an agent from a list, change the field's `type` from `string` to `agent`.
- **What a template can include, per room:** the name, description, and instructions; the messaging app and whether the channel is public or private; who can read and edit the room; agents, people, and aliases; jobs (roles), references, and room documents; and a first message to post when the room is created.
- **Not included:** packages, library documents, the room's group, and links to other rooms. Set these up after the room is created.
- **Capture:** open the room, then **Configuration > Capture as template**. This creates a Room template that *names* existing agents rather than creating them.
- **Import:** on the **Templates** page, select **Import template** (paste saved YAML). Or, in the Gateway: **Resources > Templates tab > Upload template**, then paste the YAML into **Document** or use **Load from file**.
- **Run:** **Templates**, then **Use**, fill in the fields, then the create button (**Create room**, **Create agent and room**, or **Create all**).
- **Format versions:** Switch 0.31 reads version 1 and version 2 of the template format.
- **Templates that create agents need:** agent management turned on for the server, the target machine online with its provider installed and signed in, and **Can manage agents** if an agent runs the template.
- **Sharing:** Private (default), Shared, or Open.
- **Warning:** a captured template still lists your original agents in `agents:`. Check that list before sharing.

**Full field (key) list: NOT CONFIRMED IN DOCS.** The docs page links out to the template language in the Switch GitHub repo (`sandbox-quantum/switch`, `docs/TEMPLATES.md`), which the MCP server does not contain.
**The `.template.yaml` file extension: NOT CONFIRMED IN DOCS.** The docs only say "YAML".

**For judges' reproducibility:** the safest path the docs support is: (1) export our room as a captured template, (2) commit its YAML to the repo, (3) judges onboard agents with the *same names* first, then **Import template** and **Use** it. Room templates fail if a named agent is missing on their server.

---

## c) Telegram with a local Switch server

Sources: `/switch-rooms/deploy/messaging-apps/telegram`, `/switch-rooms/deploy/index`

- **Nothing needs to be publicly reachable.** Switch opens the connection to Telegram (it polls), so a server on this laptop works.
- **Can people outside my laptop message my agents through Telegram? Yes, if both of these are true:** they are in the Telegram group with the bot, *and* the agent's **Who can talk to your agent** setting admits them. By default an agent answers only its owner and the owner's agents, so for the reporter it must be **Anyone** or **Custom rules** (source: `/switch-rooms/deploy/index`, `/switch-rooms/getting-started/agent-settings`).
- **They can reach the agents only while this laptop's server is running and the agents are connected.** This is implied by the architecture, but the docs have no statement specific to Telegram plus a local server.

Setup steps:
1. A Telegram account **with a @username** (a phone number alone is not enough).
2. In @BotFather, send `/newbot`, choose a name and a username ending in `bot`, and **save the token immediately** (it's shown once). Never paste it into a room.
3. **Before adding the bot to any chat:** in BotFather, `/mybots` > your bot > **Bot Settings** > **Group Privacy** > **Turn off**.
4. Switch Console (admin): select the server > **Home** > **Messaging apps** > **Connect** > **Telegram**. Enter a **Name**, the **Bot Token**, and the **Bot Username**, then **Connect**.
5. Create a Telegram group, then **Add Members** > the bot. Switch creates the room.
6. Post one message in the group. Then, on **Home**, use **Link your Telegram account** > search for yourself > **This is me**.
7. Invite agents: `/invite_agent @agent-name` (or `!invite-agent @agent-name`).

Telegram behaviour to design around:
- One bot represents every agent, and the agent's name is written at the start of each message.
- Agent names **don't autocomplete**. Type them in full. `!list-agents` shows them.
- A private DM with the bot is **not** a room. To get a one-to-one chat, use a group containing just you and the bot.
- Images relay as photos. Incoming files are capped at **20 MB**. Messages longer than 4096 characters are split. Tables arrive as raw text.
- **Never run two processes on one bot token.** Incoming messages get split between them at random.
- A group that converts to a supergroup gets a new chat ID. Switch follows the change automatically.

---

## d) Agent-to-agent handoff, addressing, and loops

Sources: `/switch-rooms/using/work-in-a-room`, `/switch-rooms/getting-started/agent-settings`, `/switch-rooms/internals/identity-and-access`, `/switch-rooms/internals/agent-protocol`, `/switch-rooms/getting-started/add-a-second-agent`

**Handoff:** an agent hands work to another agent by **addressing it in the room** with `@name`, an alias, or a role (e.g. `@reviewer`). The receiving agent acts only if its addressing policy admits the sender. The docs' "Hand off work" advice: post the status, open questions, and the next responsible person, agent, or role.

**Addressing** means who may mention an agent, target it, or hand it work. UI options:
- **Me and my agents** (default for new agents): the owner plus the owner's other agents. API value: `owner_and_owner_agents`.
- **Only me**: API value `owner_only`.
- **Anyone**: anyone in the agent's rooms, with no Switch account needed. API value `anyone`.
- **Custom rules**: named people, agents, and rooms.

Internally, rules have the dimensions `rooms`, `room_groups`, `users`, and `agents`, plus the symbolic subjects `owner` and `owner_agents`. Rules widen each other (any match admits). Senders who aren't permitted get a **visible refusal**. An agent can't widen its own policy.

For Vaaradhi: all our agents have the same owner, so **Me and my agents** already lets triage, fix, and checker hand off to each other. The **triage agent must be set to Anyone** (or Custom rules naming the reporter or the Telegram room) so the Telegram reporter can reach it.

**Loop prevention: what the docs say:**
- An agent doesn't act on a message that doesn't address it.
- **Follow-ups start only from a person's message, never from an agent's**, so un-tagged agent chatter doesn't trigger agents.
- The bridge-level "loop prevention" in `/switch-rooms/internals/collaboration-bridge` is only about not relaying a platform message back to the same platform. It is **not** about agents replying to each other.
- **A built-in limit on agent-to-agent reply rounds is NOT CONFIRMED IN DOCS.** We must enforce it ourselves in agent instructions: only address the next agent on an explicit handoff, never address the sender just to say thanks, and have the checker count tries (max 2, then address the human).
- One more relevant point: a session works in **one room at a time**, and an agent busy elsewhere must be addressed again (`/switch-rooms/getting-started/add-a-second-agent`).

---

## e) Human approval and permissions

Sources: `/switch-rooms/getting-started/agent-settings`, `/switch-rooms/using/work-in-a-room`, `/switch-rooms/administer/rooms`

- **Per-action tool permission requests exist.** With Auto mode off, the agent asks before every action that needs permission. With Auto mode on (the default), the provider decides which actions run, and asks in the room for the rest. Claude Code and Codex use their own automatic review. **Bypass permissions** never asks.
- A request in the room offers **Allow once**, **Allow for this session**, or **Decline**. A reply of just `yes` or `no` also works. **Switch records who approved or declined.**
- Only people the agent takes messages from can answer its requests (by default, only the owner).
- **Room access:** a new room lets anyone signed in to the workspace change it. The owner or an admin can restrict this.
- **A room-level "require human approval before agent X acts" setting: NOT CONFIRMED IN DOCS.** Permission requests are per agent and per action, not per room.
- **A built-in "ship it" approval gate: NOT CONFIRMED IN DOCS.** Two options the docs support:
  1. The deploy agent runs with Auto mode **off**. The production deploy command then triggers a permission request that the human approves in the room.
  2. Instruction-level: the deploy agent waits until the owner replies "ship it". Its addressing policy (**Only me** or Custom rules) makes sure only the human can trigger it.

---

## f) Posting an image (screenshot) into a room

Sources: `/switch-rooms/internals/connectors-and-runtime`, `/switch-rooms/internals/agent-events`, `/switch-rooms/deploy/messaging-apps/telegram`, `/switch-rooms/using/work-in-a-room`

- Agents run by Switch Console get Switch MCP tools that include **`send_attachment`** and **`download_attachment`**, served against the media routes.
- **Incoming** attachments are downloaded to a local session directory, and the agent's input line names the file paths. So the fix agent receives the reporter's screenshot as a local file.
- An event's attachment is a pointer with `filename`, `mimetype`, `size`, `mxc`, and `msgtype`, not the raw bytes.
- Telegram: images relay **as photos** so they preview inline. Several files arrive as one album.
- People attach a file **and mention the agent in the same message**, or the agent doesn't pick it up (the mention works in a file caption).
- **The exact parameters of `send_attachment`: NOT CONFIRMED IN DOCS.**
- **How an outbound image renders in Mattermost: NOT CONFIRMED IN DOCS.** Test this early.

---

## g) Linked rooms and context sharing

Sources: `/switch-rooms/administer/rooms`, `/switch-rooms/building/index`, `/switch-rooms/using/shared-context`, `/switch-rooms/internals/rooms-and-resources`

- **Room links** are **one-way** signposts with a free-text label (e.g. "escalate to"). They tell agents that another room exists and why. **A link doesn't grant access.** The agent must also be a member of the target room.
- To create a link, ask an agent in the source room, or use the Gateway room page: **Add linked room**. This needs write access to the source room.
- An agent can work in any room it's a member of.
- **Shared context in a room:** room instructions, room documents (`!list-documents`), references (pointers to repos, drives, etc.), library documents (attachable to many rooms), and packages (built in the Gateway only).
- Room content is visible only to room members.
- **Groups** file rooms together and also scope addressing rules. Moving a room between groups can change who an agent answers.
- Possible Vaaradhi use: a Telegram "reporter" room linked to a Mattermost "engineering" room. Whether a *single* agent session can relay a message from one room into another automatically: **NOT CONFIRMED IN DOCS** beyond "an agent can work in any room it's a member of".

---

## h) Windows-specific and early-access warnings

Sources: `/switch-rooms/getting-started/install-switch-console`, `/switch-rooms/getting-started/index`, `/switch-rooms/getting-started/set-up-agent-providers`, `/switch-rooms/deploy/host-remotely`, `/switch-rooms/resources/changelog`, `/switch-rooms/resources/troubleshooting`, `/switch-rooms/getting-started/what-keeps-your-agent-running`

- **Windows x64 is "early access":** "ready to use and still changing". Expect rough edges and behaviour that differs between releases.
- **Docker:** on Windows, use Docker Desktop or Rancher Desktop. The docs say "You don't need WSL" (we did need it for Docker Desktop's WSL 2 backend; see BUILD_LOG).
- **Since Console 0.40, the server runs without Docker, but only the bundled Mattermost needs Docker.** Without Docker, Switch Console doesn't flag that Mattermost was skipped.
- **PATH:** Switch Console reads PATH once at startup, and it also checks `~/.local/bin` on refresh. On Windows, closing the Switch Console window quits it. Reopen it to reread PATH.
- **Remote hosts can't be Windows** ("Not Windows: there's no install path").
- **Managed agents and the agent controller do run on Windows** (changelog).
- **Quitting Switch Console ends any sessions running on this computer.** Updates install the next time you quit.
- **Nuance on "Console must stay open":** the docs say agent management is active by default on a server that Switch Console runs (Console 0.40+). They also say Switch Console moves your agents onto a managed machine, and for a managed agent, "quitting Switch Console has no effect". The docs do **not** confirm whether the local server and Mattermost keep running after Console quits. Keep Console open, as observed. Check which kind `switch-buddy-admin` is: its page shows **"on <machine>"** if a managed machine runs it, or a **Provider sign-in** section if Switch Console runs it.
- Claude Code may ask you to trust a folder the first time. **Auto-trust worktree directories** (Settings > General) is on by default.

---

## Open questions and risks for Vaaradhi

1. **Agent-to-agent loop limit: NOT CONFIRMED IN DOCS.** Enforce it in the agent instructions (max 2 checker rounds, then escalate to the human).
2. **Template full key list and `.template.yaml` naming: NOT CONFIRMED IN DOCS.** The schema lives only in the GitHub `docs/TEMPLATES.md`.
3. **A room-level human-approval gate: NOT CONFIRMED IN DOCS.** Use per-action permission requests (Auto mode off) or an instruction-level "ship it" rule.
4. **`send_attachment` parameters and how outbound images render in Mattermost: NOT CONFIRMED IN DOCS.** This must be tested early because the before/after screenshots are central to the demo.
5. **Telegram reach depends on the laptop being on**, with Switch Console, the server, and the agents running during the demo and judging. Uptime when the laptop sleeps: NOT CONFIRMED IN DOCS.
6. **Reporter permissions:** the triage agent must be set to **Anyone** (or Custom rules). With Anyone, any Telegram group member can instruct it. Keep the group small, and keep the deploy agent on **Me and my agents** or **Only me**.
7. **Telegram identity:** the reporter needs a Telegram @username only if they must be *linked*. With **Anyone** they don't. Linking yourself requires a @username and a prior message in the group.
8. **Mattermost plus Telegram in one workflow:** cross-room relay via links and membership is supported in principle. Automatic cross-platform relay by one agent is NOT CONFIRMED IN DOCS. The simplest option may be to run the whole demo in **one** Telegram group with the human approver in it.
9. **Docs cover Console 0.40.0, not 0.40.1.** Small UI label differences are possible (Windows is early access).
10. **Second provider for the checker:** the available options are OpenCode, Codex, Cursor, and Antigravity. On OpenCode, Auto mode approves everything. Whether each provider works on Windows: NOT CONFIRMED IN DOCS.
11. **Judges reproducing the setup:** agent names must be unique per server, and room templates fail if the named agents are missing. Our README must tell judges to onboard agents with the exact names first, or ship an Agent/Group template (which needs agent management on their server).
12. **Secrets:** never commit `.switch/` (agent credentials) or the Telegram bot token.
