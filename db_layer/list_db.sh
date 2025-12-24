#!/usr/bin/bash

dbs=$(ls -d */ 2>/dev/null)

if [ -z "$dbs" ]; then
    echo "No Databases Found"
else
    echo "Databases:"
    count=1
    for db in $dbs; do
        echo "$count) ${db%/}" 
        ((count++))
    done
fi


