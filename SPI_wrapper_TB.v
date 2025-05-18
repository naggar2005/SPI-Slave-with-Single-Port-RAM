module SPI_wrapper_TB();
reg MOSI_tb , SS_n_tb;
reg clk_tb , rst_n_tb;

wire MISO_tb;

        //clock generation
    initial begin
        clk_tb = 0;
        forever begin
            #1 clk_tb = ~clk_tb;
        end
    end

        //instantiation
    SPI_wrapper DUT(MOSI_tb , MISO_tb , SS_n_tb , clk_tb , rst_n_tb);

        //monitoring
    initial begin
        $monitor("clk = %b , rst_n = %b , MOSI = %b , SS_n = %b , MISO = %b"
                , clk_tb , rst_n_tb , MOSI_tb , SS_n_tb , MISO_tb);
    end

        //TEST CASES GENERATION
    initial begin
        //$readmemb("mem.dat" , SPI_wrapper.mem);

        rst_n_tb = 0;
        MOSI_tb = 0;
        SS_n_tb = 1;
        @(negedge clk_tb);
                        //write addr
        rst_n_tb = 1;
        SS_n_tb = 0;
        @(negedge clk_tb);
        MOSI_tb = 0;       //control bit
        @(negedge clk_tb);
        MOSI_tb = 1;
            repeat(5) @(negedge clk_tb);
        
        MOSI_tb = 0;
            repeat(5) @(negedge clk_tb);       //write address = 31
        
        SS_n_tb = 1;
        @(negedge clk_tb);
        SS_n_tb = 0;
        @(negedge clk_tb);
        MOSI_tb = 0;    ////control bit
        @(negedge clk_tb);

        repeat(4)
            begin
                MOSI_tb = 1;
                @(negedge clk_tb);
                MOSI_tb = 0;
                @(negedge clk_tb);
            end     
        MOSI_tb = 1;
            @(negedge clk_tb);
        MOSI_tb = 0;            
            @(negedge clk_tb);
                                           //write data = 01_01010101


        SS_n_tb = 1;
        @(negedge clk_tb);
        SS_n_tb = 0;
        @(negedge clk_tb);

        MOSI_tb = 1;                //control bit
        @(negedge clk_tb);
        
        
         
        MOSI_tb = 1;
            repeat(5) @(negedge clk_tb);            
        MOSI_tb = 0;
            repeat(3) @(negedge clk_tb);
        MOSI_tb = 0;
            @(negedge clk_tb);
        MOSI_tb = 1;
            @(negedge clk_tb);          ////read address = 31


        
        SS_n_tb = 1;
        @(negedge clk_tb);
        SS_n_tb = 0;
        @(negedge clk_tb);

        
        MOSI_tb = 1;        //control bit
            @(negedge clk_tb);
        repeat(8) @(negedge clk_tb);
        MOSI_tb = 1;                
        @(negedge clk_tb);
        MOSI_tb = 1;                ////read data
        @(negedge clk_tb);
        repeat(10) @(negedge clk_tb);           //waiting MISO   

        SS_n_tb = 1;
        @(negedge clk_tb);
        $display("end");
        $stop;      

    end
endmodule
