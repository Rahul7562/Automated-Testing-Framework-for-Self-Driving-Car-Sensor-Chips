SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../rtl/axis_ingestion.v
VERILOG_SOURCES += $(PWD)/../rtl/secded_ecc.v
VERILOG_SOURCES += $(PWD)/../rtl/ekf_engine.v
VERILOG_SOURCES += $(PWD)/../rtl/matrix_inverter.v
VERILOG_SOURCES += $(PWD)/../rtl/safety_island.v
VERILOG_SOURCES += $(PWD)/../rtl/sensor_fusion_top.v

TOPLEVEL = sensor_fusion_top
MODULE = test_ekf

include $(shell cocotb-config --makefiles)/Makefile.sim
