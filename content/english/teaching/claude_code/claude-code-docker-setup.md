# Setting Up a Docker Sandbox for Claude Code
### A Beginner-Friendly Guide for macOS

---
_Authors: David Klinges + Claude Code_ 

## What is a Container, and Why Use One?

A **container** is like a self-contained mini-computer that runs inside your real computer. It has its own file system, its own software, and its own environment — completely separate from your Mac. Think of it like a snow globe: everything inside is isolated, and nothing leaks out.

For Claude Code, this matters because:

- **Safety** — Claude Code can only read and write files inside the container's designated folder. Your documents, photos, and other files on your Mac are invisible to it.
- **Cleanliness** — Any packages or dependencies Claude Code installs stay inside the container and don't clutter your Mac.
- **Control** — You can delete the entire container and start fresh at any time, without affecting your Mac.

**Docker** is the tool that creates and manages these containers. It's the industry standard and free to use.

---

## Prerequisites

- A Mac running macOS 12 (Monterey) or later
- A Claude Pro or Max subscription (from [claude.ai](https://claude.ai)), **or** an Anthropic API key (from [console.anthropic.com](https://console.anthropic.com))
- Basic familiarity with Terminal (you don't need to be an expert)

> **Subscription vs. API key:** This guide uses subscription-based OAuth authentication (Pro/Max), which is the recommended approach for most users. If you use an API key instead, see the FAQ at the end — but be aware that having `ANTHROPIC_API_KEY` set as an environment variable will override subscription auth and cause login errors.

---

## Part 1 — Install Homebrew (if not already installed)

Homebrew is a package manager for macOS that makes installing software from the Terminal easy. If you already have it, skip to Part 2.

Open **Terminal** (press `Cmd + Space`, type "Terminal", press Enter) and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the on-screen prompts. When it's done, verify the installation:

```bash
brew --version
# Expected output: Homebrew 4.x.x
```

---

## Part 2 — Install Docker Desktop

Docker Desktop is the application that runs Docker on your Mac. It includes a graphical interface and the underlying Docker engine.

### 2.1 Install via Homebrew

```bash
brew install --cask docker
```

This downloads and installs Docker Desktop. It may take a few minutes.

### 2.2 Launch Docker Desktop

```bash
open -a Docker
```

A Docker whale icon will appear in your Mac's menu bar (top right). **Wait until it stops animating** — this means the Docker engine has fully started. This typically takes 30–60 seconds.

### 2.3 Verify Docker is running

```bash
docker info
```

If you see several lines of system information, Docker is running correctly. If you see a socket error, Docker hasn't finished starting yet — wait another 30 seconds and try again.

### 2.4 Troubleshooting: Docker fails to launch

If Docker Desktop hangs or shows error `-1712`, try these steps in order:

```bash
# Step 1: Force quit all Docker processes and relaunch
sudo pkill -f Docker
open -a Docker

# Step 2: If still failing, reset Docker's runtime state
# (This does NOT delete your images or project files)
sudo pkill -f Docker
rm -rf ~/Library/Containers/com.docker.docker/Data/vms
rm -rf ~/Library/Group\ Containers/group.com.docker/pki
open -a Docker

# Step 3: If still failing, reinstall Docker Desktop
sudo pkill -f Docker
brew uninstall --cask docker
brew install --cask docker
open -a Docker
```

---

## Part 3 — Authenticate Claude Code on Your Mac

Claude Code must be authenticated on your Mac **before** you use it inside the container. The container inherits your credentials via the mounted `.claude` files — it does not authenticate independently.

### 3.1 Using Anthropic Subscription vs API

As of May 2026, most users of Claude Code for data science and research purposes will find it more cost-effective to use a subscription rather than the API (this may change based upon amount of usage and how Anthropic's business model changes in the coming months / years). Given this, we're going to set up the container to use a subscription rather than API key-- but you can do either.

If you have an `ANTHROPIC_API_KEY` environment variable set on your Mac, Claude Code will use it instead of your subscription, which causes OAuth login errors. Check whether it's set:

```bash
echo $ANTHROPIC_API_KEY
# If this prints a key, you need to remove it (see below)
# If this prints nothing, you're good — skip to 3.2
```

If a key is printed, search for it across all shell config files and remove it:

```bash
grep -r "ANTHROPIC_API_KEY" ~/.zshrc ~/.bash_profile ~/.bashrc ~/.profile ~/.zprofile ~/.zshenv 2>/dev/null
```

Open whichever file contains it with `nano`, delete the `export ANTHROPIC_API_KEY=...` line, save, then reload:

```bash
source ~/.zshrc   # or whichever file you edited
```

> **Note:** The key may be in a less obvious file like `~/.zshenv` (loaded for every shell session, even non-interactive ones) rather than `~/.zshrc`. Check all the files listed in the `grep` command above if it keeps reappearing.

### 3.2 Log in to Claude Code on your Mac

Install Claude Code on your Mac if you haven't already:

```bash
npm install -g @anthropic-ai/claude-code
```

Then launch it and log in:

```bash
claude
/login
```

If your browser doesn't open automatically, press `c` to copy the OAuth URL, then paste it into your browser manually. Complete the login flow with your Claude Pro or Max account.

### 3.3 Verify credentials were written

After a successful login, Claude Code writes your credentials to two locations on your Mac:

```bash
# Check that oauthAccount exists in .claude.json
grep -c "oauthAccount" ~/.claude.json
# Expected output: 1 (meaning the key was found)
```

If this returns `1`, your credentials are in place and will be available inside the container automatically via the mounts configured in Part 7.

---

## Part 4 — Create the Sandbox Folder Structure

Let's create a dedicated folder on your Mac that acts as the sandbox. This is the **only** folder Claude Code will be able to access.

```bash
# Create the sandbox directory and a workspace subfolder inside it
mkdir -p ~/claude-sandbox/workspace

# claude-sandbox/          ← the root of your sandbox
# └── workspace/           ← where your project files live (Claude Code works here)
```

> **Note on paths:** Docker's `-v` mount flag can be unreliable with the `~` shorthand. Throughout this guide, any time you reference your sandbox or home directory in `start.sh`, always use the full absolute path. For example, use `/Users/yourname/claude-sandbox/workspace` rather than `~/claude-sandbox/workspace`. You can find your exact home directory path by running `echo $HOME` in Terminal.

---

## Part 5 — Create the Dockerfile

A **Dockerfile** is a plain text recipe that tells Docker how to build your container — what software to install, what user to create, and how to set it up. It has **no file extension**; it is named exactly `Dockerfile` with a capital D.

```bash
# Navigate into the sandbox directory
cd ~/claude-sandbox

# Create the Dockerfile
nano Dockerfile
```

Paste in the following content exactly:

```dockerfile
# ~/claude-sandbox/Dockerfile

# Use Node.js 20 (slim variant = smaller image, fewer unnecessary packages)
# Always pin to a specific version — never use :latest in sandboxes
FROM node:20-slim

RUN echo "APT::Acquire::Retries \"5\";" > /etc/apt/apt.conf.d/80-retries

# Install essential system tools Claude Code may need
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ripgrep \
    nano \
    python3 \
    python3-pip \
    gnupg \
    && rm -rf /var/lib/apt/lists/*
    # ↑ Deleting the apt cache keeps the image size small

# Install R from the official CRAN Debian repository
# The key must be fetched from a keyserver by fingerprint — no .asc URL exists for Debian
RUN gpg --keyserver keyserver.ubuntu.com \
        --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' \
    && gpg --armor --export '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' \
        > /etc/apt/trusted.gpg.d/cran_debian_key.asc \
    && echo "deb http://cloud.r-project.org/bin/linux/debian bookworm-cran40/" \
        > /etc/apt/sources.list.d/r-project.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends r-base \
    && rm -rf /var/lib/apt/lists/*

# Install R development dependencies and compilers
# These are required for building R packages from source
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    pkg-config \
    cmake \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libopenblas-dev \
    liblapack-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libgit2-dev \
    libuv1-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages from CRAN
# This installs all user-required packages identified in the current container
RUN Rscript -e 'install.packages(c(
  "AER", "DBI", "Deriv", "Formula", "MatrixModels", "R6", "RColorBrewer",
  "RPostgreSQL", "RPostgres", "RSQLite", "Rcpp", "RcppArmadillo", "RcppEigen",
  "Rdpack", "S7", "SparseM", "TTR", "XML", "abind", "arrow", "askpass",
  "assertthat", "backports", "base64enc", "bit", "bit64", "blob", "brew",
  "brio", "broom", "bslib", "cachem", "callr", "car", "carData", "cellranger",
  "chron", "classInt", "cli", "clipr", "coda", "colorspace", "cols4all",
  "conflicted", "covr", "cowplot", "cpp11", "crayon", "crosstalk", "curl",
  "data.table", "dbplyr", "deldir", "desc", "dichromat", "diffobj", "digest",
  "doBy", "dplyr", "dtplyr", "e1071", "egg", "evaluate", "farver", "fastmap",
  "feather", "fontawesome", "forcats", "forecast", "fracdiff", "fs", "gargle",
  "generics", "geometries", "ggplot2", "glue", "goftest", "googledrive",
  "googlesheets4", "gridExtra", "gtable", "haven", "hexbin", "highr", "hms",
  "htmltools", "htmlwidgets", "httr", "ids", "isoband", "jquerylib", "jsonify",
  "jsonlite", "knitr", "labeling", "later", "lazyeval", "leaflet.providers",
  "lifecycle", "lme4", "lmtest", "logger", "lubridate", "magrittr", "mapproj",
  "maps", "memoise", "microbenchmark", "mime", "minqa", "mockr", "modelr",
  "mondate", "nanoarrow", "nloptr", "numDeriv", "openssl", "otel", "pbapply",
  "pbkrtest", "pillar", "pkgbuild", "pkgconfig", "pkgload", "plyr", "png",
  "polyclip", "praise", "prettyunits", "processx", "progress", "promises",
  "proxy", "ps", "purrr", "quadprog", "quantmod", "quantreg", "ragg",
  "rapidjsonr", "rappdirs", "rbibutils", "readr", "readxl", "reformulas",
  "rematch", "rematch2", "reprex", "rex", "rlang", "rmarkdown", "rprojroot",
  "rstudioapi", "rvest", "sandwich", "sass", "scales", "selectr", "sfheaders",
  "sp", "spacesXYZ", "spatstat.data", "spatstat.sparse", "spatstat.univar",
  "spatstat.utils", "stinepack", "stringdist", "stringi", "stringr",
  "strucchange", "svglite", "sys", "systemfonts", "tensor", "testthat",
  "textshaping", "tibble", "tidyr", "tidyselect", "tidyverse", "timeDate",
  "timeSeries", "timechange", "tinyplot", "tinytex", "tis", "tseries", "tzdb",
  "urca", "utf8", "uuid", "vctrs", "viridisLite", "vroom", "waldo", "withr",
  "wk", "xfun", "xml2", "xts", "yaml", "yyjsonr", "zoo"
), repos="https://cloud.r-project.org/")' && rm -rf /tmp/Rtmp*

# Create a non-root user called "claudeuser"
# Running as root inside a container is a security risk:
# if something goes wrong, a root process has more ability to cause damage
RUN useradd -ms /bin/bash claudeuser

# Install Claude Code globally inside the container
RUN npm install -g @anthropic-ai/claude-code

# Set the working directory — this is where the terminal starts inside the container
WORKDIR /workspace

# Switch from root to our safer non-root user for all operations
USER claudeuser

# When the container starts, open a bash terminal
CMD ["/bin/bash"]
```

Save and exit: `Ctrl + X`, then `Y`, then `Enter`.


<br>


You can also download this file here:

<a href="/teaching/claude_code/Dockerfile" download="Dockerfile">
  <button type="button">Download Dockerfile here</button>
</a>

<br>
<br>

---

## Part 6 — Build the Docker Image

A **Docker image** is the built version of your Dockerfile — like a snapshot of the container before it starts running. You build it once, then launch containers from it as many times as you want.

```bash
# Make sure you are in the claude-sandbox directory
cd ~/claude-sandbox

# Build the image and tag it with the name "claude-sandbox"
# The dot (.) at the end tells Docker to look for the Dockerfile in the current directory
docker build -t claude-sandbox .
```

This will take a few minutes the first time (it downloads Node.js and installs packages). You'll see output lines for each step in the build process.

### Troubleshooting: build fails with network timeouts

If the build fails mid-way with `connection timed out` or `Unable to connect` errors against `deb.debian.org`, you are likely on a **VPN**. Docker's network access during builds is frequently blocked or throttled by VPNs. Disconnect your VPN, then clean up and retry:

```bash
docker builder prune -f
docker build -t claude-sandbox .
```

### What to expect when the build finishes

Newer versions of Docker do **not** print `Successfully tagged claude-sandbox:latest` — this line was removed in recent releases. The build is still successful without it. To confirm your image was created:

```bash
docker images
```

You should see `claude-sandbox` listed with a recent timestamp.

### A note on the Docker Desktop GUI

After building, you will **not** see anything running in the Docker Desktop GUI. This is expected — `docker build` only creates an image (the recipe). No container runs until you explicitly launch one. Think of it this way:

| Term | Analogy |
|---|---|
| `Dockerfile` | A recipe |
| Image (after `docker build`) | A meal kit, ready to cook |
| Container (after `docker run`) | The actual cooked meal, now running |

---

## Part 7 — Create a Launch Script

Instead of typing a long command every time, we'll create a reusable script to launch the container.

> **Note on bash comments:** In bash, `#` comments must appear on their own line. They cannot be placed at the end of a line or within a multi-line command (after a `\` continuation). For this reason, all comments in this script are placed as a block at the top.

```bash
nano ~/claude-sandbox/start.sh
```

Paste in the following, replacing `/Users/yourname` with your actual home directory path (run `echo $HOME` if unsure):

```bash
#!/bin/bash

# Docker launch script for Claude Code sandbox
#
# -v workspace       Mounts only the workspace — no other Mac files are visible
# -v ~/.claude       Mounts Claude Code memory/config directory from your Mac (read/write)
#                    This preserves memory across sessions and between container and Mac
# -v ~/.claude.json  Mounts Claude Code configuration file from your Mac (read/write)
# -e                 Passes your API key as an env variable — never hardcode secrets. 
# 		     This is currently not used in this file. 
#		     If you want to use an API key, then paste the below line
#		     in the docker run -it call. Then, you will need to add 
#		     `export ANTHROPIC_API_KEY="sk-ant-insert-api-key....."` in your ~/.zshrc 
# -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" \

# --memory           Limits RAM to 4GB to prevent runaway processes freezing your Mac
# --cpus             Limits CPU to 4 cores maximum
# --cap-drop/add     Drops all Linux capabilities, restores only the minimum needed
# --security-opt     Blocks privilege escalation inside the container
# docker rm -f       Removes any leftover container from a previous session before starting
#                    (2>/dev/null suppresses the error if no previous container exists)

docker rm -f claude-sandbox 2>/dev/null

docker run -it \
  --name claude-sandbox \
  -v /Users/David/Documents/GitHub/claude-sandbox/workspace:/workspace \
  -v /Users/David/.claude:/home/claudeuser/.claude \
  -v /Users/David/.claude.json:/home/claudeuser/.claude.json \
  --memory="4g" \
  --cpus="4.0" \
  --cap-drop=ALL \
  --cap-add=CHOWN \
  --cap-add=SETUID \
  --cap-add=SETGID \
  --security-opt no-new-privileges:true \
  claude-sandbox
```

Save and exit: `Ctrl + X`, then `Y`, then `Enter`.

Make the script executable:

```bash
chmod +x ~/claude-sandbox/start.sh
```


<br>

You can also download this file here:  

<a href="/teaching/claude_code/start.sh" download="start.sh">
  <button type="button">Download start.sh here</button>
</a>



### Why we mount `.claude` and `.claude.json`

Claude Code stores two separate things in your Mac's home directory:

- **`~/.claude/`** — a directory containing memory, project history, and backups
- **`~/.claude.json`** — a single configuration file that sits *outside* that directory, directly in your home folder

Both must be mounted separately. Mounting only `~/.claude/` will cause a warning on startup because `.claude.json` won't be found. By mounting both, your full Claude Code configuration and memory are available inside the container, and anything Claude Code learns or saves during a session is written back to your Mac automatically.

### Why we use absolute paths

Docker's `-v` flag can be unreliable with the `~` shorthand. Always use full absolute paths like `/Users/yourname/...` to ensure mounts work correctly.

---

## Part 8 — Launch and Use the Container

### 8.1 Start the container

```bash
~/claude-sandbox/start.sh
```

Your terminal prompt will change to something like `claudeuser@abc123:/workspace$` — this means you are now **inside the container**. Your Mac's files are not accessible from here (except the mounted folders). The container will also now appear in the Docker Desktop GUI.

### 8.2 Start Claude Code

```bash
claude
```

Claude Code will launch and you can begin working. Any files it creates or modifies will appear in your `workspace` folder on your Mac.

### 8.3 Exit the container

```bash
exit
```

This returns you to your normal Mac terminal.

---

## Part 9 — Daily Workflow Reference

```bash
# ── Starting a session ───────────────────────────────────────────────────────

~/claude-sandbox/start.sh          # Launch the container (auto-cleans up previous session)
claude                             # Start Claude Code (run this inside the container)


# ── Joining the same session from a new terminal window ───────────────────────────────────────────────────────

docker exec -it claude-sandbox bash # this allows you to have parallel windows into the same container session. 
				    # E.g., if you want to have two Claude Code agent sessions running simultaneously

# ── Stopping cleanly ─────────────────────────────────────────────────────────

exit                               # Exit the container shell
docker stop claude-sandbox         # Stop the container. This still keeps packages installed in 
				   # the container available, but will terminate a claude code session
                                   

# ── Resuming a container you didn't remove ───────────────────────────────────

docker start -ai claude-sandbox


# ── Checking what exists ─────────────────────────────────────────────────────

docker ps                          # Show active (running) containers
docker ps -a                       # Show all containers including stopped ones
docker images                      # Show all built images


# ── Starting completely fresh ────────────────────────────────────────────────

docker rm claude-sandbox           # Remove the container 
				   # (DELETES packages installed while in the session, but your workspace and .claude files are safe on your Mac)
docker rm -f claude-sandbox        # Force-remove the container
docker rmi claude-sandbox          # Delete the image
cd ~/claude-sandbox
docker build -t claude-sandbox .   # Rebuild from scratch
```

---

## Troubleshooting Authentication

Authentication is the most common source of issues when running Claude Code in a container. Here are the most likely problems and their fixes.

### "Invalid OAuth Request: Unknown scope: user:mcp_server"

This error in the browser during `/login` means `ANTHROPIC_API_KEY` is set somewhere on your Mac and is overriding subscription auth. Claude Code detects the key, switches to API mode, and requests OAuth scopes your subscription doesn't support.

Fix: remove `ANTHROPIC_API_KEY` from your environment. It may be hiding in a less obvious file like `~/.zshenv` rather than `~/.zshrc`:

```bash
grep -r "ANTHROPIC_API_KEY" ~/.zshrc ~/.bash_profile ~/.bashrc ~/.profile ~/.zprofile ~/.zshenv 2>/dev/null
```

Delete the line from whichever file contains it, reload your shell, close all terminal windows, and open a fresh one. Verify it's gone:

```bash
echo $ANTHROPIC_API_KEY
# Expected: (blank)
```

### Claude Code inside the container isn't authenticated despite credentials being present

The correct approach is to **authenticate on your Mac first**, then launch the container. The container inherits credentials via the mounted `.claude` files — it does not log in independently.

Check auth status inside the container:

```bash
# Inside the container
claude
/status
```

If it shows unauthenticated despite credentials being present, run:

```bash
/logout
/login
```

Paste the URL into your Mac browser and complete the flow. Even if the browser redirect doesn't return cleanly to the container, Claude Code will detect the completed authentication and update the credential files via the mounts.

### How to verify credentials are correctly written

After a successful `/login` on your Mac, check that the `oauthAccount` block exists:

```bash
grep -c "oauthAccount" ~/.claude.json
# Expected output: 1
```

The credentials are stored as an `oauthAccount` block in `~/.claude.json` containing your email address and tokens beginning with `sk-ant-oat01-` (access token) and `sk-ant-ort01-` (refresh token). You do not need to manually edit these files — they are written and managed entirely by Claude Code.

---

## Security Summary

| Measure | What it does |
|---|---|
| Only `/workspace` is mounted for project files | Claude Code cannot see any other files on your Mac |
| Non-root user inside container | Reduces damage if something goes wrong |
| `--cap-drop=ALL` | Removes unnecessary Linux system permissions |
| `--security-opt no-new-privileges` | Prevents privilege escalation |
| OAuth credentials via mounted files | Credentials are never hardcoded into the image |
| No `ANTHROPIC_API_KEY` in environment | Prevents API key from overriding subscription auth |
| `--memory` and `--cpus` limits | Prevents the container from overloading your Mac |

**The golden rule:** your `workspace` folder is the blast radius for project files. If Claude Code does something unexpected, it cannot affect anything on your Mac outside the three mounted paths.

## Set Claude Code permissions

Claude manages permissions (what it is allowed to do and not do) according to one or more `.json` files made available to it. It creates these files automatically based upon your responses to some of its questions (e.g., when it asks "can I do this? yes/no"). You can also set these permissions yourself, and use your settings as a template upon which Claude will build upon.   

**NOTE: think of these permissions as asking Claude very nicely what it can and can't do. It is technically feasible for Claude to ignore your permissions, if it really wants to. It's just highly unlikely to ignore your permissions.** 

Below are two template `settings.json` files that you can add into your project. One of these files should go into a directory called `.claude`, which you can create by running:

```bash
mkdir .claude
```
If it doesn't already exist (hint: on Macs, directories that start with "." are hidden from display by default. You can display these directories with the shortcut Shift + Cmd + .


Here's a `settings.json` file that is pretty restrictive (eg it can read files, but must ask you if it can edit or create files). This might be more safe to have on your machine's file system.

<a href="/teaching/claude_code/restrictive_settings/settings.json" download="settings.json">
  <button type="button">Download settings.json with LIMITED permissions</button>
</a>

<br>
<br>

Here's a `settings.json` file that is far more permissive (eg it can edit and create files without asking you first). I'd recommend using something like this inside of a Docker Container, but not outside of it:

<a href="/teaching/claude_code/permissive_settings/settings.json" download="settings.json">
  <button type="button">Download settings.json with LOTS OF permissions</button>
</a>


---

<br>
<br>

## Frequently Asked Questions

**Q: Do I need to rebuild the image every time I use it?**
No. You only rebuild (`docker build`) when you change the `Dockerfile`. For normal use, just run `start.sh`.

**Q: Will my files in `workspace/` survive if I delete the container?**
Yes. The `workspace/` folder, `~/.claude/`, and `~/.claude.json` all live on your Mac, not inside the container. Deleting the container never affects them.

**Q: How do I update Claude Code inside the container?**
Update the following line in your `Dockerfile` and rebuild:
```dockerfile
RUN npm install -g @anthropic-ai/claude-code@latest
```

**Q: Can I open multiple terminal sessions into the same running container?**
Yes:
```bash
docker exec -it claude-sandbox bash
```

**Q: The Docker Desktop GUI shows no containers after I build — is something wrong?**
No, this is expected. The GUI only shows containers (running instances), not images. Run `start.sh` to launch a container and it will appear in the GUI.

**Q: I get a "container name already in use" conflict error when running start.sh — what do I do?**
The `start.sh` in this guide handles this automatically with `docker rm -f claude-sandbox` at the top. If you have an older version of the script, either update it or run this manually before launching:
```bash
docker rm claude-sandbox && ~/claude-sandbox/start.sh
```

**Q: Claude Code warns that `.claude.json` is missing when I start it inside the container.**
This means only `~/.claude/` is mounted but not `~/.claude.json` — they are two separate things. Add this line to your `docker run` command in `start.sh`:
```bash
-v /Users/yourname/.claude.json:/home/claudeuser/.claude.json \
```

**Q: I want to use an API key instead of a subscription. How do I do that?**
Add the `-e` flag back to `start.sh` to pass the key into the container as an environment variable:
```bash
-e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" \
```
Then set the key in your `~/.zshrc` and reload your shell. Note that if this variable is set, Claude Code will always use it instead of subscription OAuth credentials — so if you later want to switch back to subscription auth, you must remove it from your environment entirely (see Part 3).

**Q: How do I check which authentication method Claude Code is currently using?**
Run `/status` from inside Claude Code:
```bash
claude
/status
```
This shows whether you're authenticated via OAuth (subscription) or API key, and which account is active.


_This file was generated by Claude Code and edited by David Klinges. Last update: 1 May 2026_ 
