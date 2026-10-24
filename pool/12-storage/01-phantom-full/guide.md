# Phantom Full

## TICKET
The app reports "No space left on device" under `/var/lib/sessions`, while its dashboard shows only 70% block usage. Ops attached a new sessions volume.

**Safety:** this privileged lab can see real host disks. Format or mount **only** `/dev/disk/by-gym/sessions-vol`. Never select a device by scanning disks.
1. Reproduce the failed write. Save the error and evidence of available block space in `~/storage-report.txt`.
2. Identify the exhausted storage resource and the directory holding session files. Record block and inode availability and explain the discrepancy.
3. Count session files older than seven days, then delete only those files in bulk. Self-check: exactly 1,000 qualify. Append count and cleanup evidence.
4. Create a filesystem only on the named lab volume, mount it at `/srv/sessions`, and configure UUID-based mounting at boot without blocking boot if absent. Validate without rebooting.
5. Unmount the old `/var/lib/sessions` filesystem. Identify and resolve the process holding it busy, then unmount normally; no lazy unmount.

## COMMANDS
df du find wc lsblk blkid mkfs.ext4 mount umount findmnt lsof ps kill grep sudo cat

## QUESTIONS
1. Why identify a volume by UUID rather than `/dev/sdX`? What can go wrong with an fstab entry at boot, and how does `nofail` change the outcome?
2. What are a disk, partition, filesystem, and mount point? What does filesystem creation initialize, and why can ext4 not gain more inodes after creation?
3. Why does the kernel refuse an unmount when the target is busy? How can you find the holder, and what can go wrong with a lazy unmount?

## ANSWERS
