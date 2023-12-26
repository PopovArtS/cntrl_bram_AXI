import mux_header::*; //load parameter
module mux_v_n_cod(
	input 			clk_15_o,
	input 			nrst,
	
	input			cod_data_v,
	input			cod_data_n,
	input 			cod_ce_n, //open no shifr
    //input           cod_ce_v,
	
	input			mvsk_on,
	input			mnsk_on,
	
	output	[FOUR: NULL] 	cnt_data,	
	output	[MSB_RAM: NULL]	data_in_ram_tx_reg_b
	
	
);
    
    
    logic [FOUR: NULL] 	cnt_data;
    logic cod_ce_n_reg;
    assign cod_ce_n_reg = cod_ce_n;
    
    logic [MSB_RAM: NULL]	_data_in_ram_tx_reg_b;
    assign data_in_ram_tx_reg_b = _data_in_ram_tx_reg_b;
	logic clk;
	assign clk = mnsk_on ? cod_ce_n_reg : clk_15_o; // nsk == 1, vsk == 0
	
	logic mnsk_on_reg, mvsk_on_reg;
	
	logic cod_data_n_reg;	
	logic cod_data_v_reg;
	
	always @(posedge clk) begin
		cod_data_n_reg <= cod_data_n;
		cod_data_v_reg <= cod_data_v;
		mnsk_on_reg <= mnsk_on;
        mvsk_on_reg <= mvsk_on;
		
	end


	always @(posedge clk)
        if (nrst == ONE) begin
            if ((mnsk_on == ONE) || (mvsk_on == ONE))
                _data_in_ram_tx_reg_b [cnt_data] <= (mvsk_on_reg == ONE) ? cod_data_v_reg : cod_data_n_reg;

            if ((mnsk_on_reg == ONE) || (mvsk_on_reg == ONE)) begin     
                if (cnt_data == RANG_CNT_TX)
                    cnt_data <= NULL;
                else
                    cnt_data <= cnt_data + ONE;
            
            end else
                    cnt_data <= NULL; 

        end else begin        
                _data_in_ram_tx_reg_b <= NULL;
                cnt_data <= NULL;
            
        end



endmodule