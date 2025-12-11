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

echo "Start beam index: ${start_beam_index}" > /dev/stderr

line_index=0
char_index=$start_beam_index

stack=( "$line_index,$char_index" )



rm ./*.tmp

