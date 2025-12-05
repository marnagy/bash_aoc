#!/bin/bash

low_ranges=()
high_ranges=()

is_in_ranges() {
    local id=$1
    for i in "${!low_ranges[@]}"
    do
        if (( id >= low_ranges[i] && id <= high_ranges[i] ))
        then
            return 0
        fi
    done
    return 1
}

counter=0
ranges_loaded=false
while read -r line
do
    if [[ "$line" = "" ]]
    then
        ranges_loaded=true
        continue
    fi

    if ! $ranges_loaded
    then
        nums=(${line//-/ })
        low_ranges+=("${nums[0]}")
        high_ranges+=("${nums[1]}")
        continue
    fi

    if is_in_ranges "$line"
    then
        ((counter++))
    fi
done < "${1:-/dev/stdin}"

echo "Fresh counter: $counter"
