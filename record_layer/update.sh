#!/bin/bash
source ./Validation.sh

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
    mapfile -t datatypearray < <(awk -F"$sep" 'NR==3 {for(i=1;i<=NF;i++) print $i}' $metadata)
    mapfile -t pkarray < <(awk -F"$sep" '{print $1}' $table)
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

            if contain_PK "$pkval" "${pkarray[@]}"; then
                echo "No row found with PK = $pkval"
            else
                echo "Available Columns:"
                for i in "${!colnames[@]}"; do
                    echo "$((i+1))- ${colnames[$i]}"
                done

                read -p "Enter column name you want to update: " colname
                read -p "Enter value to update: " colval
                colval=$(echo "$colval" | xargs)
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

                if [[ $col_index -eq 0 ]] && ! contain_PK "$colval" "${pkarray[@]}"; then
                    echo -e "ERROR: Duplicated data for primary key.\n"
                    echo -e "Please try again.\n"
                else
                    is_valid_update=true
                    
                    if [[ "${datatypearray[$col_index]}" == "int" ]]; then
                        if ! is_number "$colval"; then
                            echo "Error: Value must be an integer."
                            is_valid_update=false
                        fi
                    fi
                    
                    if [[ "$is_valid_update" == "true" ]]; then
                        awk -i inplace \
                            -v id="$pkval" \
                            -v col="$((col_index + 1))" \
                            -v val="$colval" '
                        BEGIN {FS=":"; OFS=":"} 
                        {
                            if ($1 == id) {
                                $col = val;
                            }
                            print $0;
                        }
                        ' "$table"
                        
                        echo "Table updated successfully."
                    fi
                fi
            fi
            ;;
        2)
            echo "Available Columns:"
            for i in "${!colnames[@]}"; do
                echo "$((i+1))- ${colnames[$i]}"
            done
            read -p "Enter column name to search by: " search_col
            read -p "Enter value to search for: " search_val
            search_val=$(echo "$search_val" | xargs)

            search_index=-1
            for i in "${!colnames[@]}"; do
                if [[ "${colnames[$i]}" == "$search_col" ]]; then
                    search_index=$i
                    break
                fi
            done

            if [[ $search_index -eq -1 ]]; then
                echo "Column '$search_col' not found."
                continue
            fi

            awk_search_col=$((search_index + 1))
            
            match_count=$(awk -F":" -v col="$awk_search_col" -v val="$search_val" '
                $col == val { count++ } 
                END { print count+0 }
            ' "$table")

            if [[ $match_count -eq 0 ]]; then
                echo "Error: Value '$search_val' not found in '$search_col'."
            else
                echo "Record found! What do you want to update?"
                
                read -p "Enter column name to update: " colname
                read -p "Enter new value: " colval
                colval=$(echo "$colval" | xargs)
                
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

                if [[ $col_index -eq 0 ]] && ! contain_PK "update" "$colval" "${pkarray[@]}"; then
                    echo -e "ERROR: Duplicated data for primary key.\n"
                    echo -e "Please try again.\n"
                else
                    is_valid_update=true
                    if [[ "${datatypearray[$col_index]}" == "int" ]]; then
                        if ! is_number "$colval"; then
                            echo "Error: Value must be an integer."
                            is_valid_update=false
                        fi
                    fi

                    if [[ "$is_valid_update" == "true" ]]; then
                        awk_target_col=$((col_index + 1))

                        awk -i inplace \
                            -v search_c="$awk_search_col" \
                            -v search_v="$search_val" \
                            -v target_c="$awk_target_col" \
                            -v new_v="$colval" '
                        BEGIN {FS=":"; OFS=":"} 
                        {
                            if ($search_c == search_v) {
                                $target_c = new_v;
                            }
                            print $0;
                        }
                        ' "$table"
                        
                        echo "Table updated successfully."
                    fi
                fi
            fi
            ;;

        3)
            echo "Available Columns:"
            for i in "${!colnames[@]}"; do
                echo "$((i+1))- ${colnames[$i]}"
            done

            read -p "Enter column name to update: " colname
            read -p "Enter new value: " colval
            colval=$(echo "$colval" | xargs)

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

            if [[ $col_index -eq 0 && "$pk" == "yes" ]]; then
                echo "Error: Cannot update Primary Key for all rows."
                echo "This would violate the unique constraint."
                continue
            fi

            is_valid_update=true
            
            if [[ "${datatypearray[$col_index]}" == "int" ]]; then
                if ! is_number "$colval"; then
                    echo "Error: Value must be an integer."
                    is_valid_update=false
                fi
            fi

            if [[ "$is_valid_update" == "true" ]]; then
                
                awk_target_col=$((col_index + 1))

                awk -i inplace \
                    -v target_c="$awk_target_col" \
                    -v new_v="$colval" '
                BEGIN {FS=":"; OFS=":"} 
                {
                    # No "if" condition needed here.
                    # We apply the change to every single line.
                    $target_c = new_v;
                    print $0;
                }
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

