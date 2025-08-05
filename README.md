FPGA Order Matching Engine
Overview
This project implements a simplified trading order matching engine in SystemVerilog for the Digilent Basys3 FPGA board. It processes buy and sell orders (specified by price and quantity) entered via switches, matches them based on price (buy price ≥ sell price) and quantity, and outputs results to LEDs and UART. The design simulates a high-frequency trading (HFT) system, relevant to financial applications like those used at Morgan Stanley for low-latency order processing.
The project is a work in progress, primarily designed to learn SystemVerilog and improve Verilog skills. It may contain bugs, and the .xdc constraints file ports are not fully initialized for the Basys3 board. Contributions and collaborations are welcome to enhance the design!
Features

Inputs: Basys3 switches (SW0: buy/sell, SW1-3: price, SW4-6: quantity), BTN0 to submit orders.
Outputs: LEDs (LED0: match status, LED1-2: match type), UART (9600 baud) for match results ('M' for match, 'N' for no match).
Logic: Finite State Machine (FSM) to read orders, store in buy/sell queues (4 orders each), and match based on price and quantity.
Relevance: Demonstrates low-latency order matching, a key FPGA application in HFT.

Block Diagram
The design consists of:

FSM: Manages states (IDLE, READ_ORDER, MATCH_ORDER, OUTPUT_RESULT) to process inputs.
Order Queues: Stores up to 4 buy and 4 sell orders using SystemVerilog struct.
Matching Logic: Compares buy/sell orders, matches if buy price ≥ sell price and quantities match.
Output Module: Drives LEDs for match status and UART for result transmission.

(Note: A block diagram will be added once the project is fully working.)
Setup Instructions
Prerequisites

Vivado: Version 2023.1 or later.
Basys3 Board: Digilent Basys3 (XC7A35T-1CPG236C).
UART Terminal: PuTTY or similar, set to 9600 baud, 8N1.

Simulation

Open Vivado and create a new RTL project for Basys3.
Add source files:
Design: src/order_matcher.sv
Simulation: src/order_matcher_tb.sv
Constraints: src/basys3_constraints.xdc


Run behavioral simulation (run 500 ns).
Check Tcl console for $monitor output:
Buy order (price=5, quantity=2): LED=000, TX=1.
Sell order (price=4, quantity=2): LED=1XX, TX='M'.
Sell order (price=6, quantity=3): LED=000, TX='N'.
Buy order (price=6, quantity=3): LED=1XX, TX='M'.



Hardware Implementation

Set order_matcher as the top module in Vivado.
Run synthesis and implementation with basys3_constraints.xdc.
Generate bitstream and program the Basys3 via USB.
Test on hardware:
Set switches (e.g., SW0=1, SW1-3=101, SW4-6=010 for buy, price=5, quantity=2).
Press BTN0 to submit.
Observe LED0 (1 for match, 0 for no match) and LED1-2 (match type).
Check UART terminal for 'M' (match) or 'N' (no match).



Notes

The .xdc file maps to Basys3 pins but may need adjustments for full initialization.
Debug issues by verifying switch/button mappings and UART settings (9600 baud).

Demo
A demo video showing switch inputs, LED outputs, and UART terminal output will be added once the project is fully working.
Learning Goals
This project was developed to:

Learn SystemVerilog constructs (e.g., struct, enum, always_ff) for better design modularity.
Improve Verilog skills by applying them to a real-world FPGA application.
Explore HFT concepts like low-latency order matching.

Contributing
The project is in progress and may have bugs. Contributions are welcome! Please:

Fork the repo and submit pull requests for bug fixes or enhancements.
Report issues via GitHub Issues.
Suggest improvements to the matching logic, UART output, or Basys3 integration.

License
This project is licensed under the MIT License. See LICENSE for details.