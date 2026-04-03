# Logseq + Claude Memory Stack

[한국어 문서 (Korean)](./README.ko.md)

> Turn Claude from a clever autocomplete into a **genuine senior collaborator** that remembers everything across sessions.

A **session memory continuity** system that wires your project DNA, personal knowledge graph, and session history into one living, searchable brain — powered by [Logseq](https://logseq.com) + [Claude](https://claude.ai).

**Supports macOS and Windows.**

---

## The Problem

Every time you start a new Claude session, it forgets everything — architecture decisions from yesterday, the bug you fixed last night, the naming conventions you agreed on. You waste **30-40 minutes per session** re-explaining context.

## The Solution

Install once. Every session after that:

```
┌─ Session Start ──────────────────────────────────┐
│  ✓ Logseq auto-launches                          │
│  ✓ Previous session journal loaded                │
│  ✓ Pending tasks loaded                           │
│  ✓ Polaris goals & principles loaded              │
│  ✓ Current project context detected               │
│  → Claude starts with FULL context                │
├─ During Session ─────────────────────────────────┤
│  ✓ /logseq:save — persist decisions & learnings   │
│  ✓ /logseq:search — find past knowledge           │
│  ✓ Project-scoped isolation                       │
├─ Session End ────────────────────────────────────┤
│  ✓ Work summary auto-saved to journal             │
│  ✓ Decisions recorded                             │
│  ✓ Pending tasks captured                         │
│  → Next session picks up exactly where you left   │
└──────────────────────────────────────────────────┘
```

---

## Quick Start

### macOS

```bash
git clone https://github.com/sonson1023/logseq-brain-setupd.git
cd logseq-brain-setupd
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/sonson1023/logseq-brain-setupd.git
cd logseq-brain-setupd
.\install.ps1
```

### After install (one-time manual setup)

1. Open **Logseq** → **Add a graph** → select `~/logseq-graph`
2. **Settings** → **Advanced** → **Developer mode** → ON
3. **Settings** → **Advanced** → **HTTP APIs server** → ON
4. **Settings** → **Advanced** → **Authorization tokens** → paste token from `config.env`

### First session

On your first Claude Code session after install, run:

```
/logseq:config
```

Choose your memory mode and preferences. Or skip it — sensible defaults apply automatically.

---

## How Session Memory Continuity Works

### Memory Architecture

```
                    ┌──────────────┐
                    │  Logseq App  │ ← Human can browse & edit
                    │  (Graph UI)  │
                    └──────┬───────┘
                           │
┌─────────────┐    ┌──────┴───────┐    ┌──────────────┐
│ Claude Code │◄──►│ ~/logseq-graph│◄──►│Claude Desktop│
│  (MCP x3)   │    │   (files)    │    │   (MCP x3)   │
└──────┬──────┘    └──────────────┘    └──────────────┘
       │
       ▼
┌──────────────┐
│  MEMORY.md   │ ← Optional (both mode)
│ (Claude mem) │
└──────────────┘
```

### Session Lifecycle

| Event | What happens | Stored where |
|-------|-------------|--------------|
| **Session Start** | Hook loads previous journal + tasks + Polaris + project context | → Claude's context window |
| **During work** | `/logseq:save` persists decisions, `/logseq:search` finds past knowledge | → Logseq pages |
| **Session End** | Stop hook auto-saves work summary, decisions, pending tasks | → Logseq journal |
| **Next session** | Start hook reads the above | → Full continuity |

### Memory Modes

Configure via `/logseq:config`:

| Mode | Short-term | Long-term | Best for |
|------|-----------|-----------|----------|
| `logseq` (default) | Logseq journals | Logseq pages | Full knowledge graph with search & visualization |
| `claude` | MEMORY.md | MEMORY.md | Minimal setup, no Logseq dependency |
| `both` | Both | Both | Maximum redundancy & flexibility |

### Why not just MEMORY.md?

| | MEMORY.md | Logseq |
|---|-----------|--------|
| Capacity | ~200 lines (truncated) | Unlimited |
| Search | Full-load only | BM25 + semantic search |
| Structure | Flat text file | Namespaces + graph links |
| History | Latest state only | Time-series journals |
| Human access | Hard to browse | Full app with graph view |
| Project isolation | Automatic by project | Namespace-based |

**MEMORY.md** = fast sticky note. **Logseq** = long-term brain.

---

## What the Installer Does

| # | Action | macOS | Windows |
|---|--------|-------|---------|
| 1 | Package manager | Homebrew | winget |
| 2 | Node.js | `brew install node` | `winget install OpenJS.NodeJS.LTS` |
| 3 | Logseq app | `brew install --cask logseq` | `winget install Logseq.Logseq` |
| 4 | MCP npm packages | `qmd`, `server-filesystem`, `logseq-mcp` | same |
| 5 | Graph structure | `~/logseq-graph/` | `%USERPROFILE%\logseq-graph\` |
| 6 | Claude Code MCP | `claude mcp add --scope user` (3 servers) | same |
| 7 | Claude Desktop MCP | `claude_desktop_config.json` | same |
| 8 | Skills | 7 slash commands → `~/.claude/commands/logseq/` | same |
| 9 | Hooks | SessionStart (context load) + Stop (journal save) | same |
| 10 | Auto-start | Login Items | Startup folder shortcut |

---

## Skills (Slash Commands)

7 commands installed globally to `~/.claude/commands/logseq/`:

| Command | Description |
|---------|-------------|
| `/logseq:config` | Configure memory mode, language, preferences |
| `/logseq:init` | Initialize project namespace (run once per project) |
| `/logseq:polaris` | Check goal alignment with Top of Mind |
| `/logseq:save` | Save a decision or learning as atomic note |
| `/logseq:search` | Search knowledge graph (keyword + semantic) |
| `/logseq:journal` | Create or update today's daily journal |
| `/logseq:ingest` | Ingest URL or text into inbox |

---

## Project Isolation

Each project gets its own namespace in the graph. Notes never leak between projects.

### Setup

```bash
cd ~/my-project
/logseq:init my-project
```

This creates a `project/my-project` namespace and adds config to `.claude/CLAUDE.md`.

### How it works

```
~/logseq-graph/pages/
├── polaris___top-of-mind.md              ← Global (shared)
├── commonplace___docker-patterns.md      ← Global knowledge
├── project___my-project___decisions.md   ← Project-scoped
├── project___my-project___architecture.md
└── project___other-project___decisions.md ← Different project
```

| Scope | Read | Write |
|-------|------|-------|
| Global (`polaris/`, `commonplace/`) | All projects | Explicit only (`global:` prefix) |
| Project (`project/<name>/`) | Current project only | Default for saves |

---

## MCP Servers

Three servers registered globally (`--scope user`):

| Server | Type | Purpose |
|--------|------|---------|
| `logseq` | HTTP API | Search, blocks, tasks, graph queries |
| `logseq-graph` | Filesystem | Direct read/write to all files |
| `qmd` | Search | BM25 keyword + semantic search |

```bash
claude mcp list  # Verify all connected
```

---

## Graph Structure

```
~/logseq-graph/
├── pages/                          # All notes (namespace-based)
│   ├── polaris___top-of-mind.md    # Goals, principles
│   ├── commonplace___*.md          # Evergreen knowledge
│   ├── project___<name>___*.md     # Project-scoped notes
│   └── inbox___*.md                # Ingested content
├── journals/                       # Session logs (auto)
│   └── 2026-04-03.md
├── assets/
└── logseq/
    ├── config.edn                  # Logseq app settings
    └── brain-config.json           # Memory stack config
```

---

## The Polaris Strategy

`polaris/top-of-mind` is your living strategy document:
- Quarterly goals
- Active projects with success criteria
- Life Razors (non-negotiable principles)

Every session start loads this automatically. Claude becomes an accountability partner that flags when your work drifts from your stated goals.

---

## Automation

### SessionStart Hook
1. Launches Logseq if not running
2. Loads previous session journal
3. Loads pending tasks
4. Loads Polaris goals
5. Detects current project namespace
6. First-run detection → suggests `/logseq:config`

### Stop Hook
1. Summarizes work done in this session
2. Records decisions made
3. Captures pending tasks as TODOs
4. Saves everything to today's journal
5. Tags with project namespace if applicable

### Auto-start on Login
- **macOS**: Login Item (hidden)
- **Windows**: Startup folder shortcut (minimized)

---

## Repo Structure

```
logseq-brain-setupd/
├── install.sh                    # macOS installer
├── install.ps1                   # Windows installer
├── config.env                    # Token & settings
├── commands/logseq/              # Skills (→ ~/.claude/commands/logseq/)
│   ├── config.md                 #   /logseq:config
│   ├── init.md                   #   /logseq:init
│   ├── polaris.md                #   /logseq:polaris
│   ├── save.md                   #   /logseq:save
│   ├── search.md                 #   /logseq:search
│   ├── journal.md                #   /logseq:journal
│   └── ingest.md                 #   /logseq:ingest
├── scripts/
│   ├── logseq-session-start.sh   # SessionStart hook (macOS)
│   ├── logseq-session-start.ps1  # SessionStart hook (Windows)
│   ├── ensure-logseq.sh          # Logseq launcher (macOS)
│   └── ensure-logseq.ps1         # Logseq launcher (Windows)
└── templates/
    ├── config.edn
    ├── polaris___top-of-mind.md
    ├── inbox.md
    └── claude-md-addon.md
```

---

## Idempotent

The installer is safe to run multiple times:
- Already-installed tools are skipped
- Existing files are never overwritten
- MCP servers are removed then re-registered
- Skills are always copied fresh
- Hooks are added only if not present

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `logseq` MCP: Failed | Logseq not running or API disabled | Open Logseq, enable HTTP API |
| 401 Unauthorized | Token mismatch | Match `config.env` with Logseq settings |
| Port 12315 not listening | HTTP server off | Settings → Advanced → HTTP APIs server ON |
| `qmd` no results | No embeddings | Run `qmd embed` for semantic search |
| No context on start | Logseq graph empty | Fill in `polaris/top-of-mind`, use `/logseq:journal` |
| First run prompt | Normal | Run `/logseq:config` or ignore for defaults |

---

## Security

- `config.env` contains your API token → use a **private repository**
- Logseq data stays **100% local** — no cloud sync unless you configure it
- MCP servers only access `~/logseq-graph/` — no other filesystem access

---

## Credits

Inspired by the [3-Layer Memory Stack](https://x.com/intheworldofai/status/2039255561280057794) concept, adapted from Obsidian to Logseq for block-based, local-first knowledge management with session memory continuity.
