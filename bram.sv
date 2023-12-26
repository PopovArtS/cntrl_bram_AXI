import mux_header::*; //load parameter
module bram #(
	parameter RANG_RAM = 31,
	parameter MSB_RAM_WIDTH = 31,
	parameter LENGHT_RAM = 8192,
	parameter MSB_RAN = 12,
	parameter WE_REG_CONFIG_CMD = 0
	//parameter LENGHT_CNT
)
(
/*(*mark_debug = "true"*)	*/input clk_in, //read RAM 
	
	/////////////////////////////////////////////////////////////////
	//rules 
/*(*mark_debug = "true"*)	*/input			nrst,
	
	input           flag_down_last_data,
/*(*mark_debug = "true"*)	*/input			data_std, // 1 - rx, 0 - tx
/*(*mark_debug = "true"*)*/	input	[FOUR: NULL]			cnt_data, // сколько бит
	
	/////////////////////////////////////////////////////////////////
	//управляющие регистры
	output  [MSB_RAM: NULL] 		reg_contrl_upr_Rx,
	output  [MSB_RAM: NULL] 		reg_contrl_data_Tx,

	/////////////////////////////////////////////////////////////////	
	//signals input mdm
/*(*mark_debug = "true"*)*/	input			mvsk_on,
/*(*mark_debug = "true"*)*/	input			mnsk_on,

	/////////////////////////////////////////////////////////////////
	//signals output mdm	
	input 				cod_ce_n, //open no shifr
	input 				cod_ce_v, //open no shifr
	
	/////////////////////////////////////////////////////////////////
	//signals output mdm (no mix)
	//output			ce_vsk_wr, //enab vsk data clk 120 MHz since vsk demodulutor
	//output [5: 0]	signed_data_mix_mdm, // i thihk, data in RAM here
	//output [MSB_RAN: NULL] cnt_pack_addr_ram_rx, //cnt_addr ?
	
	
	/////////////////////////////////////////////////////////////////
	//for RAM
	input [RANG_RAM: NULL]               reg_config_cmd_rcv_0,
	input [RANG_RAM: NULL]               reg_config_cmd_rcv_1,
	input [RANG_RAM: NULL]               reg_config_cmd_rcv_2,

	input [RANG_RAM: NULL] 		reg_data_for_ram, //data_in_ram_tx_reg_b [cnt_data] <= (mvsk_on_reg == ONE) ? cod_data_v_reg : cod_data_n_reg; что мы пулим в bram, подготовленные данные для записи
	//input [MSB_RAN: NULL]		        reg_addr_for_ram_tx,
	input [MSB_RAN: NULL]		        reg_addr_for_ram_rx,
	input [RANG_RAM: NULL]               data_in_ram_reg_time_axi,
	
	
/*(*mark_debug = "true"*)*/	output [MSB_RAM_WIDTH: NULL] 		data_ram_tx_out, //что записываем
/*(*mark_debug = "true"*)*///	input [MSB_RAM_WIDTH: NULL] 		data_ram_rx_in, //что читаем из bram
/*(*mark_debug = "true"*)*/	output [MSB_RAN: NULL] 	            addr_ram_o,
	//output	    						clk_ram,
/*(*mark_debug = "true"*)*/	output	    						we_ram	
/*(*mark_debug = "true"*)*/	//output								en_ram_out

);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////START RX LINE FOR BRAM logic
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
	//two list for vsk and two nsk
	
	
	logic clk;
	assign clk =/* mnsk_on ? cod_ce_n_reg : */clk_in; // nsk == 1, vsk == 0	
	
	logic [RANG_RAM: NULL] reg_config_cmd_rcv [TWO: NULL];
	assign reg_config_cmd_rcv [NULL] = reg_config_cmd_rcv_0;
	assign reg_config_cmd_rcv [ONE] = reg_config_cmd_rcv_1;
	assign reg_config_cmd_rcv [TWO] = reg_config_cmd_rcv_2;
	
	logic [MSB_RAN: NULL] cnt_addr_ram_rx; //input
	logic [MSB_RAN: NULL] cnt_addr_ram_tx;
	logic [RANG_RAM: NULL] data_in_ram_reg_time_axi_b;
	
	logic [ONE: NULL] cnt_delay_data;

	
	logic [MSB_RAN: NULL] _cnt_addr_ram_rx;//перенести к данным
    logic [MSB_RAN: NULL] _cnt_addr_ram_tx;
    
    logic [SIX: NULL] reg_contrl_activ;
    logic [MSB_RAM: NULL] _reg_contrl_data_Tx;
	assign reg_contrl_data_Tx = _reg_contrl_data_Tx;
    
    logic read_number_page;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////START TX LINE FOR BRAM logic
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
    logic cod_ce_n_reg, _cod_ce_n_reg;
    logic [MSB_RAM_WIDTH: NULL] data_in_ram_tx_reg_b;
	logic [MSB_RAM_WIDTH: NULL] data_in_ram_tx_reg = NULL;

	logic _clk_ram_tx_reg;	
	logic [ONE: NULL] cnt_param_reg;
	//param
    logic [FOUR: NULL] last_bit_data;	
	logic mnsk_on_reg, mvsk_on_reg;	
	logic clk_ram_tx_reg;		
	logic [MSB_CNT_DATA: NULL] cnt_four_byte_data;	

	logic back_mvsk_on, back_mnsk_on, back_mnsk_on_reg, _back_mnsk_on_reg;
    logic begin_mvsk_on, begin_mnsk_on, back_mvsk_on_reg, _back_mvsk_on_reg;
    
	//assign cod_ce_n_reg = cod_ce_n;
    assign data_ram_tx_out = data_in_ram_tx_reg;
    assign we_ram = ~clk_ram_tx_reg; //delay? nsk

	initial
	mvsk_on_reg = NULL;

	logic [ONE: NULL] cnt_config_cmd;
	logic flag_read_page_bram;
    logic [ONE: NULL] _reg_need_read;
    logic [ONE: NULL] reg_need_read;
    //assign need_read_out = reg_need_read;    
    logic reg_last_list;
	/////////////////////////////////////////////////////////////////
	//for nsk and vsk mdm to ant
	
	logic [ONE: NULL] state_data_rd_q;
	logic [ONE: NULL] state_data_rd_d;
	logic flag_first_start;
    
	assign data_in_ram_reg_time_axi_b = data_in_ram_reg_time_axi;
	assign cnt_addr_ram_rx = reg_addr_for_ram_rx;
	assign addr_ram_o = (data_std == ONE) ? _cnt_addr_ram_rx : _cnt_addr_ram_tx; //можно не переносить управляется через cnt_data
	//адрес можно сделать единым, если управлением будет однотипным mnsk_on ~ cod_ce_n
	/////////////////////////////////////////////////////////////////
	//upr
	/////////////////////////////////////////////////////////////////
	assign reg_contrl_upr_Rx [NULL] = flag_down_last_data; //end read flash 
	assign reg_contrl_upr_Rx [ONE] = read_number_page; // 0 - reaad page 0, 1 - read page 1

	assign reg_contrl_activ [SIX] = data_std; // now read or write
	assign _reg_contrl_data_Tx [MSB_RAM: MSB_LENGHT_REG_BRAM_CNT + ONE] = reg_contrl_activ [SIX: NULL];
	
	initial begin 
		cnt_delay_data = NULL;
		cnt_param_reg = NULL;
		cnt_config_cmd = NULL;
		data_in_ram_tx_reg_b = NULL;
		state_data_rd_d = NULL;
		_clk_ram_tx_reg = NULL;
		cnt_addr_ram_tx = NULL;
		clk_ram_tx_reg = NULL;
		reg_contrl_activ [FIVE: NULL] = NULL;
		read_number_page = NULL;
		reg_last_list = NULL;
		flag_read_page_bram = NULL;
		cnt_four_byte_data = NULL;
		back_mnsk_on = NULL;
		back_mnsk_on_reg = NULL;
		_back_mnsk_on_reg = NULL;
		_back_mvsk_on_reg  = NULL;
		begin_mnsk_on = NULL;
		begin_mvsk_on = NULL;
		back_mvsk_on = NULL;
		back_mvsk_on_reg = NULL;
		_reg_need_read = NULL;
		reg_need_read = NULL;
		state_data_rd_q = NULL;
		last_bit_data = NULL;
		_cnt_addr_ram_rx = NULL;
		_cnt_addr_ram_tx = NULL;
		mvsk_on_reg = NULL;
		mnsk_on_reg = NULL;
		flag_first_start = NULL;
		cod_ce_n_reg = NULL;
		_cod_ce_n_reg = NULL;
	
	end	
	
	//1 reg for read and upr
    always @(posedge clk) begin
		read_number_page <= (cnt_addr_ram_rx > ((LENGHT_RAM >> ONE) - ONE)) ? ONE : NULL; // 1 - write page 0, 0 - write page 1, (for pc check 0 to 1) 
	   	reg_contrl_activ [FIVE: NULL] <=      (mvsk_on_reg == ONE || mnsk_on_reg == ONE) ? {flag_read_page_bram, (reg_last_list && ~WE_REG_CONFIG_CMD), _reg_need_read[ONE: NULL], mnsk_on_reg, mvsk_on_reg} : reg_contrl_activ;
	   	// [0] - tx vsk, [1] - tx nsk, [3: 2] read page tx data, [4] -last page bram, [5] -need read page 0 and check [3: 2]
		_reg_contrl_data_Tx [MSB_LENGHT_REG_BRAM_CNT: MSB_CNT_DATA + ONE] <=   (_back_mnsk_on_reg == ONE || _back_mvsk_on_reg == ONE) ? last_bit_data : _reg_contrl_data_Tx[MSB_LENGHT_REG_BRAM_CNT: MSB_CNT_DATA + ONE];
		_reg_contrl_data_Tx [MSB_CNT_DATA: NULL] <= (mvsk_on_reg == ONE || mnsk_on_reg == ONE) ? cnt_four_byte_data : _reg_contrl_data_Tx [MSB_CNT_DATA: NULL];
	   
	end
	
	//logic end_write;
	//for check addr line rx
	always @(posedge clk) begin
		_cnt_addr_ram_rx <= cnt_addr_ram_rx;
		
	end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	
	localparam 	ST_IDLE			= 3'd0,
				ST_WRITE_PREAM	= 3'd1,
				ST_WRITE_DATA	= 3'd2,
				ST_WRITE_STATUS = 3'd3;
	
	always @(posedge clk) begin 
		_clk_ram_tx_reg <= ~clk_ram_tx_reg;
		_cnt_addr_ram_tx <= cnt_addr_ram_tx; 

	end
	
	always @(posedge clk) begin
		if (cod_ce_v || cod_ce_n || flag_first_start == NULL) begin
			mnsk_on_reg <= mnsk_on;
			mvsk_on_reg <= mvsk_on;
			back_mvsk_on_reg <= back_mvsk_on;
			back_mnsk_on_reg <= back_mnsk_on;
			_back_mnsk_on_reg <= back_mnsk_on_reg;
			_back_mvsk_on_reg <= back_mvsk_on_reg;
			begin_mvsk_on <= (mvsk_on && !mvsk_on_reg);
			begin_mnsk_on <= (mnsk_on && !mnsk_on_reg);
			back_mnsk_on <= (!mnsk_on && mnsk_on_reg);
			back_mvsk_on <= (!mvsk_on && mvsk_on_reg);			
          
		end
		
		cod_ce_n_reg <= cod_ce_n;
		_cod_ce_n_reg <= cod_ce_n_reg;
		
	end
	
	

				
/////////////////////////////////////////////////////	
// comand bram	
	always @(posedge clk) begin : set_data_rd					
			case (state_data_rd_d) 
				ST_IDLE: begin
							clk_ram_tx_reg <= ONE;
							
						end
				ST_WRITE_PREAM: begin
							clk_ram_tx_reg <= NULL;
							data_in_ram_tx_reg <= data_in_ram_reg_time_axi_b;
	
						end
				ST_WRITE_DATA: begin
							clk_ram_tx_reg <= NULL;
							data_in_ram_tx_reg <= data_in_ram_tx_reg_b;
	
						end
				ST_WRITE_STATUS: begin
							clk_ram_tx_reg <= NULL;
							data_in_ram_tx_reg <= cnt_four_byte_data;
	
						end		
		default: begin
						clk_ram_tx_reg <= ONE;
				 end
		endcase

	end : set_data_rd
	

	//upr bram
	always @(posedge clk) begin
		if (nrst == ONE && data_std == NULL) begin
			//write preamb
			if ((begin_mvsk_on == ONE) || (begin_mnsk_on == ONE)) begin
				state_data_rd_d <= ST_WRITE_PREAM;
				cnt_four_byte_data <= NULL;
				//cnt_addr_ram_tx <= cnt_addr_ram_tx + ONE;
				cnt_addr_ram_tx <= NULL;
				//end_write <= ONE;
				
			end else			
			// write data                                                                                                                                      or (cnt_addr_ram_tx == NULL)
				if (((mnsk_on == ONE) && ((cod_ce_n_reg == ONE) /*|| (cod_ce_n == ONE)*/)) || ((mvsk_on == ONE) && (cod_ce_v == ONE))) begin
					if (cnt_data == RANG_RAM || (cnt_delay_data == TWO) && (cnt_param_reg == TWO) || (cnt_addr_ram_tx == NULL) && (flag_first_start == ONE) || (cnt_addr_ram_tx == (LENGHT_RAM - ONE))) begin
						cnt_four_byte_data <= cnt_four_byte_data + ONE;
						//if (flag_first_start == NULL)
							state_data_rd_d <= ST_WRITE_DATA;
						//else
							//state_data_rd_d <= ST_IDLE;
						flag_first_start <= ONE;
						//if (cnt_addr_ram_tx != NULL)	
						cnt_addr_ram_tx <= cnt_addr_ram_tx + ONE;
						
						//cnt_delay_data for delay 3 reg data
						if ((cnt_addr_ram_tx != (LENGHT_RAM - ONE)) && (WE_REG_CONFIG_CMD == ONE)) begin
							if ((cnt_delay_data != TWO) && (cnt_addr_ram_tx > NULL) && (cnt_param_reg == NULL))
								cnt_delay_data <= cnt_delay_data + ONE;
							else
								cnt_delay_data <= NULL;
							
							if ((cnt_delay_data != TWO) && (cnt_addr_ram_tx > NULL))	
								cnt_param_reg <= NULL; 
						end else begin
							cnt_delay_data <= NULL;
							cnt_param_reg <= NULL; 
							
						end						
						        											
						
					end else begin	
						// cnt_param_reg - reg for down 3 reg cmd
                        if ((cnt_delay_data == TWO) && (cnt_param_reg != TWO) && (cnt_addr_ram_tx > NULL)) begin  
                            cnt_param_reg <= cnt_param_reg + ONE;
                            state_data_rd_d <= ST_WRITE_DATA;
							cnt_addr_ram_tx <= cnt_addr_ram_tx + ONE;
                                                                                  
                        end else begin                                         
                            state_data_rd_d <= ST_IDLE;
                                                    
                        end	
					
					end
				end else begin	
				    //write end data
                    if (((back_mnsk_on == ONE) || (back_mvsk_on == ONE)) && (WE_REG_CONFIG_CMD != ONE)) begin
                        state_data_rd_d <= ST_WRITE_DATA;
                        cnt_addr_ram_tx <= cnt_addr_ram_tx + ONE;    
                        cnt_four_byte_data <= cnt_four_byte_data + ONE;                
                                            
                    end else                     
                        //it's system need for write status, for signal clk_ram_tx_reg
                        if (((back_mnsk_on_reg == ONE) || (back_mvsk_on_reg == ONE)) && (WE_REG_CONFIG_CMD != ONE)) begin
                            state_data_rd_d <= ST_IDLE;                            
                            cnt_four_byte_data <= cnt_four_byte_data + ONE;
                            
                        end else begin
                        // write status number 32 package
                            if (((_back_mnsk_on_reg == ONE) || (_back_mvsk_on_reg == ONE)) && (WE_REG_CONFIG_CMD != ONE)) begin
                                state_data_rd_d <= ST_WRITE_STATUS;
                                cnt_addr_ram_tx <= cnt_addr_ram_tx + ONE;
                                cnt_four_byte_data <= cnt_four_byte_data + ONE;
                                //end_write <= NULL;
                                                    
                            end else begin
                                state_data_rd_d <= ST_IDLE;
                                                                                
                            end
                        end				
				end							
		end else begin
			cnt_addr_ram_tx <= NULL;
			cnt_param_reg <= NULL;
			state_data_rd_d <= ST_IDLE;
		
		end
			
	end
	

	//write data in channel tx
	//этот блок оставить!!
    always @(posedge clk)
        if (nrst == ONE) begin                   
			if ((mnsk_on == ONE || back_mnsk_on == ONE) || (mvsk_on == ONE || back_mvsk_on == ONE)) begin	
				if (cnt_addr_ram_tx == (LENGHT_RAM - ONE)) begin //this is costil')
					data_in_ram_tx_reg_b <= data_in_ram_reg_time_axi_b;
                
				end else 
					if (cnt_addr_ram_tx == (LENGHT_RAM - TWO))	//this is costil')
						data_in_ram_tx_reg_b <= NULL;
					else begin
						if ((cnt_delay_data == TWO) && (WE_REG_CONFIG_CMD == ONE))
							data_in_ram_tx_reg_b <= reg_config_cmd_rcv[cnt_param_reg];
						else  
							data_in_ram_tx_reg_b <= reg_data_for_ram;
					end		

            end
            
            if (back_mvsk_on == ONE || back_mnsk_on == ONE)	
				last_bit_data <= cnt_data;

            if((_back_mnsk_on_reg == ONE) || (_back_mvsk_on_reg == ONE)) 
                data_in_ram_tx_reg_b <= NULL;
                                  
        end else        
            data_in_ram_tx_reg_b <= NULL;
            
////////////////////////////////////////////         
//read page tx	
	//check read page
	always @(posedge clk) begin 
		if (nrst == ONE)
			if (mvsk_on == ONE || mnsk_on == ONE)
				if (cnt_addr_ram_tx > (LENGHT_RAM >> ONE)) begin
					reg_need_read <= ONE; //read one page
					reg_last_list <= ONE;
					flag_read_page_bram <= ONE;
					
				end else begin
				    if (flag_read_page_bram == ONE)
					   reg_need_read <= TWO; //read two page
					else
					   reg_need_read <= NULL; 
					     
					reg_last_list <= NULL;
					
				end	
			else begin
				reg_need_read <= THREE; // can claen all
				flag_read_page_bram <= NULL;
				
			end	
		else
			reg_need_read <= NULL;
			
		_reg_need_read <= reg_need_read;	
		
	end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////END TX LINE FOR BRAM logic
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

endmodule