#!/usr/bin/env bash
# =========================================================================================
#  docker-entrypoint.sh — startet den VAULT Konfigurator HTTP-Server im Container.
#  Läuft immer headless (--bez-przegladarki, kein Browser im Docker zu öffnen).
# =========================================================================================
set -euo pipefail

PROG="${PROG:-/root/VAULT/konfigurator}"
cd "$PROG"

echo "============================================================"
echo "   VAULT Konfigurator — Docker ($(cat "$PROG/wersja.txt" 2>/dev/null || echo '?'))"
echo "   Bind-Host: ${VAULT_BIND:-0.0.0.0}   Port: 8766"
echo "   Sprache: in der App wählbar (automatisch / Polski / English / Deutsch)"
echo "   Oberfläche: http://localhost:8766/konfigurator/index.html"
echo "============================================================"

# numpy vorhandenstellen (Fallback, wie beim Installer)
if ! python3 -c "import numpy" >/dev/null 2>&1; then
    echo "  numpy fehlt — installiere..."
    pip install --no-cache-dir numpy >/dev/null 2>&1 || true
fi

# run.sh wählt .venv/python, stellt numpy sicher, dann exec'd serwer.py.
# --bez-przegladarki: keinen Browser öffnen (kein GUI im Container).
exec "$PROG/run.sh" --bez-przegladarki
