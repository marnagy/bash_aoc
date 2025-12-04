#!/bin/bash

neighbor_indices=$(seq -1 1)
count_neightbours() {
    local x=$1
    local y=$2
    local count=0

    local nx
    local ny
    for dx in $neighbor_indices
    do
        for dy in $neighbor_indices
        do
            if [[ ($dx -eq 0 && $dy -eq 0) || $count -ge 4 ]]
            then
                continue
            fi

            nx=$((x + dx))
            ny=$((y + dy))
            if [[ $nx -ge 0 && $nx -lt $lines_amount && $ny -ge 0 && $ny -lt $line_length ]]
            then
                local neighbor_char=${lines[$nx]:$ny:1}
                if [[ $neighbor_char == "@" ]]
                then
                    ((count++))
                fi
            fi
        done
    done
    echo $count
}

echo "Loading..."
lines=()
i=0
while read -r line
do
    lines+=("$line")
    ((i++))
done < "${1:-/dev/stdin}"

rolls_counter=0
line_length=${#lines[0]}
lines_amount=${#lines[@]}
for line_idx in `seq 0 $((lines_amount - 1))`
do
    echo "Processing line $((line_idx+1))/${lines_amount} ..." >> /dev/stderr
    for ((i=0; i<line_length; i++))
    do
        char=${lines[$line_idx]:$i:1}
        if [[ $char != "@" ]]
        then
            continue
        fi

        neighbour_count=$(count_neightbours $line_idx $i)

        if [[ $neighbour_count -lt 4 ]]
        then
            ((rolls_counter++))
        fi

    done
    printf "Current rolls counter: %s\n\n" "$rolls_counter" >> /dev/stderr
done

echo "Rolls counter: $rolls_counter"
