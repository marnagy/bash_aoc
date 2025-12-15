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

recursive_step() {
    local line_index=$1
    local char_index=$2

    # check cache
    if [[ -f "cache_${line_index}_${char_index}.tmp" ]]
    then
        cached_value=$(<"cache_${line_index}_${char_index}.tmp")
        echo "${cached_value}"
        return
    fi

    if ! [[ -f "line_${line_index}.tmp" ]]
    then
        new_counter=1
        echo "${new_counter}"
        return
    fi

    current_line=$(<"line_${line_index}.tmp")
    current_char=${current_line:$char_index:1}
    
    # if not split, recurse further down
    if [[ "${current_char}" != "^" ]]
    then
        recursive_step "$((line_index + 1))" "$char_index"
        return
    fi

    # if split, recurse both ways and sum
    counter_after1=$(recursive_step "${line_index}" "$((char_index + 1))")
    counter_after2=$(recursive_step "${line_index}" "$((char_index - 1))")
    summed=$(( counter_after1 + counter_after2 ))

    # save to "cache"
    echo "${summed}" > cache_${line_index}_${char_index}.tmp

    echo "${summed}"
}

## Solve using DFS + memoization (caching)
# save each line to file with corresponding line index (makeshift dictionary)
line_index=0
while read -r line
do
    echo -n "$line" > "line_${line_index}.tmp"
    ((line_index++))
done < "${1:-/dev/stdin}"


first_line=$(<"line_0.tmp")
start_beam_index=$(find_indices "S" "$first_line")

line_index=0
char_index=$start_beam_index

recursive_step 0 "$char_index"

# cleanup cache and temp files
rm ./*.tmp

