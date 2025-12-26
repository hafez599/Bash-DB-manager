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
            break
            ;;
        "List Database")
            ./db_layer/list_db.sh

            break
            ;;
        "Connect Databases")
            ./db_layer/connectDB.sh
            break
            ;;
        "Drop Database")
            ./db_layer/drop_db.sh

            break
            ;;
        *)
            echo "Invalid option, try again."
            ;;
    esac
done
