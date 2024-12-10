#!/bin/bash

node_default=$((40))
flow_default=$((20))
packet_default=$((200))
speed_default=$((10))
unmodified=$((0))
modified=$((1))

tcl_file_to_run="wireless-802.15.4.tcl"

node_result_file="results/node.out"
flow_result_file="results/flow.out"
packet_result_file="results/packet.out"
speed_result_file="results/speed.out"

node_result_file_mod="results/node-modified.out"
flow_result_file_mod="results/flow-modified.out"
packet_result_file_mod="results/packet-modified.out"
speed_result_file_mod="results/speed-modified.out"

# $node_default $flow_default $packet_default $speed_default

# Varying nodes
>$node_result_file
>$node_result_file_mod
for i in 20 40 60 80 100
do
    echo "node $i " >> $node_result_file
    echo "node $i " >> $node_result_file_mod
    ns "$tcl_file_to_run" $unmodified $i $flow_default $packet_default $speed_default
    awk -f parse.awk trace.tr >> $node_result_file
    ns "$tcl_file_to_run" $modified $i $flow_default $packet_default $speed_default
    awk -f parse.awk trace.tr >> $node_result_file_mod
done
python3 mergedGraphGenerator.py $node_result_file $node_result_file_mod "node"

# Varying flows
>$flow_result_file
>$flow_result_file_mod
for i in 10 20 30 40 50
do
    echo "flow $i " >> $flow_result_file
    echo "flow $i " >> $flow_result_file_mod
    ns "$tcl_file_to_run" $unmodified $node_default $i $packet_default $speed_default
    awk -f parse.awk trace.tr >> $flow_result_file
    ns "$tcl_file_to_run" $modified $node_default $i $packet_default $speed_default
    awk -f parse.awk trace.tr >> $flow_result_file_mod
done



# Varying speed
>$speed_result_file
>$speed_result_file_mod
for i in 5 10 15 20 25
do
    echo "speed $i " >> $speed_result_file
    echo "speed $i " >> $speed_result_file_mod
    ns "$tcl_file_to_run" $unmodified $node_default $flow_default $packet_default $i
    awk -f parse.awk trace.tr >> $speed_result_file
    ns "$tcl_file_to_run" $modified $node_default $flow_default $packet_default $i
    awk -f parse.awk trace.tr >> $speed_result_file_mod
done


# Varying packet rate
>$packet_result_file
>$packet_result_file_mod
for i in 100 200 300 400 500
do
    echo "packet $i " >> $packet_result_file
    echo "packet $i " >> $packet_result_file_mod
    echo ekhane
    ns "$tcl_file_to_run" $unmodified $node_default $flow_default $i $speed_default 
    awk -f parse.awk trace.tr >> $packet_result_file
    ns "$tcl_file_to_run" $modified $node_default $flow_default $i $speed_default 
    awk -f parse.awk trace.tr >> $packet_result_file_mod
done


python3 mergedGraphGenerator.py $flow_result_file $flow_result_file_mod "flow"
python3 mergedGraphGenerator.py $speed_result_file $speed_result_file_mod "speed"
python3 mergedGraphGenerator.py $packet_result_file $packet_result_file_mod "packet"
