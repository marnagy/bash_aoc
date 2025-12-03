#!/bin/bash

counter=0
while read -r line
do
    # split digits into separate lines
    digits=$(echo -n "$line" | sed -e 's/\(.\)/\1\n/g')
    # use `ghead` instead of `head`` for compatibility with macOS
    max_first_num=$(ghead -n "-1" <<< "$digits" | sort -nr | head -n 1)
    # sed magic I don't fully understand (https://unix.stackexchange.com/a/707343)
    max_num_index=$(sed  "/^$max_first_num$/=;d" <<< "$digits" | head -n 1)
    last_digit=$(echo "${line:$max_num_index}" <<< "$digits" | sed -e 's/\(.\)/\1\n/g' | sort -nr | head -n 1)

    echo "Final combination: $max_first_num$last_digit" > /dev/stderr
    ((counter+= max_first_num * 10 + last_digit))
done < "${1:-/dev/stdin}"

echo "Final sum: $counter"
