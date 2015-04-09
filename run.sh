#!/bin/bash

db_path=/data/db
lockfile=$db_path/mongod.lock
if [ -f $lockfile ]; then
    rm $lockfile
    mongod --dbpath ${db_path} --repair
fi

if [ ! -f $db_path/.mongodb_password_set ]; then
    /set_mongodb_password.sh
fi

cmd="mongod"
if [ "$JOURNAL" == "yes" ]; then
	cmd="$cmd --journal"
else
	cmd="$cmd --nojournal"
fi

cmd="$cmd --httpinterface --rest"
if [ "$AUTH" == "yes" ]; then
    cmd="$cmd --auth"
fi

if [ ! -f $lockfile ]; then
    exec $cmd
else
    cmd="$cmd --dbpath $db_path"
    rm $lockfile
    mongod --dbpath $db_path --repair && exec $cmd
fi

