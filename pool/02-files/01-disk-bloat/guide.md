# Disk Bloat

## TICKET
Monitoring fired: the `/var/appdata` filesystem crossed its usage threshold
overnight. The app team swears they "only write small session files" under
`/var/appdata`. Nobody knows where the space went.

Produce evidence, then clean up:
1. Find the three files actually eating the space — prove it with numbers,
   largest first, written to `~/bloat-report.txt`.
2. One file in there looks enormous in a directory listing but barely
   occupies disk. Explain the discrepancy in one appended line.
3. The tree is littered with stale `.tmp` session files and empty `.csv`
   exports. Delete all of them in bulk — no manual one-by-one deletion —
   but nothing else. Count the number of files targeted for deletion beforehand. 
4. `releases/v1/backup.log` refuses to open as text. Determine what it
   really is before deciding its fate.
5. There's a file whose name contains spaces. Remove it without renaming it.
6. A second alert: `/var/log/appsvc` is nearly full too. A teammate already
   deleted the service's huge log to fix it, but the alert never cleared and
   nobody can find what is using the space. Free the space without stopping
   or restarting the service. Append before/after usage numbers to the report
   and show the service is still running afterwards. Self-check: about 35M
   comes back.

## COMMANDS
df du ls find file stat sort head truncate wc xargs -print0 rm lsof ps

## QUESTIONS
1. Interview: `ls -l` on `/var/appdata` lists `prealloc.img` at 2G, yet `df -h /var/appdata` shows the filesystem only ~93% full (~82M used) and `du -sh /var/appdata` agrees. Explain how a 2G "file" can occupy almost nothing, and which commands (`df`, `du`, `ls`, `stat`) you'd use to confirm it.
2. Interview: every night log rotation renames `app.log` to `app.log.1` and creates a fresh `app.log`, yet the service keeps writing into `app.log.1` while the new file stays empty. Why? Name the two standard ways to rotate a live service's log safely and the trade-off of each.
3. Interview: what does an inode store, and what two pieces of information does a directory entry actually map together? Why can a filesystem run out of space with `df` showing space free?

# ANSWERS

A file has two sizes: 
- Apparent size
- Allocated size

You can compare these two sizes using commands like "stat" or "du"

The "rm" command deletes a name, not the blocks of memory it references it.  
