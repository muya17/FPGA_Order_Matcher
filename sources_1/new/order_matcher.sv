`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Self
// Engineer: Muya
// 
// Create Date: 08/06/2025 12:12:07 AM
// Design Name: 
// Module Name: order_matcher
// Project Name: FPGA_ORDER_MATCHER
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


// Order Matcher Module for Basys3
// Processes buy/sell orders, matches them, and outputs to LEDs and UART

module order_matcher (
    input logic clk,                // 100 MHz clock
    input logic reset,              // Reset (active high)
    input logic submit,             // Submit button (BTN0)
    input logic buy_sell,           // SW0: 1 for buy, 0 for sell
    input logic [2:0] price,        // SW1-3: Price (0-7)
    input logic [2:0] quantity,     // SW4-6: Quantity (1-7)
    output logic [2:0] led,         // LED0: match, LED1-2: match type
    output logic tx                 // UART TX
);

// Order structure
typedef struct packed {
    logic buy_sell; // 1: buy, 0: sell
    logic [2:0] price;
    logic [2:0] quantity;
} order_t;

// FSM states
typedef enum logic [1:0] {
    IDLE = 2'b00,
    READ_ORDER = 2'b01,
    MATCH_ORDER = 2'b10,
    OUTPUT_RESULT = 2'b11
} state_t;

// Internal signals
state_t state, next_state;
order_t [3:0] buy_queue, sell_queue; // Queues for buy and sell orders
logic [1:0] buy_count, sell_count;   // Queue counters
order_t current_order;
logic match_found;
logic [2:0] match_type; // 2-bit match type for LEDs
logic [7:0] uart_data;
logic uart_start;
logic [31:0] clk_count;

// UART parameters
localparam BAUD_RATE = 9600;
localparam CLK_FREQ = 100_000_000;
localparam BAUD_COUNT = CLK_FREQ / BAUD_RATE;

// Clock divider for UART
logic baud_tick;
logic [31:0] baud_counter;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        baud_counter <= 0;
        baud_tick <= 0;
    end else begin
        if (baud_counter == BAUD_COUNT - 1) begin
            baud_counter <= 0;
            baud_tick <= 1;
        end else begin
            baud_counter <= baud_counter + 1;
            baud_tick <= 0;
        end
    end
end

// FSM: State register
always_ff @(posedge clk or posedge reset) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

// FSM: Next state and logic
always_comb begin
    next_state = state;
    case (state)
        IDLE: begin
            if (submit)
                next_state = READ_ORDER;
        end
        READ_ORDER: begin
            next_state = MATCH_ORDER;
        end
        MATCH_ORDER: begin
            next_state = OUTPUT_RESULT;
        end
        OUTPUT_RESULT: begin
            if (!submit)
                next_state = IDLE;
        end
    endcase
end

// Order processing and matching logic
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        buy_count <= 0;
        sell_count <= 0;
        match_found <= 0;
        match_type <= 0;
        led <= 0;
        current_order <= 0;
        for (int i = 0; i < 4; i++) begin
            buy_queue[i] <= 0;
            sell_queue[i] <= 0;
        end
    end else begin
        case (state)
            READ_ORDER: begin
                current_order.buy_sell = buy_sell;
                current_order.price = price;
                current_order.quantity = quantity;
                if (buy_sell && buy_count < 4) begin
                    buy_queue[buy_count] <= current_order;
                    buy_count <= buy_count + 1;
                end else if (!buy_sell && sell_count < 4) begin
                    sell_queue[sell_count] <= current_order;
                    sell_count <= sell_count + 1;
                end
            end
            MATCH_ORDER: begin
                match_found = 0;
                match_type = 0;
                for (int i = 0; i < buy_count; i++) begin
                    for (int j = 0; j < sell_count; j++) begin
                        if (buy_queue[i].price >= sell_queue[j].price &&
                            buy_queue[i].quantity == sell_queue[j].quantity) begin
                            match_found = 1;
                            match_type = {buy_queue[i].price[1], sell_queue[j].price[1]};
                            // Remove matched orders
                            buy_queue[i] <= buy_queue[buy_count-1];
                            sell_queue[j] <= sell_queue[sell_count-1];
                            buy_count <= buy_count - 1;
                            sell_count <= sell_count - 1;
                            break;
                        end
                    end
                    if (match_found) break;
                end
            end
            OUTPUT_RESULT: begin
                led[0] = match_found;
                led[2:1] = match_type;
                uart_data = match_found ? 8'h4D : 8'h4E; // 'M' for match, 'N' for no match
                uart_start = 1;
            end
            default: begin
                led = 0;
                uart_start = 0;
            end
        endcase
    end
end

// UART transmitter
logic [3:0] bit_index;
logic [9:0] tx_shift;
logic tx_busy;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        tx <= 1;
        tx_shift <= 0;
        bit_index <= 0;
        tx_busy <= 0;
    end else if (baud_tick) begin
        if (uart_start && !tx_busy) begin
            tx_shift <= {1'b1, uart_data, 1'b0}; // Stop bit, data, start bit
            tx_busy <= 1;
            bit_index <= 0;
        end else if (tx_busy) begin
            tx <= tx_shift[0];
            tx_shift <= tx_shift >> 1;
            bit_index <= bit_index + 1;
            if (bit_index == 9)
                tx_busy <= 0;
        end
    end
end

endmodule