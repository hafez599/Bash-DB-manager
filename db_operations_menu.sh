#!/bin/bash

echo "Please choose an action:"

select choice in "Create Table" "List Tables" "Insert into Table" "Drop Table" "Delete From Table" "Select From Table" "Update Table"
do
    case $choice in 
        "Create Table")
            ./table_layer/createTable.sh "$DBNAME"
            ;;
        "List Tables")
            ./table_layer/list_tables.sh "$DBNAME"
            ;;
        "Insert into Table")
            ./record_layer/insert.sh "$DBNAME"
            ./db_operations_menu.sh
            ;;
        "Drop Table")
            ./table_layer/drop_table.sh "$DBNAME"
            ;;
        "Delete From Table")
            ./record_layer/deleteFromTable.sh "$DBNAME"
            ;;
        "Select From Table")
            ./record_layer/selectFromTable.sh "$DBNAME"
            ;;
        "Update Table")
            ./record_layer/update.sh "$DBNAME"
            ;;
        *)
            echo "Invalid option, try again."
            ;;
    esac
done
