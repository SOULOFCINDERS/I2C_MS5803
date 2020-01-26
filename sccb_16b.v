module i2c_prom_control(clk,rst_n,addr,wdata,wr_en,rd_en,rdata,rdata_vld,sio_c,sio_d,rdy);

input clk;
input rst_n;

input[7:0] addr;

input[7:0] wdata;
input wr_en; //脉冲控制信号

input rd_en; //脉冲控制信号
output[15:0] rdata;
output rdata_vld; //脉冲有效信号

output sio_c; //I2C 时钟信号,对外与SCCB的SCK相连
inout sio_d;  //I2C 数据信号,对外与SCCB的SDA相连

output rdy; //准备就绪, 等待接收读写信号

/*******************************/
parameter IDWADD = 8'hEC;
parameter IDRADD = 8'hED;

parameter SCLK_TIME = 10000; //100MHz,400kHz(MAX FOR SCCB) //100MHz/10000=10kHz
parameter SCLK_HALF_TIME = SCLK_TIME/2;
parameter SCLK_W_TIME = SCLK_TIME/4;
parameter SCLK_R_TIME = (SCLK_TIME/4)*3;

/*******************************/
//变量声明前置
wire en;
wire end_cnt_step;

reg[7:0] cnt_bit;
reg[3:0] cnt_step;

/*******************************/
reg work_flag; //工作中信号, 长有效

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            work_flag <= 1'b0;
        else if(en)
            work_flag <= 1'b1;
        else if(end_cnt_step)
            work_flag <= 1'b0;           
    end

/*******************************/
reg rdy_r;

always @(*)
    begin
        if(work_flag||wr_en||rd_en)
            rdy_r=1'b0;
        else
            rdy_r=1'b1;
    end

assign rdy = rdy_r; //0忙, 1空闲, 长有效

/*******************************/
 assign en = (work_flag==1'b0) && (wr_en||rd_en); //使能信号, 脉冲有效    

/*******************************/
reg rd_flag; //写0,读1, 长有效

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            rd_flag<=1'b0;
        else if(rd_en)
            rd_flag<=1'b1;
        else if(wr_en)
            rd_flag<=1'b0;
    end

/*******************************/
wire wr_state; //1使能, 长有效
wire rd_state; //1使能, 长有效

assign wr_state = work_flag&&(rd_flag==1'b0);
assign rd_state = work_flag&&rd_flag;

/*******************************/
wire rd_0_state; //读第1阶段,长有效
wire rd_1_state; //读第2阶段,长有效
wire rd_get_state; //第二阶段读取中,长有效

assign rd_0_state = rd_state&&(cnt_step==0);
assign rd_1_state = rd_state&&(cnt_step==1);
assign rd_get_state = rd_1_state&&((cnt_bit>=10)&&(cnt_bit<27)&&(cnt_bit!=18));

/*******************************/
reg[7:0] subadd;
reg[7:0] wdata_ff0;

always @(posedge clk or negedge rst_n) //锁存读写地址和写数据
    begin
        if(!rst_n)
            begin
                subadd<=8'd0;
                wdata_ff0<=8'd0;
            end
        else if(en)
            begin
                subadd<=addr;
                wdata_ff0<=wdata;
            end
    end

/*******************************/
reg[29:0] wdata_tmp;
reg[7:0] bit_num;
reg[3:0] step_num;

always @(*)
    begin
        if(wr_state)
            begin
                wdata_tmp = {1'b0,IDWADD,1'b1,subadd,1'b1,wdata_ff0,1'b1,2'b01};
                bit_num = 30;
                step_num = 1;
            end
        else if(rd_0_state)
            begin
                wdata_tmp = {1'b0,IDWADD,1'b1,subadd,1'b1,2'b01,9'd0}; //后面补齐0
                bit_num = 21;
                step_num = 2;
            end
        else
            begin
                wdata_tmp = {1'b0,IDRADD,1'b1,8'd0,1'b0,8'd0,1'b1,2'b01}; //后面补齐0
                bit_num = 30;
                step_num = 2;
            end
    end

/*******************************/
reg[15:0] cnt_sclk;
wire add_cnt_sclk;
wire end_cnt_sclk;

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            cnt_sclk<=16'd0;
        else if(add_cnt_sclk)
            begin
                if(end_cnt_sclk)
                    cnt_sclk<=16'd0;
                else
                    cnt_sclk<=cnt_sclk+1'b1;
            end
        else
            cnt_sclk<=16'd0;
    end

assign add_cnt_sclk = work_flag;
assign end_cnt_sclk = cnt_sclk==SCLK_TIME-1;

/*******************************/
//reg[7:0] cnt_bit;
wire add_cnt_bit;
wire end_cnt_bit;

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            cnt_bit<=8'd0;
        else if(add_cnt_bit)
            begin
                if(end_cnt_bit)
                    cnt_bit<=8'd0;
                else
                    cnt_bit<=cnt_bit+1'b1;
            end
    end

assign add_cnt_bit = end_cnt_sclk;
assign end_cnt_bit = add_cnt_bit&&(cnt_bit==bit_num-1);

/*******************************/
//reg[3:0] cnt_step;
wire add_cnt_step;
//wire end_cnt_step;

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            cnt_step<=4'd0;
        else if(add_cnt_step)
            begin
                if(end_cnt_step)
                    cnt_step<=4'd0;
                else
                    cnt_step<=cnt_step+1'b1;
            end
    end

assign add_cnt_step = end_cnt_bit;
assign end_cnt_step = add_cnt_step&&(cnt_step==step_num-1);
    
/*******************************/
wire start_area; //起始位标志
wire stop_area;  //结束位标志

assign start_area = add_cnt_sclk&&(cnt_bit==0);
assign stop_area = add_cnt_sclk&&(cnt_bit==bit_num-1);

/*******************************/
wire sclk_h2l;
wire sclk_l2h;

assign sclk_h2l = add_cnt_sclk&&(cnt_sclk==0)&&((!start_area)&&(!stop_area));
assign sclk_l2h = add_cnt_sclk&&(cnt_sclk==SCLK_HALF_TIME-1);

/*******************************/
reg sio_c_r;
 
always @(posedge clk or negedge rst_n) //sio_c 时钟信号在起始位和结束位保存高电平，一个周期先低后高
    begin
        if(!rst_n)
            sio_c_r<=1'b1;
        else if(sclk_h2l)
            sio_c_r<=1'b0;
        else if(sclk_l2h)
            sio_c_r<=1'b1;           
    end

assign sio_c = sio_c_r;

/*******************************/
wire sio_send;

assign sio_send = add_cnt_sclk&&(cnt_sclk==SCLK_W_TIME-1)&&(rd_get_state==1'b0);

/*******************************/
reg sio_out;

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            sio_out<=1'b1;
        else if(sio_send)
            sio_out<=wdata_tmp[38-cnt_bit];          
    end

/*******************************/
reg sio_out_en;

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            sio_out_en<=1'b0;
        else if(work_flag&&rd_get_state==1'b0)
            sio_out_en<=1'b1;
        else
            sio_out_en<=1'b0;
    end

assign sio_d = sio_out_en? sio_out : 1'bz; //写时序的应答位没有释放总线

/*******************************/
wire sio_get;

assign sio_get = add_cnt_sclk&&(cnt_sclk==SCLK_R_TIME-1)&&rd_get_state;

/*******************************/
wire sio_din;

assign sio_din = sio_d;

/*******************************/
reg[15:0] rdata_r;

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            rdata_r<=16'd0;
        else if(sio_get)
            rdata_r<={rdata_r[14:0],sio_din};       
    end

assign rdata = rdata_r;

/*******************************/
reg rdata_vld_r;

always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            rdata_vld_r<=1'b0;
        else if(end_cnt_step&&rd_1_state)
            rdata_vld_r<=1'b1;
        else
            rdata_vld_r<=1'b0;       
    end

assign rdata_vld = rdata_vld_r;

/*******************************/

endmodule
