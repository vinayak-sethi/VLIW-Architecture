# VLIW-Architecture
A Python - Verilog combination that simulates the working of a 32-bit 5-stage pipelined VLIW processor from input assembly code while monitoring the updates in the processor register file.

The VLIW processor contains the following modules:
- One 32-bit pipelined recursive doubling adders
- One 32-bit pipelined wallace multiplier
- One 32-bit pipelined floating point adders (IEEE 32-bit floating point representation)
- One 32-bit pipelined floating point multiplier (IEEE 32-bit floating point representation)
- One logic unit
- One memory load unit
- One memory store unit
- One register move unit

Instruction format is given in instructions.txt.

## Usage
- For UNIX users
  - ```./setup.sh```
- For Windows users
  - Install Icarus Verilog 
- ```python3 main.py```

## Technologies used
- Python3
- Verilog
