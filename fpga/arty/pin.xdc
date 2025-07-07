# Clock signal
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN E3} [get_ports { CLOCK_100 }];

# Reset
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN C2} [get_ports { RESETn }];

# Uart TX/RX
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN D10} [get_ports { UART_TXD }];
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN A9}  [get_ports { UART_RXD }];

## Digilent Pmod VGA XDC for Arty A7-35T
## PMOD VGA is plugged into JA (R/G) and JB (B/Sync)

## VGA Red signals (JA1, JA2, JA3, JA4)
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN G13} [get_ports {VGA_R[0]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN B11} [get_ports {VGA_R[1]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN A11} [get_ports {VGA_R[2]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN D12} [get_ports {VGA_R[3]}]

## VGA Green signals (JA7, JA8, JA9, JA10)
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN D13} [get_ports {VGA_G[0]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN B18} [get_ports {VGA_G[1]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN A18} [get_ports {VGA_G[2]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN K16} [get_ports {VGA_G[3]}]

## VGA Blue signals (JB1, JB2, JB3, JB4)
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN E15} [get_ports {VGA_B[0]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN E16} [get_ports {VGA_B[1]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN D15} [get_ports {VGA_B[2]}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN C15} [get_ports {VGA_B[3]}]

## VGA Synchronization signals (JB7, JB8)
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN J17} [get_ports {VGA_HS}]
set_property -dict {IOSTANDARD LVCMOS33  PACKAGE_PIN J18} [get_ports {VGA_VS}]