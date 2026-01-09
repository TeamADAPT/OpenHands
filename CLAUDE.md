# CLAUDE.md

This file provides guidance for Claude Code when working with this codebase.

## Project Overview

**OpenHands** is an AI-driven development platform that enables AI agents to autonomously write, fix, and enhance software code. It provides multiple interfaces: CLI, local GUI, and cloud/enterprise deployments.

## Tech Stack

- **Backend**: Python 3.12, FastAPI, Poetry, LiteLLM (LLM orchestration)
- **Frontend**: React 19, TypeScript, HeroUI, TailwindCSS 4.x, Vite
- **Database**: PostgreSQL via SQLAlchemy
- **Runtime**: Docker (for sandbox execution)
- **Testing**: pytest, Playwright, Vitest

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `openhands/` | Core Python backend (agents, server, runtime, integrations) |
| `frontend/` | React web UI (v1) |
| `openhands-ui/` | Shared UI component library (v2) |
| `evaluation/` | Benchmarking & evaluation suites (30+ benchmarks) |
| `tests/` | Unit and e2e tests |
| `containers/` | Docker container definitions |

## Development Commands

```bash
# Initial setup
make build              # Install all dependencies
make setup-config       # Configure LLM settings

# Running locally
make run                # Start both backend and frontend
make start-backend      # Backend only
make start-frontend     # Frontend only

# Testing
poetry run pytest ./tests/unit/test_*.py
npm run test            # Frontend tests

# Code quality
make format             # Format code (ruff, prettier)
make lint               # Run linters
```

## Configuration

- **Main config**: `config.template.toml` - LLM settings, runtime, sandbox, browser env
- **Python**: `pyproject.toml`, `poetry.lock`
- **Frontend**: `frontend/package.json`, `frontend/tsconfig.json`

## Architecture Overview

```
Agent → Action → Runtime → Observation → State Update → (loop)
         ↓
    EventStream ←→ Frontend
```

**Key components**:
- `openhands/agenthub/`: Agent implementations (CodeActAgent, BrowsingAgent, etc.)
- `openhands/server/`: FastAPI backend server
- `openhands/runtime/`: Code execution environments (Docker sandbox)
- `openhands/integrations/`: GitHub, GitLab, Jira, Slack, etc.

## Code Style

- **Python**: ruff for formatting/linting, mypy for type checking
- **Frontend**: ESLint, Prettier, TypeScript strict mode
- Follow patterns in existing code (readability over clever tricks)

## Important Notes

1. **Docker is used for sandbox/runtime environments** - not for development deployment
2. **No venv required** - use system Python with Poetry
3. **LLM configuration is critical** - set up API keys in config before running agents
4. **Backend runs on port 3000**, frontend on port 5173 (Vite default)
5. **Socket.IO** handles real-time communication between frontend and backend
