transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/gally/Desktop/445/ECE445/FPGA/hdl {C:/Users/gally/Desktop/445/ECE445/FPGA/hdl/mem_block.v}
vlog -sv -work work +incdir+C:/Users/gally/Desktop/445/ECE445/FPGA/hdl {C:/Users/gally/Desktop/445/ECE445/FPGA/hdl/TopLevel.sv}
vlog -sv -work work +incdir+C:/Users/gally/Desktop/445/ECE445/FPGA/hdl {C:/Users/gally/Desktop/445/ECE445/FPGA/hdl/pixel_traversal.sv}
vlog -sv -work work +incdir+C:/Users/gally/Desktop/445/ECE445/FPGA/hdl {C:/Users/gally/Desktop/445/ECE445/FPGA/hdl/HexdriverOverload.sv}
vlog -sv -work work +incdir+C:/Users/gally/Desktop/445/ECE445/FPGA/hdl {C:/Users/gally/Desktop/445/ECE445/FPGA/hdl/Hexdriver.sv}
vlog -sv -work work +incdir+C:/Users/gally/Desktop/445/ECE445/FPGA/hdl {C:/Users/gally/Desktop/445/ECE445/FPGA/hdl/pixel_algorithm_unit.sv}
vlog -sv -work work +incdir+C:/Users/gally/Desktop/445/ECE445/FPGA/hdl {C:/Users/gally/Desktop/445/ECE445/FPGA/hdl/dithering_loop_control.sv}

vlog -sv -work work +incdir+C:/Users/gally/Desktop/445/ECE445/FPGA/hvl {C:/Users/gally/Desktop/445/ECE445/FPGA/hvl/finalproj_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  finalproj_tb

add wave sim:/finalproj_tb/toplevel/gray/pixel_sram/address_a sim:/finalproj_tb/toplevel/gray/pixel_sram/data_a sim:/finalproj_tb/toplevel/gray/pixel_sram/wren_a sim:/finalproj_tb/toplevel/gray/pixel_sram/address_b sim:/finalproj_tb/toplevel/gray/pixel_sram/rden_b sim:/finalproj_tb/toplevel/gray/pixel_sram/q_b sim:/finalproj_tb/toplevel/gray/pixel_sram/clock sim:/finalproj_tb/toplevel/gray/control0/store_old_p sim:/finalproj_tb/toplevel/gray/control0/state sim:/finalproj_tb/toplevel/gray/control0/compute_fin sim:/finalproj_tb/toplevel/gray/control0/compare_and_store_n sim:/finalproj_tb/toplevel/gray/control0/png_idx sim:/finalproj_tb/toplevel/gray/png_data_color_closest sim:/finalproj_tb/toplevel/gray/png_data_color_buffer_q_error sim:/finalproj_tb/i sim:/finalproj_tb/toplevel/MCU_TX_RDY sim:/finalproj_tb/toplevel/MCU_RX_RDY 
view structure
view signals
run -all
