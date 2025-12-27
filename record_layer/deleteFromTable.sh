#!/bin/bash
source ./Validation.sh

DBNAME=$1
db_path="./Databases/$DBNAME"

while true; do
    read -p "Please Enter Table Name: " tname
    table="$db_path/$tname.SQL"
    metadata="$db_path/.$tname.metadata"

    if [[ ! -f "$table" ]]; then
        echo "Table not found. Please try again."
        continue
    fi

    pk=$(awk -F: 'NR==1 {print $2}' "$metadata")
    mapfile -t colnames < <(awk -F: 'NR==2 {for(i=1;i<=NF;i++) print $i}' "$metadata")

    echo "Delete Option:"
    echo "1) Delete by Primary Key"
    echo "2) Delete by Column Value"
    echo "3) Delete All Rows"
    read -p "#? " choice

    case $choice in
        1)
            if [[ "$pk" != "yes" ]]; then
                echo "This table has no primary key."
                continue
            fi
            read -p "Enter Primary Key value to delete: " pkval
            pkval=$(echo "$pkval" | xargs)  # remove leading/trailing spaces
            tmpfile=$(mktemp)
            awk -F: -v val="$pkval" '$1 != val {print $0}' "$table" > "$tmpfile"
            if [[ $(wc -l < "$tmpfile") -eq $(wc -l < "$table") ]]; then
                echo "No row found with PK = $pkval"
                rm -f "$tmpfile"
            else
                mv "$tmpfile" "$table"
                echo "Row with PK=$pkval deleted successfully."
            fi
            ;;
        2)
            echo "Available Columns:"
            for i in "${!colnames[@]}"; do
                echo "$((i+1))- ${colnames[$i]}"
            done
            read -p "Enter column name to delete by: " colname
            read -p "Enter value to delete: " colval
            colval=$(echo "$colval" | xargs)  # trim spaces

            col_index=-1
            for i in "${!colnames[@]}"; do
                if [[ "${colnames[$i]}" == "$colname" ]]; then
                    col_index=$i
                    break
                fi
            done

            if [[ $col_index -eq -1 ]]; then
                echo "Column '$colname' not found."
                continue
            fi

            tmpfile=$(mktemp)
            awk -F: -v idx=$((col_index+1)) -v val="$colval" '$idx != val {print $0}' "$table" > "$tmpfile"
            if [[ $(wc -l < "$tmpfile") -eq $(wc -l < "$table") ]]; then
                echo "No row found with $colname = $colval"
                rm -f "$tmpfile"
            else
                mv "$tmpfile" "$table"
                echo "Rows with $colname=$colval deleted successfully."
            fi
            ;;
        3)
            read -p "Are you sure you want to delete all rows? [y/n]: " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                > "$table"
                echo "All rows deleted successfully."
            else
                echo "Deletion cancelled."
            fi
            ;;
        *)
            echo "Invalid option. Try again."
            continue
            ;;
    esac

    # عرض الجدول بعد الحذف
    if [[ -s "$table" ]]; then
        echo "Current Table Content:"
        column -s: -t "$table"
    else
        echo "Table is now empty."
    fi

    echo
    echo "Next Action:"
    echo "1) Delete from Another Table"
    echo "2) Return to Main Menu"
    echo "3) Exit"
    read -p "#? " next

    case $next in
        1)
            continue
            ;;
        2)
            ./db_operations_menu.sh
            break
            ;;
        3)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Returning to Main Menu..."
            ./main.sh
            break
            ;;
    esac
done

