#!/bin/bash
source ./Validation.sh

select_column() {
    local prompt_msg="$1"
    
    echo "Available Columns:"
    for i in "${!colnames[@]}"; do
        echo "$((i+1))- ${colnames[$i]}"
    done

    read -p "$prompt_msg" colname_input
    
    ret_idx=-1
    
    for i in "${!colnames[@]}"; do
        if [[ "${colnames[$i]}" == "$colname_input" ]]; then
            ret_idx=$i
            break
        fi
    done

    if [[ $ret_idx -eq -1 ]]; then
        echo "Column '$colname_input' not found."
        return 1 
    fi
    return 0 
}

validate_type() {
    local idx="$1"
    local val="$2"
    
    if [[ "${datatypearray[$idx]}" == "int" ]]; then
        if ! is_number "$val"; then
            echo "Error: Value must be an integer."
            return 1
        fi
    fi
    return 0
}


DBNAME=$1
db_path="./Databases/$DBNAME"
sep=":"

while true; do
    read -p "Please Enter Table Name: " tname
    table="$db_path/$tname.SQL"
    metadata="$db_path/.$tname.metadata"

    if [[ ! -f "$table" ]]; then
        echo "Table not found. Please try again."
        continue
    fi

    pk=$(awk -F"$sep" 'NR==1 {print $2}' "$metadata")
    mapfile -t colnames < <(awk -F"$sep" 'NR==2 {for(i=1;i<=NF;i++) print $i}' "$metadata")
    mapfile -t datatypearray < <(awk -F"$sep" 'NR==3 {for(i=1;i<=NF;i++) print $i}' "$metadata")
    mapfile -t pkarray < <(awk -F"$sep" '{print $1}' "$table")
    
    echo "Update Option:"
    echo "1) Update by Primary Key"
    echo "2) Update by Column Value"
    echo "3) Update All Rows"
    read -p "#? " choice

    case $choice in
        1)
            if [[ "$pk" != "yes" ]]; then
                echo "This table has no primary key."
                continue
            fi

            read -p "Enter Primary Key value to update: " pkval
            pkval=$(echo "$pkval" | xargs)

            if ! contain_PK "update" "$pkval" "${pkarray[@]}"; then
                echo "No row found with PK = $pkval"
            else
                if ! select_column "Enter column name you want to update: "; then
                    continue
                fi
                col_index=$ret_idx  

                read -p "Enter value to update: " colval
                colval=$(echo "$colval" | xargs)

                if [[ $col_index -eq 0 ]] && ! contain_PK "insert" "$colval" "${pkarray[@]}"; then
                    echo -e "ERROR: Duplicated data for primary key.\n"
                    echo -e "Please try again.\n"
                else
                    if validate_type "$col_index" "$colval"; then
                        
                        awk -i inplace \
                            -v id="$pkval" \
                            -v col="$((col_index + 1))" \
                            -v val="$colval" '
                        BEGIN {FS=":"; OFS=":"} 
                        { if ($1 == id) $col = val; print $0; }
                        ' "$table"
                        echo "Table updated successfully."
                    fi
                fi
            fi
            ;;
        2)
            if ! select_column "Enter column name to search by: "; then
                continue
            fi
            search_index=$ret_idx 

            read -p "Enter value to search for: " search_val
            search_val=$(echo "$search_val" | xargs)

            awk_search_col=$((search_index + 1))
            match_count=$(awk -F":" -v col="$awk_search_col" -v val="$search_val" '$col == val { count++ } END { print count+0 }' "$table")

            if [[ $match_count -eq 0 ]]; then
                echo "Error: Value '$search_val' not found."
            else
                echo "Record found! What do you want to update?"
                
                if ! select_column "Enter column name to update: "; then
                    continue
                fi
                col_index=$ret_idx 

                read -p "Enter new value: " colval
                colval=$(echo "$colval" | xargs)

                if [[ $col_index -eq 0 ]] && ! contain_PK "insert" "$colval" "${pkarray[@]}"; then
                    echo -e "ERROR: Duplicated data for primary key.\n"
                    echo -e "Please try again.\n"
                else
                    if validate_type "$col_index" "$colval"; then
                        
                        awk_target_col=$((col_index + 1))
                        awk -i inplace \
                            -v search_c="$awk_search_col" \
                            -v search_v="$search_val" \
                            -v target_c="$awk_target_col" \
                            -v new_v="$colval" '
                        BEGIN {FS=":"; OFS=":"} 
                        { if ($search_c == search_v) $target_c = new_v; print $0; }
                        ' "$table"
                        echo "Table updated successfully."
                    fi
                fi
            fi
            ;;

        3)
            if ! select_column "Enter column name to update: "; then
                continue
            fi
            col_index=$ret_idx 

            read -p "Enter new value: " colval
            colval=$(echo "$colval" | xargs)

            if [[ $col_index -eq 0 && "$pk" == "yes" ]]; then
                echo "Error: Cannot update Primary Key for all rows."
                continue
            fi

            if validate_type "$col_index" "$colval"; then
                
                awk_target_col=$((col_index + 1))
                awk -i inplace \
                    -v target_c="$awk_target_col" \
                    -v new_v="$colval" '
                BEGIN {FS=":"; OFS=":"} 
                { $target_c = new_v; print $0; }
                ' "$table"
                echo "All rows updated successfully."
            fi
            ;;
        *)
            echo "Invalid option. Try again."
            continue
            ;;
    esac

    echo
    echo "Next Action:"
    echo "1) Update Another Table" 
    echo "2) Return to Main Menu"
    echo "3) Exit"
    read -p "#? " next

    case $next in
        1) continue ;;
        2) ./db_operations_menu.sh; break ;;
        3) echo "Exiting..."; break ;;
        *) ./main.sh; break ;;
    esac
done