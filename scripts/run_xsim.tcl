# Vivado Tcl script for compilation and simulation

# Define project name and simulation directory
set proj_name "sensor_fusion_sim"
set sim_dir "vivado_sim"

# Create directory
file mkdir $sim_dir
cd $sim_dir

# Compile RTL sources
exec xvlog -sv ../../rtl/axis_ingestion.v \
               ../../rtl/secded_ecc.v \
               ../../rtl/ekf_engine.v \
               ../../rtl/matrix_inverter.v \
               ../../rtl/safety_island.v \
               ../../rtl/sensor_fusion_top.v

# To integrate with Cocotb, typically vivado needs a top-level TB, or we just load VPI.
# We compile standard Xsim with VPI libraries provided by cocotb.
# Note: Full cocotb integration with Vivado usually requires a specific makefile,
# but this script serves as the foundational compile/elab script.
puts "RTL Compilation complete. To run with Cocotb, utilize the cocotb xsim makefile."
