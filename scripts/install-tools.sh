#!/usr/bin/env bash
set -euo pipefail
if [[ $(id -u) != 0 ]]; then
    echo 'Run as root: sudo bash scripts/install-tools.sh' >&2
    exit 1
fi
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    binutils-aarch64-linux-gnu qemu-user make gdb-multiarch git ca-certificates
rm -rf /var/lib/apt/lists/*
