#!/bin/bash

host=$1
status=$(mysql -h "$host" -uroot -prootpass -e "SHOW SLAVE STATUS\G" 2>/dev/null | grep "Slave_IO_Running" | awk '{print $2}')

if [[ "$status" == "Yes" ]]; then
    echo "OK - Replication is running"
    exit 0
else
    echo "CRITICAL - Replication is not running"
    exit 2
fi
