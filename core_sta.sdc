set current_design core

create_clock -name CLK -period 12 -waveform {0 6} [get_ports clk_i]
set_max_fanout 10 [current_design]

# used to pass the requirements, however logically it won't work so I'll probably take this part out in the future
# set_multicycle_path -setup 2 -from [all_registers] -to [all_registers]
# set_multicycle_path -hold 1 -from [all_registers] -to [all_registers]


