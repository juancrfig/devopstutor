# Release Day Wreckage

## TICKET
Release day for the checkout service. Your clone of the `infra` repo is in
`~/infra`. The shared server copy everyone pulls from is `/srv/git/infra.git`.

Three days ago you finished a change on `feature/healthcheck-timeout`, sent it
to the server the usual way, and it landed on the server's `master`. Nobody
reviewed it. Your feature branch does not exist on the server. Since then a
teammate has added more work on top of `master`. Your tree also has a
half-done memory change that you have not committed yet.

Clean it up before the release. Do it in this order:
1. Postmortem first, before you change anything. In `~/postmortem.txt`, write
   which server branch your feature branch was following, and which setting
   made a plain send follow it. Show where that setting is defined.
2. Put your feature branch on the server under its own name. From now on, a
   plain send from it must go there and nowhere else.
3. Take the healthcheck change off the server's `master` without rewriting
   history that others have already pulled. Your half-done memory change must
   survive. It must not be committed, and it must not reach `master`.
4. Rosa's `feature/replicas` is approved. Bring it into `master`. Where her
   work and the team's work collide, the final file must have image `v1.5.0`
   AND 4 replicas, with no conflict markers left. Resolve it in vim.
5. Someone committed `.env`, and it has a database password in it. Stop
   tracking it, but keep the file on disk for local dev. Make sure no future
   `.env` gets added by accident.
6. On Monday you committed a TLS cert rotation script. It never reached the
   server, and now it is gone from every branch. Bring it back on a branch
   called `feature/cert-rotation` and publish it.
7. Deploys hang because someone set surge pods to zero. In `~/blame.txt`,
   write the commit that did it, its author, and the reason they gave.
8. Mark the final `master` as release `v1.5.0`, with a message, and publish
   the mark.
9. Go back to your feature branch with the memory change restored and still
   uncommitted.

Prove it: one graph of every branch, local and remote, shows each step above.

## COMMANDS
git status git log git branch git switch git config git fetch git pull
git push git stash git revert git merge git diff git add git commit git rm
git reflog git tag git blame git show vim cat echo

## QUESTIONS
1. Interview: when you run a plain `git push`, how does git decide which remote branch gets your commits? Explain upstream tracking, and compare `push.default` `simple`, `upstream` and `current`. How did `git checkout -b x origin/master` set the trap here? Why did even `git push -u origin feature/healthcheck-timeout` try to go to `master`? How would you stop this across a whole team (hint: the server side)?
2. Interview: reset vs revert. When do you use each one, and why is a force-push to a shared `master` dangerous? Follow-up: you reverted the healthcheck commit on `master`. Later, merging `feature/healthcheck-timeout` into `master` brings in nothing. Why? How do you get the change back?
3. Interview: fetch vs pull, and merge vs rebase. What is a fast-forward? When would you rebase, and when must you never rebase?
4. Interview: what is the reflog? Is it shared with the remote? How long does it keep entries? What work can `reset --hard` destroy that the reflog cannot bring back?
5. Interview: a password was committed and pushed. Why is untracking the file not enough? List everything you would do, in order.
