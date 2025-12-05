#!/bin/bash

all_intervals=()

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
        all_intervals+=("$line")
    fi

done < "${1:-/dev/stdin}"

sorted_intervals=($(echo "${all_intervals[@]}" | tr ' ' '\n' | sort -n -t "-" -k1 | tr '\n' ' '))

i=0
while (( i < ${#sorted_intervals[@]} ))
do
    if [[ $i -eq $((${#sorted_intervals[@]} - 1)) ]]
    then
        break
    fi

    interval1=(${sorted_intervals[$i]//-/ })
    interval1_low="${interval1[0]}"
    interval1_high="${interval1[1]}"
    interval2=(${sorted_intervals[$((i + 1))]//-/ })
    interval2_low="${interval2[0]}"
    interval2_high="${interval2[1]}"

    if (( interval1_high >= interval2_low - 1 ))
    then
        if (( interval1_high <= interval2_high ))
        then
            # Merge intervals
            sorted_intervals[$i]="${interval1_low}-${interval2_high}"
        fi
        # Remove interval2
        sorted_intervals=("${sorted_intervals[@]:0:$((i+1))}" "${sorted_intervals[@]:$((i + 2))}")
    else
        ((i++))
    fi
done

ids_counter=0
for interval in "${sorted_intervals[@]}"
do
    nums=(${interval//-/ })
    low="${nums[0]}"
    high="${nums[1]}"

    ((ids_counter+=high-low+1))
done

echo "Total merged intervals count: $ids_counter"
