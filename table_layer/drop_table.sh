#!/bin/bash

source ./Validation.sh

db_path="./Databases/$DBNAME"


table_list=($(ls "$db_path"/*.SQL 2>/dev/null))

if [[ ${#table_list[@]} -eq 0 ]]; then
    echo "No Tables Found! Nothing to delete."

    read -p "Do you want to return to Table Menu? [y/n]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        ./db_operations_menu.sh
    else
        echo "Exiting..."
        exit 0
    fi
fi



while true; do
    read -p "Please enter the Table name to drop: " table_name

    # Validation
    if ! validate_name "$table_name"; then
        echo "Invalid table name. Please try again."
        continue
    fi

    table_file="$db_path/$table_name.SQL"
    metadata_file="$db_path/.$table_name.metadata"

    if [[ ! -f "$table_file" ]]; then
        echo "Table '$table_name' not found!"
        read -p "Do you want to try again? [y/n]: " retry
        if [[ "$retry" =~ ^[Yy]$ ]]; then
            continue
        else
            break
        fi
    fi

    read -p "Are you sure you want to delete table '$table_name'? [y/n]: " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -f "$table_file" "$metadata_file"
        echo "-----------------------------"
        echo "Table '$table_name' deleted successfully."
        echo "-----------------------------"
    else
        echo "Operation cancelled."
    fi

    read -p "Do you want to return to Table Menu? [y/n]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        ./db_operations_menu.sh
    else
        echo "Exiting..."
        exit 0
    fi
done

