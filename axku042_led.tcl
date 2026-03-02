source ./util.tcl

set p_device "xcku040-ffva1156-2-i"
set project_name "axku042_led"

create_project -force $project_name ./${project_name} -part $p_device

## IP repository
set_property ip_repo_paths {\
    ./hls \
} [current_project]
update_ip_catalog

## Sources / Constraints
add_files -fileset constrs_1 -norecurse {\
    "./axku042_led.xdc" \
}

## block design
create_bd_design "system"

# External ports
# Differential 200 MHz input clock
create_bd_port -dir I -type clk PL_CLK0_P
create_bd_port -dir I -type clk PL_CLK0_N

# External reset (active low を想定)
create_bd_port -dir I -type rst ext_resetn

# LED outputs (4 bits)
create_bd_port -dir O -from 3 -to 0 user_led

# =========================
# Clocking Wizard
# =========================
create_bd_cell -type ip -vlnv [latest_ip clk_wiz] clk_wiz_0

# Clocking Wizard settings:
# - Use differential clock input
# - Input freq = 200 MHz
# - Output clk_out1 = 200 MHz (そのまま使う)
set_property -dict [list \
    CONFIG.PRIM_IN_FREQ {200.000} \
    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
    CONFIG.USE_RESET {true} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
] [get_bd_cells clk_wiz_0]

# Connect differential clock pins
connect_bd_net [get_bd_ports PL_CLK0_P] [get_bd_pins clk_wiz_0/clk_in1_p]
connect_bd_net [get_bd_ports PL_CLK0_N] [get_bd_pins clk_wiz_0/clk_in1_n]

# Feed external resetn into clk_wiz resetn
connect_bd_net [get_bd_ports ext_resetn] [get_bd_pins clk_wiz_0/resetn]

# =========================
# proc_sys_reset (recommended)
# =========================
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_sys_0
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins rst_sys_0/slowest_sync_clk]
connect_bd_net [get_bd_ports ext_resetn]        [get_bd_pins rst_sys_0/ext_reset_in]

# =========================
# HLS IP: led_counter_1s
# (VLNV must match export_design vendor/library/name)
# =========================
# 例: user.org:hls:led_counter_1s:1.0 みたいになることが多いです。
# catalog上のVLNVが違う場合はここを修正してください。
create_bd_cell -type ip -vlnv [latest_ip led_counter_1s] led_counter_1s_0

# Clock/Reset to HLS IP
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1]      [get_bd_pins led_counter_1s_0/ap_clk]
connect_bd_net [get_bd_pins rst_sys_0/peripheral_reset] [get_bd_pins led_counter_1s_0/ap_rst]

# LEDs out
connect_bd_net [get_bd_pins led_counter_1s_0/leds] [get_bd_ports user_led]

# =========================
# Validate & generate
# =========================
validate_bd_design
save_bd_design

set wrapper_path [make_wrapper -fileset sources_1 -files [get_files -norecurse system.bd] -top]
add_files -norecurse -fileset sources_1 $wrapper_path
set_property top system_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1
