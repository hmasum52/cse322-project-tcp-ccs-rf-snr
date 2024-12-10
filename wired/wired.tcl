# author: Hasan Masum(1805052)
if {$argc != 4} {
    puts "Usage: ns $argv0 <tcp-type(0=>TCP, 1=>TCPSnr)> <number_of_nodes> <number_of_flows> <packets_per_second>"
    exit 1
}


set ns [new Simulator]

#======================
# define options
set val(agent) [lindex $argv 0]
set val(nn) [lindex $argv 1]
set val(nf) [lindex $argv 2]
set val(pkt_per_sec) [lindex $argv 3]
set val(pkt_size) 1000
set val(qlimit) 30
set val(t_start) 0.5
set val(t_end) 25
#======================



set namFile [open animation.nam w]
$ns namtrace-all $namFile
set traceFile [open trace.tr w]
$ns trace-all $traceFile

set node_(r1) [$ns node]
set node_(r2) [$ns node]

set val(nn) [expr {$val(nn) - 2}]

# puts "Number of nodes: $val(nn)"

expr srand(52)

for {set i 0} {$i < [expr {$val(nn) / 2}]} {incr i} {
    set node_(s$i) [$ns node]
    $ns duplex-link $node_(s$i) $node_(r1) 10Mb 2ms DropTail
}

$ns duplex-link $node_(r1) $node_(r2) 1.5Mb 20ms RED 
$ns queue-limit $node_(r1) $node_(r2) $val(qlimit)
$ns queue-limit $node_(r2) $node_(r1) $val(qlimit)

for {set i 0} {$i < [expr {$val(nn) / 2}]} {incr i} {
    set node_(d$i) [$ns node]
    $ns duplex-link $node_(d$i) $node_(r2) 10Mb 2ms DropTail
}

$ns duplex-link-op $node_(r1) $node_(r2) orient right
$ns duplex-link-op $node_(r1) $node_(r2) queuePos 0
$ns duplex-link-op $node_(r2) $node_(r1) queuePos 0

for {set i 0} {$i < $val(nf)} {incr i} {
    set source [expr int(rand() * ($val(nn)/2))]
    set dest [expr int(rand() * ($val(nn)/2))]
    if {$val(agent) == 0} {
        set tcp_($i) [new Agent/TCP]
    } else {
        set tcp_($i) [new Agent/TCP/TCPSnr]
    }
    # set tcp_($i) [new Agent/TCP]
    set sink_($i) [new Agent/TCPSink]
    $ns attach-agent $node_(s$source) $tcp_($i)
    $ns attach-agent $node_(d$dest) $sink_($i)

    # [$ns create-connection TCP $node_(s$source) TCPSink $node_(d$dest) $i]
    $tcp_($i) set packetSize_ $val(pkt_size)
    $tcp_($i) set maxcwnd_ [expr ($val(pkt_per_sec) / 25)]

    $ns connect $tcp_($i) $sink_($i)
    $tcp_($i) set fid_ $i

    set ftp_($i) [new Application/FTP]
    $ftp_($i) attach-agent $tcp_($i)
}

for {set i 0} {$i < $val(nf)} {incr i} {
    $ns at $val(t_start) "$ftp_($i) start"
    $ns at $val(t_end) "$ftp_($i) stop"
}

$ns at $val(t_end) "finish"

# Define 'finish' procedure (include post-simulation processes)
proc finish {} {
    exit 0
}

$ns run