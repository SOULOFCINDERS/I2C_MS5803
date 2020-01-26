module tx_control(
    input clk,
    input rst_n,
    input tx_vld,
    input[7:0] tx_data,
    output uart_tx,
    output reg tx_rdy,
    output tx_done_sig
);

/********************************************************/
reg[3:0] i;

/********************************************************/
wire tx_start;
reg tx_en;

always @(posedge clk or negedge rst_n)
    if(!rst_n)
        tx_en<=1'b0;
    else if(tx_start)
        tx_en<=1'b1;
    else if(i==4'd11)
        tx_en<=1'b0; 

assign tx_start = tx_vld && !tx_en;

/********************************************************/
reg[7:0] tx_data_tmp;

always @(posedge clk or negedge rst_n)
    if(!rst_n)
        tx_data_tmp<=8'd0;
    else if(tx_start)
        tx_data_tmp<=tx_data;

/********************************************************/   
reg[15:0] count_bps;
wire bps_clk;
     
always @(posedge clk or negedge rst_n)
    if(!rst_n)
        count_bps <= 16'd0;
    else if(count_bps == 16'd10416) //9600bps,100MHz, 
        count_bps <= 16'd0;
    else if(tx_en)
        count_bps <= count_bps + 1'b1;
    else
        count_bps <= 16'd0;

assign bps_clk = (count_bps == 16'd5208) ? 1'b1 : 1'b0; //

/********************************************************/
reg rTX;
reg isDone;
    
always @(posedge clk or negedge rst_n)
    if(!rst_n)
        begin
            i <= 4'd0;
            rTX <= 1'b1;
            isDone <= 1'b0;
        end
    else if(tx_en)
        case(i)                
            4'd0:
                if(bps_clk) begin i <= i + 1'b1; rTX <= 1'b0; end                    
            4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8:
                if(bps_clk) begin i <= i + 1'b1; rTX <= tx_data_tmp[i - 1]; end                     
            4'd9:
                if(bps_clk) begin i <= i + 1'b1; rTX <= 1'b1; end                                                      
            4'd10:
                if(bps_clk) begin i <= i + 1'b1; isDone <= 1'b1; end                     
            4'd11:
                begin i <= 4'd0; isDone <= 1'b0; end
        endcase
        
assign uart_tx = rTX;    
assign tx_done_sig = isDone;

/********************************************************/
always @(*)
    if(tx_en||tx_vld)
        tx_rdy=1'b0;
    else
        tx_rdy=1'b1;

/********************************************************/
    
endmodule