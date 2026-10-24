<p align="center">
  <a href="https://docbigs-lab.de">
    <img src="https://raw.githubusercontent.com/DocBigs-Lab/SML-Meter-Gateway/main/docs/assets/docbigslab_logo.svg" alt="DocBigsLab Logo" width="200">
  </a>
</p>
<p align="center">
  <a href="https://docbigs-lab.de">https://docbigs-lab.de</a>
</p>



# VAULT Konfigurator — Docker

Docker image for the [VAULT Konfigurator](https://github.com/rawel2/Vault-Konfigurator-wydania) — a local web UI for configuring USSA Design VAULT storage towers.

## Step-by-step guide

- 🇬🇧 [English guide](guide-vault-konfigurator.md)
- 🇩🇪 [Deutsche Anleitung](anleitung-vault-konfigurator.md)

## Quick start

```bash
docker build -t vault-konfigurator .
docker run -it --rm -p 8766:8766 -v vault_data:/root/VAULT vault-konfigurator
```

Open **http://localhost:8766/konfigurator/index.html** in your browser.

## docker-compose

```bash
mkdir -p vault do_druku
docker compose up -d --build
docker compose down
```

## Updating

The VAULT Konfigurator gets frequent releases. The image downloads the latest release **at build time**, but Docker caches that step, so a plain `--build` keeps the old version. To update, rebuild without cache:

```bash
git pull                                   # get changes to this Docker setup
docker compose build --pull --no-cache     # fetch the latest configurator release
docker compose up -d
docker compose logs vault | grep Konfigurator   # shows the running version
```

Without compose: `docker build --pull --no-cache -t vault-konfigurator .`

Your STL files in `./vault` and exports in `./do_druku` are bind mounts and survive the update.

Releases: https://github.com/rawel2/Vault-Konfigurator-wydania/releases

## STL files

The VAULT STL files (purchased from [USSA Design](https://www.ussadesign.com/pages/vault)) go into the mounted volume:

```bash
docker run -it --rm -p 8766:8766 \
  -v vault_data:/root/VAULT \
  -v "$HOME/vault_stls:/root/VAULT/vault:ro" \
  vault-konfigurator
```

Or point to them in the web UI under "File library".

## Language

The interface supports **Polski**, **English**, and **Deutsch**.

- Automatic: detected from browser language
- Manual: dropdown in the top-left corner

## VAULT_BIND / VAULT_HOSTS

Since version 1.1.10, the configurator supports two environment variables:

| Variable | Default | Purpose |
|----------|---------|---------|
| `VAULT_BIND` | `127.0.0.1` | Server bind address. Set to `0.0.0.0` for Docker. |
| `VAULT_HOSTS` | empty | Additional allowed hosts (e.g. for NAS/LAN access) |

```bash
docker run -it --rm -p 8766:8766 \
  -e VAULT_BIND=0.0.0.0 \
  -e VAULT_HOSTS=192.168.1.50:8766 \
  -v vault_data:/root/VAULT \
  vault-konfigurator
```

> ⚠️ With `VAULT_BIND=0.0.0.0` anyone on the network can access the configurator — no login. Fine for home use, not for public hosts.

## Supported printers

Includes support for: Bambu Lab H2S/X2D, Elegoo Centauri Carbon, **LightMake L4** (4-color, 354×370×386 mm), Anycubic Kobra S1 Max, Snapmaker U1.

## Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Image definition — pulls latest release from GitHub |
| `docker-entrypoint.sh` | Starts the server headless in the container |
| `docker-compose.yml` | Compose config with ports and volumes |
| `guide-vault-konfigurator.md` | Step-by-step guide (English) |
| `anleitung-vault-konfigurator.md` | Step-by-step guide (German) |

## License

The VAULT Konfigurator is developed by [rawel2](https://github.com/rawel2) under the [MIT license](https://github.com/rawel2/Vault-Konfigurator-wydania/blob/main/LICENSE). STL files are copyrighted by [USSA Design](https://www.ussadesign.com/pages/vault) and are not included here.

This Docker image is a community project — not affiliated with rawel2 or USSA Design.

The Docker setup in this repository (Dockerfile, scripts, guides) is released under the [MIT license](LICENSE).
