# ns 1805052.tcl
# nam animation.nam
echo "\n-----------running wired.tcl-----------\n"
pkt_per_sec=100 # default packet ser rate
nn=40 # default number of node
nf=20 # default number of node flow
# "./wired.sh <agent> <agent_type> <csv_file>"
csv_file="wired.csv"
awk_file="wired.awk"
agent=$1
echo "" > $csv_file;
# for each in list

echo "\n-----------varing number of node-----------\n"
echo "varying number of node" >> $csv_file;
echo "number_of_node,throughput,average_delay,delivery_ratio,drop_ratio" >> $csv_file;
for node in 20 40 60 80 100
do
    echo "\n-----------number of node: $node-----------\n"
    # ns <file>.tcl <grid size> <# node> <# node flow>
    echo -n "$node , " >> $csv_file;
    ns wired.tcl $agent $node $nf $pkt_per_sec
    # echo "\n-----------running nam-----------\n"
    # nam animation.nam
    echo "\n-----------running awk-----------\n"
    awk -f $awk_file trace.tr
done

echo "\n-----------varing number of flows-----------\n"
echo "varying number of flows" >> $csv_file;
echo "flow,throughput,average_delay,delivery_ratio,drop_ratio" >> $csv_file;
# for each in list
for flow in 10 20 30 40 50
do
    echo "\n-----------area size: $area-----------\n"
    # ns <file>.tcl <grid size> <# node> <# node flow>
    echo -n "$flow , " >> $csv_file;
    ns wired.tcl $agent $nn $flow $pkt_per_sec
    # echo "\n-----------running nam-----------\n"
    # nam animation.nam
    echo "\n-----------running awk-----------\n"
    awk -f $awk_file trace.tr
done

echo "\n-----------varying number of packets-----------\n"
echo "varying number of packets" >> $csv_file;
echo "packet_rate,throughput,average_delay,delivery_ratio,drop_ratio" >> $csv_file;
# for each in list
for pkt in 100 200 300 400 500
do
    echo "\n-----------area size: $area-----------\n"
    # ns <file>.tcl <grid size> <# node> <# node flow>
    echo -n "$pkt , " >> $csv_file;
    ns wired.tcl $agent $nn $nf $pkt
    # echo "\n-----------running nam-----------\n"
    # nam animation.nam
    echo "\n-----------running awk-----------\n"
    awk -f $awk_file trace.tr
done


# rm animation.nam trace.tr
