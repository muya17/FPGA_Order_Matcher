`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2025 12:15:08 AM
// Design Name: 
// Module Name: order_matcher_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Testbench for Order Matcher
module order_matcher_tb;

logic clk, reset, submit, buy_sell;
logic [2:0] price, quantity;
logic [2:0] led;
logic tx;

// Instantiate DUT
order_matcher dut (
    .clk(clk),
    .reset(reset),
    .submit(submit),
    .buy_sell(buy_sell),
    .price(price),
    .quantity(quantity),
    .led(led),
    .tx(tx)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock
end

// Test stimulus
initial begin
    // Initialize
    reset = 1;
    submit = 0;
    buy_sell = 0;
    price = 0;
    quantity = 0;
    #20 reset = 0;

    // Test Case 1: Add buy order
    buy_sell = 1;
    price = 3'b101; // Price 5
    quantity = 3'b010; // Quantity 2
    submit = 1;
    #10 submit = 0;
    #100;

    // Test Case 2: Add sell order (matching)
    buy_sell = 0;
    price = 3'b100; // Price 4
    quantity = 3'b010; // Quantity 2
    submit = 1;
    #10 submit = 0;
    #100;

    // Test Case 3: Add non-matching sell order
    buy_sell = 0;
    price = 3'b110; // Price 6
    quantity = 3'b011; // Quantity 3
    submit = 1;
    #10 submit = 0;
    #100;

    // Test Case 4: Add matching buy order
    buy_sell = 1;
    price = 3'b110; // Price 6
    quantity = 3'b011; // Quantity 3
    submit = 1;
    #10 submit = 0;
    #100;

    $finish;
end

// Monitor outputs
initial begin
    $monitor("Time=%0t: LED=%b, TX=%b", $time, led, tx);
end

endmodule
