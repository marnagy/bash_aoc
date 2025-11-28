#!/bin/bash

# shellcheck source=../lib.bash
source ../lib.bash

# file_name="tut.in"
filename=$1

first_col_nums=()
second_col_nums=()
line=""
while read -r line
do
    # echo "Line:" $line
    parts=()
    for part in $line
    do
        parts+=("$part")
    done
    # echo "First:" ${parts[0]}
    # echo "Second:" ${parts[1]}

    first_col_nums+=("${parts[0]}")
    second_col_nums+=("${parts[1]}")
done < "$filename"

master_counter="0"
for num in "${first_col_nums[@]}"
do
    # echo "Num:" "$num"
    count_local=$(count_occurences "$num" "${second_col_nums[@]}")
    # echo "Count local:" "$count_local"
    master_counter=$(( master_counter + (num * count_local) ))
    # counters+=("$count_local")
done

echo "Result:" "$master_counter"
