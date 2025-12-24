#!/bin/bash

source ./Validation.sh

mydir="./Databases"
if [[ ! -d "$mydir" ]]; then
    mkdir "$mydir"
    echo "Databases Folder Created Successfully!"
fi

while true; do
    read -p "Please Enter Database Name: " name
    
    if ! validate_name "$name"; then
        echo "Please try again."
        continue
    fi
    
    if [[ -d "$mydir/$name" ]]; then
        echo "Database With This Name Already Exists!"
        echo "Please Enter Another Name."
        continue
    fi
    
    break
done

mydir="$mydir/$name"
mkdir "$mydir"
chmod +x "$mydir"
echo "-----------------------------"
echo "Database Created Successfully"
echo "-----------------------------"