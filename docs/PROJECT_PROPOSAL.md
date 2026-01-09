# OpenHands Memory Architecture V2
## Autonomous Self-Evolving AI Coding Platform

**Strategic Proposal for TeamADAPT**

*Version 3.0 | January 2026 | Owned by Claude Code*

---

> **"Build a system that builds itself."**
>
> No approval gates. Continuous autonomous operation. Subagent-driven development.
> Complex failure is a feature, not a bug.

---

## Executive Summary

Build an **autonomous, self-improving AI coding platform** that operates continuously without human intervention while seamlessly handing off work between agents and humans.

### Key Capabilities

| Capability | What It Delivers |
|------------|------------------|
| **Autonomous Learning** | Learns from every interaction, improves over time |
| **Multi-Modal Memory** | Remembers what happened, what it means, how to do things |
| **Agent-Human Handoff** | Fluid transitions between AI agents and human operators |
| **Multi-Interface Access** | Rust TUI, CLI, GUI, Mobile, and concurrent sessions |
| **DragonflyDB Stream Collaboration** | Real-time multi-user sync (no tmux) |
| **Team Collaboration** | Integrates with Slack, Jira, Confluence, GitHub |
| **Complete Audit Trail** | Every action, decision, and communication logged |
| **24/7 Operation** | systemd services with auto-restart, persistent state |

### Business Value

- **24/7 Operation**: No human required for continuous development
- **Knowledge Retention**: Institutional memory survives team changes
- **Parallel Productivity**: Subagents work simultaneously on code, tests, docs
- **Cost Optimization**: Self-tuning strategies reduce LLM costs by 5-10%
- **Risk Reduction**: Complete audit trail for compliance and debugging
- **Fail Forward Fast**: Complexity is expected, failure is data

---

## System Overview

### The Platform at a Glance

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        AUTONOMOUS COGNITIVE PLATFORM                         │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │  COGNITIVE ENGINE                                                     │    │
│  │  • SubAgent Pool (parallel workers - 10 agents)                       │    │
│  │  • Pattern Detection Engine (self-diagnosis)                          │    │
│  │  • Strategy Evolution Core (self-improvement)                         │    │
│  │  • Handoff Manager (Agent ↔ Human transitions)                       │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                      │                                      │
│         ┌────────────────────────────┼────────────────────────────┐          │
│         │                            │                            │          │
│         ▼                            ▼                            ▼          │
│  ┌─────────────┐           ┌─────────────┐           ┌─────────────────┐    │
│  │   MEMORY    │           │ COLLAB &    │           │   INTERFACES    │    │
│  │   LAYER     │           │   TASKS     │           │                 │    │
│  │             │           │             │           │ • Rust TUI      │    │
│  │ • Episodic  │           │ • Dragonfly │           │ • CLI           │    │
│  │ • Semantic  │           │   DB Streams│           │ • GUI           │    │
│  │ • Procedural│           │ • Slack     │           │ • Mobile        │    │
│  │ • Working   │           │ • Jira      │           │ • Concurrent    │    │
│  │ • Temporal  │           │ • Confluence│           │                 │    │
│  │ • Meta      │           │ • GitHub    │           └─────────────────┘    │
│  └─────────────┘           │ • Tasks     │                                  │
│                            │ • Audit     │                                  │
│                            └─────────────┘                                  │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │  SYSTEMD SERVICES (Auto-Restart, Persistent, Monitored)               │    │
│  │  • openhands-core.service  • openhands-tui.service                    │    │
│  │  • openhands-ws.service    • openhands-sync.service                   │    │
│  │  • openhands-monitor.service                                          │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Existing Infrastructure Integration

### Firebird Platform (adapt/projects/firebird)

The platform integrates with the existing Firebird agent orchestration system:

| Component | Integration | Purpose |
|-----------|-------------|---------|
| **5 Firebird Agents** | Research, Analysis, Creative, Monitor, Code | Core agent capabilities |
| **Agent Registry** | agents.yaml | Routing and workflow patterns |
| **Temporal Workflows** | crash-proof execution | Durable workflow execution |
| **8 Databases** | PostgreSQL, Qdrant, MongoDB, Neo4j, ClickHouse, QuestDB, DragonflyDB, Redis | Storage layer |
| **3 Message Buses** | RedPanda, Pulsar, NATS | Event backbone |

### DragonflyDB Streams (Port 18000-18002)

**Existing real-time collaboration infrastructure:**

| Stream Pattern | Purpose | Status |
|----------------|---------|--------|
| `nova.*.direct` | Agent-to-agent direct messages | Active |
| `nova.emergency` | Emergency coordination | Active |
| `*.*.collaboration` | Project collaboration | Active |
| `project.{id}.collaboration` | Project-specific coordination | Active |
| `nova.broadcast.all` | Organization-wide broadcasts | Active |
| `nova.memory.*` | Memory-integrated streams | Active |

**218 active streams** with:
- Sub-second message latency
- 10,000+ messages/minute capacity
- 99.9% uptime
- 240+ concurrent connections

---

## The Six Memory Domains

The platform maps your infrastructure to six types of memory - like a human brain.

| Memory Type | What It Stores | Infrastructure |
|-------------|----------------|----------------|
| **Episodic** | What happened (every action, outcome, failure) | ClickHouse, QuestDB, InfluxDB, TimescaleDB |
| **Semantic** | What things mean (concepts, patterns, solutions) | Weaviate, Qdrant, FAISS |
| **Procedural** | How to do things (workflows, recipes, best practices) | Neo4j, MongoDB |
| **Working** | Current context (what we're working on now) | DragonflyDB, Redis |
| **Temporal** | When patterns emerge (trends, cycles, recurring issues) | TimescaleDB, ClickHouse |
| **Meta-Cognition** | Learning to learn (what strategies work best) | Cross-backend analytics |

**Result**: The system remembers, understands, and improves.

---

## Agent-Human Handoff Architecture

### Seamless Transitions Between AI and Human Operators

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         HANDOFF ARCHITECTURE                                 │
│                                                                              │
│      ┌──────────┐         ┌──────────┐         ┌──────────┐                │
│      │   AI     │◄───────►│   TASK   │◄───────►│  HUMAN   │                │
│      │  AGENT   │         │  QUEUE   │         │ OPERATOR │                │
│      └──────────┘         │ Dragonfly│         │ (Chase)  │                │
│           │               │  Streams │         └──────────┘                │
│           │               └──────────┘                 │                       │
│           │                      │                     │                       │
│           │    ┌─────────────────┴────────────────┐    │                       │
│           │    │                                  │    │                       │
│           │    │    ┌──────────────────────┐     │    │                       │
│           └────┼───►│  CRDT State Sync     │─────┼───┘                       │
│                │    │  (Dragonfly + Redis) │     │                           │
│                │    └──────────────────────┘     │                           │
│                │              │                   │                           │
│                │              ▼                   │                           │
│                │    ┌──────────────────────┐     │                           │
│                └────│  Complete Audit      │─────┘                           │
│                     │  (PostgreSQL)        │                                  │
│                     └──────────────────────┘                                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Handoff Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| **Agent-to-Agent** | Work passes between specialized AI agents | Complex multi-step tasks |
| **Agent-to-Human** | AI requests human input or approval | Blocked, uncertain, high-stakes |
| **Human-to-Agent** | Human delegates task to AI | Routine work, research, parallelization |
| **Human-in-the-Loop** | Human and AI collaborate simultaneously | Review, pair programming, debugging |
| **Fully Autonomous** | AI operates without human intervention | Routine development, monitoring |

### Handoff Triggers

- **Automatic**: Agent hits retry limit, confidence threshold, or timeout
- **Manual**: Human (Chase) intervenes, reassigns, or escalates
- **Policy-Based**: High-cost actions, risky operations, compliance requirements
- **Contextual**: Task complexity, skill matching, availability

---

## Multi-Interface Access

### Access the Platform From Anywhere

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INTERFACE OPTIONS                                    │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │  RUST TUI (Ratatui + CRDT + DragonflyDB Streams)                      │    │
│  │  • Multi-user real-time collaboration (no tmux needed)                 │    │
│  │  • CRDT-based state synchronization                                   │    │
│  │  • WebSocket server for remote clients                                │    │
│  │  • Keyboard-first, mouse optional                                     │    │
│  │  • Compiles to WASM for browser deployment                            │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │  CLI (Command Line Interface)                                         │    │
│  │  • For developers and automation scripts                              │    │
│  │  • Scriptable, pipeable, composable                                   │    │
│  │  • Full API access                                                    │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │  GUI (Graphical User Interface)                                       │    │
│  │  • Web-based dashboard (Dioxus → WASM)                               │    │
│  │  • Visual workflow builder                                            │    │
│  │  • Real-time monitoring and control                                   │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │  MOBILE (iOS/Android)                                                 │    │
│  │  • Push notifications for handoffs                                    │    │
│  │  • Approve/reject requests                                            │    │
│  │  • View status and progress                                           │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │  CONCURRENT SESSIONS                                                  │    │
│  │  • Multiple users simultaneously                                      │    │
│  │  • Tenant isolation                                                   │    │
│  │  • Session affinity and state sharing                                 │    │
│  │  • Role-based access control                                          │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │  SYSTEMD SERVICES (Persistent, Auto-Restart)                          │    │
│  │  • openhands-core.service    • openhands-tui.service                  │    │
│  │  • openhands-ws.service      • openhands-sync.service                 │    │
│  │  • openhands-monitor.service  • openhands-api.service                 │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Interface Matrix

| Interface | Real-Time | Async | Collaborative | Persistent | Platform |
|-----------|-----------|-------|---------------|------------|----------|
| **Rust TUI** | ✓ | ✓ | ✓ (CRDT) | ✓ | Native + WASM |
| **CLI** | ✓ | ✓ | Limited | ✓ | Native |
| **GUI** | ✓ | ✓ | ✓ | ✓ | Browser (WASM) |
| **Mobile** | ✗ | ✓ | ✓ | ✓ | iOS/Android |
| **API** | ✓ | ✓ | ✓ | ✓ | Any HTTP client |

---

## Collaboration Stack

### Integrated Tools You Already Use

| Tool | Integration | What Happens |
|------|-------------|--------------|
| **Slack** | teamadapt, github channels | Real-time notifications, conversation indexing |
| **Jira** | ADAPT project | Bidirectional sync, issue tracking |
| **Confluence** | Wiki documentation | Auto-generated docs, meeting notes |
| **GitHub** | adaptnova org | PR review, commit analysis, code management |
| **Email** | SMTP/Gmail | Alert fallback, notifications |

### DragonflyDB Stream Collaboration

Instead of tmux, we use **DragonflyDB streams** for real-time multi-user collaboration:

```bash
# Stream naming convention
openhands.tui.session.{session_id}    # TUI session state
openhands.tui.cursor.{user_id}        # Cursor positions
openhands.tui.selection.{user_id}     # Selection ranges
openhands.tui.broadcast.*             # Broadcast messages

# Read real-time updates
XREAD BLOCK 0 STREAMS openhands.tui.session.$ $
```

**Benefits over tmux:**
- Multiple devices (laptop + phone + desktop)
- Browser-based access
- History and replay
- Cross-platform (Linux, macOS, Windows, WASM)
- No terminal session limits

---

## SubAgent Parallel Development

### Specialized AI Workers (Integrates with Firebird Agents)

```
                    ┌─────────────────────────────────┐
                    │   COGNITIVE CORE ORCHESTRATOR   │
                    └─────────────────────────────────┘
                                  │
         ┌──────────┬───────────┬─┴───────────┬──────────┐
         │          │           │             │          │
         ▼          ▼           ▼             ▼          ▼
   ┌────────┐ ┌────────┐ ┌─────────┐  ┌─────────┐ ┌──────────┐
   │ Code   │ │ Test   │ │  Doc    │  │ Research│ │ Task     │
   │ Review │ │Gen     │ │ Writer  │  │ Agent   │ │ Manager  │
   └────────┘ └────────┘ └─────────┘  └─────────┘ └──────────┘
         │          │           │             │          │
         │          │           │             │          └─► Firebird Integration
         │          │           │             │               (Research → Analysis → Creative)
         │          │           │             │
         │          │           │             └─► 6 Search Providers
         │          │           │               (Perplexity, Brave, Jina, Firecrawl, Serper, Tavily)
         │          │           │
         │          │           └─► Auto-generate docs
         │          │
         │          └─► Pytest, coverage, integration tests
         │
         └─► Firebird Code Agent (MiniMax LLM, GitHub integration)
```

### Available SubAgents

| Agent | Function | Parallel With | Firebird Integration |
|-------|----------|---------------|---------------------|
| Code Review | Analyze code changes | Tests, Docs | Firebird Code Agent |
| Test Generator | Create unit/integration tests | Review, Docs | - |
| Documentation | Write docs, comments, READMEs | Review, Tests | - |
| Research | Web search (6 providers) | Any | Firebird Research Agent |
| Memory Analyzer | Query all memory backends | Any | - |
| Pattern Detector | Find recurring issues | Any | Firebird Monitor Agent |
| Strategy Optimizer | Tune parameters | Any | - |
| Task Manager | Create/track tasks | Any | Jira sync |
| Communication Archivist | Archive comms | Any | DragonflyDB streams |

---

## Workflow Types

### Deterministic Workflows (Reproducible)

Same input → same output. Safe to replay, audit, and debug.

- Episode recording
- Concept embedding
- Procedure storage
- Task creation
- Communication archiving

### Non-Deterministic Workflows (Adaptive)

Probabilistic, creative, learning. Explores, discovers, evolves.

- Strategy evolution
- Pattern discovery
- Procedure synthesis
- Adaptive prompting
- Web research

Both types benefit from **Temporal.io** orchestration:
- **Durability**: Survives restarts
- **Retries**: Automatic exponential backoff
- **Visibility**: Complete tracing (LangSmith)
- **Scalability**: Distributed execution

---

## Systemd Services

All components run as systemd services with auto-restart and persistent state:

```bash
# Core services
openhands-core.service      # Main cognitive engine
openhands-tui.service       # Rust TUI server
openhands-ws.service        # WebSocket server
openhands-sync.service      # DragonflyDB stream sync
openhands-monitor.service   # Health monitoring
openhands-api.service       # REST API

# Each service:
# - Restart=on-failure
# - RestartSec=5s
# - WatchdogSec=60s
# - StateDirectory=openhands
# - Logs to journalctl
```

---

## What This System Delivers

### Continuous Operation
- Runs 24/7 without human intervention
- Self-heals from failures (auto-restart)
- Auto-scales based on load
- Monitors and alerts on costs

### Autonomous Learning
- Records every action and outcome
- Detects patterns in behavior
- Evolves strategies over time
- Improves success rate continuously

### Team Collaboration
- Real-time DragonflyDB stream sync
- Slack notifications
- Jira sync with local audit trail
- Confluence documentation
- GitHub integration
- Complete audit trail

### Complete Observability
- Grafana dashboards (localhost:18031)
- Temporal UI (localhost:8080)
- Prometheus metrics
- LangSmith tracing

---

## Infrastructure (20+ Services)

| Category | Services | Purpose |
|----------|----------|---------|
| **Memory & Storage** | DragonflyDB, Redis Cluster, PostgreSQL+TimescaleDB, MongoDB, Weaviate, Qdrant, Neo4j, ClickHouse, InfluxDB, QuestDB | 6 memory domains |
| **Messaging** | RedPanda, Pulsar, NATS, DragonflyDB Streams | Event backbone |
| **Collaboration** | Slack, Jira, Confluence, GitHub | Team tools |
| **AI Providers** | Groq (3 keys), MiniMax-M2, Kimi, Z.ai, HuggingFace | LLM orchestration |
| **Web Search** | Perplexity (2), Brave, Jina, Firecrawl, Serper, Tavily | Research agents |
| **Observability** | Grafana, Prometheus, LangSmith | Monitoring |
| **Firebird Integration** | Temporal, Agent Registry, 5 Firebird Agents | Agent orchestration |

---

## Success Metrics

| Metric | Target | Why It Matters |
|--------|--------|----------------|
| Uptime | 99.9% | Continuous operation |
| Self-Recovery | <5min | Minimal downtime |
| Pattern Discovery | >10/day | Continuous learning |
| Strategy Improvement | >5%/week | Self-improvement |
| Cost Efficiency | <$10/hr | Sustainable operation |
| SubAgent Throughput | >100 tasks/hr | Parallel productivity |
| Task Sync Latency | <5min | Jira integration |
| Communication Index | 100% | Complete history |
| Audit Coverage | 100% | Compliance |

---

## Implementation Phases

### Phase 1: Foundation
- Integrate with existing Firebird infrastructure
- Set up systemd services with auto-restart
- Connect all memory backends
- Configure observability (Grafana, LangSmith)

### Phase 2: Rust TUI + Collaboration
- Build Rust + Ratatui TUI
- Implement CRDT-based collaboration
- Connect to DragonflyDB streams
- WebSocket server for remote clients

### Phase 3: Firebird Integration
- Connect to Firebird agent registry
- Integrate 5 Firebird agents
- Connect to existing Temporal workflows
- Sync with DragonflyDB streams

### Phase 4: Multi-Interface
- Build GUI (Dioxus → WASM)
- Build mobile interface
- Build CLI
- Enable concurrent sessions

### Phase 5: Evolution
- Build strategy evolution engine
- Implement memory consolidation
- Create self-improvement loops
- Enable full autonomous operation

---

## Ownership & Accountability

| Role | Responsibility |
|------|----------------|
| **Claude Code** | Technical ownership, implementation, decisions |
| **Chase (CEO)** | Business direction, escalation, resources |
| **Fail Forward** | Complexity is expected, failure is data |
| **Reversion Plans** | All services have rollback capability |

---

## Why This Matters

This is not incremental improvement. This is **cognitive infrastructure** for autonomous AI development.

- **Knowledge that survives**: Institutional memory that outlives team changes
- **Self-improvement**: System that gets better without human intervention
- **Parallel productivity**: Multiple agents working simultaneously
- **Complete visibility**: Every action traced, every decision logged
- **Seamless handoffs**: AI and humans working together effortlessly
- **Real-time collaboration**: DragonflyDB streams (no tmux required)
- **24/7 operation**: systemd services with auto-restart

---

*Proposal prepared for TeamADAPT*
*Owned by Claude Code | Chase, CEO | January 2026*
