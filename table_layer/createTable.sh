#!/bin/bash
source ./Validation.sh

DB_NAME=$1
db_path="./Databases/$DB_NAME"
counter=1
sep=":"
datatypes=""
colnames=""

while true; do
    read -p "Please Enter Table Name: " table_name

    if ! validate_name "$table_name"; then
        echo "Please Enter Another Name."
        continue
    fi

    if [[ -f "$db_path/$table_name.SQL" ]]; then
        echo "Table With This Name Already Exists!"
        continue
    fi

    break
done

table_file="$db_path/$table_name.SQL"
metadata_file="$db_path/.$table_name.metadata"

touch "$table_file" "$metadata_file"
chmod u+rw "$table_file" "$metadata_file"

while true; do
    read -p "Please Enter Number Of Columns: " colNum
    [[ "$colNum" =~ ^[1-9]+$ ]] && break
    echo "Invalid number. Please enter a positive integer."
done

echo "Do You Want To Have Primary Key in This Table?"
select pkStatus in Yes No; do
    case $pkStatus in
        Yes)
            printf 'pk%syes\n' "$sep" >> "$metadata_file"
            break
            ;;
        No)
            printf 'pk%sno\n' "$sep" >> "$metadata_file"
            break
            ;;
        *)
            echo "Invalid option ($REPLY). Try again."
            ;;
    esac
done

while (( counter <= colNum )); do

    echo "Datatype Of The $counter th Column."
    select datatype in int str; do
        case $datatype in
            int|str)
                datatypes="$datatypes$sep$datatype"
                break
                ;;
            *)
                echo "Invalid option ($REPLY). Try again."
                ;;
        esac
    done

    echo "Please Enter the $counter th Column Name:"
    while true; do
        read -r colname

        if [[ ":$colnames:" == *":$colname:"* ]]; then
            echo "This Column Name Already Exists. Try again."
        elif ! validate_name "$colname"; then
            echo "Please Enter Another Name."
        else
            colnames="$colnames$sep$colname"
            break
        fi
    done

    ((counter++))
done

colnames="${colnames#$sep}"
datatypes="${datatypes#$sep}"

printf '%s\n' "$colnames"   >> "$metadata_file"
printf '%s\n' "$datatypes" >> "$metadata_file"

echo "-----------------------------"
echo "Table Created Successfully"
echo "-----------------------------"