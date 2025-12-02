#!/usr/bin/env bash

regex='^\([1-9][0-9]*\)\1$'

counter=0
while read -r -d ',' range
do
    printf "Processing %s\n" "$range" # logging
    nums=(${range//-/ })
    start=${nums[0]}
    end=${nums[1]}
    
    #?: faster then "for" loop over individual numbers, not sure why
    repeating_nums=$(seq -f %1.0f "$start" "$end" | grep "$regex")
    for val in $repeating_nums
    do
        ((counter+=val))
    done
done < "${1:-/dev/stdin}"

echo "Counter total: $counter"
