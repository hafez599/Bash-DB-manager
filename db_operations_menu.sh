#!/bin/bash

echo "Please choose an action:"

select choice in "Create Table" "List Tables" "Insert into Table" "Drop Table" "Delete From Table" "Select From Table" "Update Table"
do
    case $choice in 
        "Create Table")
            ./table_layer/createTable.sh "$DNAME"
            ;;
        "List Tables")
            ./db_layer/list_db.sh
            ;;
        "Insert into Table")
            ./db_layer/connectDB.sh
            ;;
        "Drop Table")
            echo "Dropping database..."
            ;;
        "Delete From Table")
            ./db_layer/createDB.sh
            ;;
        "Select From Table")
            ./db_layer/list_db.sh
            ;;
        "Insert into Table")
            ./db_layer/connectDB.sh
            ;;
        "Update Table")
            echo "Dropping database..."
            ;;
        *)
            echo "Invalid option, try again."
            ;;
    esac
done
