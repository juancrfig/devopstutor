# Silent Backup

## TICKET
The nightly shop backup has been reported as healthy for weeks, but a restore
check found the archives empty. The job runs from your account, and the data is
in `/srv/shop-data`.

1. Inspect the existing archives without extracting them. There are exactly
   two recent archives; compare their contents with the source tree and record
   your findings in `~/backup-report.txt`.
2. Make the backup script fail loudly: a failed operation must produce a
   non-zero exit status and no success message. Run it once with a deliberately
   invalid source path and record the exit status in your report.
3. Repair the script so it archives the intended data, including
   `customer notes.txt`. Inspect the new archive and verify the space-containing
   filename is present.
4. Restore just `customer notes.txt` into `/tmp/restore`, then prove it is
   identical to the original.
5. Schedule the backup every minute in your own account, with output appended
   to `~/backup-cron.log`. It will fail when first run by the scheduler. Find
   the cause, correct it without hiding errors, and prove two successful
   scheduled runs in the log.

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
