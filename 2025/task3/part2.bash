#!/bin/bash

batteries_amount=12
counter=0
while read -r line
do
    remaining_line=$line
    batteries_remaining=$batteries_amount
    line_number=0

    while [[ $batteries_remaining -gt "0" ]]
    do
        digits=$(echo -n "$remaining_line" | sed -e 's/\(.\)/\1\n/g') # split digits into separate lines
        # use `ghead` instead of `head`` for compatibility with macOS
        max_num=$(ghead -n "-$((batteries_remaining - 1))" <<< "$digits" | sort -nr | head -n 1)
        max_num_index=$(sed  "/^$max_num$/=;d" <<< "$digits" | head -n 1) # sed magic

        # update step
        remaining_line="${remaining_line:$((max_num_index))}"
        ((batteries_remaining-=1))
        ((line_number = line_number * 10 + max_num))
    done

    echo "Final combination: $line_number" > /dev/stderr # logging
    ((counter+= line_number))
done < "${1:-/dev/stdin}"

echo "Final sum: $counter"
