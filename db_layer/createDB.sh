#!/bin/bash

# Source validation functions at the start
source ./Validation.sh

mydir="./Databases"
if [[ ! -d "$mydir" ]]; then
    mkdir "$mydir"
    echo "Databases Folder Created Successfully!"
fi

# Loop to allow re-entry if name is invalid
while true; do
    read -p "Please Enter Database Name: " name
    
    # Validate the name first
    if ! validate_name "$name"; then
        echo "Please try again."
        continue
    fi
    
    # Check if database already exists
    if [[ -d "$mydir/$name" ]]; then
        echo "Database With This Name Already Exists!"
        echo "Please Enter Another Name."
        continue
    fi
    
    # Name is valid and unique, create database
    break
done

# Create the database
mydir="$mydir/$name"
mkdir "$mydir"
chmod +x "$mydir"
echo "-----------------------------"
echo "Database Created Successfully"
echo "-----------------------------"