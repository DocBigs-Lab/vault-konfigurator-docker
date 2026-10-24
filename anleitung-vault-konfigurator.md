# Anleitung: VAULT Konfigurator via Docker starten

Diese Anleitung erklärt, wie du den **VAULT Konfigurator** (ein Tool zur Konfiguration von USSA Design VAULT Lagertürmen für den 3D-Druck) mithilfe von Docker installierst und ausführst.

---

## Voraussetzungen
1. **Docker & Docker Compose** müssen auf deinem System installiert sein und laufen.
2. Du benötigst die urheberrechtlich geschützten **VAULT STL-Dateien** von USSA Design. Diese sind aus rechtlichen Gründen nicht im Repository enthalten.

---

## Schritt-für-Schritt-Anleitung

### 1. Repository herunterladen (Klonen)
Öffne ein Terminal (Eingabeaufforderung, PowerShell oder Linux-Terminal) und führe folgende Befehle aus, um das Projekt herunterzuladen und in das Verzeichnis zu wechseln:

```bash
git clone https://github.com/DocBigs-Lab/vault-konfigurator-docker.git
cd vault-konfigurator-docker
```
*(Alternativ kannst du das Repository auf GitHub als ZIP-Archiv herunterladen und entpacken).*

### 2. Ordner erstellen und STL-Dateien einfügen
Der Konfigurator benötigt zwei lokale Ordner im selben Verzeichnis:
* `vault`: Für deine gekauften STL-Dateien.
* `do_druku`: Hier speichert das Tool später die fertig konfigurierten Druckdateien ab.

Erstelle die Ordner mit diesem Befehl:
```bash
mkdir -p vault do_druku
```
**Wichtig:** Kopiere jetzt alle deine gekauften **VAULT STL-Dateien** direkt in den neu erstellten Ordner `vault`.

### 3. Docker-Container starten (Lokal auf dem PC)
Wenn du den Konfigurator direkt auf dem PC ausführst, auf dem du auch den Browser nutzt, starte Docker Compose mit folgendem Befehl:

```bash
docker compose up -d --build
```
Der Parameter `-d` sorgt dafür, dass die Container im Hintergrund (detached) laufen.

### 4. Benutzeroberfläche öffnen
Sobald der Container erfolgreich gestartet ist, öffne deinen Webbrowser und rufe folgende Adresse auf:

👉 **http://localhost:8766/konfigurator/index.html**

*Hinweis zum Sprachwechsel:* Die Oberfläche unterstützt Deutsch, Englisch und Polnisch. Sie erkennt deine Sprache automatisch, alternativ kannst du sie oben links in der Ecke manuell umstellen.

---

## Erweiterte Nutzung: Betrieb auf einem NAS oder Heimserver

Falls der Docker-Container auf einem separaten Gerät im Netzwerk läuft (z. B. Synology NAS, Unraid oder Linux-Server), ist standardmäßig kein Zugriff erlaubt. Verwende in diesem Fall statt `docker compose` den folgenden manuellen `docker run`-Befehl:

```bash
docker run -it --rm -p 8766:8766 \
  -e VAULT_BIND=0.0.0.0 \
  -e VAULT_HOSTS=DEINE_SERVER_IP:8766 \
  -v vault_data:/root/VAULT \
  -v "$(pwd)/vault:/root/VAULT/vault:ro" \
  vault-konfigurator
```

### Wichtige Parameter dabei:
* Ersetze `DEINE_SERVER_IP` mit der echten IP-Adresse deines Servers im Netzwerk (z. B. `192.168.1.50`).
* **Sicherheitshinweis:** Durch `VAULT_BIND=0.0.0.0` kann jeder in deinem lokalen Netzwerk ohne Login auf den Konfigurator zugreifen. Das ist für den Heimgebrauch absolut in Ordnung, aber schalte diesen Port niemals im Router nach außen (Internet) frei!

---

## Auf eine neue Version aktualisieren

Der VAULT Konfigurator wird häufig aktualisiert. Neue Versionen findest du auf der [Release-Seite](https://github.com/rawel2/Vault-Konfigurator-wydania/releases).

Das Docker-Image lädt die neueste Version beim Bauen herunter. Docker speichert diesen Schritt im Cache, deshalb holt `docker compose up -d --build` allein **keine** neue Version. Zum Aktualisieren führst du im Projektordner diese Befehle aus:

```bash
git pull
docker compose build --pull --no-cache
docker compose up -d
```

* `git pull` holt Änderungen an diesem Docker-Setup.
* `--no-cache` sorgt dafür, dass Docker das neueste Release des Konfigurators neu herunterlädt.
* `--pull` aktualisiert zusätzlich das Python-Basis-Image.

So prüfst du, welche Version läuft:
```bash
docker compose logs vault | grep Konfigurator
```

Deine STL-Dateien im Ordner `vault` und die Druckdateien in `do_druku` bleiben erhalten.

*NAS/Server mit `docker run`:* Baue das Image mit `docker build --pull --no-cache -t vault-konfigurator .`, stoppe den alten Container und starte ihn mit dem `docker run`-Befehl von oben neu.

---

## Container stoppen
Wenn du das Tool via Docker Compose gestartet hast und es beenden möchtest, nutze folgenden Befehl im Projektordner:

```bash
docker compose down
```