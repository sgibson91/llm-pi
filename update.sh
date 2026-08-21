#!/usr/bin/env bash
set -euo pipefail

# ponytail: single compose dir, no iteration needed unlike internet-pi
config_file="config.yml"
[[ -f "$config_file" ]] || config_file="example.config.yml"

config_dir=$(yq -r '.config_dir' "$config_file")
config_dir="${config_dir/#\~/$HOME}"

cd "$config_dir"
docker compose pull
docker compose up -d --no-deps
docker system prune --all -f
