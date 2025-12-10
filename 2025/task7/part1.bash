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
        # echo "Beam index: ${beam_index}" > /dev/stderr
        beam_indices+=("$beam_index")
        ((line_index++))
        continue
    fi

    # echo "Processing line: ${line}" > /dev/stderr
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
                # ((split_counter++))
            fi
        else
            # continue beam
            if ! [[ " ${new_beam_indices[@]} " =~ " ${index} " ]]
            then
                new_beam_indices+=( "${index}" )
            fi
            # new_beam_indices+=( "$index" )
        fi
    done
    # echo "New beam indices: ${new_beam_indices[@]}" > /dev/stderr
    # echo "Split count: ${split_counter}" > /dev/stderr
    beam_indices=( "${new_beam_indices[@]}" )
done < "${1:-/dev/stdin}"

# echo "Beams count: ${#beam_indices[@]}" > /dev/stderr
echo "Split count: ${split_counter}" > /dev/stderr

# tr " " "\n" <<< "${beam_indices[@]}" | cat > /dev/stderr

# echo "Master counter:" "$master_counter"

# rm ./*.tmp 2> /dev/null && echo "All temp files removed."
