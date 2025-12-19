#!/bin/bash

shopt -s extglob

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

get_cluster_id() {
    local node_id=$1
    cat "node_${node_id}_to_cluster_id.tmp"
}

get_current_cluster_count() {
    ls -al | grep -c " cluster"
}

line_index=0
while read -r line
do
    node_index="$line_index"
    # echo "Current line: ${line}" >> /dev/stderr
    IFS=',' read -r -a nums <<< "$line"
    # echo "Nums: ${nums[@]}" >> /dev/stderr
    # echo "Num1: ${nums[0]}" >> /dev/stderr
    # echo "Num1: ${nums[1]}" >> /dev/stderr
    # echo "Num1: ${nums[2]}" >> /dev/stderr

    # save node coords
    echo -n "${nums[@]}" > "num_${node_index}.tmp"
    # save node -> cluster_id (default: node_id)
    echo -n "${node_index}" > "node_${node_index}_to_cluster_id.tmp"
    # save nodes for the given cluster
    echo "${node_index}" > "cluster_${node_index}.tmp"

    ((line_index++))
done < "${1:-/dev/stdin}"

((line_index-=1))

# echo "Max ID: ${line_index}" >> /dev/stderr

echo -n "" > "distances.csv.tmp"

for ((i=0; i<=line_index; i++))
do
    echo "Saving distance of index ${i}/${line_index} to file..." >> /dev/stderr
    # start_j=$((i + 1))
    IFS=' ' read -r -a num1_nums < "num_${i}.tmp"
    for ((j=i+1; j<=line_index; j++))
    do
        # echo "Saving distance index pair ${i}-${j} to file..." >> /dev/stderr
        # echo "Coords: ${i}-${j}" >> /dev/stderr

        IFS=' ' read -r -a num2_nums < "num_${j}.tmp"

        # echo "Nums1: ${num1_nums[*]}" >> /dev/stderr
        # echo "Nums2: ${num2_nums[*]}" >> /dev/stderr

        distance=$(compute_distance "${num1_nums[0]}" "${num1_nums[1]}" "${num1_nums[2]}" \
        "${num2_nums[0]}" "${num2_nums[1]}" "${num2_nums[2]}")

        # echo "Distance for ${i}-${j}: ${distance}" >> /dev/stderr

        echo "${i},${j},${distance}" >> "distances.csv.tmp"
    done
done

# rm ./num*.tmp

# max_connected_nodes=1000
max_connected_nodes=1000
# max_connected_nodes=2
current_node_pairs_connected=0
while read -r line
do
    # echo "Current node pairs connected count: ${current_node_pairs_connected}" >> /dev/stderr
    cluster_counter=$(get_current_cluster_count)
    echo "Current cluster count: $cluster_counter" >> /dev/stderr
    # if ! [[ "$current_node_pairs_connected" -lt "$max_connected_nodes" ]]
    # then
    #     echo "Enough pairs connected."
    #     break
    # fi

    IFS=',' read -r -a pair_values <<< "$line"
    node_id1="${pair_values[0]}"
    node_id2="${pair_values[1]}"

    # get cluster_id for node1
    cluster_id1=$(get_cluster_id "$node_id1")
    # get cluster_id for node2
    cluster_id2=$(get_cluster_id "$node_id2")

    # if cluster_id1 == cluster_id2 then continue (don't raise counter)
    if [[ "$cluster_id1" -eq "$cluster_id2" ]]
    then
        ((current_node_pairs_connected++))    
        continue
    fi

    ## echo "Reading coords with index ${node_id1}" >> /dev/stderr
    IFS=' ' read -r -a num1_nums < "num_${node_id1}.tmp"
    # echo "Node1 coords: ${num1_nums[*]}" >> /dev/stderr
    ## echo "Reading coords with index ${node_id2}" >> /dev/stderr
    IFS=' ' read -r -a num2_nums < "num_${node_id2}.tmp"
    # echo "Node2 coords: ${num2_nums[*]}" >> /dev/stderr

    if [[ "$cluster_counter" -eq 2 ]]
    then
        res=$(( num1_nums[0] * num2_nums[0] ))
        echo "Final product: $res" >> /dev/stderr
        break
    fi

    # echo "Merging clusters ${cluster_id1} and ${cluster_id2}" >> /dev/stderr

    ## merge cluster2 into cluster1:
    while read -r cluster2_node_id
    do
        # echo "Cluster2 (${cluster_id2}) node id ${cluster2_node_id}" >> /dev/stderr
        # add cluster2.nodes to cluster1.nodes' file
        echo "$cluster2_node_id" >> "cluster_${cluster_id1}.tmp"
        #   rewrite cluster_id for node to cluster_id1
        echo -n "${cluster_id1}" > "node_${cluster2_node_id}_to_cluster_id.tmp"
    done < "cluster_${cluster_id2}.tmp"
    # remove cluster2.nodes file
    # echo "Removing cluster ${cluster_id2}" >> /dev/stderr
    rm "cluster_${cluster_id2}.tmp"


    ((current_node_pairs_connected++))
done <<< "$(sort -n -t "," -k3,3 "distances.csv.tmp")"

echo "Current cluster count:" >> /dev/stderr
echo cluster*.tmp | wc -l >> /dev/stderr

# get sizes of all clusters, sort by #lines and multiply top 3

if [[ -e "cluster_sizes.csv.tmp" ]]
then
    rm "cluster_sizes.csv.tmp"
fi

for cluster_file_name in ./cluster_*
do
    # echo "Cluster file name ${cluster_file_name}" >> /dev/stderr
    cluster_size=$(wc -l < "$cluster_file_name")
    # echo "Cluster size: ${cluster_size}" >> /dev/stderr
    echo "${cluster_file_name},${cluster_size}" >> "cluster_sizes.csv.tmp"
done

counter=1
while read -r line
do
    # echo "Cluster line $line" >> /dev/stderr
    IFS=',' read -r -a line_parts <<< "$line"
    cluster_size="${line_parts[1]}"
    ((counter *= cluster_size))
done <<< "$(sort -nr -t "," -k2,2 "cluster_sizes.csv.tmp" | head -n 3)"

echo "Final counter: $counter" >> /dev/stderr
echo "Final counter: $counter" > "result.txt"

# rm ./*.tmp && echo "Deleted .tmp files" >> /dev/stderr
