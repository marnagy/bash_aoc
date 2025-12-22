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


echo "Drawing map..." >> /dev/stderr
current_max_area=0
for ((i=0; i<line_index; i++))
do
    echo
done

rm ./*.tmp

# the rectangle is inside if all points on the perimeter of it are inside.

echo "Max area found: ${current_max_area}" >> /dev/stderr
