#!/bin/bash

filename="$1"

## Read input file and remember at what indices are the "space columns".
space_indices=""
master_counter=0
while IFS='\n' read -r line
do
    # add space at the end so we can split line later more effectively
    line+=" "
    if [[ "${#space_indices}" -eq 0 ]]
    then
        # echo "Adding all indices as space indices." > /dev/stderr
        space_indices="$(seq 0 $(( ${#line} - 1)) )"
    fi


    for ((i=0; i<"${#line}"; i++))
    do
        # echo "Comparing char" "${line:$i:1}" > /dev/stderr
        if [[ "${line:$i:1}" != " " ]]
        then
            space_indices=$(grep -v "^$i$" <<< "$space_indices")
        fi
    done

    # echo "Space indices:" "$(tr '\n' ' ' <<< "$space_indices")" > /dev/stderr
done < "$filename"

# echo "Indices loaded: ${space_indices}" > /dev/stderr

space_indices=( $(tr "\n" " " <<< "$space_indices") )

echo "Transformed into array:" "${space_indices[@]}" > /dev/stderr

while IFS='\n' read -r line
do
    line+=" "
    if grep "^[0-9 ]\+$" <<< "$line"
    then
        next_space_index=0
        for ((line_index=0; line_index<"${#line}"; line_index++))
        do
            # echo "Comparing char '${line:$line_index:1}' col ${next_space_index}" > /dev/stderr
            if [[ "$line_index" -lt "${space_indices[$next_space_index]}" ]]
            then
                # echo "$line_index < ${space_indices[$next_space_index]}" > /dev/stderr
                digit="${line:$line_index:1}"
                if [[ "$digit" == " " ]]
                then
                    continue
                fi
                echo -n "$digit" >> "col_${next_space_index}_idx_${line_index}.tmp"
            else
                # echo "Same index!" > /dev/stderr
                ((next_space_index++))
            fi
        done
        echo "" > /dev/stderr
    else
        # echo "OP line" > /dev/stderr
        operations=$(tr -s " " <<< "$line")

        col_idx=0
        while IFS=" " read -r op
        do
            # echo "OP: ${op}" > /dev/stderr
            local_counter=0
            if [[ "$op" == "*" ]]
            then
                local_counter=1
            fi
            for file in col_${col_idx}_idx_*.tmp
            do
                # echo "Filename: ${file}" > /dev/stderr
                content="$(<"$file")"
                # echo "File content: ${content}" > /dev/stderr
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
