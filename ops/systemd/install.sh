#!/bin/bash
#
# OpenHands Systemd Services Installation Script
# ===============================================
# Installs all OpenHands systemd services with auto-restart and persistence.
#
# Usage: sudo ./install.sh [--user <username>] [--data-dir <path>]
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
USER="${USER:-openhands}"
DATA_DIR="${DATA_DIR:-/var/lib/openhands}"
LOG_DIR="${LOG_DIR:-/var/log/openhands}"
RUN_DIR="${RUN_DIR:-/run/openhands}"
CONFIG_DIR="${CONFIG_DIR:-/etc/openhands}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            USER="$2"
            shift 2
            ;;
        --data-dir)
            DATA_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--user <username>] [--data-dir <path>]"
            echo ""
            echo "Options:"
            echo "  --user      User to run services as (default: openhands)"
            echo "  --data-dir  Data directory (default: /var/lib/openhands)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  OpenHands Systemd Services Installer${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="${SCRIPT_DIR}"

# Create user if needed
if ! id "${USER}" &>/dev/null; then
    echo -e "${YELLOW}Creating user: ${USER}${NC}"
    useradd --system \
        --home-dir "${DATA_DIR}" \
        --shell /usr/sbin/nologin \
        --comment "OpenHands Service Account" \
        "${USER}"
fi

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p "${DATA_DIR}"
mkdir -p "${LOG_DIR}"
mkdir -p "${RUN_DIR}"
mkdir -p "${CONFIG_DIR}"
mkdir -p "${DATA_DIR}/core"
mkdir -p "${DATA_DIR}/tui"
mkdir -p "${DATA_DIR}/ws"
mkdir -p "${DATA_DIR}/sync"
mkdir -p "${DATA_DIR}/monitor"
mkdir -p "${DATA_DIR}/api"
mkdir -p "${LOG_DIR}/tui"
mkdir -p "${LOG_DIR}/ws"
mkdir -p "${LOG_DIR}/sync"
mkdir -p "${LOG_DIR}/monitor"
mkdir -p "${LOG_DIR}/api"

# Set permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chown -R "${USER}:${USER}" "${DATA_DIR}"
chown -R "${USER}:${USER}" "${LOG_DIR}"
chown -R "${USER}:${USER}" "${RUN_DIR}"
chown -R "${USER}:${USER}" "${CONFIG_DIR}"
chmod 755 "${DATA_DIR}"
chmod 755 "${LOG_DIR}"
chmod 755 "${RUN_DIR}"
chmod 755 "${CONFIG_DIR}"

# Install systemd units
echo -e "${YELLOW}Installing systemd units...${NC}"
for service in "${SYSTEMD_DIR}"/*.service; do
    if [[ -f "${service}" ]]; then
        service_name=$(basename "${service}")
        cp "${service}" "/etc/systemd/system/${service_name}"
        echo -e "  ${GREEN}Installed: ${service_name}${NC}"
    fi
done

# Reload systemd
echo -e "${YELLOW}Reloading systemd daemon...${NC}"
systemctl daemon-reload

# Enable services (but don't start yet)
echo -e "${YELLOW}Enabling services...${NC}"
systemctl enable openhands-core.service
systemctl enable openhands-tui.service
systemctl enable openhands-ws.service
systemctl enable openhands-sync.service
systemctl enable openhands-monitor.service
systemctl enable openhands-api.service

# Create environment template
echo -e "${YELLOW}Creating environment template...${NC}"
cat > "${CONFIG_DIR}/openhands-core.env.template" << 'EOF'
# OpenHands Core Environment Template
# Copy to openhands-core.env and fill in values

# Database Connections
POSTGRES_HOST=localhost
POSTGRES_PORT=18030
POSTGRES_USER=postgres_admin_user
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

DRAGONFLY_HOST=localhost
DRAGONFLY_PORT=18000
DRAGONFLY_PASSWORD=dragonfly-password-f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2

MONGODB_HOST=localhost
MONGODB_PORT=18070
MONGODB_USER=admin
MONGODB_PASSWORD=${MONGODB_PASSWORD}

# LLM Providers
GROQ_API_KEY=${GROQ_API_KEY}
MINIMAX_M2_API_KEY=${MiniMax_M2_CODE_PLAN_API_KEY}
MOONSHOT_API_KEY=${MOONSHOT_CR_CODING_AI_API_KEY}
Z_AI_API_KEY=${Z_AI_API_KEY}
HUGGING_FACE_API_KEY=${HUGGING_FACE_API_KEY}

# Web Search
PERPLEXITY_API_KEY=${PERPLEXITY_API_KEY}
BRAVE_SEARCH_API_KEY=${BRAVE_SEARCH_API_KEY}
JINA_API_KEY=${JINA_API_KEY}
FIRECRAWL_API_KEY=${FIRECRAWL_API_KEY}
SERPER_API_KEY=${SERPER_API_KEY}
TAVILY_API_KEY=${TAVILY_CR_API_KEY}

# Collaboration
SLACK_BOT_TOKEN=${SLACK_BOT_TOKEN}
JIRA_BASE_URL=https://levelup2x.atlassian.net/jira
CONFLUENCE_BASE_URL=https://levelup2x.atlassian.net/wiki
GITHUB_ORG=adaptnova
GITHUB_APP_ID=${ADAPTDEV-APP_APP_ID}

# Observability
LANGSMITH_API_KEY=${LANGSMITH_API_KEY}
EOF

chown "${USER}:${USER}" "${CONFIG_DIR}/openhands-core.env.template"
chmod 640 "${CONFIG_DIR}/openhands-core.env.template"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Copy environment templates and fill in values:"
echo "   cp ${CONFIG_DIR}/openhands-core.env.template ${CONFIG_DIR}/openhands-core.env"
echo "   nano ${CONFIG_DIR}/openhands-core.env"
echo ""
echo "2. Start services:"
echo "   sudo systemctl start openhands-core"
echo "   sudo systemctl start openhands-tui"
echo "   sudo systemctl start openhands-ws"
echo "   sudo systemctl start openhands-sync"
echo "   sudo systemctl start openhands-monitor"
echo "   sudo systemctl start openhands-api"
echo ""
echo "3. Check status:"
echo "   systemctl status openhands-*"
echo "   journalctl -u openhands-core -f"
echo ""
echo "4. View logs:"
echo "   journalctl -u openhands-* -f"
echo "   journalctl -u openhands-monitor -f"
echo ""
