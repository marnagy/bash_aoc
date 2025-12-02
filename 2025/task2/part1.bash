#!/usr/bin/env bash

# shellcheck source=../lib.bash
source ../../lib.bash
regex='^\([1-9][0-9]*\)\1$'

is_number_repeating() {
    local number=$1

    echo $(grep -F "$regex" <<< "$number")
}

counter=0
while read -r -d ',' range
do
    echo $range
    nums=(${range//-/ })
    start=${nums[0]}
    end=${nums[1]}

    # for i in {"$start".."$end"}
    for i in `seq -f %1.0f "$start" "$end"`
    do
        # echo "Number:" "$i"
        if [ "$(is_number_repeating "$i")" ]; then
            ((counter+=i))
        fi
    done
done < "${1:-/dev/stdin}"

echo "Counter total: $counter"
