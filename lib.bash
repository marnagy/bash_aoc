#!/bin/bash

sum() {
    local result="0"
    local values=("$@")

    # echo "Arguments:" $values
    for num in "${values[@]}"
    do
        # echo $num
        result=$(( result + num))
        # echo $result
    done

    echo $result
}

contains() {
    local item=$1
    shift 1
    local values=("$@")

    for num in "${values[@]}";
    do
        if [[ $num -eq $item ]]
        then
            # true
            return 0
        fi
    done
    # false
    return 1
}

count_occurences() {
    local item=$1
    shift 1
    local values=("$@")

    local counter="0"
    for num in "${values[@]}";
    do
        # echo "Checking $item agains $num"
        if [[ "$num" -eq "$item" ]];
        then
            counter=$(( counter + 1 ))
        fi
        # echo "Current counter:" "$counter"
    done

    echo $counter
}

# R52W7005CHB