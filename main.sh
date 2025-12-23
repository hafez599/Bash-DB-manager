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
            echo "Listing databases..."
            break
            ;;
        "Connect Databases")
            ./db_layer/connectDB.sh
            break
            ;;
        "Drop Database")
            echo "Dropping database..."
            break
            ;;
        *)
            echo "Invalid option, try again."
            ;;
    esac
done
