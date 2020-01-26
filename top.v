module top(
    input sys_clk_pin,
    input sys_rst_n_pin,
    
    input uart_rx_pin,
    output uart_tx_pin,
    
    output sccb_sclk_1,
    inout sccb_data_1,
    
    output sccb_sclk_2,
    inout sccb_data_2,
        
    output sccb_sclk_3,
    inout sccb_data_3,
        
    output reg[7:0] led_pin
);
/********************************************************/
wire[7:0] rx_data;
wire rx_done_sig;

rx_control rx_control(
    .clk(sys_clk_pin),
    .rst_n(sys_rst_n_pin),
    .uart_rx(uart_rx_pin),    
    .rx_data(rx_data),
    .rx_done_sig(rx_done_sig)
);

/********************************************************/
reg[31:0] cnt;
reg add_cnt_flag;
wire end_cnt_flag;
wire end_cnt_flag1;
wire end_cnt_flag2;

always @(posedge sys_clk_pin or negedge sys_rst_n_pin)
    if(!sys_rst_n_pin)
        cnt<=32'd0;
    else if(add_cnt_flag)
        cnt<=cnt+1'b1;
    else
        cnt<=32'd0;
 
assign end_cnt_flag  = cnt==32'd60_000; 
assign end_cnt_flag1 = cnt==32'd60_000;
assign end_cnt_flag2 = cnt==32'd100;

/********************************************************/
reg[7:0] i;
reg[7:0] sccb_addr;
reg[7:0] sccb_wdata; 
reg sccb_wr_en;
reg sccb_rd_en;

wire[23:0] sccb_rdata_1;
wire sccb_rdata_vld_1;

wire[23:0] sccb_rdata_2;
wire sccb_rdata_vld_2;

wire[23:0] sccb_rdata_3;
wire sccb_rdata_vld_3;

reg[63:0] dd1_1;
reg[63:0] dd2_1;

reg[63:0] dd1_2;
reg[63:0] dd2_2;

reg[63:0] dd1_3;
reg[63:0] dd2_3;

reg[3:0] n;

reg cal_send_flag;

always @(posedge sys_clk_pin or negedge sys_rst_n_pin)
    if(!sys_rst_n_pin)
        begin
            i<=8'd0;
            sccb_wr_en<=1'b0;
            sccb_rd_en<=1'b0;
            cal_send_flag<=1'b0;
            n<=4'd0;
        end
    else 
        case(i)
            8'd0:
                if(rx_done_sig)
                    if(rx_data==8'hAA) begin i<=i+1'b1; end
            8'd1: 
                begin i<=i+1'b1; sccb_addr<=8'h40; end  //
            8'd2:
                begin i<=i+1'b1; sccb_wr_en<=1'b1; end
            8'd3:
                begin i<=i+1'b1; sccb_wr_en<=1'b0; add_cnt_flag<=1'b1; end
            8'd4:
                if(end_cnt_flag) begin add_cnt_flag<=1'b0; i<=i+1'b1; sccb_addr<=8'h00; end
            8'd5:
                begin i<=i+1'b1; sccb_rd_en<=1'b1; end
            8'd6:
                begin i<=i+1'b1; sccb_rd_en<=1'b0; end
            8'd7: 
                if((sccb_rdata_vld_1)||(sccb_rdata_vld_2)||(sccb_rdata_vld_3))
                    begin
                        n=n+sccb_rdata_vld_1+sccb_rdata_vld_2+sccb_rdata_vld_3;
                        if(n==3) begin n<=4'd0; i<=i+1'b1;dd1_1<={40'd0,sccb_rdata_1};dd1_2<={40'd0,sccb_rdata_2};dd1_3<={40'd0,sccb_rdata_3}; end 
                    end     
            8'd8: 
                begin i<=i+1'b1; sccb_addr<=8'h50; end  //
            8'd9:
                begin i<=i+1'b1; sccb_wr_en<=1'b1; end
            8'd10:
                begin i<=i+1'b1; sccb_wr_en<=1'b0; add_cnt_flag<=1'b1; end
            8'd11:
                if(end_cnt_flag1) begin add_cnt_flag<=1'b0; i<=i+1'b1; sccb_addr<=8'h00; end
            8'd12:
                begin i<=i+1'b1; sccb_rd_en<=1'b1; end
            8'd13:
                begin i<=i+1'b1; sccb_rd_en<=1'b0; end
            8'd14:
                if((sccb_rdata_vld_1)||(sccb_rdata_vld_2)||(sccb_rdata_vld_3)) 
                   begin
                       n=n+sccb_rdata_vld_1+sccb_rdata_vld_2+sccb_rdata_vld_3;
                       if(n==3) begin  n<=4'd0; i<=i+1'b1;dd2_1<={40'd0,sccb_rdata_1};dd2_2<={40'd0,sccb_rdata_2};dd2_3<={40'd0,sccb_rdata_3};add_cnt_flag<=1'b1; end
                   end                 
            8'd15:
                if(end_cnt_flag2) begin add_cnt_flag<=1'b0; i<=i+1'b1;  cal_send_flag<=1'b1; end             
            8'd16:
                begin i<=8'd0;  cal_send_flag<=1'b0; end
                           
        endcase

/********************************************************/
//wire[23:0] sccb_rdata;
//wire sccb_rdata_vld;

i2c_control i2c_control_1(
    .clk(sys_clk_pin),
    .rst_n(sys_rst_n_pin),
    .addr(sccb_addr),
    .wr_en(sccb_wr_en),
    .rd_en(sccb_rd_en),
    .rdata(sccb_rdata_1),
    .rdata_vld(sccb_rdata_vld_1),
    .sio_c(sccb_sclk_1),
    .sio_d(sccb_data_1),
    .rdy()
);

i2c_control i2c_control_2(
    .clk(sys_clk_pin),
    .rst_n(sys_rst_n_pin),
    .addr(sccb_addr),
    .wr_en(sccb_wr_en),
    .rd_en(sccb_rd_en),
    .rdata(sccb_rdata_2),
    .rdata_vld(sccb_rdata_vld_2),
    .sio_c(sccb_sclk_2),
    .sio_d(sccb_data_2),
    .rdy()
);

i2c_control i2c_control_3(
    .clk(sys_clk_pin),
    .rst_n(sys_rst_n_pin),
    .addr(sccb_addr),
    .wr_en(sccb_wr_en),
    .rd_en(sccb_rd_en),
    .rdata(sccb_rdata_3),
    .rdata_vld(sccb_rdata_vld_3),
    .sio_c(sccb_sclk_3),
    .sio_d(sccb_data_3),
    .rdy()
);

/********************************************************/
reg[3:0] j;
reg[7:0] tx_data;
reg tx_vld;
wire tx_done_sig;

wire[63:0] pp1;
wire[63:0] pp2;
wire[63:0] pp3;

always @(posedge sys_clk_pin or negedge sys_rst_n_pin)
    if(!sys_rst_n_pin)
        begin
            j<=4'd0;
            tx_data<=8'd0;
            tx_vld<=1'b0;
        end
    else
        case(j)
        4'd0:
            if(cal_send_flag) begin
                tx_data<=pp1[15:8];
                tx_vld<=1'b1;
                j<=j+1'b1;
            end
        4'd1:
            begin tx_vld<=1'b0; j<=j+1'b1;end
        4'd2:
            if(tx_done_sig) begin
                tx_data<=pp1[7:0];
                tx_vld<=1'b1;
                j<=j+1'b1;
            end
        4'd3:
            begin tx_vld<=1'b0; j<=j+1'b1;end
        4'd4:
            if(tx_done_sig) begin
                tx_data<=pp2[15:8];
                tx_vld<=1'b1;
                j<=j+1'b1;
            end
        4'd5:
            begin tx_vld<=1'b0; j<=j+1'b1;end
        4'd6:
            if(tx_done_sig) begin
                tx_data<=pp2[7:0];
                tx_vld<=1'b1;
                j<=j+1'b1;
            end
        4'd7:
            begin tx_vld<=1'b0; j<=j+1'b1;end
        4'd8:
            if(tx_done_sig) begin
                tx_data<=pp3[15:8];
                tx_vld<=1'b1;
                j<=j+1'b1;
            end
        4'd9:
            begin tx_vld<=1'b0; j<=j+1'b1;end
            
        4'd10:
            if(tx_done_sig) begin
                tx_data<=pp3[7:0];
                tx_vld<=1'b1;
                j<=j+1'b1;
            end
        4'd11:
            begin tx_vld<=1'b0; j<=2'd0;end
        endcase

/********************************************************/
tx_control tx_control(
    .clk(sys_clk_pin),
    .rst_n(sys_rst_n_pin),
    .tx_vld(tx_vld),
    .tx_data(tx_data),
    .uart_tx(uart_tx_pin),
    .tx_rdy(),
    .tx_done_sig(tx_done_sig)
);

/********************************************************/
//wire[63:0] dd_1;
//wire[63:0] dd_2;
//wire[63:0] pp;

caculate caculate(
    .D_1A(dd1_1),
    .D_2A(dd2_1),
    .PA(pp1),
    .D_1B(dd1_2),
    .D_2B(dd2_2),
    .PB(pp2),
    .D_1C(dd1_3),
    .D_2C(dd2_3),
    .PC(pp3)
);

//assign led_pin = i;

endmodule
