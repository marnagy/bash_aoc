#!/bin/bash

find_indices() {
    local char=$1
    local line=$2

    for ((i=0; i<${#line}; i++))
    do
        if [[ "$char" == "${line:$i:1}" ]]
        then
            echo "$i"
        fi
    done
}

compute_distance() {
    local x1=$1
    local y1=$2
    local z1=$3
    local x2=$4
    local y2=$5
    local z2=$6

    local sq_diff_x=$(( (x2 - x1) ** 2 ))
    local sq_diff_y=$(( (y2 - y1) ** 2 ))
    local sq_diff_z=$(( (z2 - z1) ** 2 ))

    local summed_sq=$(( sq_diff_x + sq_diff_y + sq_diff_z ))

    result=$(( summed_sq ** 0.5 ))

    echo "${result}"
}


while read -r line
do

done < "${1:-/dev/stdin}"

echo "Split count: ${split_counter}" > /dev/stderr
