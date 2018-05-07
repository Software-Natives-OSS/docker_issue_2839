#!/bin/sh
chown -R borg.borg /home/borg/.ssh

/usr/bin/supervisord
