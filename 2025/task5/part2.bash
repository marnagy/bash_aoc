#!/bin/bash

low_ranges=()
high_ranges=()

min() {
    local values=("$@")
    local min_value=${values[0]}
    for value in "${values[@]}"; do
        if (( value < min_value )); then
            min_value=$value
        fi
    done
    echo "$min_value"
}

max() {
    local values=("$@")
    local max_value=${values[0]}
    for value in "${values[@]}"; do
        if (( value > min_value )); then
            min_value=$value
        fi
    done
    echo "$min_value"
}

counter=0
ranges_loaded=false
while read -r line
do
    if [[ "$line" = "" ]]
    then
        ranges_loaded=true
        break
    fi

    if ! $ranges_loaded
    then
        nums=(${line//-/ })
        low_ranges+=("${nums[0]}")
        high_ranges+=("${nums[1]}")
        continue
    fi
done < "${1:-/dev/stdin}"

min_id=$(min "${low_ranges[@]}")
max_id=$(max "${high_ranges[@]}")

echo "Min ID: $min_id"
echo "Max ID: $max_id"

size=$((max_id - min_id + 1))

for ((num=0; num<=size; num++))
do
    id=$((min_id + num))
    echo "Checking ID $id [$((num+1))/$size]"
    found=false
    for i in $(seq 0 $((${#low_ranges[@]} - 1)))
    do
        # echo "I: $i"
        low=${low_ranges[$i]}
        high=${high_ranges[$i]}
        if [[ $id -ge $low && $id -le $high ]]
        then
            # echo "ID $id is in range $low-$high"
            found=true
            break
        fi
    done

    if $found
    then
        ((counter++))
    fi
done

echo "Fresh counter: $counter"
