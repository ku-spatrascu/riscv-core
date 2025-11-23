set current_design core

create_clock -name CLK -period 10 -waveform {0 5} [get_ports clk_i]

set_input_delay 3.0 -clock CLK [all_inputs]

set_output_delay 3.0 -clock CLK [all_outputs]

