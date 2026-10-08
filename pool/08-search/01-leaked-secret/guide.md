# Leaked Secret

## TICKET
Someone pasted the production database password into a public chat. The
password is exactly `Tr0ub4dor.3$`. Security will rotate it tonight. Before
they do, they need to know every place on this box that holds it. The app
lives in `/srv/shop`. Its config lives in `/etc/shop`. Staging uses a
different password, `Tr0ub4dor_3`, which was not leaked.

Build the report in `~/leak-report.txt`. Add each section after the last
one; do not overwrite your own report.
1. List every file under `/srv/shop` and `/etc/shop` that holds the leaked
   password, one path per line. Skip the `.git` and `vendor` folders. Files
   only root can read still count. Security's scan found exactly 8 files. If
   your list has a different number, or it shows the staging file, your
   search is wrong.
2. For each of those files, record how many lines hold the password (files
   with zero do not belong in this section). Then record every line that
   holds it, with its line number.
3. The password setting has different names in different files:
   `DB_PASSWORD`, `db_password` and `Db_Pass`. With one search over both
   folders, record every line that uses any of these names in any letter
   case. Lines that only contain these names inside a longer name
   (`OLD_DB_PASSWORD_HINT`, `db_password_rotated_at`) must not appear.
4. Every `.conf` file directly inside `/etc/shop` must turn on the
   `SECRETS_BACKEND` setting. A setting inside a comment is not on. Record
   the files that do not turn it on. Then record only the settings that are
   in effect in `/etc/shop/shop.conf`, with no comments and no blank lines.
5. Editors and admins leave stale copies behind. Search `/etc` and `/srv`
   as yourself, without admin rights, and with no error noise on screen.
   Record every file (not folder) whose name ends in `.bak` or `~` that was
   changed in the last 3 days. Then record every env file the app loader can
   see. The loader reads names that end in `.env` in any letter case, and it
   goes at most 3 levels below `/srv/shop`.
6. A file that holds the password and that every user on the box can read
   is a second incident. Record those files under `/srv/shop` and
   `/etc/shop`. Skip `.git` and `vendor`. Do it in one command, with no
   loop.
7. The database now refuses the old password from some hosts. In
   `/var/log/shop/db-client.log`, record each refused login with the 2
   lines before it and the 2 lines after it. Then rank the hosts by the
   number of refused logins, highest first.

## COMMANDS
grep find sudo sort uniq wc cat echo

## QUESTIONS
1. Interview: why did a plain search for `Tr0ub4dor.3$` miss real hits and catch the staging password? Explain basic vs extended regex vs fixed strings. Then explain why single quotes and double quotes around that pattern behave differently in the shell.
2. Interview: compare `find ... -exec cmd {} \;`, `find ... -exec cmd {} +` and `find ... | xargs cmd`. Which one starts the most processes? Which ones break on file names with spaces or newlines, and how do you make them safe?
3. Interview: `find / -name '*.pem'` fills your screen with "Permission denied". How do you hide only the errors and keep the results? Compare `2>/dev/null`, `&>/dev/null` and `2>&1 | grep -v denied`. Why does running it as root give a different answer, and why is that both useful and risky?
4. Interview: what exactly do `-mtime -3`, `-mtime 3` and `-mtime +3` match? How does find round file age into days? When would you use `-mmin` or `-newer` instead?
5. Interview: you must search a 500 GB tree full of logs, `node_modules` and binaries for a string. How do you keep the search fast and the output useful? Think about narrowing with find first, skipping folders, skipping binary files, and what `grep -r` vs `grep -R` does with symlinks.

## ANSWERS
