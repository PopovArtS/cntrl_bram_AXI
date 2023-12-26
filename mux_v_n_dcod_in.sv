import mux_header::*; //load parameter
module mux_v_n_dcod_in #(
    parameter LIMIT_SK_IN,
    parameter LEFT_DATA,
    parameter ADD_CNT,
	parameter LENGHT_BRAM,    
    parameter PACKAGE_PACT, //if ONE - VSK, if NULL - NSK
    parameter MSB_ADDR
)
(
	input clk,
	input clk_120,
	
    input locked_bram_once_in,
    output locked_bram_once_out,
/*(*mark_debug = "true"*)*/	    output [FOUR: NULL]				cnt_data_tx,//signal we
/*(*mark_debug = "true"*)*/ 	output                          flag_sk_out,//signal valid data
                                output                          flag_reboot_bram,
	
/*(*mark_debug = "true"*)*/	    //output [MSB_RAM_RX_WIDTH: NULL]	addr_ram_tx, //нужно подумать на счёт формирования адреса тх линии, потому что мог быть отличные условия формирования сигнала mvsk/mnsk
/*(*mark_debug = "true"*)*/ 	output [RANG_CNT_TX: NULL]		reg_ram_tx,//RANG_RAM_RX
	                            input                           locked_we, //zapret write
	                            input                           flag_otv,  //down flag sihr valid data                
/*(*mark_debug = "true"*)*/	    input                           start_write_for_ip_snif_o, //sinhr data
	                            input [LIMIT_SK_IN: NULL] 	    soft_demodulated_out, //data in 
	                            input 							dcod_start_in //надо понять, как это работает

);

    logic [RANG_CNT_TX: NULL]		_reg_ram_tx;//RANG_RAM_RX
	assign reg_ram_tx = _reg_ram_tx;
    
    logic locked_we_data;
    assign locked_we_data = locked_we;
    
	logic [LIMIT_SK_IN: NULL] dcod_data_in_reg;
	assign dcod_data_in_reg = soft_demodulated_out;
	
	logic dcod_start_in_reg;
	assign dcod_start_in_reg = dcod_start_in;

    logic [RANG_CNT_TX: NULL] reg_ram_data_tx;
    logic flag_data_out;
    logic [FOUR: NULL] cnt_data;
    logic [FOUR: NULL] cnt_data_out;
	assign cnt_data_tx = cnt_data_out;
	
	logic [MSB_ADDR: NULL]	reg_addr_ram_tx;
	//assign addr_ram_tx = reg_addr_ram_tx;
	
	logic reg_locked_bram_once_in, _reg_locked_bram_once_in, reg_locked_bram_once_out;
    assign reg_locked_bram_once_in = locked_bram_once_in;
    assign locked_bram_once_out = reg_locked_bram_once_out;
	
    //logic reg_reboot_we;
	logic back_start_write_for_ip_snif_o;
	logic [NINE: NULL] cnt_dalay;
	
	logic flag_sk;
	assign flag_sk_out = flag_sk;
	
	logic _flag_reboot_bram;
	assign flag_reboot_bram = _flag_reboot_bram;
	
	initial begin
		cnt_data_out = NULL;
        _reg_ram_tx = NULL;
        reg_ram_data_tx = NULL;
        flag_sk = NULL;
        _flag_reboot_bram = NULL;
        reg_addr_ram_tx = NULL;
        back_start_write_for_ip_snif_o = NULL;
        cnt_dalay = NULL;
        cnt_data = NULL;
        flag_data_out = NULL;
        _reg_locked_bram_once_in = NULL;
        reg_locked_bram_once_out = NULL;
        //reg_reboot_we = NULL;
	
	end

    always @(posedge clk_120) begin
        _flag_reboot_bram <= dcod_start_in_reg;
        
    end

	always @(posedge clk_120) begin
	   back_start_write_for_ip_snif_o <= dcod_start_in_reg;
	   _reg_locked_bram_once_in <= reg_locked_bram_once_in;
      
       if (reg_locked_bram_once_in == ONE && reg_addr_ram_tx > (LENGHT_BRAM - THREE) && flag_sk == ONE)
           reg_locked_bram_once_out <= ONE;
       else
           reg_locked_bram_once_out <= NULL;
	           
	   if ((!back_start_write_for_ip_snif_o && dcod_start_in_reg) == ONE) begin
            flag_sk <= ONE;
       end else       
            if (flag_otv == ONE) begin
                flag_sk <= NULL;
	        end   
	
	end
	
	//обнуление адреса надо дописать!!
	always @(posedge clk_120)
		if (locked_we_data == NULL && flag_reboot_bram == NULL && reg_locked_bram_once_out == NULL) begin 
			if ((cnt_data == NULL) && clk) begin 
                if (PACKAGE_PACT == ONE)   
                    _reg_ram_tx <= {2'h00, reg_ram_data_tx[RANG_RAM_RX: NULL]}; 
                else
		            _reg_ram_tx <= reg_ram_data_tx;   
            
                if (reg_addr_ram_tx != NULL)
					cnt_data_out <= RANG_RAM;
					
                reg_addr_ram_tx <= reg_addr_ram_tx + ONE;		         
			         		   
			end else 
		        cnt_data_out <= NULL;
			
			if ((dcod_start_in_reg == ONE) || _reg_locked_bram_once_in == !reg_locked_bram_once_in)
                reg_addr_ram_tx <= NULL;
			     			         			     			     
            if (clk) begin 
				reg_ram_data_tx <= (reg_ram_data_tx << LEFT_DATA) + dcod_data_in_reg;
				
				if ((cnt_data == CNT_VSK_PACK) && (PACKAGE_PACT == ONE))
				    cnt_data <= NULL;
				else    
				    cnt_data <= cnt_data + ADD_CNT;      
				
			end
		end else begin
            if (locked_we_data == ONE) begin
                reg_addr_ram_tx <= NULL;
                _reg_ram_tx <= NULL;
                reg_ram_data_tx <= NULL;
                cnt_data <= NULL;
                cnt_data_out <= NULL;
                        
             end else begin  
                if (clk && reg_locked_bram_once_out == NULL) 
                    reg_ram_data_tx <= (reg_ram_data_tx << LEFT_DATA) + dcod_data_in_reg;
                                 
                cnt_data <= NULL;
                cnt_data_out <= NULL;
                _reg_ram_tx <= reg_ram_data_tx;
                                           
             end    
                
         end    

endmodule