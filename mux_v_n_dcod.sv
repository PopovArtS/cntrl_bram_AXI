import mux_header::*; //load parameter
module mux_v_n_dcod (
	input clk_15_o,
	input clk_120,
	input nrst,
	
	input data_std,
	output flag_down_last_data,//end read flash, refresh addr?
	
	input cod_ce_v,
	input cod_ce_n,
	
	input [MSB_RAM_RX_WIDTH: NULL] weight_pack,
	input [MSB_RAM: NULL] 		     data_ram_rx_in,
	
/*(*mark_debug = "true"*) */	output [MSB_ADDR_VSK: NULL] addr_ram_rx,
	
	output [FIVE: NULL] 			dcod_data_v_ram,
	output [THREE: NULL]			dcod_data_n_ram,
	output 							dcod_start_v_ram, //надо понять, как это работает
	output 							dcod_start_n_ram //надо понять, как это работает

);

	logic data_std_reg;
	
	logic [MSB_RAM_RX_WIDTH: NULL] cnt_addr_ram_rx = NULL;
	assign addr_ram_rx = cnt_addr_ram_rx [MSB_ADDR_VSK: NULL];
	
	logic [FIVE: NULL]	reg_dcod_data_v_ram; //shifr data
	logic [THREE: NULL] reg_dcod_data_n_ram; //shifr data
	
	logic [FIVE: NULL] dcod_data_v_reg_ram;
	assign dcod_data_v_ram = dcod_data_v_reg_ram; // dcod_data_v_reg_ram
	
	logic [THREE: NULL] dcod_data_n_reg;
	assign dcod_data_n_ram = dcod_data_n_reg;
	
	logic [MSB_RAM: NULL] data_in_ram_rx_reg;
	logic [FIVE: NULL] _data_in_ram_rx_reg; 
	
	logic [TWO: NULL] cnt_slv;

	logic [ONE: NULL] _flag_down_last_data;
	assign flag_down_last_data = _flag_down_last_data[NULL];
	
	logic reg_dcod_start_v_ram, reg_dcod_start_n_ram;
	logic [FOUR: NULL] _dcod_start_v_ram;
	logic [THREE: NULL] _dcod_start_n_ram;
    assign dcod_start_n_ram = _dcod_start_n_ram [NULL];
	assign dcod_start_v_ram = _dcod_start_v_ram [FOUR];
	
	logic flag_rk; //omg
	logic flag_rk_nsk;
	
	initial begin
		data_std_reg = NULL;
		cnt_addr_ram_rx = NULL;
		reg_dcod_data_v_ram = NULL;
		reg_dcod_data_n_ram = NULL;
		dcod_data_v_reg_ram = NULL;
		dcod_data_n_reg = NULL;
		data_in_ram_rx_reg = NULL;
		_data_in_ram_rx_reg = NULL;
		cnt_slv = NULL;
		_flag_down_last_data [NULL] = NULL;
		_flag_down_last_data [ONE] = NULL;
		_dcod_start_n_ram = NULL;
		_dcod_start_v_ram = NULL;	
	
	end
	
	always @(posedge clk_15_o) begin //clk_120
        flag_rk <= (data_std == ONE && _flag_down_last_data == NULL && cod_ce_v == ONE) ? ONE : NULL;
        reg_dcod_start_v_ram <= (data_std == ONE && _flag_down_last_data == NULL && cod_ce_v == ONE && flag_rk == NULL) ? ONE : NULL;       
        data_std_reg <= data_std;
        _dcod_start_v_ram <= {_dcod_start_v_ram [THREE: NULL], reg_dcod_start_v_ram};                
        
 		if (cod_ce_n == ONE) begin   
            if (cnt_slv > FIVE  || _flag_down_last_data [ONE] == ONE) begin 
                flag_rk_nsk <= (data_std == ONE && _flag_down_last_data == NULL) ? ONE : NULL;     
                reg_dcod_start_n_ram <= (data_std == ONE && _flag_down_last_data == NULL && flag_rk_nsk == NULL) ? ONE : NULL; 

            end
            
            _dcod_start_n_ram <= {_dcod_start_n_ram [TWO: NULL], reg_dcod_start_n_ram};
        
        end
    end
	
//управление RX
//управление адресом чтения, выдача данных из ram
	always @(posedge clk_15_o) 
		if (nrst == ONE) begin
			if (data_std == NULL || _flag_down_last_data [ONE] == ONE) begin
				cnt_addr_ram_rx <= NULL;
				cnt_slv         <= NULL;

				if (!data_std && data_std_reg == ONE) begin
					_flag_down_last_data <= NULL;
		            dcod_data_v_reg_ram <= NULL;
                    dcod_data_n_reg <= NULL;
		            
		        end
			end else begin
				dcod_data_v_reg_ram <= reg_dcod_data_v_ram;
				dcod_data_n_reg <= reg_dcod_data_n_ram;
				_flag_down_last_data[ONE] <= _flag_down_last_data[NULL];
	
				if (cod_ce_v == ONE) begin
					reg_dcod_data_v_ram <= (data_in_ram_rx_reg >> (cnt_slv * SIX));
							
					if (cnt_slv == FOUR) begin
					    cnt_slv <= NULL;
                        cnt_addr_ram_rx <=  cnt_addr_ram_rx + ONE;                          
                        data_in_ram_rx_reg <= data_ram_rx_in;
							     
						if ((weight_pack + ONE) <= cnt_addr_ram_rx)
						    _flag_down_last_data [NULL] <= ONE;
						else
						    _flag_down_last_data [NULL] <= NULL;     
							     
					end else
					    cnt_slv <= cnt_slv + ONE;
							
				end else if (cod_ce_n == ONE) begin
					reg_dcod_data_n_ram <= (data_in_ram_rx_reg >> (cnt_slv * FOUR));
							
					if (cnt_slv == SEVEN) begin
                        cnt_slv <= NULL;
                        cnt_addr_ram_rx <=  cnt_addr_ram_rx + ONE;  
                        data_in_ram_rx_reg <= data_ram_rx_in;                        
                                
                        if ((weight_pack + ONE) <= cnt_addr_ram_rx)
                            _flag_down_last_data [NULL] <= ONE;
                        else
                            _flag_down_last_data [NULL] <= NULL; 
                                
                    end else
                        cnt_slv <= cnt_slv + ONE; 
						
				end								
			end 			
		end	else begin
			cnt_addr_ram_rx <= NULL;

		end


endmodule