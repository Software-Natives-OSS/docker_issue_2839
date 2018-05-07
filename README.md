# Reproduce docker issue 2839
This repository's single purpose is to reproduce [Docker issue 2839](https://github.com/docker/for-mac/issues/2839).

Do **NOT USE THIS REPO FOR PRODUCTION PURPOSES**.

Following the instructions below, you'll end up with two containers:
 - The "server": runs `ssh` and backs up files to `./folders/backups`
 - The "client": has access to `/` of the docker host and sends all these files via `ssh` to the server

`ssh` login happens by client certificate which are already part of this repo.

Note: Maybe it wouldn't be required to let the client have access to `/` but during my test run, the memory consumption of `com.docker.osxfs` only started grewing after several minutes (> 15 minutes). Therefore, it may be crucial to "backup" real files instead of creating an artificial set of files to backup.

## Reproduce it!
After cloning this repo, execute:
```
docker-compose up
```
Have a look at the "Expected output" further below.

On my MacBook Pro (17-inch, Early 2011), 8 GByte RAM running High Sierra (10.13.4) it takes roughly more than 15 minutes (maybe even 30) until the system "renders unusable".

I supervised memory usage of the system using the "Activity Monitor". Here's what I noticed:
 - `com.docker.osxfs`: Memory consumption highly fluctuates (which is ok and understandable)
 - `kernel_task`: Memory consumption starts at 1.11 GB. It stays there for a long time (>15 mins) but then suddenly starts growing up to 5 GB in my case. That happens just before the system "crashes"
 - When I noticed `kernel_task`'s high memory usage, `com.docker.osxfs`'s memory usage also was higher than any value I've seen before

## Expected output
```
Starting issue_2839_server_1 ... done
Starting issue_2839_client_1 ... done
Attaching to issue_2839_server_1, issue_2839_client_1
client_1  | DEBUG: sleep a bit...
server_1  | /usr/lib/python2.7/site-packages/supervisor/options.py:298: UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations (including its current working directory); you probably want to specify a "-c" argument specifying an absolute path to a configuration file for improved security.
server_1  |   'Supervisord is running as root and it is searching '
server_1  | 2018-05-10 08:28:59,659 CRIT Supervisor running as root (no user in config file)
server_1  | 2018-05-10 08:28:59,665 INFO supervisord started with pid 6
server_1  | 2018-05-10 08:29:00,670 INFO spawned: 'sshd' with pid 9
server_1  | 2018-05-10 08:29:01,677 INFO success: sshd entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
client_1  | DEBUG: add server key to known_hosts
client_1  | # server:22 SSH-2.0-OpenSSH_7.5
client_1  | DEBUG: create remote backup repo
client_1  | Remote: Warning: Permanently added the RSA host key for IP address '172.20.0.2' to the list of known hosts.
client_1  |
client_1  | By default repositories initialized with this version will produce security
client_1  | errors if written to with an older version (up to and including Borg 1.0.8).
client_1  |
client_1  | If you want to use these older versions, you can disable the check by running:
client_1  | borg upgrade --disable-tam ssh://borg@server:22/backups/just_a_backup
client_1  |
client_1  | See https://borgbackup.readthedocs.io/en/stable/changes.html#pre-1-0-9-manifest-spoofing-vulnerability for details about the security implications.
client_1  | DEBUG: start backup
client_1  | Ensuring legacy configuration is upgraded
client_1  | /config/config.yaml: Parsing configuration file
client_1  | /config/config.yaml: Running command for pre-backup hook
client_1  | /config/config.yaml: Hook command: echo "`date` - Starting a backup job."
client_1  | Thu May 10 08:29:08 UTC 2018 - Starting a backup job.
client_1  | ssh://borg@server:22/backups/just_a_backup: Pruning archives
client_1  | borg prune ssh://borg@server:22/backups/just_a_backup --keep-within 3H --keep-minutely 60 --keep-hourly 24 --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --keep-yearly 2 --prefix default- --lock-wait 5 --debug --stats --list
client_1  | using builtin fallback logging configuration
client_1  | 35 self tests completed in 0.32 seconds
client_1  | SSH command line: ['ssh', '-p', '22', 'borg@server', 'borg', 'serve', '--umask=077', '--debug']
client_1  | Remote: using builtin fallback logging configuration
client_1  | Remote: 35 self tests completed in 0.35 seconds
client_1  | Remote: using builtin fallback logging configuration
client_1  | Remote: Initialized logging system for JSON-based protocol
client_1  | Remote: Resolving repository path b'/backups/just_a_backup'
client_1  | Remote: Resolved repository path to '/backups/just_a_backup'
client_1  | Remote: Verified integrity of /backups/just_a_backup/index.1
client_1  | TAM-verified manifest
client_1  | security: read previous location 'ssh://borg@server:22/backups/just_a_backup'
client_1  | security: read manifest timestamp '2018-05-10T08:29:07.410498'
client_1  | security: determined newest manifest timestamp as 2018-05-10T08:29:07.410498
client_1  | security: repository checks ok, allowing access
client_1  | Verified integrity of /cache/e32aa21ebd2fccfb64925fc6b58fafd19ec48274d9a06e22abc42bcc3d190c79/chunks
client_1  | security: read previous location 'ssh://borg@server:22/backups/just_a_backup'
client_1  | security: read manifest timestamp '2018-05-10T08:29:07.410498'
client_1  | security: determined newest manifest timestamp as 2018-05-10T08:29:07.410498
client_1  | security: repository checks ok, allowing access
client_1  | ------------------------------------------------------------------------------
client_1  |                        Original size      Compressed size    Deduplicated size
client_1  | Deleted data:                    0 B                  0 B                  0 B
client_1  | All archives:                    0 B                  0 B                  0 B
client_1  |
client_1  |                        Unique chunks         Total chunks
client_1  | Chunk index:                       0                    0
client_1  | ------------------------------------------------------------------------------
client_1  | RemoteRepository: 213 B bytes sent, 2.49 kB bytes received, 5 messages sent
client_1  | ssh://borg@server:22/backups/just_a_backup: Creating archive
client_1  | borg create ssh://borg@server:22/backups/just_a_backup::default-{now} /source --exclude-from /tmp/tmp58h3lco9 --exclude-caches --compression lz4 --files-cache ctime,size,inode --umask 77 --lock-wait 5 --debug --list --stats
client_1  | using builtin fallback logging configuration
client_1  | 35 self tests completed in 0.33 seconds
client_1  | SSH command line: ['ssh', '-p', '22', 'borg@server', 'borg', 'serve', '--umask=077', '--debug']
client_1  | Remote: using builtin fallback logging configuration
client_1  | Remote: 35 self tests completed in 0.31 seconds
client_1  | Remote: using builtin fallback logging configuration
client_1  | Remote: Initialized logging system for JSON-based protocol
client_1  | Remote: Resolving repository path b'/backups/just_a_backup'
client_1  | Remote: Resolved repository path to '/backups/just_a_backup'
client_1  | Remote: Verified integrity of /backups/just_a_backup/index.1
client_1  | TAM-verified manifest
client_1  | security: read previous location 'ssh://borg@server:22/backups/just_a_backup'
client_1  | security: read manifest timestamp '2018-05-10T08:29:07.410498'
client_1  | security: determined newest manifest timestamp as 2018-05-10T08:29:07.410498
client_1  | security: repository checks ok, allowing access
client_1  | Verified integrity of /cache/e32aa21ebd2fccfb64925fc6b58fafd19ec48274d9a06e22abc42bcc3d190c79/chunks
client_1  | Reading files cache ...
client_1  | security: read previous location 'ssh://borg@server:22/backups/just_a_backup'
client_1  | security: read manifest timestamp '2018-05-10T08:29:07.410498'
client_1  | security: determined newest manifest timestamp as 2018-05-10T08:29:07.410498
client_1  | security: repository checks ok, allowing access
client_1  | Processing files ...
client_1  | s /source/libau.so
client_1  | s /source/libau.so.2
client_1  | A /source/libau.so.2.9
client_1  | A /source/sendtohost
client_1  | A /source/port/README
client_1  | d /source/port
client_1  | A /source/etc/ca-certificates.conf
client_1  | A /source/etc/ethertypes
client_1  | A /source/etc/exports
client_1  | A /source/etc/fstab
client_1  | A /source/etc/fuse.conf
...
```
Followed by files of your file system.
