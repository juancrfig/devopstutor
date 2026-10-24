# Silent Backup

## TICKET
Nightly backups report success, but restore tests find empty archives. Source data is in `/srv/shop-data`.
1. Inspect the two recent archives without extracting them. Compare their contents to the source tree and record findings in `~/backup-report.txt`.
2. Ensure the backup script exits nonzero and never prints success after a required operation fails. Test an invalid source path and record its exit status.
3. Repair the archive to include intended data, including `customer notes.txt`. Verify that file appears in the archive.
4. Restore only `customer notes.txt` to `/tmp/restore` and prove it matches the source exactly.
5. Schedule the backup every minute under your account with output appended to `~/backup-cron.log`. Diagnose and fix the initial scheduler-only failure without hiding errors; prove two successful scheduled runs.

## COMMANDS
bash chmod echo $? set tar cmp diff crontab env export command -v vim cat ls grep

## QUESTIONS
1. Why do exit statuses matter in automation? Explain what `set -e`, `set -u`,
   and `set -o pipefail` change, including one situation where `set -e` does
   not behave as a simple "stop on any error" switch.
2. A script works in an interactive terminal but fails under cron. Why can
   their environments differ, and what other common differences can cause
   this kind of failure?
3. What does exporting a shell variable change? Which variables does a child
   process inherit, and why can a privileged command run without variables
   that were present in your shell?
4. Why should expansions usually be written as `"$var"`? Describe how word
   splitting and pathname expansion can change an unquoted filename that
   contains spaces or `*`.

## ANSWERS
