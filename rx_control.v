module rx_control(
    input clk,
    input rst_n,
    input uart_rx,    
    output[7:0] rx_data,
    output rx_done_sig
);

/********************************************************/
wire h2l_sig;
reg h2l_q1;
reg h2l_q2;

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                h2l_q1<=1;
                h2l_q2<=1;
            end
        else
            begin
                h2l_q1<=uart_rx;
                h2l_q2<=h2l_q1;
            end
    end

assign h2l_sig = h2l_q2 & !h2l_q1;

/********************************************************/
reg isCount;

/********************************************************/
reg[15:0] count_bps;
wire bps_clk;
     
always @(posedge clk or negedge rst_n)
    if(!rst_n)
        count_bps <= 16'd0;
    else if(count_bps == 16'd10416) //9600bps,100MHz
        count_bps <= 16'd0;
    else if(isCount)
        count_bps <= count_bps + 1'b1;
    else
        count_bps <= 16'd0;

assign bps_clk = (count_bps == 16'd5208) ? 1'b1 : 1'b0; //

/********************************************************/    
reg[3:0] i;
reg[7:0] rData;
reg isDone;

always @(posedge clk or negedge rst_n)
    if(!rst_n)
        begin
            i <= 4'd0;
            rData <= 8'd0;
            isCount <= 1'b0;
            isDone <= 1'b0;     
        end
    else
        case(i)
            4'd0:
                if(h2l_sig) begin i <= i + 1'b1; isCount <= 1'b1; end
            4'd1: 
                if(bps_clk) begin i <= i + 1'b1; end                     
            4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9:
                if(bps_clk) begin i <= i + 1'b1; rData[i - 2] <= h2l_q2; end                                      
            4'd10:
                if(bps_clk) begin i <= i + 1'b1; end                    
            4'd11:
                begin i <= i + 1'b1; isDone <= 1'b1; isCount <= 1'b0; end                    
            4'd12:
                begin i <= 4'd0; isDone <= 1'b0; end
        endcase    

assign rx_data = rData;
assign rx_done_sig = isDone;

/********************************************************/
    
endmodule