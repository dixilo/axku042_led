open_project -reset proj_led_counter_1s

# Add design files
add_files led_counter_1s.cpp

# Set the top-level function
set_top led_counter_1s

# ########################################################
# Create a solution
open_solution -reset solution1 -flow_target vivado

# Define technology and clock rate
set_part {xcku040-ffva1156-2-i}
create_clock -period 5.0
set_clock_uncertainty 0.2
config_rtl -reset all

csynth_design
export_design -format ip_catalog

exit
