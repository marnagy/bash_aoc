#!/bin/bash

compute_distance() {
    # number 1
    local x1=$1
    local y1=$2
    local z1=$3
    # number 2
    local x2=$4
    local y2=$5
    local z2=$6

    local sq_diff_x=$(( (x2 - x1) ** 2 ))
    local sq_diff_y=$(( (y2 - y1) ** 2 ))
    local sq_diff_z=$(( (z2 - z1) ** 2 ))

    local summed_sq=$(( sq_diff_x + sq_diff_y + sq_diff_z ))

    # echo "Squared summed: ${summed_sq}" >> /dev/stderr

    result=$(echo sqrt "($summed_sq)" | bc -l)

    echo "${result}"
}


line_index=0
while read -r line
do
    echo "Current line: ${line}" >> /dev/stderr
    IFS=',' read -r -a nums <<< "$line"
    echo "Nums: ${nums[@]}" >> /dev/stderr
    echo "Num1: ${nums[0]}" >> /dev/stderr
    echo "Num1: ${nums[1]}" >> /dev/stderr
    echo "Num1: ${nums[2]}" >> /dev/stderr

    echo -n "${nums[@]}" > "num_${line_index}.tmp"
    ((line_index++))
done < "${1:-/dev/stdin}"

((line_index-=1))

echo "Max ID: ${line_index}" >> /dev/stderr

echo -n "" > "distances.csv.tmp"

for i in $(seq 0 $line_index)
do
    start_j=$((i + 1))
    for j in $(seq $start_j $line_index)
    do
        # echo "Coords: ${i}-${j}" >> /dev/stderr

        IFS=' ' read -r -a num1_nums < "num_${i}.tmp"
        IFS=' ' read -r -a num2_nums < "num_${j}.tmp"

        # echo "Nums1: ${num1_nums[*]}" >> /dev/stderr
        # echo "Nums2: ${num2_nums[*]}" >> /dev/stderr

        distance=$(compute_distance "${num1_nums[0]}" "${num1_nums[1]}" "${num1_nums[2]}" "${num2_nums[0]}" "${num2_nums[1]}" "${num2_nums[2]}")

        # echo "Distance for ${i}-${j}: ${distance}" >> /dev/stderr

        echo "${i},${j},${distance}" >> "distances.csv.tmp"
    done
done

for line in $(sort -rn -t "," -k3,3 "distances.csv.tmp" | head -n 5)
do
    IFS=',' read -r -a pair_values <<< "$line"

    echo "Reading coords with index ${pair_values[0]}" >> /dev/stderr
    IFS=' ' read -r -a num1_nums < "num_${pair_values[0]}.tmp"
    echo "Reading coords with index ${pair_values[1]}" >> /dev/stderr
    IFS=' ' read -r -a num2_nums < "num_${pair_values[1]}.tmp"
done

# rm ./*.tmp && echo "Deleted .tmp files" >> /dev/stderr
