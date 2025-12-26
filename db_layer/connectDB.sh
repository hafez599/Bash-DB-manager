#!/bin/bash

export DBNAME

read -p "Please Enter Database Name: " DBNAME

if [[ ! -d "./Databases/$DBNAME" ]]; then
    echo "Database Not Found please try again"
else
    ./db_operations_menu.sh
fi