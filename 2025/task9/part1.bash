#!/bin/bash

abs() {
    local num=$1

    if [[ "$num" -lt 0 ]]
    then
        ((num=-num))
    fi

    echo "$num"
}

compute_area() {
    local x1=$1
    local y1=$2
    local x2=$3
    local y2=$4

    x_diff=$(abs $((x1 - x2 + 1)))
    y_diff=$(abs $((y1 - y2 + 1)))

    area=$((x_diff * y_diff))

    echo "$area"
}

line_index=0
while read -r line
do
    echo -n "$line" > "point_${line_index}.tmp"

    ((line_index++))
done < "${1:-/dev/stdin}"

current_max_area=0
for ((i=0; i<line_index; i++))
do
    echo "Computing areas for index $i" >> /dev/stderr
    for ((j=i+1; j<line_index; j++))
    do
        IFS=',' read -r -a point1_nums < "point_${i}.tmp"
        IFS=',' read -r -a point2_nums < "point_${j}.tmp"

        area=$(compute_area "${point1_nums[0]}" "${point1_nums[1]}" "${point2_nums[0]}" "${point2_nums[1]}")

        if [[ "$area" -gt "$current_max_area" ]]
        then
            current_max_area="$area"
        fi
    done
done

echo "Max area found: ${current_max_area}" >> /dev/stderr
