# =========================================================================================
#  VAULT Konfigurator — Docker-Image
#  Quelle: rawel2/Vault-Konfigurator-wydania (Release: vault-konfigurator.zip)
#  App:    Python-HTTP-Server (serwer.py) auf Port 8766, Weboberfläche in index.html.
#
#  Build:  docker build -t vault-konfigurator .
#  Run:    docker run -it --rm -p 8766:8766 -v vault_data:/root/VAULT vault-konfigurator
#          → öffne http://localhost:8766/konfigurator/index.html
# =========================================================================================
FROM python:3.11-slim

LABEL maintainer="Gedockert aus rawel2/Vault-Konfigurator-wydania"
LABEL description="VAULT Konfigurator (USSA Design) Speicher-Turm-Konfigurator — Weboberfläche auf :8766"

# ── System-Abhängigkeiten: curl zum Holt des Releases ─────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        zenity \
    && rm -rf /var/lib/apt/lists/*

# numpy braucht nur bei Quell-Build Header; die Wheel läuft auf slim ohne weiteres
ENV PYTHONUNBUFFERED=1 \
    CEL=/root/VAULT \
    PROG=/root/VAULT/konfigurator \
    VAULT_BIND=0.0.0.0 \
    VAULT_HOSTS=

# ── Arbeitsverzeichnisse ──────────────────────────────────────────────────────
RUN mkdir -p "$CEL" "$PROG" "$CEL/vault" "$CEL/do_druku"
WORKDIR "$CEL"

# ── Neuestes Release herunterladen und in $PROG entpacken ─────────────────────
ARG ZIP_URL=https://github.com/rawel2/Vault-Konfigurator-wydania/releases/latest/download/vault-konfigurator.zip
RUN curl -fsSL -o /tmp/vault.zip "${ZIP_URL}" \
    && python3 -c 'import zipfile,sys; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])' \
        /tmp/vault.zip /tmp/vault_pliki \
    && cp -R /tmp/vault_pliki/. "$PROG/" \
    && rm -f /tmp/vault.zip && rm -rf /tmp/vault_pliki \
    && chmod +x "$PROG/run.sh" "$PROG/install.sh" \
    && echo "Version: $(cat "$PROG/wersja.txt")"

# ── numpy vorinstallieren (entspricht run.sh --przygotuj) ─────────────────────
RUN "$PROG/run.sh" --przygotuj || pip install --no-cache-dir numpy

# ── Entrypoint ────────────────────────────────────────────────────────────────
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# ── Persistenz: STL-Bibliothek, Ausgabe und Einstellungen (literale Pfade — VOLUME
#    erweitert keine Shell-Variablen, daher die aufgelösten Orte fest codieren) ──
VOLUME ["/root/VAULT/vault", "/root/VAULT/do_druku"]
EXPOSE 8766
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -fsS http://127.0.0.1:8766/konfigurator/index.html >/dev/null || exit 1
