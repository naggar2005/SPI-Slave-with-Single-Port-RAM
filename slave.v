module slave(clk , rst_n , MOSI , SS_n , tx_data , tx_valid
            , rx_data , rx_valid , MISO);

parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter WRITE = 3'b010;
parameter READ_ADD = 3'b011;
parameter READ_DATA = 3'b100;

input clk , rst_n , MOSI  , SS_n , tx_valid;
input [7:0] tx_data;

output reg MISO;
output reg rx_valid;
output reg [9:0] rx_data;
        //type of FSM encoding
    (* fsm_encoding = "sequential" *)
reg [2:0] cs , ns;
reg to_read_data ;


reg [9:0] temp_reg;
reg [4:0] cnt;
        //current state memory
    always @(posedge clk) begin
        if(~rst_n)
            cs <= IDLE;
        else
            cs <= ns; 
    end

        //next state logic
    always @(*) begin
        case(cs)
            IDLE:
                if(!SS_n)
                    ns = CHK_CMD;
                else
                    ns = cs;

            CHK_CMD:
                if(SS_n)
                    ns = IDLE;
                else
                    begin
                        if(MOSI)
                            begin
                                if(to_read_data)
                                        ns = READ_DATA;                                       
                                else
                                        ns = READ_ADD;
                            end

                        else
                            ns = WRITE;
                    end

            WRITE:
                if(SS_n)
                    ns = IDLE;
                else
                    ns = cs;

            READ_ADD:
                if(SS_n)
                    ns = IDLE;
                else
                    ns = cs;

            READ_DATA:
                if(SS_n)
                    ns = IDLE;
                else
                    ns = cs;

            default: ns = IDLE;
        endcase
    end

            //output
    always @(posedge clk) begin
        if(~rst_n)
            begin
                rx_data <= 0;
                MISO <= 0;
                cnt <= 0;
                rx_valid <= 0;      //new update
                to_read_data <= 0;
            end
        else
            begin
                if(((cs == READ_ADD) || (cs == WRITE) || (cs == READ_DATA)) && cnt == 10)
                        rx_valid <= 1;
                else
                        rx_valid <= 0;

                if(cs == READ_ADD)
                        to_read_data <= 1;
                else if(cs == READ_DATA)
                        to_read_data <= 0;
                else
                        to_read_data <= to_read_data;


                if((cs == READ_ADD) || (cs == WRITE))
                    begin
                        if(cnt <= 9)
                        begin
                            rx_data <= {MOSI , rx_data[9:1]};
                            cnt <= cnt + 1;
                        end
                        else if(cnt == 10)      //send rx_data
                            cnt <= cnt + 1;
                        else
                            cnt <= 0;
                        
                    end
                else if(cs == READ_DATA)
                    begin
                        if(cnt <= 9)
                            begin
                                rx_data <= {MOSI , rx_data[9:1]};
                                cnt <= cnt + 1;
                            end 
                        else if(cnt == 10 || cnt == 11)                                      //sending rx_data or waiting  ram answer
                            cnt <= cnt + 1;
                       /* else if((cnt == 12) && (rx_valid))
                            begin
                                cnt <= cnt;
                                MISO_ON <= 1;
                            end*/
                        else if((cnt >= 12) && (cnt <=19))
                            begin
                                case(cnt)
                                    12: MISO <= tx_data[0];
                                    13: MISO <= tx_data[1];
                                    14: MISO <= tx_data[2];
                                    15: MISO <= tx_data[3];
                                    16: MISO <= tx_data[4];
                                    17: MISO <= tx_data[5];
                                    18: MISO <= tx_data[6];
                                    19: MISO <= tx_data[7];
                                    default: MISO <= 0;                         //m4 hnwslha kda kda
                                endcase
                                cnt <= cnt + 1;
                            end
                        else
                            begin
                                cnt <= 0;
                            end
                            

                    end
                else
                    begin
                        cnt <= 0;
                    end
                    
            end               
    end

   endmodule