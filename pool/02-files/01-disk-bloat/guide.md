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
   but nothing else. Count what you deleted first.
4. `releases/v1/backup.log` refuses to open as text. Determine what it
   really is before deciding its fate.
5. There's a file whose name contains spaces. Remove it without renaming it.

## COMMANDS
df du find file stat ls wc rm touch

## QUESTIONS
1. Interview: `ls -l` on `/var/appdata` lists `prealloc.img` at 2G, yet `df -h /var/appdata` shows the filesystem only ~90% full (~80M used) and `du -sh /var/appdata` agrees. Explain how a 2G "file" can occupy almost nothing, and name a second, unrelated way a filesystem can stay full after its largest file is deleted (e.g. a deleted-but-still-open file) — for each, say which command (`df`, `du`, `ls`, `lsof`) you'd use to confirm it.
2. Interview: you deleted a 30G log file but the disk usage didn't drop. Why, and how do you actually reclaim the space without restarting the service?
3. Interview: what does an inode store, and what two pieces of information does a directory entry actually map together? Why can a filesystem run out of space with `df` showing space free?
