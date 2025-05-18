module SPI_wrapper(MOSI , MISO , SS_n , clk , rst_n);

input MOSI , SS_n;
input clk , rst_n;
output MISO;

wire [9:0] rx_data;
wire [7:0] tx_data;
wire rx_valid , tx_valid;

slave Slave(clk , rst_n , MOSI , SS_n , tx_data , tx_valid
            , rx_data , rx_valid , MISO);

single_port_sync_RAM RAM (clk , rst_n , rx_data , rx_valid , tx_data , tx_valid);

endmodule