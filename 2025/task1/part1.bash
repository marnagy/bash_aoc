#!/bin/bash

# shellcheck source=../lib.bash
source ../../lib.bash

filename=$1
total_num="100"


current_num="50"
master_counter="0"
while read -r line
do
    # echo "Current num:" "$current_num"
    # echo "$line"
    # echo "${line:0:1}"
    if [[ "${line:0:1}" = 'R' ]]
    then
        is_right="1"
    else
        is_right="-1"
    fi
    # echo "Is right:" $is_right
    num="${line:1}"

    current_num=$(( current_num + is_right * num ))
    if [[ "$current_num" -lt "0" ]]
    then
        current_num=$(( current_num + total_num ))
    fi
    current_num=$(( current_num % total_num ))

    # count
    if [[ "$current_num" = "0" ]]
    then
        master_counter=$(( master_counter + 1 ))
    fi
done < "$filename"

# echo "Current num:" "$current_num"

echo "Counter:" "$master_counter"

