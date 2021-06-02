# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN AA11 [get_ports {d0}];  # "JA2"
set_property PACKAGE_PIN Y11  [get_ports {sync}];  # "JA1"
set_property PACKAGE_PIN AA9  [get_ports {sclk}];  # "JA4"
#set_property PACKAGE_PIN Y10  [get_ports {d1}];  # "JA3"

# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN N15 [get_ports {rst}];  # "BTNL"
set_property PACKAGE_PIN T18 [get_ports {str}];  # "BTNU"

# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y9 [get_ports {clk}];



set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];