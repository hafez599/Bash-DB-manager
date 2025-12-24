#!/usr/bin/bash

read -p "Enter database name to drop: " db_name

if [ -z "$db_name" ]; then
    echo "Error: Database name cannot be empty!"
    exit 1
fi

if [[ ! "$db_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Error: Database name can only contain letters, numbers, and underscores."
    exit 1
fi

if [ ! -d "$db_name" ]; then
    echo "Database '$db_name' does not exist!"
    exit 1
fi

read -p "Are you sure you want to delete '$db_name'? [y/n]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

rm -r "$db_name"
echo "Database '$db_name' deleted successfully."

