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

    # echo "Recursive step from ${line_index}:${char_index}" >> /dev/stderr
    # echo "Current index: ${current_counter}" >> /dev/stderr
    # echo "Current file line_${line_index}.tmp" >> /dev/stderr

    # test -e "line_${line_index}.tmp"

    if ! [[ -f "line_${line_index}.tmp" ]]
    then
        new_counter=1
        echo "${new_counter}"
        return
    fi

    # if not split, recurse further
    # echo "Reading file line_${line_index}.tmp" >> /dev/stderr
    current_line=$(<"line_${line_index}.tmp")
    current_char=${current_line:$char_index:1}
    # echo "Current char: ${current_char}" >> /dev/stderr
    
    if [[ "${current_char}" != "^" ]]
    then
        recursive_step "$((line_index + 1))" "$char_index"
        return
    fi

    counter_after1=$(recursive_step "$((line_index + 1))" "$((char_index + 1))")
    counter_after2=$(recursive_step "$((line_index + 1))" "$((char_index - 1))")

    echo "$(( counter_after1 + counter_after2 ))"
}

## Solve using DFS (how the hell do I implement DFS in Bash??)

# save each line to file with corresponding line index

line_index=0
while read -r line
do
    echo -n "$line" > "line_${line_index}.tmp"
    ((line_index++))
done < "${1:-/dev/stdin}"


first_line=$(<"line_0.tmp")
start_beam_index=$(find_indices "S" "$first_line")

# echo "Start beam index: ${start_beam_index}" > /dev/stderr

line_index=0
char_index=$start_beam_index

recursive_step 0 "$char_index"

rm ./*.tmp

