# Release Links

## TICKET
The site returns 404 after cleanup.
1. Save every broken symlink under `/srv` and `/etc/nginx` in `~/broken-links.txt` (exactly two).
2. Restore `/srv/app/current` to point at `/srv/app/releases/v2`, replacing the link atomically without an absent intermediate state. Verify the link and target; leave release contents untouched.
3. In `~/release-report.txt`, record inode, link count and disk usage for the live and archived API log names. Remove the archive name, demonstrate usage is unchanged, then remove the remaining name for that inode and record freed space (at least 20 MB).

## COMMANDS

ln readlink ls -li find (-xtype l -samefile -links -size) stat df rm mv -T

## QUESTIONS

1. In inode terms, what does a hard link share with its other names, and how
   does that differ from a symbolic link? Which kind can cross filesystems,
   and what happens to each when another name is removed?
2. Why do deployments switch a `current` link instead of copying files into a
   live directory? What failure can an in-place update expose, and how does a
   same-filesystem rename make the switch atomic to readers?
3. A cleanup removes one filename but filesystem usage stays the same. What
   relationship between directory entries, link counts, open file descriptors,
   and allocated blocks could explain the result?

## ANSWERS
