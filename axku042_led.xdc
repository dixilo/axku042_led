## =========================
## USER LEDs
## system_wrapper port: user_led[3:0]
##
## user_led[0] -> LED1 (E12, Bank66, 1.8V)
## user_led[1] -> LED2 (F12, Bank66, 1.8V)
## user_led[2] -> LED3 (L9,  Bank66, 1.8V)
## user_led[3] -> LED4 (H23, Bank65, 3.3V)
## =========================

## LED1
set_property PACKAGE_PIN E12 [get_ports {user_led[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {user_led[0]}]

## LED2
set_property PACKAGE_PIN F12 [get_ports {user_led[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {user_led[1]}]

## LED3
set_property PACKAGE_PIN L9  [get_ports {user_led[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {user_led[2]}]

## LED4
set_property PACKAGE_PIN H23 [get_ports {user_led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_led[3]}]


## =========================
## Differential system clock (200 MHz)
## PL_CLK0_P: AK17
## PL_CLK0_N: AK16
## Bank VCCO = 1.8V
## =========================

set_property PACKAGE_PIN AK17 [get_ports PL_CLK0_P]
set_property PACKAGE_PIN AK16 [get_ports PL_CLK0_N]

## Differential I/O standard
set_property IOSTANDARD LVDS [get_ports {PL_CLK0_P PL_CLK0_N}]

## Create clock (period = 5.000 ns => 200 MHz)
create_clock -name PL_CLK0 -period 5.000 [get_ports PL_CLK0_P]

## =========================
## External Reset (Active-Low)
## FPGA_RSETN : N27 (Bank 3.3V)
## =========================
set_property PACKAGE_PIN N27 [get_ports ext_resetn]
set_property IOSTANDARD LVCMOS33 [get_ports ext_resetn]

## 基本は入力なので DRIVE/SLEW は不要
## 必要ならプルアップ（ボード側に無ければ）
# set_property PULLUP true [get_ports FPGA_RSETN]
