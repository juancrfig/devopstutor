#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# The lab boots systemd as PID 1, so services and scheduled jobs are real.
# The container runs detached; your shell joins it with `docker exec`, and the
# container is removed when that shell exits, so every session starts fresh.
name="devops-lab-$$"
active_ticket=
if [[ -f .gym-active ]]; then
  IFS= read -r active_ticket < .gym-active || true
fi

docker build -t gym/devops-lab .

# --privileged: systemd needs it in a container, and setup.sh mounts small
# dedicated filesystems at runtime (disk-bloat, storage). Throwaway lab, so the
# broad grant is acceptable.
docker run -d --rm --name "$name" --privileged --hostname devops-lab \
  --tmpfs /run --tmpfs /run/lock gym/devops-lab >/dev/null
trap 'docker rm -f "$name" >/dev/null 2>&1 || true' EXIT

# Wait for boot. "degraded" (some unit failed) still counts as booted: some
# tickets ship a broken service on purpose.
# The first seconds fail with "Failed to connect to bus" until systemd
# opens its socket, so retry for up to a minute.
state=unknown
for _ in $(seq 1 60); do
  state=$(docker exec "$name" systemctl is-system-running --wait 2>/dev/null || true)
  case "$state" in running|degraded) break ;; esac
  sleep 1
done
case "$state" in
  running|degraded) ;;
  *) echo "lab did not boot (systemd state: ${state:-unknown})" >&2; exit 1 ;;
esac

# Start the expensive fixtures only for their ticket; systemd units stay disabled
# in the image so every unrelated session remains quiet from its first boot.
if [[ "$active_ticket" == "09-resources/01-slow-box" ]]; then
  docker exec "$name" systemctl start report-builder.service thumbnailer.service
fi

docker exec -it -u juanes -w /home/juanes -e HOME=/home/juanes \
  -e TERM="${TERM:-xterm}" "$name" bash
