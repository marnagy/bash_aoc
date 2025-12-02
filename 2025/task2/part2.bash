#!/usr/bin/env bash

regex='^\([1-9][0-9]*\)\1\+$'

counter=0
while read -r -d ',' range # expects "," at the end of the line
do
    IFS=" " read -r -a nums <<< "${range//-/ }"
    start=${nums[0]}
    end=${nums[1]}
    
    repeating_nums=$(seq -f %1.0f "$start" "$end" | grep "$regex")
    for val in $repeating_nums
    do
        ((counter+=val))
    done
done < "${1:-/dev/stdin}"

echo "Counter total: $counter"
