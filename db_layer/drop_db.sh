#!/bin/bash

source ./Validation.sh

mydir="./Databases"

if [[ ! -d "$mydir" ]]; then
    mkdir "$mydir"

fi

db_list=($(ls -1 "$mydir" 2>/dev/null))
if [[ ${#db_list[@]} -eq 0 ]]; then
    echo "No Databases Found! Nothing to delete."
    read -p "Do you want to return to Main Menu? [y/n]: " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        ./main.sh
    else
        echo "Exiting..."
    fi
    exit 0
fi

while true; do
    read -p "Please enter the Database name to drop: " dbname

    if ! validate_name "$dbname"; then
        echo "Invalid name. Please try again."
        continue
    fi

    if [[ ! -d "$mydir/$dbname" ]]; then
        echo "Database '$dbname' not found!"
        read -p "Do you want to try again? [y/n]: " retry
        if [[ "$retry" == "y" || "$retry" == "Y" ]]; then
            continue
        else
            echo "Exiting..."
            exit 1
        fi
    fi

    read -p "Are you sure you want to delete '$dbname'? [y/n]: " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        rm -r "$mydir/$dbname"
        echo "-----------------------------"
        echo "Database '$dbname' deleted successfully."
        echo "-----------------------------"
    else
        echo "Deletion cancelled."
    fi

    read -p "Do you want to return to Main Menu? [y/n]: " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        ./main.sh
    else
        echo "Exiting..."
    fi

    break
done

