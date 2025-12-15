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

# master_counter=0
line_index=0
beam_indices=()
split_counter=0
while read -r line
do
    if (( line_index == 0 ))
    then
        # find index of S
        beam_index=$(find_indices "S" "$line")
        beam_indices+=("$beam_index")
        ((line_index++))
        continue
    fi

    new_beam_indices=()
    for index in "${beam_indices[@]}"
    do
        if [[ "${line:$index:1}" == "^" ]]
        then
            # split beam
            ((split_counter++))
            idx1="$((index-1))"
            if ! [[ " ${new_beam_indices[@]} " =~ " ${idx1} " ]]
            then
                new_beam_indices+=( "${idx1}" )
            fi

            idx2="$((index+1))"
            if ! [[ " ${new_beam_indices[@]} " =~ " ${idx2} " ]]
            then
                new_beam_indices+=( "${idx2}" )
            fi
        else
            # continue beam
            if ! [[ " ${new_beam_indices[@]} " =~ " ${index} " ]]
            then
                new_beam_indices+=( "${index}" )
            fi
        fi
    done
    beam_indices=( "${new_beam_indices[@]}" )
done < "${1:-/dev/stdin}"

echo "Split count: ${split_counter}" > /dev/stderr
