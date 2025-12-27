#!/bin/bash

source ./Validation.sh

db_path="./Databases/$DBNAME"

echo "-----------------------------------"
echo "Tables in '$DBNAME':"
echo "-----------------------------------"

tables=$(ls "$db_path"/*.SQL 2>/dev/null)

if [[ -z "$tables" ]]; then
    echo "No tables found in '$DBNAME'."
else
    counter=1
    for item in $tables; do
        echo "$counter- $(basename "$item" .SQL)"
        ((counter++))
    done
fi

echo
read -p "Do you want to return to Table Menu? [y/n]: " choice

if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    ./db_operations_menu.sh
else
    echo "Exiting..."
fi

