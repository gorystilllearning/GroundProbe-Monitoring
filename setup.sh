#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   GroundProbe Monitoring System — Installer v2.0             ║
# ║   PT GroundProbe Indonesia                                   ║
# ╚══════════════════════════════════════════════════════════════╝

# ── ANSI Colors ────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}✔${NC}  $1"; }
fail() { echo -e "  ${RED}✘${NC}  $1"; }
info() { echo -e "  ${CYAN}→${NC}  $1"; }
warn() { echo -e "  ${YELLOW}!${NC}  $1"; }
step() { echo -e "\n${BOLD}${BLUE}[$1]${NC} $2"; }

# ── EMBEDDED LOGO (base64) ─────────────────────────────────────
# Untuk mengganti logo:
#   1. Siapkan file logo.png (PNG transparan, 220x60px disarankan)
#   2. Jalankan: base64 -w 0 logo.png
#   3. Paste hasilnya menggantikan teks di bawah ini (di antara tanda kutip)
LOGO_BASE64=""
# ──────────────────────────────────────────────────────────────

# ── HEADER ────────────────────────────────────────────────────
clear
echo -e "${BOLD}${BLUE}"
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║                                                          ║"
echo "  ║       GroundProbe Monitoring System                      ║"
echo "  ║       Automated Installer  v2.0                          ║"
echo "  ║       PT GroundProbe Indonesia                           ║"
echo "  ║                                                          ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  Target  : ${CYAN}Zabbix 6.4${NC} + Liquid Glass Theme + Company Branding"
echo -e "  Access  : ${CYAN}http://localhost:8080${NC}"
echo ""

# ── PRE-FLIGHT CHECKS ─────────────────────────────────────────
step "1/5" "Pre-flight checks"

# Docker daemon
if ! docker info > /dev/null 2>&1; then
  fail "Docker is not running"
  echo ""
  echo -e "  ${YELLOW}→ Please start Docker Desktop and re-run this installer.${NC}"
  exit 1
fi
ok "Docker is running"

# Docker Compose
if ! docker compose version > /dev/null 2>&1; then
  fail "Docker Compose not found (requires Docker Desktop v2+)"
  exit 1
fi
ok "Docker Compose available ($(docker compose version --short))"

# docker-compose.yml present
if [ ! -f "docker-compose.yml" ]; then
  fail "docker-compose.yml not found — run this script from the repo root folder"
  exit 1
fi
ok "docker-compose.yml found"

# Port 8080 availability
if lsof -i:8080 > /dev/null 2>&1; then
  warn "Port 8080 is already in use — Zabbix web may not start correctly"
else
  ok "Port 8080 is free"
fi

# CSS theme file
if [ -f "zabbix-liquid-glass.css" ]; then
  ok "Theme CSS found"
else
  warn "zabbix-liquid-glass.css not found — theme will not be applied"
fi

# ── START SERVICES ────────────────────────────────────────────
step "2/5" "Starting Docker services"
docker compose up -d 2>&1 | while IFS= read -r line; do
  echo -e "  ${CYAN}│${NC}  $line"
done

if [ ${PIPESTATUS[0]} -ne 0 ]; then
  fail "Failed to start services — check docker-compose.yml"
  exit 1
fi
ok "All containers started"

# ── WAIT WITH COUNTDOWN ───────────────────────────────────────
step "3/5" "Waiting for database initialization"
echo -ne "  ${CYAN}→${NC}  Please wait "
for i in $(seq 60 -1 1); do
  echo -ne "${BOLD}${i}s${NC}  \r  ${CYAN}→${NC}  Please wait "
  sleep 1
done
echo -e "\n"
ok "Database should be ready"

# ── APPLY THEME ───────────────────────────────────────────────
step "4/5" "Applying Liquid Glass theme"

if [ -f "zabbix-liquid-glass.css" ]; then
  cat zabbix-liquid-glass.css | docker exec -u root -i groundprobe-zabbix-web \
    sh -c "cat >> /usr/share/zabbix/assets/styles/blue-theme.css"
  if [ $? -eq 0 ]; then
    ok "Theme injected successfully"
  else
    fail "Theme injection failed — container may still be starting, retry manually:"
    warn "cat zabbix-liquid-glass.css | docker exec -u root -i groundprobe-zabbix-web sh -c \"cat >> /usr/share/zabbix/assets/styles/blue-theme.css\""
  fi
else
  warn "Skipped — CSS file missing"
fi

# ── APPLY LOGO ────────────────────────────────────────────────
step "5/5" "Applying company branding (logo)"

LOGO_APPLIED=false

# Priority 1: embedded base64 logo
if [ -n "$LOGO_BASE64" ]; then
  echo "$LOGO_BASE64" | base64 -d > /tmp/company-logo.png 2>/dev/null
  if [ $? -eq 0 ]; then
    docker cp /tmp/company-logo.png groundprobe-zabbix-web:/usr/share/zabbix/assets/img/company-logo.png
    rm -f /tmp/company-logo.png
    ok "Logo applied (embedded)"
    LOGO_APPLIED=true
  else
    warn "Failed to decode embedded logo — check LOGO_BASE64 value"
  fi
fi

# Priority 2: logo.png file in repo folder
if [ "$LOGO_APPLIED" = false ] && [ -f "logo.png" ]; then
  docker cp logo.png groundprobe-zabbix-web:/usr/share/zabbix/assets/img/company-logo.png
  ok "Logo applied (from logo.png file)"
  LOGO_APPLIED=true
fi

if [ "$LOGO_APPLIED" = false ]; then
  warn "No logo found — Zabbix default logo will be shown"
  info "To add logo later: docker cp logo.png groundprobe-zabbix-web:/usr/share/zabbix/assets/img/company-logo.png"
fi

# ── DONE ──────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}"
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║                  ✅  Installation Complete!              ║"
echo "  ╠══════════════════════════════════════════════════════════╣"
echo -e "  ║  ${NC}${CYAN}URL      :${NC}${BOLD}${GREEN}  http://localhost:8080                          ${BOLD}${GREEN}║"
echo -e "  ║  ${NC}${CYAN}Username :${NC}${BOLD}${GREEN}  Admin  (capital A)                             ${BOLD}${GREEN}║"
echo -e "  ║  ${NC}${CYAN}Password :${NC}${BOLD}${GREEN}  zabbix                                         ${BOLD}${GREEN}║"
echo -e "  ║  ${NC}${CYAN}Support  :${NC}${BOLD}${GREEN}  support@groundprobe.com                        ${BOLD}${GREEN}║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
