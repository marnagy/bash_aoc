#!/bin/bash

filename="$1"

## Read input file and remember at what indices are the "space columns".
space_indices=""
master_counter=0
while IFS=$'\n' read -r line
do
    line+=" "
    if [[ "${#space_indices}" -eq 0 ]]
    then
        space_indices="$(seq 0 $(( ${#line} - 1)) )"
    fi


    for ((i=0; i<"${#line}"; i++))
    do
        if [[ "${line:$i:1}" != " " ]]
        then
            space_indices=$(grep -v "^$i$" <<< "$space_indices")
        fi
    done
done < "$filename"

space_indices=( $(tr "\n" " " <<< "$space_indices") )

# echo "Transformed into array:" "${space_indices[@]}" > /dev/stderr

while IFS=$'\n' read -r line
do
    line+=" "
    if grep "^[0-9 ]\+$" 2>&1 > /dev/null <<< "$line"
    then
        next_space_index=0
        for ((line_index=0; line_index<"${#line}"; line_index++))
        do
            if [[ "$line_index" -lt "${space_indices[$next_space_index]}" ]]
            then
                digit="${line:$line_index:1}"
                if [[ "$digit" == " " ]]
                then
                    continue
                fi
                echo -n "$digit" >> "col_${next_space_index}_idx_${line_index}.tmp"
            else
                ((next_space_index++))
            fi
        done
    else
        # operations line
        operations=$(tr -s " " <<< "$line")

        col_idx=0
        while IFS=" " read -r op
        do
            local_counter=0
            if [[ "$op" == "*" ]]
            then
                local_counter=1
            fi
            for file in col_${col_idx}_idx_*.tmp
            do
                content="$(<"$file")"
                if [[ "$op" == "+" ]]
                then
                    ((local_counter+=content))
                else
                    ((local_counter*=content))
                fi 
            done
            ((master_counter+=local_counter))
            ((col_idx++))
        done <<< "$(tr " " "\n" <<< "$operations")"
    fi
done < "$filename"

echo "Final count: ${master_counter}" > /dev/stderr

rm ./*.tmp 2> /dev/null && echo "All temp files removed."
