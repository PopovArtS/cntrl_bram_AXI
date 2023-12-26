import mux_header::*; //load parameter
module switch_data_rx_n_v
(
	input	clk_15_o,
	
	input				end_data,
	input				data_std,
	input [ONE: NULL]	vsk_rate,

	//данные для выставления из bram
	input			dcod_start_v_i_ram, //mdm_loop_emu_z045 sig dcod_start_v_i
	input			dcod_data_v_i_ram, //mdm_loop_emu_z045 sig dcod_data_v_i
	input			dcod_start_n_i_ram, //ram nsk
	input			dcod_data_n_i_ram, //ram nsk

	
	//old data
	input 					cod_ce_n_in,
	input					cod_ce_v_in,
	input					dcod_start_v_in,
	input					dcod_start_n_in,
	input	[FIVE: NULL]	dcod_data_v_in,
	input	[THREE: NULL]	dcod_data_n_in,
	
	//ram data
	output 					cod_ce_n_ram,
	output					cod_ce_v_ram,
	
	//out signals
	output 					cod_ce_n_out,
	output					cod_ce_v_out,
	output					dcod_start_v_out,
	output					dcod_start_n_out,
	output	[FIVE: NULL]	dcod_data_v_out,
	output	[THREE: NULL]	dcod_data_n_out
	
);

	/* logic
	логику использовать для выдачи данных из ram, старую напрямую
		vsk тактируется clk_15_o
		sdrb_data_clk_locked - то есть всегда можно принимать
		dcod_start_v_i - старт и прореживание
	
	*/
    logic					dcod_start_v_ram;
    logic                    dcod_start_n_ram;
    logic    [FIVE: NULL]    dcod_data_v_ram;
    logic    [THREE: NULL]    dcod_data_n_ram;
	
	//block assign, choose line
	/*assign cod_ce_n_out 	= (data_std == ONE && _end_data [ONE] == NULL)  ? cod_ce_n_ram 		: cod_ce_n_in;
	assign cod_ce_v_out 	= (data_std == ONE && _end_data [ONE] == NULL)	? cod_ce_v_ram 		: cod_ce_v_in;
	assign dcod_start_v_out	= (data_std == ONE && _end_data [ONE] == NULL)	? dcod_start_v_ram 	: dcod_start_v_in; 
	assign dcod_start_n_out	= (data_std == ONE && _end_data [ONE] == NULL)	? dcod_start_n_ram 	: dcod_start_n_in;
	assign dcod_data_v_out 	= (data_std == ONE && _end_data [ONE] == NULL)	? dcod_data_v_ram 	: dcod_data_v_in;
	assign dcod_data_n_out 	= (data_std == ONE && _end_data [ONE] == NULL)	? dcod_data_n_ram 	: dcod_data_n_in;*/
	assign cod_ce_n_out = _cod_ce_n_out;
	assign cod_ce_v_out = _cod_ce_v_out;
	assign dcod_start_v_out = _dcod_start_v_out;
	assign dcod_start_n_out = _dcod_start_n_out;
	assign dcod_data_v_out = _dcod_data_v_out;
	assign dcod_data_n_out = _dcod_data_n_out;
		
	//end block assign
	logic _cod_ce_n_out, _cod_ce_v_out, _dcod_start_v_out, _dcod_start_n_out;
	logic [FIVE:NULL] _dcod_data_v_out;
	logic [THREE: NULL] _dcod_data_n_out;
	
	logic bb_ce_3_75M, bb_ce_7_5M;
	logic [ONE: NULL] bb_ce_3_75M_cntr;
	assign bb_cod_ce_v_i_ram = (vsk_rate[ONE: NULL] == TWO) ? bb_ce_3_75M : (vsk_rate[ONE: NULL] == ONE) ? bb_ce_7_5M : ONE;
	
	logic [ONE: NULL] _end_data;
	always @(posedge clk_15_o) begin
	   _end_data <= {_end_data [NULL], end_data};
	   _cod_ce_n_out 	<= (data_std == ONE && _end_data [ONE] == NULL)  ? cod_ce_n_ram 		: cod_ce_n_in;
       _cod_ce_v_out     <= (data_std == ONE && _end_data [ONE] == NULL)    ? cod_ce_v_ram         : cod_ce_v_in;
       _dcod_start_v_out    <= (data_std == ONE && _end_data [ONE] == NULL)    ? dcod_start_v_ram     : dcod_start_v_in; 
       _dcod_start_n_out    <= (data_std == ONE && _end_data [ONE] == NULL)    ? dcod_start_n_ram     : dcod_start_n_in;
       _dcod_data_v_out     <= (data_std == ONE && _end_data [ONE] == NULL)    ? dcod_data_v_ram     : dcod_data_v_in;
       _dcod_data_n_out     <= (data_std == ONE && _end_data [ONE] == NULL)    ? dcod_data_n_ram     : dcod_data_n_in;
	   
	   
	end   
	   
	
	always @(posedge clk_15_o) 
		if (data_std == ONE) begin
			bb_ce_3_75M_cntr <= bb_ce_3_75M_cntr + ONE;
		
			if (bb_ce_3_75M_cntr[ONE: NULL] == NULL) 
				bb_ce_3_75M <= ONE;
			else 
				bb_ce_3_75M <= NULL;
		
			if (bb_ce_3_75M_cntr[NULL] == NULL) 
				bb_ce_7_5M <= ONE;
			else 
				bb_ce_7_5M <= NULL;
			
		end

	//vsk
	logic dcod_start_v_i_d_ram;
	logic [FIVE: NULL] dcod_data_v_i_d_ram;
	
	always @(posedge clk_15_o) begin //assign clk_15_o = data_clk_15M;
		if (data_std == ONE && bb_cod_ce_v_i_ram == ONE) begin
			dcod_start_v_i_d_ram 	<= dcod_start_v_i_ram; // start из ram vsk
			dcod_data_v_i_d_ram 	<= dcod_data_v_i_ram; // data из ram vsk
			
		end
	end

	//nsk
	logic we_data_ram; //enable write data ram
	always @(posedge clk_15_o) //assign clk_15_o = data_clk_15M;
		if (data_std == ONE && we_data_ram == ONE && bb_cod_ce_n_i_ram == ONE) begin
			dcod_start_n_ram 	<= dcod_start_n_i_ram; //выставленеие данных из ram nsk
			dcod_data_n_ram 	<= dcod_data_n_i_ram; //data из ram nsk
			
		end

	
	//i don`t know, delay ONE tact
	logic bb_cod_ce_n_i_ram, bb_cod_ce_v_i_ram, cod_ce_n_ram, cod_ce_v_ram;
	always @(posedge clk_15_o) 
		if (data_std == ONE) begin
			dcod_start_v_ram 	<= dcod_start_v_i_d_ram;
			dcod_data_v_ram 	<= dcod_data_v_i_d_ram;
			cod_ce_n_ram 		<= bb_cod_ce_n_i_ram; //сигнал о валидности данных на линии для забора
			cod_ce_v_ram		<= bb_cod_ce_v_i_ram;
			
		end
	
	logic [IEGHT: NULL] bb_cod_ce_n_cntr;
	//logic bb_cod_ce_n_4_out;
	
	//now, as standart package, по сути пропуски, для взятия сигнала nsk из ram
	//нужно счётчит синхронизировать с выдачей ram 
	always @(posedge clk_15_o) 
		if (data_std == ONE) begin
			if (bb_cod_ce_n_cntr == NULL) bb_cod_ce_n_cntr <= WINDOW_CUT; else bb_cod_ce_n_cntr <= bb_cod_ce_n_cntr - ONE;
			if (bb_cod_ce_n_cntr == NULL) bb_cod_ce_n_i_ram <= ONE; else bb_cod_ce_n_i_ram <= NULL; //это enable для выдачи nsk
			if (bb_cod_ce_n_cntr == WINDOW_CUT_0_5) we_data_ram <= ONE; else we_data_ram <= NULL; //логика разрешения отностильно 15 МГц для пакета nsk
		
		end




endmodule