#!/bin/bash

export DNAME

read -p "Please Enter Database Name: " DNAME

if [[ ! -d "./Databases/$DNAME" ]]; then
    echo "Database Not Found please try again"
else
    ./db_operations_menu.sh
fi