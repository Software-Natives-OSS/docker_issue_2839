#!/bin/sh
export SERVER=server
export PORT=22
export BORG_PASSPHRASE='not_safe'

# Sleeping may not really be required
echo "DEBUG: sleep a bit..."
sleep 30

echo "DEBUG: add server key to known_hosts"
ssh-keyscan -t rsa -p $PORT $SERVER > ~/.ssh/known_hosts

echo "DEBUG: create remote backup repo"
borg init --encryption=repokey ssh://borg@$SERVER:$PORT/backups/just_a_backup

echo "DEBUG: start backup"
/usr/bin/borgmatic -c /config/config.yaml -v 2 2>&1
