#!/bin/bash

while true; do
    read -p "Please Enter Database Name: " DBNAME
    export DBNAME

    if [[ ! -d "./Databases/$DBNAME" ]]; then
        echo "Database Not Found, please try again"
    else
        ./db_operations_menu.sh
        break
    fi
done

