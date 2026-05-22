#!/bin/bash

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║       GroundProbe Monitoring System Setup                ║"
echo "║       Mac / Linux Version                                ║"
echo "║       PT GroundProbe Indonesia                           ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker is not running. Please start Docker Desktop and try again."
  exit 1
fi
echo "✅ Docker is running"
echo ""

echo "🚀 Starting all services..."
docker compose up -d

if [ $? -ne 0 ]; then
  echo "❌ Failed to start services."
  exit 1
fi

echo ""
echo "⏳ Waiting for database schema initialization (60 seconds)..."
sleep 60

# Inject Liquid Glass CSS
echo ""
echo "🎨 Applying GroundProbe Liquid Glass theme..."
if [ -f "zabbix-liquid-glass.css" ]; then
  cat zabbix-liquid-glass.css | docker exec -u root -i groundprobe-zabbix-web \
    sh -c "cat >> /usr/share/zabbix/assets/styles/blue-theme.css"
  echo "✅ Theme applied successfully"
else
  echo "⚠ CSS file not found — theme not applied"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                  ✅ Setup Complete!                      ║"
echo "║                                                          ║"
echo "║   Open your browser: http://localhost:8080               ║"
echo "║   Username : Admin                                       ║"
echo "║   Password : zabbix                                      ║"
echo "║   Support  : support@groundprobe.com                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""