#!/bin/bash

rm ./*.tmp 2> /dev/null || echo "All temp files removed."
master_counter=0
while read -r line
do
    # echo "Line: '$line'" > /dev/stderr
    nums=$(echo "$line" | tr -s ' ' | tr " " "\n")
    # echo "Line nums:" "${nums}" > /dev/stderr
    # if (( line_length == 0 ))
    # then
    #     line_length="${#nums[@]}"
    # fi

    if grep '^[0-9 ]\+$' > /dev/null <<< "$line"
    then
        # echo "Num LINE"
        num_index=0
        while read -r num
        do
            # echo "Num:" "$num"
            echo "$num" >> "$num_index.tmp"
            ((num_index++))
        done <<< "$nums"
    else
        # echo "Operations line"
        op_index=0
        while read -r op
        do
            loc_counter=0
            if [[ "$op" == "*" ]]
            then # *
                loc_counter=1
            else # +
                loc_counter=0
            fi

            while read -r num
            do
                if [[ "$op" = "*" ]]
                then # *
                    ((loc_counter*=num))
                else # +
                    ((loc_counter+=num))
                fi
            done < "$op_index.tmp"
            echo "Local counter:" "$loc_counter"
            ((master_counter+=loc_counter))
            ((op_index++))
        done <<< "$nums"
    fi

    ((line_counter++))
done < "${1:-/dev/stdin}"

echo "Master counter:" "$master_counter"

rm ./*.tmp 2> /dev/null && echo "All temp files removed."
