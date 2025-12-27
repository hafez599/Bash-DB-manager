#!/bin/bash
source ./Validation.sh
DBNAME=$1

while true; do  
    read -p "Please Enter Table Name " tname
    table="./Databases/$DBNAME/$tname.SQL"
    metadata="./Databases/$DBNAME/.$tname.metadata"
    dararow=""
    sep=":"
    typeset -i counter=0
    if [[ -f $table ]]; then
        pk=$(awk -F: 'NR==1 {print $2}' $metadata)
        colnum=$(awk -F: 'NR==2 {print NF}' $metadata)
        mapfile -t namesarray < <(awk -F: 'NR==2 {for(i=1;i<=NF;i++) print $i}' $metadata)
        mapfile -t datatypearray < <(awk -F: 'NR==3 {for(i=1;i<=NF;i++) print $i}' $metadata)
        mapfile -t pkarray < <(awk -F: '{print $1}' $table)
        flag=false
        echo "number of field is $colnum \n" 
        echo "PK is $pk"
        
        for (( i=0;i<$colnum;i++ )); do
            while true; do
                flag=false
                read -p "Please enter data for $((i+1)) column " coldata
                if [[ $i -eq 0 && $pk == "yes" ]]; then
                    if ! contain_PK "$coldata"  "${pkarray[@]}"; then
                        continue
                    else
                        if [[ ${datatypearray[$i]} == "int" ]]; then
                            if ! is_number "$coldata"; then
                                continue
                            else
                                dararow="$dararow$sep$coldata"
                                break
                            fi
                        else
                            dararow="$dararow$sep$coldata"
                            break
                        fi
                    fi
                else
                    if [[ ${datatypearray[$i]} == "int" ]]; then
                            if ! is_number "$coldata"; then
                                continue
                            else
                                dararow="$dararow$sep$coldata"
                                break
                            fi
                    else
                        dararow="$dararow$sep$coldata"
                        break
                    fi
                fi

        done
        done
    else 
        echo "Table not found"\n
        echo "please try agian"\n
        continue
    fi
    dararow="${dararow#$sep}"
    printf '%s\n' "$dararow" >> "$table"
    
    select option in "Insert Another Record" "Return To Main Menu"; do
        case $option in
            "Insert Another Record")
                break;;
            "Return To Main Menu")
                break 2;;
            *)
                echo "please enter a vaild input";;
        esac
    done
done
