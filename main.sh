#!/bin/bash

echo "---------------------------------------------------------------------------"
echo
echo "                Welcome ${USER^} to Bash-DBMS System "
echo
echo "---------------------------------------------------------------------------"

echo "Please choose an action:"

select choice in "Create Database" "List Database" "Connect Databases" "Drop Database"
do
    case $choice in 
        "Create Database")
            ./db_layer/createDB.sh
            ;;
        "List Database")
            ./db_layer/list_db.sh

            break
            ;;
        "Connect Databases")
            ./db_layer/connectDB.sh
            ;;
        "Drop Database")
            echo "Dropping database..."
            ./db_layer/drop_db.sh

            break
            ;;
        *)
            echo "Invalid option, try again."
            ;;
    esac
done
