# Logseq + Claude Memory Stack

[한국어 문서 (Korean)](./README.ko.md)

> Turn Claude from a clever autocomplete into a **genuine senior collaborator** that knows your stack, your standards, and your long-term goals.

A 3-layer compounding memory system that wires your **project DNA**, **personal knowledge graph**, and **external research** into one living, searchable brain — powered by [Logseq](https://logseq.com) + [Claude](https://claude.ai).

**Supports macOS and Windows.**

---

## Why?

Most developers waste **30-40 minutes per session** re-explaining context to AI. This setup eliminates that by giving Claude persistent, searchable access to everything you've built, decided, and learned.

| Layer | What | How |
|-------|------|-----|
| **Session Memory** | `CLAUDE.md` + Auto-Memory | Claude reads project rules & writes its own learnings |
| **Knowledge Graph** | Logseq + MCP Bridge | Claude traverses your entire second brain in real time |
| **Ingestion** | Inbox → Commonplace | Every consumed content becomes permanently searchable |

---

## Quick Start

### macOS

```bash
git clone https://github.com/sonson1023/logseq-brain-setupd.git
cd logseq-brain-setup
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/sonson1023/logseq-brain-setupd.git
cd logseq-brain-setup
.\install.ps1
```

That's it. The script handles everything automatically.

---

## What the installer does

| # | Action | macOS | Windows |
|---|--------|-------|---------|
| 1 | Package manager | Homebrew | winget |
| 2 | Node.js | `brew install node` | `winget install OpenJS.NodeJS.LTS` |
| 3 | Logseq app | `brew install --cask logseq` | `winget install Logseq.Logseq` |
| 4 | MCP npm packages | `qmd`, `server-filesystem`, `logseq-mcp` | same |
| 5 | Graph structure | `~/logseq-graph/` | `%USERPROFILE%\logseq-graph\` |
| 6 | Claude Code MCP | `claude mcp add --scope user` (3 servers) | same |
| 7 | Claude Desktop MCP | `~/Library/.../claude_desktop_config.json` | `%APPDATA%\Claude\claude_desktop_config.json` |
| 8 | SessionStart Hook | `bash ensure-logseq.sh` | `powershell ensure-logseq.ps1` |
| 9 | Auto-start on login | Login Items (osascript) | Startup folder shortcut |

---

## After install (one-time manual setup)

The Logseq HTTP API requires enabling through the app UI:

1. Open **Logseq** → **Add a graph** → select `~/logseq-graph` (or `%USERPROFILE%\logseq-graph`)
2. **Settings** → **Advanced** → **Developer mode** → ON
3. **Settings** → **Advanced** → **HTTP APIs server** → ON
4. **Settings** → **Advanced** → **Authorization tokens** → paste the token from `config.env`

Verify:

```bash
# macOS / Linux
curl -s http://localhost:12315/api -H "Authorization: Bearer <your-token>"

# Windows PowerShell
Invoke-RestMethod -Uri http://localhost:12315/api -Headers @{Authorization="Bearer <your-token>"}
```

---

## Configuration

### `config.env`

```env
# Logseq API auth token
LOGSEQ_TOKEN="your-token-here"

# Graph path override (optional)
# LOGSEQ_GRAPH="$HOME/logseq-graph"
```

> **Security**: This file contains your API token. Always use a **private repository**.

### Generating a new token

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

## MCP Servers

Three servers are registered globally (`--scope user`) so they work across **all projects**:

| Server | Type | Purpose |
|--------|------|---------|
| `logseq` | HTTP API | Search, create blocks, manage tasks, query graph DB |
| `logseq-graph` | Filesystem | Direct read/write to all Logseq files |
| `qmd` | Search Engine | Fast BM25 keyword + semantic search across pages |

Verify with:

```bash
claude mcp list
```

---

## Skills (Slash Commands)

The installer copies 5 Logseq skills to `~/.claude/commands/logseq/`, available globally:

| Command | Description |
|---------|-------------|
| `/logseq:polaris` | Read Top of Mind, evaluate work alignment with goals |
| `/logseq:save` | Save a decision or learning as an atomic note |
| `/logseq:search` | Search the knowledge graph (keyword + semantic) |
| `/logseq:journal` | Create or update today's daily journal |
| `/logseq:ingest` | Ingest a URL or text into inbox as structured note |

---

## Graph Structure

```
~/logseq-graph/
├── pages/                          # All notes (flat + namespace)
│   ├── polaris___top-of-mind.md    # Goals, principles, active projects
│   ├── commonplace___*.md          # Atomic notes, evergreen ideas
│   └── inbox.md                    # Temporary landing zone
├── journals/                       # Daily logs (auto-created by Logseq)
│   └── 2026-04-03.md
├── assets/                         # Attachments
└── logseq/
    └── config.edn                  # Logseq app settings
```

### Logseq Namespaces

Logseq uses `___` (triple underscore) in filenames to represent `/` namespaces:

| Filename | Logseq page name |
|----------|-----------------|
| `polaris___top-of-mind.md` | `polaris/top-of-mind` |
| `commonplace___auth-patterns.md` | `commonplace/auth-patterns` |

---

## The Polaris Strategy

`polaris/top-of-mind` is a living document containing:
- Current quarterly goals
- Active projects with success criteria
- Life Razors (non-negotiable principles)

Start every significant work session with:

```
Read my polaris/top-of-mind page.
Evaluate how this task aligns with my Q2 goals.
Flag any misalignments before we begin.
```

Claude becomes an accountability partner that pushes back when you drift from your own stated direction.

---

## Automation

### SessionStart Hook

Every time Claude Code starts, the hook automatically:
1. Checks if Logseq is running (port 12315)
2. Launches Logseq in background if not running
3. Waits up to 10 seconds for API readiness

### Auto-start on Login

- **macOS**: Registered as a Login Item (runs hidden)
- **Windows**: Shortcut placed in Startup folder (runs minimized)

---

## Repo Structure

```
logseq-brain-setup/
├── install.sh                # macOS installer
├── install.ps1               # Windows installer
├── config.env                # Shared config (token)
├── commands/
│   └── logseq/               # Claude Code skills (→ ~/.claude/commands/logseq/)
│       ├── polaris.md
│       ├── save.md
│       ├── search.md
│       ├── journal.md
│       └── ingest.md
├── scripts/
│   ├── ensure-logseq.sh      # SessionStart hook (macOS)
│   └── ensure-logseq.ps1     # SessionStart hook (Windows)
└── templates/
    ├── config.edn            # Logseq app config
    ├── polaris___top-of-mind.md
    ├── inbox.md
    └── claude-md-addon.md    # Appended to ~/.claude/CLAUDE.md
```

---

## Idempotent

The installer is safe to run multiple times:
- Already-installed tools are skipped
- Existing files are never overwritten
- MCP servers are removed then re-registered
- CLAUDE.md addon is appended only if not already present

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `logseq` MCP: Failed | Logseq not running or API disabled | Open Logseq, enable HTTP API |
| 401 Unauthorized | Token mismatch | Check `config.env` matches Logseq settings |
| Port 12315 not listening | Logseq HTTP server off | Settings → Advanced → HTTP APIs server ON |
| `qmd` no results | No embeddings | Run `qmd embed` for semantic search |

---

## Credits

Inspired by the [3-Layer Memory Stack](https://x.com/intheworldofai/status/2039255561280057794) concept, adapted from Obsidian to Logseq for block-based, local-first knowledge management.
