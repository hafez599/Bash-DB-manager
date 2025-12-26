#!/bin/bash

mydir="./Databases"

if [[ ! -d "$mydir" ]]; then
    mkdir "$mydir"
    
fi

db_list=()
for item in "$mydir"/*; do
    if [[ -d "$item" ]]; then
        db_list+=("$(basename "$item")")
    fi
done

if [[ ${#db_list[@]} -eq 0 ]]; then
    echo "No Databases Found!"
else
    echo "Available Databases:"
    counter=1
    for db in "${db_list[@]}"; do
        echo "$counter- $db"
        ((counter++))
    done
fi

read -p "Do you want to return to Main Menu? [y/n]: " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    ./main.sh
else
    echo "Exiting..."
fi

