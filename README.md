# Quake 3 Dedicated Server (Docker)

This repository provides a Dockerized **Quake 3 dedicated server via ioquake3** suitable for running multiplayer Quake 3 servers in a clean, reproducible way.  
The image is designed for **headless operation**, supports bind-mounted mods and configuration, and handles legacy runtime dependencies required by Quake 3.

---

## Features

- Runs the **Quake 3 dedicated server** (`ioq3ded.x86_64`)
- Optionally downloads and extracts mod archives from URLs at startup
- Automated build & push via GitHub Actions

## Docker Compose Example
```yaml
services:
  Quake 3:
    image: lancommander/quake3:latest
    container_name: quake3-server

    # Quake 3 uses UDP
    ports:
      - "27960:27960/udp"

    # Bind mounts so files appear on the host
    volumes:
      - ./config:/config

    environment:
      # Optional: download mods/maps at startup
      # EXTRA_MOD_URLS: >
      #   https://example.com/maps.zip,
      #   https://example.com/gameplay.pk3

      # Optional overrides
      # SERVER_ARGS: '+set dedicated 2 +set sv_allowDownload 1 +set sv_dlURL \"\" +set com_hunkmegs 64'

    # Ensure container restarts if the server crashes or host reboots
    restart: unless-stopped
```

---

## Directory Layout (Host)

```text
.
└── config/
    ├── Server/            # Base ioquake3 install
    │   └── baseq3/        # Quake 3 game files base directory
    ├── Overlay/           # Files to overlay on game directory (optional)
    │   └── baseq3/        # Counter-Strike: Source overlay directory
    │       ├── maps/      # Custom maps
    │       └── ...        # Any other files you want to overlay
    ├── Merged/            # Overlayfs merged view (auto-created)
    ├── .overlay-work/     # Overlayfs work directory (auto-created)
    ├── Scripts/
        └── Hooks/         # Script files in this directory get automatically executed if registered to a hook
```
Both directories **must be writable** by Docker.

---

## Game Files
You will need to copy the file `pak0.pk3` from your retail copy of Quake 3 into the `/config/Server/baseq3` directory. The server will not run without this file.

---

## Configuration
An `autoexec.cfg` file can also be created for adjusting server settings.
Example:
```
// ==============================
// Quake III Arena Dedicated Server
// Basic FFA with Map Rotation
// ==============================

// --- Server Basics ---
seta sv_hostname "My Quake 3 Server"
seta sv_maxclients "16"
seta sv_privateClients "0"
seta sv_pure "1"
seta sv_floodProtect "1"

// --- Network ---
seta sv_maxRate "25000"
seta sv_minRate "3000"
seta sv_timeout "200"

// --- Logging ---
seta g_log "games.log"
seta g_logSync "1"

// --- Gameplay ---
seta g_gametype "0"        // 0 = Free For All
seta timelimit "15"
seta fraglimit "30"
seta g_quadfactor "3"
seta g_weaponrespawn "5"
seta g_inactivity "300"
seta g_forcerespawn "20"

// --- Voting ---
seta g_allowVote "1"
seta g_voteFlags "0"

// --- Message of the Day ---
seta g_motd "Welcome to My Quake 3 Server"

// ==============================
// Map Rotation
// ==============================

set m1 "map q3dm1;  set nextmap vstr m2"
set m2 "map q3dm2;  set nextmap vstr m3"
set m3 "map q3dm3;  set nextmap vstr m4"
set m4 "map q3dm7;  set nextmap vstr m5"
set m5 "map q3dm17; set nextmap vstr m1"

// Start the rotation
vstr m1
```
All gameplay rules, cvars, maps, and RCON settings should live here.

## Extra Mod Downloads
Archives provided via `EXTRA_MOD_URLS` are extracted into `/config/Overlay` before startup.

---

## Environment Variables

| Variable | Description | Default |
|--------|-------------|---------|
| `EXTRA_MOD_URLS` | URLs to download and extract into `/config` at startup | *(empty)* |
| `SERVER_ARGS` | Additional Quake 3 command-line arguments (advanced) | *(empty)* |

### `EXTRA_MOD_URLS`

A list of URLs separated by **commas**, **spaces**, or **newlines**.

Examples:

```bash
EXTRA_MOD_URLS="https://example.com/maps.zip,https://example.com/mod.pk3"
```
Archives are extracted into /config/Overlay. Single files are copied as-is.

---

## Running the Server
### Basic run (recommended)
```bash
mkdir -p config

docker run --rm -it \
  -p 27960:27960/udp \
  -v "$(pwd)/config:/config" \
  lancommander/quake3:latest
```
### With automatic mod downloads
docker run --rm -it \
  -p 27960:27960/udp \
  -v "$(pwd)/config:/config" \
  -e EXTRA_MOD_URLS="https://example.com/modpack.zip" \
  lancommander/quake3:latest

## Ports
- **UDP 27960** – default Quake 3 server port

## License
ioquake3 is distributed under its own license.
This repository contains only Docker build logic and helper scripts licensed under MIT.