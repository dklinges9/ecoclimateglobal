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
