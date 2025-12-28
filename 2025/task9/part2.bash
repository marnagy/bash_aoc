#!/bin/bash

abs() {
    local num=$1

    if [[ "$num" -lt 0 ]]
    then
        num="-$num"
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

create_red_point() {
    local x=$1
    local y=$2

    echo -n "RED" > "point_${x}_${y}.tmp"
}

create_green_point() {
    local x=$1
    local y=$2

    echo -n "GREEN" > "point_${x}_${y}.tmp"
}

create_line() {
    local point1_index=$1
    local point2_index=$2

    IFS=',' read -r -a point1_nums < "index_${point1_index}.tmp"
    IFS=',' read -r -a point2_nums < "index_${point2_index}.tmp"

    echo "Creating line between ${point1_nums[*]} and ${point2_nums[*]}" >> /dev/stderr

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

    local current_coord=0
    if [[ "$coord_diff" -gt 0 ]]
    then
        # echo "Positive coord diff" >> /dev/stderr
        for ((current_coord=1; current_coord<coord_diff; current_coord++))
        do
            local green_point_coords=("" "")
            green_point_coords[other_coord_index]="$const_coord"
            local green_point_num=$(( point1_nums[coord_index] - current_coord ))
            green_point_coords[coord_index]="$green_point_num"
            echo "Green point coords: ${green_point_coords[*]}" >> /dev/stderr
            create_green_point "${green_point_coords[@]}"
        done
    else
        # echo "Negative coord diff" >> /dev/stderr
        for ((current_coord=1; current_coord<-coord_diff; current_coord++))
        do
            local green_point_coords=("" "")
            green_point_coords[other_coord_index]="$const_coord"
            local green_point_num=$(( point1_nums[coord_index] + current_coord ))
            green_point_coords[coord_index]="$green_point_num"
            echo "Green point coords: ${green_point_coords[*]}" >> /dev/stderr
            # echo "Green point coords: Var coord: ${green_point_num} Const coord: ${const_coord}" >> /dev/stderr
            create_green_point "${green_point_coords[@]}"
        done
    fi
}

line_index=0
max_horizontal_coord=0
while read -r line
do
    echo -n "$line" > "index_${line_index}.tmp"
    IFS=',' read -r -a coords <<< "$line"

    if [[ "${coords[0]}" -gt "$max_horizontal_coord" ]]
    then
        max_horizontal_coord="${coords[0]}"
    fi

    create_red_point "${coords[0]}" "${coords[1]}"

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

# go over horizontal lines to "fill-in" points in between points



# the rectangle is inside if all points on the perimeter of it are inside.

# echo "Max area found: ${current_max_area}" >> /dev/stderr
# rm ./*.tmp
