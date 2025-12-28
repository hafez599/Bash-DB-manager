#!/bin/bash
validate_name(){
    name=$1

    if [[ -z $name ]]; then
        echo "Name Cannot Be Empty."
        return 1
    fi

    if [[ ${#name} -gt 255 ]]; then 
        echo "name cannot exceed 255 charcters."
        return 1
    fi

    if [[ ! $name =~ ^[a-zA-Z_] ]]; then
        echo "Error: Name must start with a letter or underscore"
        return 1
    fi

    if [[ ! $name =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Error: Name can only contain letters, numbers, and underscores"
        return 1
    fi

    return 0
}
is_number(){
    num=$1

    if [[ -z $num ]]; then
        echo "Data Cannot Be Empty."
        return 1
    fi

    if [[ ! $num =~ ^[0-9]+$ ]]; then
        echo "Error: Column must start with a number"
        return 1
    fi

    return 0
}
contain_PK(){
    search_value="$1"
    shift
    pkarray=("$@")
    for val in "${pkarray[@]}"; do
        if [[ "$val" == "$search_value" ]]; then
            return 1 
        fi
    done
    return 0 
}
