#!/bin/bash
set -e

# ── ANSI Color codes ────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

clear
echo -e "${BOLD}${BLUE}"
echo "  +===========================================================+"
echo "  |                                                           |"
echo "  |       GroundProbe Monitoring System                       |"
echo "  |       Automated Installer  v2.0                           |"
echo "  |       PT GroundProbe Indonesia                            |"
echo "  |                                                           |"
echo "  +===========================================================+"
echo -e "${NC}"
echo "  Target  : Zabbix 6.4 + Liquid Glass Theme (ghcr.io Image)"
echo "  Access  : http://localhost:8080"
echo ""

# ── PRE-FLIGHT CHECKS ───────────────────────────────────────
echo -e "${BOLD}${BLUE}[1/4]${NC} Pre-flight checks"
echo ""

if ! command -v docker &> /dev/null; then
    echo -e "  ${RED}[X]${NC} Docker is not installed"
    exit 1
fi
if ! docker info > /dev/null 2>&1; then
    echo -e "  ${RED}[X]${NC} Docker is not running. Please start the Docker daemon."
    exit 1
fi
echo -e "  ${GREEN}[OK]${NC} Docker is running"

if ! docker compose version > /dev/null 2>&1; then
    echo -e "  ${RED}[X]${NC} Docker Compose not found"
    exit 1
fi
echo -e "  ${GREEN}[OK]${NC} Docker Compose available"

if [ ! -f "docker-compose.yml" ]; then
    echo -e "  ${RED}[X]${NC} docker-compose.yml not found in the current directory"
    exit 1
fi
echo -e "  ${GREEN}[OK]${NC} docker-compose.yml found"
echo ""

# ── AUTHENTICATION ──────────────────────────────────────────
echo -e "${BOLD}${BLUE}[2/4]${NC} GitHub Packages Authentication"
echo ""
echo "Please enter your GitHub Personal Access Token (PAT)"
echo "to authenticate and pull the private Docker image."
read -p "GitHub PAT: " GH_TOKEN

if [ -z "$GH_TOKEN" ]; then
    echo -e "  ${RED}[X]${NC} Token cannot be empty!"
    exit 1
fi

if ! echo "$GH_TOKEN" | docker login ghcr.io -u gorystilllearning --password-stdin > /dev/null 2>&1; then
    echo -e "  ${RED}[X]${NC} Login failed. Please check your token."
    exit 1
fi
echo -e "  ${GREEN}[OK]${NC} Successfully authenticated with ghcr.io"
echo ""

# ── START SERVICES ──────────────────────────────────────────
echo -e "${BOLD}${BLUE}[3/4]${NC} Starting Docker services"
echo ""
if ! docker compose up -d; then
    echo ""
    echo -e "  ${RED}[X]${NC} Failed to start services"
    exit 1
fi
echo ""
echo -e "  ${GREEN}[OK]${NC} All containers started"

# ── WAIT WITH COUNTDOWN ─────────────────────────────────────
echo ""
echo -e "${BOLD}${BLUE}[4/4]${NC} Waiting for database initialization"
echo ""
echo -n "  ->  Please wait 30 seconds "
for i in {1..30}; do
    sleep 1
    echo -n "."
done
echo -e "  ${GREEN}[OK]${NC} System is ready"
echo ""

# ── DONE ────────────────────────────────────────────────────
echo -e "${BOLD}${GREEN}"
echo "  +===========================================================+"
echo "  |              Installation Complete!                       |"
echo "  +===========================================================+"
echo "  |  URL      :  http://localhost:8080                        |"
echo "  |  Username :  Admin  (capital A)                           |"
echo "  |  Password :  zabbix                                       |"
echo "  |  Support  :  support@groundprobe.com                      |"
echo "  +===========================================================+"
echo -e "${NC}"
