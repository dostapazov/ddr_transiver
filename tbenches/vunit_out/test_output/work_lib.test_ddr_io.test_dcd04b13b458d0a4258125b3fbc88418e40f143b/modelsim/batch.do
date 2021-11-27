onerror {quit -code 1}
source "/home/dostapazov/projects/ddr_transmitter/tbenches/vunit_out/test_output/work_lib.test_ddr_io.test_dcd04b13b458d0a4258125b3fbc88418e40f143b/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
