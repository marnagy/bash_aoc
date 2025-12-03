#!/bin/bash

batteries_on_amount=2


while read -r line
do
    printf "Processing line %s\n" "$line"

    echo -n "12345" | ghead -n -1 | sed -e 's/\(.\)/\1\n/g'

done < "${1:-/dev/stdin}"

