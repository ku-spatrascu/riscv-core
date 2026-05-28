read_liberty sky130_fd_sc_hd__ff_n40C_1v95.lib
read_verilog results.v
link_design core
read_sdc core_sta.sdc

# power
set_power_activity -input -activity 0.1
set_power_activity -input_ports rst_ni -activity 0

