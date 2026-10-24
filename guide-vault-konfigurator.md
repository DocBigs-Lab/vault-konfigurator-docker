# Guide: Running the VAULT Konfigurator with Docker

This guide explains how to install and run the **VAULT Konfigurator** (a tool for configuring USSA Design VAULT storage towers for 3D printing) using Docker.

> [!IMPORTANT]
> **There is now an official Docker setup.** Since release 1.1.20 the VAULT Konfigurator includes its own Docker files (folder `docker/` in [the release package](https://github.com/rawel2/Vault-Konfigurator-wydania/releases/latest)), maintained by the developer. It keeps your settings and caches across updates and also explains Synology. **Please use that one.** This guide is no longer updated. How to switch over is described in the [README](README.md).

---

## Requirements
1. **Docker & Docker Compose** must be installed and running on your system.
2. You need the copyrighted **VAULT STL files** from USSA Design. For legal reasons they are not included in the repository.

---

## Step-by-step guide

### 1. Download the repository (clone)
Open a terminal (Command Prompt, PowerShell or a Linux terminal) and run the following commands to download the project and change into its directory:

```bash
git clone https://github.com/DocBigs-Lab/vault-konfigurator-docker.git
cd vault-konfigurator-docker
```
*(Alternatively, you can download the repository from GitHub as a ZIP archive and extract it.)*

### 2. Create the folders and add the STL files
The configurator needs two local folders in the same directory:
* `vault`: for your purchased STL files.
* `do_druku`: this is where the tool saves the finished, configured print files.

Create the folders with this command:
```bash
mkdir -p vault do_druku
```
**Important:** Now copy all your purchased **VAULT STL files** directly into the newly created `vault` folder.

### 3. Start the Docker container (locally on your PC)
If you run the configurator on the same PC you use the browser on, start Docker Compose with the following command:

```bash
docker compose up -d --build
```
The `-d` flag makes the containers run in the background (detached).

### 4. Open the user interface
Once the container has started successfully, open your web browser and go to:

👉 **http://localhost:8766/konfigurator/index.html**

*Note on language:* The interface supports German, English and Polish. It detects your language automatically; you can also switch it manually in the top-left corner.

---

## Advanced use: running on a NAS or home server

If the Docker container runs on a separate device on your network (e.g. a Synology NAS, Unraid or a Linux server), access via that device's IP address is not allowed by default. Add the address to `VAULT_HOSTS` in `docker-compose.yml`:

```yaml
      - VAULT_HOSTS=YOUR_SERVER_IP:8766
```

Then start the container as in step 3 with `docker compose up -d --build` and open `http://YOUR_SERVER_IP:8766/konfigurator/index.html` in your browser.

**Without Docker Compose:** If your system has no Compose, build the image yourself and start it with `docker run`:

```bash
docker build -t vault-konfigurator .
docker run -d --name vault-konfigurator --restart unless-stopped -p 8766:8766 \
  -e VAULT_BIND=0.0.0.0 \
  -e VAULT_HOSTS=YOUR_SERVER_IP:8766 \
  -v "$(pwd)/vault:/root/VAULT/vault" \
  -v "$(pwd)/do_druku:/root/VAULT/do_druku" \
  vault-konfigurator
```

### Important parameters:
* Replace `YOUR_SERVER_IP` with the actual IP address of your server on the network (e.g. `192.168.1.50`).
* **Security note:** With `VAULT_BIND=0.0.0.0`, anyone on your local network can access the configurator without logging in. That is perfectly fine for home use, but never forward this port to the outside (internet) in your router!

---

## Updating to a new version

The VAULT Konfigurator is updated frequently. You can find new versions on the [releases page](https://github.com/rawel2/Vault-Konfigurator-wydania/releases).

The Docker image downloads the latest version while it is being built. Docker caches this step, so `docker compose up -d --build` alone does **not** fetch a new version. To update, run these commands in the project folder:

```bash
docker compose build --pull --no-cache
docker compose up -d
```

* `--no-cache` forces Docker to download the latest configurator release again.
* `--pull` also updates the Python base image.

To check which version is running:
```bash
docker compose logs vault | grep Konfigurator
```

Your STL files in the `vault` folder and your print files in `do_druku` are kept.

*Updating the Docker setup itself (optional):* If you got the repository with `git clone`, run `git pull` before the build to fetch changes to the Dockerfile, compose file and guides. If you downloaded it as a ZIP, the folder is not a Git repository and `git pull` reports `fatal: not a git repository`. In that case, just skip this step. It is not needed to get a new configurator version.

*Without Docker Compose:* build the image with `docker build --pull --no-cache -t vault-konfigurator .`, remove the old container with `docker rm -f vault-konfigurator` and start it again with the `docker run` command above.

---

## Stopping the container
If you started the tool with Docker Compose and want to stop it, run the following command in the project folder:

```bash
docker compose down
```
