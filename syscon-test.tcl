# A Tcl script for the Qsys system console

# Start Qsys, open your soc_system.qsys file, run File->System Console,
# then execute this script by selecting it with Ctrl-E

# The System Console is described in Chapter 10 of Volume III of
# the Quartus II Handbook

# Alternately,
# system-console --project_dir=. --script=syscon-test.tcl
#
# system-console --project_dir=. -cli
#   and then "source syscon-test.tcl"

# Base addresses of the peripherals: take from Qsys
set vga_led 0x0

puts "Started system-console-test-script"

# Using the JTAG chain, check the clock and reset"

set j [lindex [get_service_paths jtag_debug] 0]
open_service jtag_debug $j
puts "Opened jtag_debug"

puts "Checking the JTAG chain loopback: [jtag_debug_loop $j {1 2 3 4 5 6}]"
jtag_debug_reset_system $j

puts -nonewline "Sampling the clock: "
foreach i {1 1 1 1 1 1 1 1 1 1 1 1} {
    puts -nonewline [jtag_debug_sample_clock $j]
}
puts ""

puts "Checking reset state: [jtag_debug_sample_reset $j]"

close_service jtag_debug $j
puts "Closed jtag_debug"

# Perform bus reads and writes

set m [lindex [get_service_paths master] 0]
open_service master $m
puts "Opened master"

# zero out all memory
foreach i {0 4 8 12 16 20 24 28 32 36 40 44 48 52} {
    master_write_32 $m [expr $vga_led + $i] 0x00000000
}

# write convolution buffer
foreach {r v} {48 0x000000ff 52 0xff000000} {
    master_write_32 $m [expr $vga_led + $r] $v
}

# write point location
master_write_8 $m [expr $vga_led + 0x05] 0xff

foreach i {0 4 8 12 16 20 24 28 32 36 40 44 48 52 56} {
    set x [master_read_32 $m [expr $vga_led + $i] 1]
    puts "$i: $x"
}

set ready [master_read_8 $m [expr $vga_led + 59] 1]
set pos [master_read_8 $m [expr $vga_led + 58] 1]
set val [master_read_16 $m [expr $vga_led + 56] 1]

puts "pos: $pos"
puts "val: $val"
puts "ready: $ready"

# Write a test pattern to the various registers
#foreach {r v} {0 0xff 1 0x1 2 0x2 3 0x4 4 0x8 5 0x10 6 0x20 7 0x40} {
#    master_write_8 $m [expr $vga_led + $r] $v
#}

close_service master $m
puts "Closed master"




