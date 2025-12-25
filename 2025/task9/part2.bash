#!/bin/bash

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

create_line() {
    local point1_index=$1
    local point2_index=$2

    IFS=',' read -r -a point1_nums < "point_${point1_index}.tmp"
    IFS=',' read -r -a point2_nums < "point_${point2_index}.tmp"

    # check if horizontal or vertical

    # for each point that is not RED, create a file with "LINE"
    local coord_index=0 # horizontal
    local other_coord_index=1
    if [[ "${point1_nums[0]}" -eq "${point2_nums[0]}" ]]
    then
        coord_index=1
        other_coord_index=0
    fi

    local const_coord="${point1_nums[$other_coord_index]}"

    echo "Difference coord: ${coord_index}" >> /dev/stderr
    local point1_num="${point1_nums[$coord_index]}"
    local point2_num="${point2_nums[$coord_index]}"
    local coord_diff=$(( point1_num - point2_num ))
    echo "Coord diff: ${coord_diff}" >> /dev/stderr

    local index_multiplier="1"
    if [[ "$coord_diff" -lt 0 ]]
    then
        index_multiplier="-1"
    fi

    # !: wrong condition
    # ?: Why though?
    for ((i=1; i<coord_diff-1; i+1))
    do
        if [[ "$coord_index" -eq 0 ]]
        then
            green_point_num=$(( point1_nums[coord_index] + i * index_multiplier ))
            echo "Green point coords: ${green_point_num}-${const_coord}" >> /dev/stderr
        fi
    done
}

line_index=0
while read -r line
do
    echo -n "$line" > "point_${line_index}.tmp"
    echo -n "RED" > "${line}.tmp"

    ((line_index++))
done < "${1:-/dev/stdin}"


echo "Connecting red points..." >> /dev/stderr
for ((i=0; i<line_index; i++))
do
    next_point_index=$((i+1))
    if [[ "$next_point_index" -eq "$line_index" ]]
    then
        next_point_index=0
    fi

    # "connect" points
    create_line "$i" "$next_point_index"
done

# rm ./*.tmp

# the rectangle is inside if all points on the perimeter of it are inside.

# echo "Max area found: ${current_max_area}" >> /dev/stderr
