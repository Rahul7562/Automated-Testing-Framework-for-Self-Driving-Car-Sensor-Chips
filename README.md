# Automotive VLSI Sensor Fusion Coprocessor

This repository contains the RTL implementation and UVM-compliant Verification Framework for a centralized Autonomous Vehicle Sensor Fusion Coprocessor. The coprocessor ingests raw sensor data (e.g., LiDAR, Radar, Camera), corrects potential hardware faults using SECDED error correction, processes object tracking states through a hardware Extended Kalman Filter (EKF) utilizing Q16.16 fixed-point arithmetic, and completes covariance operations via a Matrix Inverter.

This design aims to adhere to the stringent requirements of the ISO 26262 Automotive Safety Integrity Level D (ASIL-D) standard.

## Architecture

The system consists of the following hardware blocks:
1. **AXI4-Stream Ingestion Buffer** (`axis_ingestion.v`): Ingests and buffers continuous high-speed sensor packets.
2. **SECDED ECC** (`secded_ecc.v`): Single Error Correction, Double Error Detection logic to protect incoming data. Detects fault injections and self-corrects single bit-flips.
3. **EKF Engine** (`ekf_engine.v`): Hardware implementation of the Extended Kalman Filter prediction and update sequences.
4. **Matrix Inverter** (`matrix_inverter.v`): Hardware matrix operations for Kalman Gain computation.
5. **Safety Island** (`safety_island.v`): Diagnostic monitor that tallies single-bit faults and halts the system on fatal double-bit errors, ensuring ASIL-D fail-safe operation.

## Verification Environment

The verification environment leverages **Cocotb**, **PyUVM**, and a Python reference model (`ekf_reference.py`) to validate the mathematical and structural integrity of the RTL.

- The Python model performs bit-accurate, signed fixed-point tracking matching the RTL structure exactly.
- `PyUVM` agents inject randomized 64-bit sensor payloads.
- `PyUVM` Scoreboard automatically compares RTL outputs with the Python golden model via TLM FIFOs.

## Simulating the Project

### 1. Icarus Verilog (Local Debugging)
To simulate locally using the free, open-source `iverilog` simulator:
```bash
# Ensure dependencies are installed
pip install cocotb pyuvm

# Run the PyUVM Testbench
cd tb
make SIM=icarus
```
You should see a `TEST PASSED` message at the end of the simulation.

### 2. Xilinx Vivado (xsim)
To simulate the project within your Vivado environment, you have two options.

**Option A: Cocotb Make (Recommended)**
```bash
cd tb
make SIM=xsim
```
*Note: Ensure your Vivado `bin` directory is sourced and in your `$PATH` so `xelab` and `xsim` commands are recognized.*

**Option B: Manual TCL Execution**
If you wish to compile the RTL without Cocotb for a custom Verilog testbench:
```bash
cd scripts
vivado -mode tcl -source run_xsim.tcl
```

## Mathematics
The Extended Kalman Filter updates tracking via the sequence:
`state_x <= state_x + ((meas_x - state_x) >> 1)`

This ensures stable integration of spatial and velocity data with fixed-point accuracy.
