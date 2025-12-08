#!/bin/bash

filename="$1"

## Read input file and remember at what indices are the "space columns".
space_indices=()
master_counter=0
while IFS='\n' read -r line
do
    line+=" "
    if [[ "${#space_indices[@]}" -eq 0 ]]
    then
        echo "Adding all indices as space indices." > /dev/stderr
        space_indices=("$(seq 0 $(( ${#line})) | tr '\n' ' ')")
    fi

    echo "Space indices: ${space_indices[@]}" > /dev/stderr
    
    for (( i=0; i<"${#line}"; i++ ))
    do
        # echo "Testing character '${line:i:1}' at index $i" > /dev/stderr
        if [[ "${line:i:1}" != " " ]]
        then
            echo "Removing index $i from space indices." > /dev/stderr
            space_indices=("${space_indices[@]/$i}")
        fi
        # echo "Char: '${line:i:1}' at index $i" > /dev/stderr
    done
    echo "Space indices: ${space_indices[@]}" > /dev/stderr
done < "$filename"

echo "Indices loaded before truncating: ${space_indices[@]}" > /dev/stderr

space_indices=( $(tr -s " " <<< "${space_indices[@]}") )

echo "Indices loaded: ${space_indices[@]}" > /dev/stderr

# split file into temp file for each column
while IFS='\n' read -r line
do
    echo "Processing line: '$line'" > /dev/stderr
    current_indices_index=0
    for (( i=0; i<"${#line}"; i++ ))
    do
        echo "Comparing index $i with space index ${space_indices[$current_indices_index]}" > /dev/stderr
        if [[ "$i" -lt "${space_indices[$current_indices_index]}" ]]
        then
        upper_bound=${space_indices[$current_indices_index]}
        else
            upper_bound=${#line}
        fi
            col_digit_idx=$((i - ${space_indices[$((current_indices_index - 1))]} - 1))
            echo "${line:i:1}" >> "numcol_${current_indices_index}_col_${col_digit_idx}.tmp"
        else
            ((current_indices_index++))
        fi
    done
done < "$filename"

echo "Master counter:" "$master_counter"

# rm ./*.tmp 2> /dev/null && echo "All temp files removed."
