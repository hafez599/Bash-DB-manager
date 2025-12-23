#!/bin/bash
pwd
read -p "Please Enter Database Name: " name

mydir="./Databases"
if [[ ! -d "$mydir" ]]; then
    mkdir $mydir
    echo "Databases Folder Created Successfully!"
fi
mydir="$mydir/$name"

if [[ -d "$mydir" ]]; then
    echo "Database With This Name Already Exit!"
    echo "Please ENter Another Name."
    else
        mkdir $mydir
        echo "Database Created Successfully."
fi