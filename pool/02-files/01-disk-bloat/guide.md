# Disk Bloat

## TICKET
Monitoring reports unexpected disk usage under `/var/appdata`. The app team believes it stores only small session files there. A separate alert says `/var/log/appsvc` is nearly full.

1. Identify the three largest space-consuming files under `/var/appdata`. Save their paths and sizes in descending order to `~/bloat-report.txt`.
2. Find the file whose apparent size is much larger than its actual disk usage. Append both measurements and a short explanation to the report.
3. Count stale `.tmp` session files and zero-byte `.csv` exports, then delete only those matching files in bulk. Record the count before deletion and verify the targeted files are gone.
4. Investigate `releases/v1/backup.log`, which cannot be read as ordinary text. Identify its actual format and record the finding before taking any action on it.
5. Remove the file with spaces in its name without renaming it or affecting neighboring files.
6. Investigate why disk usage remains high after a teammate deleted the service's log filename under `/var/log/appsvc`. Reclaim the space without stopping or restarting the service. Append before-and-after usage and proof the service remains running. Self-check: roughly 35 MB is recovered.

## COMMANDS
df du ls find file stat sort head truncate wc xargs -print0 rm lsof ps

## QUESTIONS
1. Interview: `ls -l` on `/var/appdata` lists `prealloc.img` at 2G, yet `df -h /var/appdata` shows the filesystem only ~93% full (~82M used) and `du -sh /var/appdata` agrees. Explain how a 2G "file" can occupy almost nothing, and which commands (`df`, `du`, `ls`, `stat`) you'd use to confirm it.
2. Interview: every night log rotation renames `app.log` to `app.log.1` and creates a fresh `app.log`, yet the service keeps writing into `app.log.1` while the new file stays empty. Why?
3. Interview: what does an inode store, and what two pieces of information does a directory entry actually map together?

## ANSWERS

A file has two sizes: 
- Apparent size
- Allocated size

You can compare these two sizes using commands like "stat" or "du"

The "rm" command deletes a name, not the blocks of memory it references it.  
