#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

docker build -t gym/devops-lab .
# --privileged grants CAP_SYS_ADMIN so setup.sh can mount the dedicated 88M
# tmpfs at /var/appdata at runtime — the disk-bloat ticket needs a near-full
# filesystem, and the default host-backed overlay would otherwise read ~6%.
# Throwaway --rm lab container, so the broad grant is acceptable.
exec docker run -it --rm --privileged --hostname devops-lab gym/devops-lab
