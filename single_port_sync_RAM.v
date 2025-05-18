module single_port_sync_RAM(clk , rst_n , din , rx_valid , dout , tx_valid);

parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;

input clk , rst_n , rx_valid;
input [9:0] din;

output reg [7:0] dout;
output reg tx_valid;

reg [ADDR_SIZE-1:0] addr;        //to hold address for both read , write operation (single_port)

reg [7 :0] mem [MEM_DEPTH-1 : 0];

//assign tx_valid = ((din[9:8] == 2'b11) /*&& rx_valid*/) ? 1 : 0;

always @(posedge clk)
begin
    if(~rst_n)
        begin
            dout <= 0;
            tx_valid <= 0;
        end

    else if(rx_valid)
        begin
            if((din[9:8] == 2'b10) || (din[9:8] == 2'b00))
                        addr <= din [7:0];
                
            else if(din[9:8] == 2'b01)
                        mem[addr] <= din [7:0];
            else                                //if(din[9:8] == 2'b11)
                begin
                    dout <= mem[addr];
                    tx_valid <= 1;
                end
        end 
        
    
    else
        tx_valid <= 0;
        
end

endmodule