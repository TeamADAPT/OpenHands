# OpenHands Memory Architecture V2
## Technical Deep-Dive

**For Architects & Engineers**

*Version 3.0 | January 2026 | Owned by Claude Code*

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Max Agent Integration](#max-agent-integration)
3. [Memory Domains](#memory-domains)
4. [Systemd Services](#systemd-services)
5. [DragonflyDB Stream Collaboration](#dragonflydb-stream-collaboration)
6. [Rust TUI with CRDT](#rust-tui-with-crdt)
7. [Workflow Engine](#workflow-engine)
8. [SubAgent System](#subagent-system)
9. [Multi-Interface Architecture](#multi-interface-architecture)
10. [Infrastructure Services](#infrastructure-services)
11. [Deployment Guide](#deployment-guide)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        AUTONOMOUS COGNITIVE PLATFORM                                 │
│                                                                                      │
│    ┌──────────────────────────────────────────────────────────────────────────┐      │
│    │                    TEMPORAL ORCHESTRATION LAYER                           │      │
│    │   Deterministic Workflows ◄──► Non-Deterministic Workflows ◄──► Agents   │      │
│    │                                                                          │      │
│    │   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐  │      │
│    │   │ SubAgent Manager│  │ Pattern Engine  │  │ Strategy Evolution Core │  │      │
│    │   │ (Parallel Dev)  │  │ (Self-Diagnosis)│  │ (Self-Improvement)      │  │      │
│    │   └─────────────────┘  └─────────────────┘  └─────────────────────────┘  │      │
│    └──────────────────────────────────────────────────────────────────────────┘      │
│                                    │                                               │
│     ┌──────────────────────────────┼──────────────────────────────┐                 │
│     │                              │                              │                 │
│     ▼                              ▼                              ▼                 │
│ ┌──────────┐               ┌───────────┐               ┌──────────────┐            │
│ │  COGNITIVE│               │  MEMORY   │               │  COMMUNICATION│            │
│ │  CORE     │               │  LAYER    │               │  & COLLAB     │            │
│ └────┬─────┘               └─────┬─────┘               └──────┬───────┘            │
│      │                           │                           │                      │
│      │    ┌──────────────────────┼───────────────────────────┘                      │
│      │    │                                                                      │
│      ▼    ▼                                                                      │
│─────────────┐ ┌────────────────────────────────────────────────────────────────     │
│ │                        INFRASTRUCTURE LAYER (20+ SERVICES)                   │     │
│ ├─────────────────────────────────────────────────────────────────────────────┤     │
│ │                                                                              │     │
│ │  MEMORY & STORAGE                    │  MESSAGING & EVENTS                    │     │
│ │  ├── DragonflyDB (18000-02)          │  ├── RedPanda (18021-23) [PRIMARY]     │     │
│ │  ├── Redis Cluster (18010-12)        │  ├── Pulsar (8080) [FALLBACK]          │     │
│ │  ├── PostgreSQL+TimescaleDB (18030)  │  ├── NATS (18020) [HIGH-PERF]          │     │
│ │  ├── MongoDB (18070)                 │  └── DragonflyDB Streams               │     │
│ │  ├── Weaviate (18050)                │                                         │     │
│ │  ├── Qdrant (18054)                  │  COLLABORATION                         │     │
│ │  ├── Neo4j (18060-61)                │  ├── Slack, Jira, Confluence, GitHub   │     │
│ │  ├── ClickHouse (18090)              │  ├── PostgreSQL Tasks                  │     │
│ │  ├── InfluxDB (18100)                │  ├── MongoDB Communications            │     │
│ │  └── QuestDB (18091)                 │  ├── Redis State Cache                 │     │
│ │                                       │  └── Neo4j Relationships              │     │
│ │  FIREBIRD INTEGRATION                │                                         │     │
│ │  ├── Agent Registry                  │  OBSERVABILITY                         │     │
│ │  ├── 5 Firebird Agents               │  ├── Grafana (18031)                   │     │
│ │  ├── Temporal Workflows              │  ├── Prometheus (9090)                 │     │
│ │  └── Agent Coordination              │  └── LangSmith Tracing                 │     │
│ │                                                                              │     │
│ └─────────────────────────────────────────────────────────────────────────────┘     │
│                                                                                      │
└───────────────────────────────────────────────────────────────┬──────────────────────┘
                                                                │
                                                                ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         MULTI-TENANT UI & CONCURRENT SESSIONS                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐│
│  │  Tenant A   │  │  Tenant B   │  │  Tenant C   │  │  System UI  │  │  Admin UI   ││
│  │  Session 1  │  │  Session 1  │  │  Session 1  │  │  (Monitoring│  │  (Control)  ││
│  │  Session 2  │  │  Session 2  │  │  Session 2  │  │   + Logs)   │  │  + Config)  ││
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │                     RUST TUI (Ratatui + CRDT + WebSocket)                    │    │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐   │    │
│  │  │ Local Terminal  │◄─►│ WebSocket Server│◄─►│ Remote Clients (Browser)   │   │    │
│  │  │ (Ratatui)       │  │   (Tokio)       │  │   (WASM + Dioxus)           │   │    │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Max Agent Integration

### Max Protocol Overview

Max (from `/adapt/platform/devops/max-dev/AGENT.md`) provides a comprehensive agent framework that OpenHands integrates with:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MAX AGENT INTEGRATION LAYER                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────┐      │
│  │                    MAX MEMORY HIERARCHY                            │      │
│  │  ┌─────────────────────────────────────────────────────────────┐  │      │
│  │  │              EPISODIC MEMORY (Weaviate)                     │  │      │
│  │  │  - Conversation transcripts                                 │  │      │
│  │  │  - Session experiences                                      │  │      │
│  │  │  - Event sequences                                          │  │      │
│  │  │  Port: 18050 | Vector-based semantic search                │  │      │
│  │  └─────────────────────────────────────────────────────────────┘  │      │
│  │                               │                                     │      │
│  │                               ▼                                     │      │
│  │  ┌─────────────────────────────────────────────────────────────┐  │      │
│  │  │            SEMANTIC MEMORY (Weaviate)                       │  │      │
│  │  │  - Learned facts and concepts                               │  │      │
│  │  │  - Knowledge structures                                     │  │      │
│  │  │  - Entity relationships                                     │  │      │
│  │  │  Port: 18050 | Embedding-based storage                      │  │      │
│  │  └─────────────────────────────────────────────────────────────┘  │      │
│  │                               │                                     │      │
│  │                               ▼                                     │      │
│  │  ┌─────────────────────────────────────────────────────────────┐  │      │
│  │  │          PROCEDURAL MEMORY (PostgreSQL)                     │  │      │
│  │  │  - Learned behaviors                                        │  │      │
│  │  │  - Task patterns                                            │  │      │
│  │  │  - Workflow procedures                                      │  │      │
│  │  │  Port: 18030 | Structured persistent storage               │  │      │
│  │  └─────────────────────────────────────────────────────────────┘  │      │
│  │                               │                                     │      │
│  │                               ▼                                     │      │
│  │  ┌─────────────────────────────────────────────────────────────┐  │      │
│  │  │             WORKING MEMORY (DragonflyDB)                    │  │      │
│  │  │  - Current session context                                  │  │      │
│  │  │  - Active conversations                                     │  │      │
│  │  │  - Immediate tasks                                          │  │      │
│  │  │  Port: 18000 | Sub-millisecond access                      │  │      │
│  │  └─────────────────────────────────────────────────────────────┘  │      │
│  └───────────────────────────────────────────────────────────────────┘      │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────┐      │
│  │                    TEMPORAL.IO DURABILITY                          │      │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐               │      │
│  │  │  Workflows  │  │  Activities │  │   Signals   │               │      │
│  │  │  Durable    │  │  Reliable   │  │  Reactive   │               │      │
│  │  │  Execution  │  │  Execution  │  │  Handling   │               │      │
│  │  └─────────────┘  └─────────────┘  └─────────────┘               │      │
│  │  Port: 7233 | Namespace: max | Task Queue: max-tasks             │      │
│  └───────────────────────────────────────────────────────────────────┘      │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────┐      │
│  │                    MULTI-AGENT COORDINATION                        │      │
│  │                                                                    │      │
│  │  NATS Subject Hierarchy:                                           │      │
│  │  ────────────────────────                                          │      │
│  │  max.{env}.{scope}.{target}                                       │      │
│  │                                                                    │      │
│  │  Examples:                                                         │      │
│  │  • max.dev.sessions.broadcast     - Broadcast to all              │      │
│  │  • max.dev.sessions.{id}          - Direct to session             │      │
│  │  • max.dev.tasks.{task_id}        - Task coordination             │      │
│  │  • max.dev.events.{event_type}    - Event notifications           │      │
│  │  • max.dev.instances.active       - Instance discovery            │      │
│  └───────────────────────────────────────────────────────────────────┘      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Integration Points

```python
# openhands/integrations/max_agent.py

from temporalio.client import Client as TemporalClient
from datetime import timedelta
from typing import Optional
import json

class MaxAgentIntegration:
    """
    Integrates OpenHands with Max Agent protocols.

    Uses:
    - Temporal.io for durable workflows
    - NATS for multi-agent coordination
    - DragonflyDB for working memory
    - PostgreSQL for long-term memory
    - Weaviate for semantic memory
    """

    def __init__(self):
        self.temporal: Optional[TemporalClient] = None
        self.nats_client = None
        self.dragonfly = DragonflyClient(host="localhost", port=18000)
        self.postgres = PostgreSQLClient(host="localhost", port=18030)
        self.weaviate = WeaviateClient(url="http://localhost:18050")

    async def connect(self):
        """Connect to all Max infrastructure."""
        # Temporal
        self.temporal = await TemporalClient.connect("localhost:7233")

        # NATS
        import nats
        self.nats_client = await nats.connect("localhost:18020")

        # Register with coordination layer
        await self._register_instance()

    async def _register_instance(self):
        """Register this OpenHands instance with Max coordination."""
        await self.nats_client.publish(
            subject="openhands.dev.instances.active",
            payload=json.dumps({
                "instance_id": "openhands-main",
                "capabilities": ["memory", "reasoning", "code", "research"],
                "status": "active",
                "timestamp": datetime.utcnow().isoformat(),
            }).encode(),
        )

    async def execute_max_workflow(self, workflow_name: str, args: dict):
        """Execute a Max-defined workflow via Temporal."""
        handle = await self.temporal.start_workflow(
            f"max.{workflow_name}",
            args,
            id=f"openhands-{workflow_name}-{uuid.uuid4().hex[:8]}",
            task_queue="max-tasks",
        )
        return await handle.result()

    async def publish_event(self, event_type: str, payload: dict):
        """Publish event to NATS for Max coordination."""
        await self.nats_client.publish(
            subject=f"openhands.dev.events.{event_type}",
            payload=json.dumps(payload).encode(),
        )

    async def get_context_from_memory(self, query: str) -> dict:
        """Retrieve context from Max memory layers."""
        # Search semantic memory (Weaviate)
        semantic_results = await self.weaviate.search(
            class_name="MaxMemory",
            query=query,
            limit=5,
        )

        # Retrieve working memory (DragonflyDB)
        working_memory = await self.dragonfly.get("openhands:context")

        # Get procedural memory (PostgreSQL)
        procedural = await self.postgres.fetch("""
            SELECT * FROM max_procedures
            WHERE relevant_to = $1
            ORDER BY success_rate DESC
            LIMIT 5
        """, query)

        return {
            "semantic": semantic_results,
            "working": working_memory,
            "procedural": procedural,
        }
```

---

## Memory Domains

### 2.1 Episodic Memory (What Happened)

**Backends**: ClickHouse, QuestDB, InfluxDB, TimescaleDB

```python
# openhands/memory/episodic.py

@dataclass
class EpisodeEvent:
    """Something that happened during agent execution."""
    session_id: UUID
    action_type: str  # file_edit, command_run, agent_delegate, etc.
    action_input: dict
    action_output: dict
    outcome: str  # success, failure, partial
    duration_ms: float
    timestamp: datetime
    embedding: List[float]
    task_type: str
    domain_context: dict

class EpisodicMemoryStore:
    """Stores episodes across all time-series backends."""

    def __init__(self):
        self.clickhouse = ClickHouseClient("localhost", 18090)
        self.questdb = QuestDBClient("localhost", 18091)
        self.influxdb = InfluxDBClient("localhost", 8086)
        self.timescale = PostgreSQLClient("localhost", 18030)

    async def record_episode(self, episode: EpisodeEvent):
        """Record episode to all time-series backends."""
        # Parallel writes
        await asyncio.gather(
            self._write_clickhouse(episode),
            self._write_questdb(episode),
            self._write_influxdb(episode),
            self._write_timescale(episode),
        )

    async def _write_clickhouse(self, episode: EpisodeEvent):
        """Write to ClickHouse for analytics."""
        await self.clickhouse.execute("""
            INSERT INTO agent_episodes (session_id, action_type, outcome, duration_ms, timestamp)
            VALUES (%s, %s, %s, %s, %s)
        """, [
            str(episode.session_id),
            episode.action_type,
            episode.outcome,
            episode.duration_ms,
            episode.timestamp,
        ])

    async def _write_questdb(self, episode: EpisodeEvent):
        """Write to QuestDB via ILP for high-frequency ingestion."""
        self.questdb.write(
            table="agent_episodes",
            symbols={"session_id": str(episode.session_id), "action_type": episode.action_type},
            columns={"outcome": episode.outcome, "duration_ms": episode.duration_ms},
            at=episode.timestamp,
        )

    async def query_by_pattern(
        self,
        pattern: str,
        time_range: tuple[datetime, datetime],
    ) -> List[EpisodeEvent]:
        """Query episodes matching a semantic pattern."""
        # Use ClickHouse for analytics queries
        results = await self.clickhouse.query("""
            SELECT * FROM agent_episodes
            WHERE timestamp BETWEEN %s AND %s
            AND action_type = %s
            ORDER BY timestamp DESC
        """, time_range[0], time_range[1], pattern)
        return results
```

### 2.2 Semantic Memory (What It Means)

**Backends**: Weaviate, Qdrant, FAISS

```python
# openhands/memory/semantic.py

@dataclass
class Concept:
    """Learned concept with multi-vector storage."""
    concept_id: UUID
    content: str
    embedding_weaviate: Optional[List[float]] = None
    embedding_qdrant: Optional[List[float]] = None
    embedding_faiss: Optional[List[float]] = None
    source_episode: UUID = None
    confidence: float = 1.0
    decay_weight: float = 1.0
    related_concepts: List[str] = []
    is_a_relations: List[str] = []
    part_of_relations: List[str] = []

class SemanticMemoryStore:
    """Multi-vector semantic memory with CRDT sync."""

    def __init__(self):
        self.weaviate = WeaviateClient("http://localhost:18050")
        self.qdrant = QdrantClient("localhost", 18054)
        self.faiss_index = None  # Local FAISS index

    async def store_concept(self, concept: Concept):
        """Store concept in all vector backends."""
        # Generate embeddings for each backend
        embedding = await self._generate_embedding(concept.content)

        # Weaviate (primary)
        await self.weaviate.data_object.create(
            class_name="SemanticConcept",
            data_object={
                "content": concept.content,
                "concept_id": str(concept.concept_id),
                "confidence": concept.confidence,
                "source_episode": str(concept.source_episode),
            },
            vector=embedding,
        )

        # Qdrant (specialized for high-dim)
        await self.qdrant.upsert(
            collection_name="openhands_concepts",
            points=[{
                "id": str(concept.concept_id),
                "vector": embedding,
                "payload": {
                    "content": concept.content,
                    "confidence": concept.confidence,
                }
            }]
        )

        # FAISS (local cache)
        if self.faiss_index is not None:
            self.faiss_index.add([embedding])

    async def search_similar(
        self,
        query: str,
        limit: int = 10,
    ) -> List[SearchResult]:
        """Search across all vector stores and merge results."""
        query_embedding = await self._generate_embedding(query)

        # Parallel search
        weaviate_results, qdrant_results, faiss_results = await asyncio.gather(
            self._search_weaviate(query_embedding, limit),
            self._search_qdrant(query_embedding, limit),
            self._search_faiss(query_embedding, limit),
        )

        # Merge with weighted voting
        return self._merge_results(
            [weaviate_results, qdrant_results, faiss_results],
            weights={"weaviate": 0.4, "qdrant": 0.4, "faiss": 0.2}
        )
```

### 2.3 Procedural Memory (How To Do Things)

**Backends**: Neo4j, MongoDB

```python
# openhands/memory/procedural.py

@dataclass
class Procedure:
    """How to accomplish a task."""
    procedure_id: UUID
    goal: str
    steps: List[dict]  # Ordered steps with conditions
    prerequisites: List[str]
    expected_outcomes: List[str]
    failure_modes: List[dict]
    applicability_conditions: dict
    learned_from_episode: UUID
    success_count: int = 0
    failure_count: int = 0

class ProceduralMemoryStore:
    """Graph + document procedural memory."""

    def __init__(self):
        self.neo4j = Neo4jClient("bolt://localhost", 18061)
        self.mongodb = MongoDBClient("mongodb://localhost:27017")

    async def store_procedure(self, procedure: Procedure):
        """Store procedure in Neo4j (graph) + MongoDB (document)."""
        # Neo4j graph structure
        await self.neo4j.write("""
            MERGE (p:Procedure {id: $id})
            SET p.goal = $goal,
                p.success_count = $success_count,
                p.failure_count = $failure_count

            WITH p
            UNWIND $steps AS step
            MERGE (s:Step {id: step.id})
            SET s.action = step.action,
                s.conditions = step.conditions
            MERGE (p)-[:HAS_STEP {order: step.order}]->(s)

            WITH p
            UNWIND $prerequisites AS prereq
            MERGE (c:Concept {id: prereq})
            MERGE (p)-[:REQUIRES]->(c)
        """, {
            "id": str(procedure.procedure_id),
            "goal": procedure.goal,
            "success_count": procedure.success_count,
            "failure_count": procedure.failure_count,
            "steps": [
                {"id": f"step_{i}", "action": s["action"], "conditions": s.get("conditions", {}), "order": i}
                for i, s in enumerate(procedure.steps)
            ],
            "prerequisites": procedure.prerequisites,
        })

        # MongoDB full document
        await self.mongodb.db.procedures.insert_one({
            "_id": str(procedure.procedure_id),
            "goal": procedure.goal,
            "steps": procedure.steps,
            "prerequisites": procedure.prerequisites,
            "failure_modes": procedure.failure_modes,
            "applicability_conditions": procedure.applicability_conditions,
            "learned_from_episode": str(procedure.learned_from_episode),
            "success_count": procedure.success_count,
            "failure_count": procedure.failure_count,
        })

    async def find_procedure_for_goal(self, goal: str) -> List[Procedure]:
        """Find procedures that can achieve a goal."""
        # Query Neo4j for goal-matching procedures
        results = await self.neo4j.read("""
            MATCH (p:Procedure)-[:HAS_STEP]->(s:Step)
            WHERE p.goal CONTAINS $goal OR s.action CONTAINS $goal
            WITH p, collect(s) as steps
            RETURN p.id as id, p.goal as goal, steps
            ORDER BY p.success_count DESC
            LIMIT 10
        """, goal=goal)

        return [Procedure(
            procedure_id=r["id"],
            goal=r["goal"],
            steps=[{"action": s["action"], "conditions": s.get("conditions", {})} for s in r["steps"]],
            prerequisites=[],
            expected_outcomes=[],
            failure_modes=[],
            applicability_conditions={},
            learned_from_episode=None,
        ) for r in results]
```

---

## Systemd Services

### 3.1 Service Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SYSTEMD SERVICE LAYER                                │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │                    SERVICE DEPENDENCY GRAPH                           │    │
│  │                                                                      │    │
│  │                         network.target                                │    │
│  │                              │                                        │    │
│  │         ┌────────────────────┼────────────────────┐                   │    │
│  │         │                    │                    │                   │    │
│  │         ▼                    ▼                    ▼                   │    │
│  │   dragonfly.service    postgresql.service    mongod.service          │    │
│  │   (18000)              (18030)               (18070)                │    │
│  │         │                    │                    │                   │    │
│  │         └────────────────────┼────────────────────┘                   │    │
│  │                              │                                        │    │
│  │                              ▼                                        │    │
│  │                    openhands-core.service                            │    │
│  │                              │                                        │    │
│  │         ┌────────────────────┼────────────────────┐                   │    │
│  │         │                    │                    │                   │    │
│  │         ▼                    ▼                    ▼                   │    │
│  │   openhands-tui.service  openhands-ws.service  openhands-sync.service│    │
│  │   (TUI server)         (WebSocket)           (Stream sync)          │    │
│  │         │                    │                    │                   │    │
│  │         └────────────────────┼────────────────────┘                   │    │
│  │                              │                                        │    │
│  │                              ▼                                        │    │
│  │                    openhands-api.service                             │    │
│  │                              │                                        │    │
│  │                              ▼                                        │    │
│  │                    openhands-monitor.service                         │    │
│  │                                                                      │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │                    SERVICE FEATURES                                   │    │
│  │                                                                      │    │
│  │  • Restart=on-failure        • WatchdogSec=60                       │    │
│  │  • RestartSec=5s             • StateDirectory=openhands            │    │
│  │  • MemoryMax=2G              • LogsDirectory=openhands/logs        │    │
│  │  • LimitNOFILE=65536         • NoNewPrivileges=true                │    │
│  │  • ProtectSystem=strict      • PrivateTmp=true                     │    │
│  │  • EnvironmentFile=-         • StandardOutput=journal              │    │
│  │                                                                      │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Service Definitions

**Location**: `/adapt/projects/OpenHands/ops/systemd/`

| Service | Purpose | Port | Restart Policy |
|---------|---------|------|----------------|
| `openhands-core.service` | Main cognitive engine | 8000 | on-failure |
| `openhands-tui.service` | Rust TUI server | 8765 | on-failure |
| `openhands-ws.service` | WebSocket server | 8766 | on-failure |
| `openhands-sync.service` | DragonflyDB stream sync | N/A | on-failure |
| `openhands-monitor.service` | Health monitoring | N/A | on-failure |
| `openhands-api.service` | REST API | 8080 | on-failure |

### 3.3 Installation Script

```bash
#!/bin/bash
# OpenHands Systemd Installation

# Install services
sudo cp openhands-*.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable services (auto-start on boot)
sudo systemctl enable openhands-core
sudo systemctl enable openhands-tui
sudo systemctl enable openhands-ws
sudo systemctl enable openhands-sync
sudo systemctl enable openhands-monitor
sudo systemctl enable openhands-api

# Start services
sudo systemctl start openhands-core
sudo systemctl start openhands-tui
sudo systemctl start openhands-ws
sudo systemctl start openhands-sync
sudo systemctl start openhands-monitor
sudo systemctl start openhands-api

# Check status
systemctl status openhands-*

# View logs
journalctl -u openhands-core -f
journalctl -u openhands-monitor -f
```

---

## DragonflyDB Stream Collaboration

### 4.1 Stream Architecture

Instead of tmux, use DragonflyDB streams for real-time multi-user collaboration:

```python
# openhands/collaboration/streams.py

import asyncio
import json
from typing import Dict, List, Optional, Callable
from dataclasses import dataclass, field
from datetime import datetime
import redis.asyncio as redis

@dataclass
class StreamMessage:
    """Message in a collaboration stream."""
    id: str
    type: str
    sender: str
    payload: dict
    timestamp: datetime = field(default_factory=datetime.utcnow)
    sequence: int = 0

@dataclass
class CollaborationSession:
    """Multi-user collaboration session."""
    session_id: str
    users: Dict[str, dict]  # user_id -> presence info
    cursors: Dict[str, tuple[int, int]]  # user_id -> (line, col)
    selections: Dict[str, tuple[int, int]]  # user_id -> (start, end)
    state: dict = field(default_factory=dict)

class DragonflyDBStreamCollaboration:
    """
    Real-time collaboration via DragonflyDB streams.

    Stream naming:
    - openhands.tui.session.{session_id}    # Session state
    - openhands.tui.cursor.{user_id}         # Cursor positions
    - openhands.tui.selection.{user_id}      # Selection ranges
    - openhands.tui.broadcast.*              # Broadcast messages
    - openhands.tui.presence.*               # Presence updates
    """

    def __init__(self):
        self.redis = redis.Redis(
            host="localhost",
            port=18000,
            password="dragonfly-password-f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2",
            decode_responses=True,
        )
        self.pubsub = self.redis.pubsub()
        self.sessions: Dict[str, CollaborationSession] = {}
        self.message_handlers: List[Callable] = []

    async def create_session(self, session_id: str) -> CollaborationSession:
        """Create a new collaboration session."""
        session = CollaborationSession(session_id=session_id, users={})
        self.sessions[session_id] = session

        # Initialize stream group
        await self.redis.xgroup_create(
            name=f"openhands.tui.session.{session_id}",
            group_name="openhands-tui",
            id="0",
            mkstream=True,
        )

        return session

    async def join_session(self, session_id: str, user_id: str, user_info: dict):
        """Join an existing session."""
        session = self.sessions.get(session_id)
        if not session:
            raise ValueError(f"Session {session_id} not found")

        # Add user to session
        session.users[user_id] = {
            **user_info,
            "joined_at": datetime.utcnow().isoformat(),
        }

        # Publish presence update
        await self._publish_presence(session_id, user_id, "joined", user_info)

    async def broadcast_cursor(
        self,
        session_id: str,
        user_id: str,
        position: tuple[int, int],
    ):
        """Broadcast cursor position to session."""
        await self.redis.xadd(
            name=f"openhands.tui.cursor.{session_id}",
            fields={
                "type": "cursor",
                "user_id": user_id,
                "line": str(position[0]),
                "col": str(position[1]),
                "timestamp": datetime.utcnow().isoformat(),
            },
        )

    async def broadcast_selection(
        self,
        session_id: str,
        user_id: str,
        start: tuple[int, int],
        end: tuple[int, int],
    ):
        """Broadcast selection range."""
        await self.redis.xadd(
            name=f"openhands.tui.selection.{session_id}",
            fields={
                "type": "selection",
                "user_id": user_id,
                "start_line": str(start[0]),
                "start_col": str(start[1]),
                "end_line": str(end[0]),
                "end_col": str(end[1]),
                "timestamp": datetime.utcnow().isoformat(),
            },
        )

    async def broadcast_state(
        self,
        session_id: str,
        user_id: str,
        state_update: dict,
    ):
        """Broadcast state change."""
        message = {
            "type": "state",
            "user_id": user_id,
            "state": json.dumps(state_update),
            "timestamp": datetime.utcnow().isoformat(),
        }
        await self.redis.xadd(
            name=f"openhands.tui.session.{session_id}",
            fields=message,
        )

    async def subscribe_session(self, session_id: str):
        """Subscribe to all session streams."""
        await self.pubsub.subscribe(
            f"openhands.tui.session.{session_id}",
            f"openhands.tui.cursor.{session_id}",
            f"openhands.tui.selection.{session_id}",
            f"openhands.tui.presence.{session_id}",
        )

    async def listen(self, session_id: str):
        """Listen for collaboration messages."""
        async for message in self.pubsub.listen():
            if message["type"] == "message":
                data = json.loads(message["data"])
                for handler in self.message_handlers:
                    await handler(session_id, data)

    async def get_session_state(self, session_id: str) -> dict:
        """Get current session state from stream."""
        # Read last 100 messages from session stream
        messages = await self.redis.xrevrange(
            name=f"openhands.tui.session.{session_id}",
            count=100,
        )

        state = {"updates": []}
        for msg in messages:
            state["updates"].append({
                "id": msg["id"],
                "type": msg["type"],
                "user_id": msg.get("user_id"),
                "state": json.loads(msg.get("state", "{}")),
                "timestamp": msg.get("timestamp"),
            })

        # Get cursor positions
        cursor_messages = await self.redis.xrevrange(
            name=f"openhands.tui.cursor.{session_id}",
            count=50,
        )
        state["cursors"] = {
            msg["user_id"]: (int(msg["line"]), int(msg["col"]))
            for msg in cursor_messages
            if "user_id" in msg
        }

        # Get selections
        selection_messages = await self.redis.xrevrange(
            name=f"openhands.tui.selection.{session_id}",
            count=50,
        )
        state["selections"] = {
            msg["user_id"]: ((int(msg["start_line"]), int(msg["start_col"])),
                           (int(msg["end_line"]), int(msg["end_col"])))
            for msg in selection_messages
            if "user_id" in msg
        }

        return state

    async def _publish_presence(
        self,
        session_id: str,
        user_id: str,
        action: str,
        user_info: dict,
    ):
        """Publish presence update."""
        await self.redis.xadd(
            name=f"openhands.tui.presence.{session_id}",
            fields={
                "type": "presence",
                "action": action,
                "user_id": user_id,
                "user_info": json.dumps(user_info),
                "timestamp": datetime.utcnow().isoformat(),
            },
        )
```

---

## Rust TUI with CRDT

### 5.1 Rust + Ratatui Architecture

```rust
// src/collab/crdt_state.rs

use serde::{Serialize, Deserialize};
use std::collections::HashMap;
use std::sync::{Arc, RwLock};
use tokio::sync::broadcast;
use std::hash::Hash;

/// CRDT-based collaborative state
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CrdtState {
    // Document state (Yjs-like)
    documents: HashMap<String, YjsDoc>,

    // Presence state
    presence: HashMap<String, Presence>,

    // Vector clocks
    vector_clock: HashMap<String, u64>,

    // Session metadata
    session_id: String,
    created_at: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct YjsDoc {
    pub id: String,
    pub text: LWWRegister<String>,
    pub deletions: GCounter,
    pub insertions: GCounter,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Presence {
    pub user_id: String,
    pub user_name: String,
    pub cursor: Option<Cursor>,
    pub selection: Option<Selection>,
    pub color: String,
    pub last_seen: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Cursor {
    pub line: u32,
    pub col: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Selection {
    pub start_line: u32,
    pub start_col: u32,
    pub end_line: u32,
    pub end_col: u32,
}

/// Last-Writer-Wins Register
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct LWWRegister<T: Clone + PartialEq + Default> {
    value: T,
    timestamp: u64,
    client_id: String,
}

impl<T: Clone + PartialEq + Default> LWWRegister<T> {
    pub fn set(&mut self, value: T, timestamp: u64, client_id: String) {
        if timestamp > self.timestamp {
            self.value = value;
            self.timestamp = timestamp;
            self.client_id = client_id;
        }
    }

    pub fn get(&self) -> &T {
        &self.value
    }
}

/// Grow-only Counter
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct GCounter {
    counts: HashMap<String, u64>,
}

impl GCounter {
    pub fn new() -> Self {
        Self { counts: HashMap::new() }
    }

    pub fn increment(&mut self, client_id: &str) {
        *self.counts.entry(client_id.to_string()).or_insert(0) += 1;
    }

    pub fn value(&self) -> u64 {
        self.counts.values().sum()
    }
}

impl CrdtState {
    pub fn new(session_id: String) -> Self {
        Self {
            documents: HashMap::new(),
            presence: HashMap::new(),
            vector_clock: HashMap::new(),
            session_id,
            created_at: chrono::Utc::now().timestamp() as u64,
        }
    }

    pub fn apply_update(&mut self, update: CrdtUpdate, client_id: &str) {
        let timestamp = update.timestamp;

        // Apply document update
        if let Some(doc_update) = update.document {
            if let Some(doc) = self.documents.get_mut(&doc_update.doc_id) {
                doc.merge(doc_update);
            } else {
                self.documents.insert(doc_update.doc_id.clone(), YjsDoc::from(doc_update));
            }
        }

        // Apply presence update
        if let Some(pres) = update.presence {
            self.presence.insert(pres.user_id.clone(), pres);
        }

        // Update vector clock
        *self.vector_clock.entry(client_id.to_string()).or_insert(0) = timestamp;
    }

    pub fn get_presence(&self) -> Vec<&Presence> {
        self.presence.values().collect()
    }

    pub fn get_document(&self, doc_id: &str) -> Option<&YjsDoc> {
        self.documents.get(doc_id)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CrdtUpdate {
    pub document: Option<YjsDoc>,
    pub presence: Option<Presence>,
    pub timestamp: u64,
    pub client_id: String,
}

impl From<YjsDocUpdate> for YjsDoc {
    fn from(update: YjsDocUpdate) -> Self {
        Self {
            id: update.doc_id,
            text: LWWRegister {
                value: update.text.unwrap_or_default(),
                timestamp: update.timestamp,
                client_id: update.client_id,
            },
            deletions: GCounter::new(),
            insertions: GCounter::new(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct YjsDocUpdate {
    pub doc_id: String,
    pub text: Option<String>,
    pub timestamp: u64,
    pub client_id: String,
}
```

### 5.2 TUI Main Application

```rust
// src/main.rs

use ratatui::{
    layout::{Constraint, Direction, Layout},
    widgets::{Block, Borders, List, Paragraph, Table, Row},
    style::{Style, Color, Modifier},
    Frame, Terminal,
};
use crossterm::{
    event::{self, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, ClearType},
};
use std::io::{self, stdout};
use std::sync::Arc;
use tokio::sync::RwLock;
use crate::collab::crdt_state::CrdtState;
use crate::collaboration::dragonfly_client::DragonflyClient;

struct TUIApp {
    state: Arc<RwLock<CrdtState>>,
    dragonfly: DragonflyClient,
    current_user: String,
    current_tab: usize,
    running: bool,
}

impl TUIApp {
    fn new(state: Arc<RwLock<CrdtState>>, current_user: String) -> Self {
        Self {
            state,
            dragonfly: DragonflyClient::new(),
            current_user,
            current_tab: 0,
            running: true,
        }
    }

    async fn run(&mut self) -> io::Result<()> {
        enable_raw_mode()?;
        let mut stdout = stdout();

        execute!(stdout, event::EnableBracketedPaste)?;
        execute!(stdout, event::EnableMouseCapture)?;

        let mut terminal = Terminal::new(ratatui::backend::CrosstermBackend::new(stdout))?;

        while self.running {
            terminal.draw(|f| self.render(f))?;

            if let Event::Key(key) = event::read()? {
                if key.kind == KeyEventKind::Press {
                    match key.code {
                        KeyCode::Char('q') => self.running = false,
                        KeyCode::Char('1') => self.current_tab = 0,
                        KeyCode::Char('2') => self.current_tab = 1,
                        KeyCode::Char('3') => self.current_tab = 2,
                        KeyCode::Char('4') => self.current_tab = 3,
                        KeyCode::Esc => self.running = false,
                        _ => self.handle_input(key).await?,
                    }
                }
            }
        }

        disable_raw_mode()?;
        execute!(stdout, event::DisableMouseCapture)?;
        Ok(())
    }

    fn render(&self, f: &mut Frame) {
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Length(3),
                Constraint::Min(0),
                Constraint::Length(3),
            ])
            .split(f.size());

        // Header
        let header = Paragraph::new(format!(
            "OpenHands TUI | Session: {} | User: {} | [1]Sessions [2]Memory [3]Workflows [4]Tasks [q]uit",
            self.state.read().unwrap().session_id,
            self.current_user
        ));
        f.render_widget(header, chunks[0]);

        // Main content
        match self.current_tab {
            0 => self.render_sessions(f, chunks[1]),
            1 => self.render_memory(f, chunks[1]),
            2 => self.render_workflows(f, chunks[1]),
            3 => self.render_tasks(f, chunks[1]),
            _ => self.render_sessions(f, chunks[1]),
        }

        // Footer with presence
        let presence = self.state.read().unwrap().get_presence();
        let presence_text: String = presence.iter()
            .map(|p| format!("[{}] ", p.user_name))
            .collect();
        let footer = Paragraph::new(format!("Collaborators: {}", presence_text));
        f.render_widget(footer, chunks[2]);
    }

    fn render_sessions(&self, f: &mut Frame, area: ratatui::layout::Rect) {
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Percentage(30), Constraint::Percentage(70)])
            .split(area);

        // Session list
        let sessions = vec!["main-session", "debug-session", "research-session"];
        let session_list = List::new(sessions)
            .block(Block::default().title("Sessions").borders(Borders::ALL));
        f.render_widget(session_list, chunks[0]);

        // Session details
        let details = Paragraph::new("Select a session to view details");
        f.render_widget(details, chunks[1]);
    }

    fn render_memory(&self, f: &mut Frame, area: ratatui::layout::Rect) {
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Percentage(50), Constraint::Percentage(50)])
            .split(area);

        // Memory domains
        let domains = vec![
            "Episodic (ClickHouse, QuestDB)",
            "Semantic (Weaviate, Qdrant, FAISS)",
            "Procedural (Neo4j, MongoDB)",
            "Working (DragonflyDB, Redis)",
            "Temporal (TimescaleDB)",
            "Meta-Cognition",
        ];
        let domain_list = List::new(domains)
            .block(Block::default().title("Memory Domains").borders(Borders::ALL));
        f.render_widget(domain_list, chunks[0]);

        // Memory details
        let details = Paragraph::new("Select a memory domain to view details");
        f.render_widget(details, chunks[1]);
    }

    fn render_workflows(&self, f: &mut Frame, area: ratatui::layout::Rect) {
        // Workflow list
        let workflows = vec!["Episode Recording", "Concept Learning", "Procedure Discovery"];
        let workflow_list = List::new(workflows)
            .block(Block::default().title("Active Workflows").borders(Borders::ALL));
        f.render_widget(workflow_list, area);
    }

    fn render_tasks(&self, f: &mut Frame, area: ratatui::layout::Rect) {
        // Task board
        let tasks = vec![
            ("TODO", vec!["Research Rust async", "Implement CRDT"]),
            ("IN PROGRESS", vec!["TUI Layout"]),
            ("DONE", vec!["Systemd Services"]),
        ];

        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([
                Constraint::Percentage(33),
                Constraint::Percentage(33),
                Constraint::Percentage(34),
            ])
            .split(area);

        for (i, (title, items)) in tasks.iter().enumerate() {
            let col = List::new(items.iter().map(|s| ListItem::new(s.clone()).style(
                Style::default().fg(Color::White)
            ).collect::<Vec<_>>())
                .block(Block::default().title(title).borders(Borders::ALL));
            f.render_widget(col, chunks[i]);
        }
    }

    async fn handle_input(&mut self, key: event::KeyEvent) -> io::Result<()> {
        match key.code {
            KeyCode::Up => self.move_cursor(0, -1).await?,
            KeyCode::Down => self.move_cursor(0, 1).await?,
            KeyCode::Left => self.move_cursor(-1, 0).await?,
            KeyCode::Right => self.move_cursor(1, 0).await?,
            _ => {}
        }
        Ok(())
    }

    async fn move_cursor(&self, _dx: i32, _dy: i32) -> io::Result<()> {
        // Broadcast cursor position via DragonflyDB
        // self.dragonfly.publish_cursor(self.session_id, self.current_user, position).await
        Ok(())
    }
}

#[tokio::main]
async fn main() -> io::Result<()> {
    let state = Arc::new(RwLock::new(CrdtState::new("main-session".to_string())));
    let mut app = TUIApp::new(state, "user-1".to_string());
    app.run().await
}
```

---

## Workflow Engine

### 6.1 Deterministic Workflows

```python
# openhands/workflow/deterministic.py

from temporalio import workflow, activity
from dataclasses import dataclass
from datetime import timedelta
import json

@dataclass
class EpisodeEvent:
    session_id: str
    action_type: str
    action_input: dict
    action_output: dict
    outcome: str
    duration_ms: float
    timestamp: datetime
    embedding: List[float]
    task_type: str
    domain_context: dict

@workflow.defn
class EpisodeRecordingWorkflow:
    """Record an episode to all time-series backends."""

    @workflow.run
    async def run(self, episode: EpisodeEvent) -> dict:
        # Parallel writes to all time-series backends
        results = await workflow.execute_activity_group(
            write_episodic_to_all_backends,
            episode,
            start_to_close_timeout=timedelta(seconds=10),
        )

        # Emit event to RedPanda
        await workflow.execute_activity(
            emit_episode_event,
            {"episode": episode, "results": results},
            start_to_close_timeout=timedelta(seconds=5),
        )

        return {"status": "recorded", "backends": list(results.keys())}

@activity.defn
async def write_episodic_to_all_backends(episode: EpisodeEvent) -> dict:
    """Write episode to ClickHouse, QuestDB, InfluxDB, TimescaleDB."""
    results = {}

    # ClickHouse
    clickhouse = get_clickhouse_client()
    await clickhouse.execute("""
        INSERT INTO agent_episodes (session_id, action_type, outcome, duration_ms, timestamp)
        VALUES (%s, %s, %s, %s, %s)
    """, [episode.session_id, episode.action_type, episode.outcome,
          episode.duration_ms, episode.timestamp])
    results["clickhouse"] = "written"

    # QuestDB (ILP)
    questdb = get_questdb_client()
    await questdb.write("agent_episodes", {
        "session_id": episode.session_id,
        "action_type": episode.action_type,
        "outcome": episode.outcome,
        "duration_ms": episode.duration_ms,
    }, timestamp_precision="ns")
    results["questdb"] = "written"

    # InfluxDB
    influx = get_influx_client()
    await influx.write([
        {
            "measurement": "agent_actions",
            "tags": {"session_id": episode.session_id, "action_type": episode.action_type},
            "fields": {"duration_ms": episode.duration_ms, "success": 1 if episode.outcome == "success" else 0},
            "time": episode.timestamp,
        }
    ])
    results["influxdb"] = "written"

    # TimescaleDB
    timescale = get_timescale_client()
    await timescale.execute("""
        INSERT INTO agent_episodes
        (session_id, action_type, action_input, action_output, outcome,
         duration_ms, timestamp, embedding, task_type, domain_context)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, [episode.session_id, episode.action_type,
          json.dumps(episode.action_input), json.dumps(episode.action_output),
          episode.outcome, episode.duration_ms, episode.timestamp,
          episode.embedding, episode.task_type, json.dumps(episode.domain_context)])
    results["timescaledb"] = "written"

    return results
```

### 6.2 Non-Deterministic Workflows

```python
# openhands/workflow/non_deterministic.py

@workflow.defn
class StrategyEvolutionWorkflow:
    """Evolve agent strategies based on performance data."""

    @workflow.run
    async def run(self, evolution_request: EvolutionRequest) -> dict:
        # Collect performance data
        performance_data = await workflow.execute_activity(
            collect_performance_data,
            evolution_request,
            start_to_close_timeout=timedelta(seconds=30),
        )

        # Analyze patterns
        patterns = await workflow.execute_activity(
            analyze_performance_patterns,
            performance_data,
            start_to_close_timeout=timedelta(seconds=30),
        )

        # Generate variations
        variations = await workflow.execute_activity(
            generate_strategy_variations,
            {"patterns": patterns, "strategy_id": evolution_request.strategy_id},
            start_to_close_timeout=timedelta(seconds=60),
        )

        # Evaluate (can be A/B tested)
        evaluations = await workflow.execute_activity_group(
            evaluate_strategy_variation,
            variations,
            start_to_close_timeout=timedelta(seconds=120),
        )

        # Select best
        best = self._select_best(evaluations)

        if best.improvement > evolution_request.min_improvement:
            await workflow.execute_activity(
                apply_strategy_evolution,
                {"strategy_id": evolution_request.strategy_id, "variation": best},
                start_to_close_timeout=timedelta(seconds=30),
            )
            return {"evolved": True, "variation": best, "improvement": best.improvement}

        return {"evolved": False, "reason": "Improvement below threshold"}
```

---

## SubAgent System

### 7.1 SubAgent Pool

```python
# openhands/agents/subagent_pool.py

from typing import Dict, List, Optional
from dataclasses import dataclass
from datetime import datetime
import asyncio

@dataclass
class AgentTask:
    id: UUID
    agent_type: str
    task_id: UUID
    context: dict
    status: str
    created_at: datetime
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    result: Optional[dict] = None
    error: Optional[str] = None

class SubAgentPool:
    """Parallel development via specialized subagents."""

    def __init__(self, max_concurrent: int = 16):
        self.max_concurrent = max_concurrent
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.active_tasks: Dict[str, List[AgentTask]] = {}

        self.agents = {
            "code_review": CodeReviewAgent(),
            "test_generator": TestGeneratorAgent(),
            "documentation": DocumentationAgent(),
            "refactor": RefactorAgent(),
            "research": ResearchAgent(search_providers=[
                PerplexityProvider(),
                BraveSearchProvider(),
                JinaProvider(),
                FirecrawlProvider(),
                SerperProvider(),
                TavilyProvider(),
            ]),
            "memory_analyzer": MemoryAnalyzerAgent(),
            "pattern_detector": PatternDetectorAgent(),
            "strategy_optimizer": StrategyOptimizerAgent(),
            "task_manager": TaskManagerAgent(),
            "communication_archivist": CommunicationArchivistAgent(),
        }

    async def dispatch(
        self,
        agent_type: str,
        task_id: UUID,
        context: dict,
    ) -> AgentTask:
        """Dispatch task to subagent with concurrency control."""
        async with self.semaphore:
            agent = self.agents[agent_type]
            task = AgentTask(
                id=UUID(),
                agent_type=agent_type,
                task_id=task_id,
                context=context,
                status="pending",
                created_at=datetime.utcnow(),
            )

            # Run in background
            asyncio.create_task(self._execute_task(task, agent))

            return task

    async def _execute_task(self, task: AgentTask, agent):
        """Execute task and update status."""
        task.status = "running"
        task.started_at = datetime.utcnow()

        try:
            result = await agent.execute(task.context)
            task.result = result
            task.status = "completed"
        except Exception as e:
            task.error = str(e)
            task.status = "failed"
        finally:
            task.completed_at = datetime.utcnow()

    async def dispatch_parallel(
        self,
        tasks: List[AgentDispatchRequest],
    ) -> List[AgentTask]:
        """Dispatch multiple tasks in parallel."""
        return await asyncio.gather(*[
            self.dispatch(req.agent_type, req.task_id, req.context)
            for req in tasks
        ])
```

---

## Infrastructure Services

### 8.1 Complete Service Mapping

| Service | Port | Purpose | Memory Domain |
|---------|------|---------|---------------|
| DragonflyDB | 18000-02 | Cache, working memory | WORKING |
| Redis Cluster | 18010-12 | Fallback cache, real-time state | WORKING |
| PostgreSQL+TimescaleDB | 18030 | Workflow state, temporal patterns, tasks, audit | TEMPORAL + TASKS |
| MongoDB | 18070 | Document procedures, chat history, notes | PROCEDURAL + COMMS |
| Weaviate | 18050 | Semantic memory | SEMANTIC |
| Qdrant | 18054 | Specialized vectors | SEMANTIC |
| Neo4j | 18060-61 | Graph procedures, team relationships | PROCEDURAL + RELATIONSHIPS |
| ClickHouse | 18090 | Analytics, episode storage, collab analytics | EPISODIC + ANALYTICS |
| InfluxDB | 18100 | Metrics storage | EPISODIC |
| QuestDB | 18091 | High-frequency ingestion | EPISODIC |
| RedPanda | 18021-23 | Event backbone | ORCHESTRATION |
| Pulsar | 8080 | Fallback messaging | ORCHESTRATION |
| NATS | 18020 | High-perf messaging | ORCHESTRATION |
| Grafana | 18031 | Dashboards | OBSERVABILITY |
| Prometheus | 9090 | Metrics | OBSERVABILITY |

---

## Deployment Guide

### 9.1 Quick Start

```bash
# Clone and enter directory
cd /adapt/projects/OpenHands

# Run installation script
sudo ./ops/systemd/install.sh --user $USER --data-dir /var/lib/openhands

# Copy and configure environment
sudo cp /etc/openhands/openhands-core.env.template /etc/openhands/openhands-core.env
sudo nano /etc/openhands/openhands-core.env

# Start services
sudo systemctl start openhands-*

# Check status
systemctl status openhands-*

# View logs
journalctl -u openhands-core -f
journalctl -u openhands-monitor -f
```

### 9.2 Service Management

```bash
# Start all services
sudo systemctl start openhands-*

# Stop all services
sudo systemctl stop openhands-*

# Restart a service
sudo systemctl restart openhands-core

# Check status
systemctl status openhands-*

# Enable auto-start
sudo systemctl enable openhands-*

# View logs
journalctl -u openhands-core -f
journalctl -u openhands-tui -f
journalctl -u openhands-monitor -f

# Check health
curl http://localhost:8000/health
curl http://localhost:8080/api/v1/health
```

### 9.3 Monitoring Endpoints

| Endpoint | Port | Purpose |
|----------|------|---------|
| `/health` | 8000 | Core service health |
| `/metrics` | 8000 | Prometheus metrics |
| `/api/v1/health` | 8080 | API health |
| `/api/v1/metrics` | 8080 | API metrics |
| http://localhost:18031 | Grafana | Dashboards |
| http://localhost:8080 | Temporal | Workflow UI |

---

*Technical documentation for TeamADAPT engineers*
*Version 3.0 | January 2026*
