#!/bin/bash

source ../lib.bash

# file_name="tut.in"
filename=$1

first_col_nums=()
second_col_nums=()
line=""
while read line
do
    # echo "Line:" $line
    parts=()
    for part in "$line"
    do
        parts+=($part)
    done
    # echo "First:" ${parts[0]}
    # echo "Second:" ${parts[1]}

    first_col_nums+=(${parts[0]})
    second_col_nums+=(${parts[1]})
done < $filename


# echo "First nums:" ${first_col_nums[@]}
# echo "Second nums:" ${second_col_nums[@]}

first_col_nums=( $( printf "%s\n" "${first_col_nums[@]}" | sort -n ) )
second_col_nums=( $( printf "%s\n" "${second_col_nums[@]}" | sort -n ) )
# echo "After sort:"
# echo "First nums:" ${first_col_nums[@]}
# echo "Second nums:" ${second_col_nums[@]}

arr_len="${#first_col_nums[@]}"
differences=()
for i in $(seq 0 $(($arr_len - 1)) )
do
    num1=${first_col_nums[$i]}
    # echo "Num1:" $num1
    num2=${second_col_nums[$i]}
    # echo "Num2:" $num2
    difference=`expr $num1 - $num2`
    # echo "Difference:" $difference
    abs_difference="${difference/#-}"
    # echo "Abs difference:" $abs_difference
    # echo "Absolute difference:" $abs_difference
    differences+=($abs_difference)
done

# echo "All differences:" ${differences[@]}

summed=$(sum ${differences[@]})
echo "Result:" $summed
