#!/bin/bash
source ./Validation.sh
DBNAME=$1
db_path="./Databases/$DBNAME"

print_table() {
    local header="$1"
    local data="$2"

    {
        echo "$header"
        echo "$data"
    } | column -s: -t | awk '
    BEGIN { print "+-------------------------------------------------+" }
    NR==1 { print "| " $0; print "+-------------------------------------------------+"; next }
    { print "| " $0 }
    END { print "+-------------------------------------------------+" }'
}

while true; do
    read -p "Please Enter Table Name: " tname
    table="$db_path/$tname.SQL"
    metadata="$db_path/.$tname.metadata"

    if [[ ! -f "$table" ]]; then
        echo "Table not found. Please try again."
        continue
    fi

    mapfile -t colnames < <(awk -F: 'NR==2 {for(i=1;i<=NF;i++) print $i}' "$metadata")
    mapfile -t datatypes < <(awk -F: 'NR==3 {for(i=1;i<=NF;i++) print $i}' "$metadata")
    pk=$(awk -F: 'NR==1 {print $2}' "$metadata")

    echo
    echo "Select Options:"
    echo "1) Select All Rows"
    echo "2) Select by Primary Key"
    echo "3) Select by Column Value"
    echo "4) Select Specific Column(s)"
    read -p "#? " choice

    case $choice in
        1)
            echo
            echo "All Rows in Table: $tname"
            header=$(echo "${colnames[*]}" | tr ' ' ':')
            data=$(cat "$table")
            print_table "$header" "$data"
            ;;
        2)
            if [[ "$pk" != "yes" ]]; then
                echo "This table has no primary key."
                continue
            fi
            read -p "Enter Primary Key value to search: " pkval
            result=$(awk -F: -v val="$pkval" '$1==val {print $0}' "$table")
            if [[ -z "$result" ]]; then
                echo "No record found with primary key: $pkval"
                continue
            fi
            header=$(echo "${colnames[*]}" | tr ' ' ':')
            print_table "$header" "$result"
            ;;
        3)
            echo "Available Columns:"
            for i in "${!colnames[@]}"; do
                echo "  $((i+1))- ${colnames[$i]}"
            done
            read -p "Enter column name to filter by: " colfilter
            read -p "Enter value to search in '$colfilter': " valfilter

            # احصل على index العمود
            col_idx=-1
            for i in "${!colnames[@]}"; do
                if [[ "${colnames[$i]}" == "$colfilter" ]]; then
                    col_idx=$((i+1))
                    break
                fi
            done

            if [[ $col_idx -eq -1 ]]; then
                echo "Column not found."
                continue
            fi

            result=$(awk -F: -v col="$col_idx" -v val="$valfilter" '$col==val {print $0}' "$table")
            if [[ -z "$result" ]]; then
                echo "No record found with $colfilter = $valfilter"
                continue
            fi
            header=$(echo "${colnames[*]}" | tr ' ' ':')
            print_table "$header" "$result"
            ;;
        4)
            echo "Available Columns:"
            for i in "${!colnames[@]}"; do
                echo "  $((i+1))- ${colnames[$i]}"
            done
            read -p "Enter column name(s) separated by comma: " selcols
            IFS=',' read -ra cols <<< "$selcols"
            idxs=()
            for col in "${cols[@]}"; do
                col=$(echo "$col" | xargs)
                found=false
                for i in "${!colnames[@]}"; do
                    if [[ "${colnames[$i]}" == "$col" ]]; then
                        idxs+=($((i+1)))
                        found=true
                        break
                    fi
                done
                if ! $found; then
                    echo "Column '$col' not found. Skipping."
                fi
            done

            if [[ ${#idxs[@]} -eq 0 ]]; then
                echo "No valid columns selected."
                continue
            fi

            selnames=()
            for i in "${idxs[@]}"; do
                selnames+=("${colnames[$((i-1))]}")
            done

            header=$(echo "${selnames[*]}" | tr ' ' ':')
            data=$(awk -F: -v cols="${idxs[*]}" '
                BEGIN { split(cols, c, " ") }
                {
                    line=""
                    for(i in c){
                        if(line != "") line = line ":"
                        line = line $c[i]
                    }
                    print line
                }' "$table")
            print_table "$header" "$data"
            ;;
        *)
            echo "Invalid option. Try again."
            continue
            ;;
    esac

    echo
    echo "Next Action:"
    echo "1) Select from Another Table"
    echo "2) Return to Main Menu"
    echo "3) Exit"
    read -p "#? " next

    case $next in
        1) continue ;;
        2) ./db_operations_menu.sh; break ;;
        3) echo "Exiting... Goodbye!"; break ;;
        *) echo "Invalid option. Returning to Main Menu..."; ./db_operations_menu.sh; break ;;
    esac
done

