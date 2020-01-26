set_property PACKAGE_PIN V12 [get_ports {pmod_1_i[0]}]
set_property PACKAGE_PIN U12 [get_ports {pmod_1_i[1]}]
set_property PACKAGE_PIN V11 [get_ports {pmod_1_i[2]}]
set_property PACKAGE_PIN V10 [get_ports {pmod_1_i[3]}]
set_property PACKAGE_PIN U13 [get_ports {pmod_1_o[0]}]
set_property PACKAGE_PIN T13 [get_ports {pmod_1_o[1]}]
set_property PACKAGE_PIN U11 [get_ports {pmod_1_o[2]}]
set_property PACKAGE_PIN T11 [get_ports {pmod_1_o[3]}]

set_property PACKAGE_PIN V16 [get_ports {pmod_2_i[0]}]
set_property PACKAGE_PIN V15 [get_ports {pmod_2_i[1]}]
set_property PACKAGE_PIN V14 [get_ports {pmod_2_i[2]}]
set_property PACKAGE_PIN U14 [get_ports sccb_sclk_3]
set_property PACKAGE_PIN U18 [get_ports {pmod_2_o[0]}]
set_property PACKAGE_PIN U17 [get_ports {pmod_2_o[1]}]
set_property PACKAGE_PIN V17 [get_ports {pmod_2_o[2]}]
set_property PACKAGE_PIN U16 [get_ports sccb_data_3]

set_property PACKAGE_PIN B16 [get_ports sccb_sclk_2]
set_property PACKAGE_PIN B17 [get_ports {pmod_3_i[1]}]
set_property PACKAGE_PIN B18 [get_ports {pmod_3_i[2]}]
set_property PACKAGE_PIN A18 [get_ports {pmod_3_i[3]}]
set_property PACKAGE_PIN C16 [get_ports sccb_data_2]
set_property PACKAGE_PIN C17 [get_ports {pmod_3_o[1]}]
set_property PACKAGE_PIN E17 [get_ports {pmod_3_o[2]}]
set_property PACKAGE_PIN D17 [get_ports {pmod_3_o[3]}]

set_property PACKAGE_PIN C12 [get_ports {pmod_4_i[0]}]
set_property PACKAGE_PIN B12 [get_ports {pmod_4_i[1]}]
set_property PACKAGE_PIN B13 [get_ports {pmod_4_i[2]}]
set_property PACKAGE_PIN B14 [get_ports sccb_sclk_1]
set_property PACKAGE_PIN A13 [get_ports {pmod_4_o[0]}]
set_property PACKAGE_PIN A14 [get_ports {pmod_4_o[1]}]
set_property PACKAGE_PIN A15 [get_ports {pmod_4_o[2]}]
set_property PACKAGE_PIN A16 [get_ports sccb_data_1]

set_property IOSTANDARD LVCMOS33 [get_ports pmod_*]
set_property IOSTANDARD LVCMOS33 [get_ports sccb_sclk_1]
set_property IOSTANDARD LVCMOS33 [get_ports sccb_data_1]
set_property IOSTANDARD LVCMOS33 [get_ports sccb_sclk_2]
set_property IOSTANDARD LVCMOS33 [get_ports sccb_data_2]
set_property IOSTANDARD LVCMOS33 [get_ports sccb_sclk_3]
set_property IOSTANDARD LVCMOS33 [get_ports sccb_data_3]
