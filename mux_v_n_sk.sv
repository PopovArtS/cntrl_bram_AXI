import mux_header::*; //load parameter
module mux_v_n_sk 
(
	input clk_15_o, //read RAM 
	input clk_120,//vsk demodulutor for wr RAM clk_vsk_120_MHz
	
	/////////////////////////////////////////////////////////////////
	//rules 
	input			nrst,
	
	/////////////////////////////////////////////////////////////////
	input wire [MSB_RAM: NULL] rx0_modes_reg,
    input wire [SEVEN: NULL] irl_bpsk_bpatf_var_delay,
    input wire [THREE: NULL] irl_bpsk_sts_var_delay,
    input wire [THREE: NULL] irl_bpsk_rate01_sts_var_delay,
    input wire [THREE: NULL] irl_bpsk_rate10_sts_var_delay,
    input wire [FOUR: NULL] irl_bpsk_accum_div_sig,
    input wire [FOUR: NULL] irl_bpsk_sts_accum_div_sig,
    input wire [MSB_RAM: NULL] agc_parameters_reg,
    input wire [MSB_RAM: NULL] agc_sec_params_reg,

	/////////////////////////////////////////////////////////////////	
	//signals input mdm
	input			cod_data_v,
	input			cod_data_n,

	input			mvsk_on,
	input			mnsk_on,
	
	input [ONE: NULL]	vsk_rate,
	
	/////////////////////////////////////////////////////////////////
	//signals output mdm
/*(*mark_debug = "true"*)*/	input start_write_for_ip_snif_v_o,
    input start_write_for_ip_snif_n_o,
/*(*mark_debug = "true"*)*/	input           inf_clk_out,
/*(*mark_debug = "true"*)*/    input    [FIVE: NULL] soft_demodulated_v_out,
/*(*mark_debug = "true"*) */   input           clk120_ce_n_out,
/*(*mark_debug = "true"*)  */  input    [THREE: NULL] soft_demodulated_n_out,
    
/*(*mark_debug = "true"*)*/	input 			cod_ce_n, //open no shifr
	input 			cod_ce_v, //open no shifr
	input 			dcod_start_v,
	input 			dcod_start_n,

	input [FIVE: NULL] 	dcod_data_v, //shifr data
	input [THREE: NULL]	dcod_data_n, //shifr data
	
	/////////////////////////////////////////////////////////////////
	//signals output mdm (no mix)
	output			cod_ce_n_out,
	output			cod_ce_v_out,
	output			dcod_start_v_out,
	output			dcod_start_n_out,
	output	[FIVE: NULL]		dcod_data_v_out,
	output	[THREE: NULL]		dcod_data_n_out,
	
	/////////////////////////////////////////////////////////////////
	//data out to RAM Tx //mdm to ant
	output 	[MSB_RAM: NULL] 		data_ram_tx_out, 
	output 	[MSB_RAM_TX_WIDTH: NULL]addr_ram_tx_o,
	output	[THREE: NULL]			we_ram_tx,
	
	output  [MSB_RAM: NULL] 		reg_contrl_data_Tx_line_Tx,
	
	///////////////////////////////NSK//////////////////////////////////
	//data out to RAM Rx //ant to mdm
	input	[MSB_RAM: NULL]		data_ram_rx_vsk_in,
/*(*mark_debug = "true"*)*/	output 	[MSB_RAM: NULL] 	data_ram_rx_vsk_out,  
/*(*mark_debug = "true"*)*/	output 	[MSB_ADDR_VSK: NULL] addr_ram_rx_vsk_o,
/*(*mark_debug = "true"*)*/	output	[THREE: NULL]			we_ram_rx_vsk,
	//output							en_ram_rx_vsk,
	
	output [MSB_RAM: NULL] reg_contrl_data_Tx_line_Rx_vsk,
	output [MSB_RAM: NULL] reg_contrl_upr_Rx_line_Rx_vsk, //[0] - end read, [1] - read page, [2] - valid data
	
    //////////////////////////////VSK///////////////////////////////////
    //data out to RAM Rx //ant to mdm
    input    [MSB_RAM: NULL]        data_ram_rx_nsk_in,
/*(*mark_debug = "true"*)*/    output     [MSB_RAM: NULL]     data_ram_rx_nsk_out,  
/*(*mark_debug = "true"*)*/    output     [TEN: NULL]         addr_ram_rx_nsk_o,
/*(*mark_debug = "true"*)*/    output    [THREE: NULL]            we_ram_rx_nsk,
    //output                            en_ram_rx_nsk,

    output [MSB_RAM: NULL] reg_contrl_data_Tx_line_Rx_nsk,
    output [MSB_RAM: NULL] reg_contrl_upr_Rx_line_Rx_nsk,    
	
	//input	[MSB_RAM: NULL] 		reg_contrl_line_Rx_rx,

    input  [MSB_RAM: NULL] data_in_ram_reg_time_axi,
    input  [MSB_RAM: NULL] reg_upr_read_comad // [0] read vsk data, [1] read nsk data, [3: 2] - vsk_rate, perebrat bits, [4] - cpu begin read data vsk, [5] - cpu begin read data nsk,
    	
);
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////reg_config
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    logic [MSB_RAM: NULL] reg_config_cmd_rcv_0;
    logic [MSB_RAM: NULL] reg_config_cmd_rcv_1;
    logic [MSB_RAM: NULL] reg_config_cmd_rcv_2;
    
    always @(posedge clk_120) 
        if (cnt_data_line_Rx_vsk_tx == RANG_RAM || cnt_data_line_Rx_tx_nsk == RANG_RAM) begin
            reg_config_cmd_rcv_0 <= {irl_bpsk_rate10_sts_var_delay, irl_bpsk_rate01_sts_var_delay, irl_bpsk_sts_var_delay, irl_bpsk_bpatf_var_delay, rx0_modes_reg[31], rx0_modes_reg[27], rx0_modes_reg[25], rx0_modes_reg[24: 19], rx0_modes_reg[15:14], rx0_modes_reg[TEN], rx0_modes_reg[SIX]};
            reg_config_cmd_rcv_1 <= agc_parameters_reg;
            reg_config_cmd_rcv_2 <= {irl_bpsk_accum_div_sig, irl_bpsk_sts_accum_div_sig, agc_sec_params_reg[14: NULL]};   
            
        end   

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////LINE Tx BRAM 
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 22/08/23 - module bram_Tx work, check tb	
	//отправка данных в антенну
	bram  #(
		.RANG_RAM(31),
	    .MSB_RAM_WIDTH(31),
	    .LENGHT_RAM(8192)
	
	) bram_Tx (
		.clk_in(clk_15_o),
		.nrst(nrst),
		.mvsk_on(mvsk_on),
		.mnsk_on(mnsk_on),
		.cod_ce_n(cod_ce_n),
		.cod_ce_v(cod_ce_v),
		.data_std(NULL), //only tx 
		.cnt_data(cnt_data_line_Tx_tx), //we for module
		.reg_data_for_ram(reg_ram_line_Tx_tx),//data write
				
        .reg_contrl_data_Tx(reg_contrl_data_Tx_line_Tx),//for AXI
        .data_in_ram_reg_time_axi(data_in_ram_reg_time_axi),
        
		.addr_ram_o(addr_ram_tx_o),//addr for ram
		.data_ram_tx_out(data_ram_tx_out), //data for ram
		.we_ram(we_ram_line_Rx_tx)
		
	);
	
	logic we_ram_line_Rx_tx; //i don't know machine write, this 
	logic [MSB_RAM: NULL] 		data_ram_tx_out;
	assign we_ram_tx = {FOUR{we_ram_line_Rx_tx}};
	logic [FOUR: NULL] cnt_data_line_Tx_tx;
	logic [MSB_RAM: NULL] reg_ram_line_Tx_tx;
	// 22/08/23 - module mux_v_n_cod_v_1_0 work, check tb	
	//запись Tx в bram с линии в mdm
	mux_v_n_cod mux_v_n_cod_v_1_0 (
		.clk_15_o(clk_15_o),
		.nrst(nrst),	
		.cod_data_v(cod_data_v),
		.cod_ce_n(cod_ce_n), //если 0, то данные nsk
		.cod_data_n(cod_data_n), 
	    .mvsk_on(mvsk_on),
	    .mnsk_on(mnsk_on),
		.cnt_data(cnt_data_line_Tx_tx),	
		.data_in_ram_tx_reg_b(reg_ram_line_Tx_tx)
	
	);
	

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////LINE Rx BRAM VSK
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 22/08/23 - module mux_v_n_dcod_in_vsk_1_0 work, check tb		
	//выгразка данных из памяти - вместо антенны
	bram   #(
        .RANG_RAM(31),
        .MSB_RAM_WIDTH(31),
        .LENGHT_RAM(LENGHT_BRAM_VSK),
        .MSB_RAN(16),
        .WE_REG_CONFIG_CMD(1)
    
    ) bram_Rx_vsk (
        .clk_in(clk_120),
        .nrst(nrst),
        .reg_config_cmd_rcv_0(reg_config_cmd_rcv_0),
        .reg_config_cmd_rcv_1(reg_config_cmd_rcv_1),
        .reg_config_cmd_rcv_2(reg_config_cmd_rcv_2),
        .mnsk_on(NULL),
        .mvsk_on(~flag_reboot_bram_vsk), //for update addr for begin addr - 0, 
        .flag_down_last_data(flag_down_last_data),//признак выгрузки данных в sv4, end read data for AXI
        .data_std(reg_data_std_vsk),//условие для чтения, 1 - read, 0 - write, 0 - default, input AXI
        .cnt_data(cnt_data_line_Rx_vsk_tx),//последние биты для записи

        .cod_ce_v(cod_ce_v),
        
        .reg_contrl_data_Tx(reg_contrl_data_Tx_line_Rx_vsk),
        .reg_contrl_upr_Rx(reg_contrl_upr_Rx_line_Rx_vsk),
        .data_in_ram_reg_time_axi(data_in_ram_reg_time_axi),

        .reg_data_for_ram(reg_ram_line_Rx_tx_vsk), //обработанные данные для записи в bram
        .reg_addr_for_ram_rx(addr_ram_line_Rx_tx_sk),
        .data_ram_tx_out(data_ram_rx_vsk_out), //запись данных в bram
        .addr_ram_o(addr_ram_rx_vsk_o), //адрес для bram, переключаемый, для чтения и записи
        .we_ram(_we_ram_rx_vsk)    //запись по это  признику
        
    );	
		
/*(*mark_debug = "true"*)*/	logic _we_ram_rx_vsk;
	assign we_ram_rx_vsk = {FOUR{_we_ram_rx_vsk}};
    
    logic [FOUR: NULL] cnt_data_line_Rx_vsk_tx;
    logic [MSB_RAM: NULL] reg_ram_line_Rx_tx_vsk;
    logic [MSB_ADDR_VSK: NULL] addr_ram_line_Rx_tx_sk;
	
	logic flag_down_last_data;
	
	logic reg_data_std_vsk;
	assign reg_data_std_vsk = reg_upr_read_comad[NULL];
	
	logic inf_clk_out, clk120_ce_n_out;
	logic [FIVE: NULL] soft_demodulated_v_out;
	logic [THREE: NULL] soft_demodulated_n_out;
	
	logic flag_nsk_out, flag_reboot_bram_vsk;
    
    assign reg_contrl_upr_Rx_line_Rx_vsk [TWO] =  flag_vsk_out;
    assign reg_contrl_upr_Rx_line_Rx_vsk [THREE] =  locked_bram_once_out_vsk;
    
    logic locked_bram_once_in_vsk, locked_bram_once_out_vsk;
    assign locked_bram_once_in_vsk = reg_upr_read_comad[BIT_ONCE_VSK];
    
// 22/08/23 - module mux_v_n_dcod_in_vsk_1_0 work, check tb	    
//запись Tx в bram с линии в sv4
	mux_v_n_dcod_in   #(
        .LIMIT_SK_IN(FIVE),
        .LEFT_DATA(SIX),
        .ADD_CNT(FOUR),
        .LENGHT_BRAM(LENGHT_BRAM_VSK),
        .PACKAGE_PACT(ONE),
        .MSB_ADDR(MSB_ADDR_VSK)    
    ) mux_v_n_dcod_in_vsk_1_0    (
        .clk            (inf_clk_out),
        .clk_120        (clk_120),
        .locked_bram_once_in(locked_bram_once_in_vsk),
        .locked_bram_once_out(locked_bram_once_out_vsk),
        .locked_we      (reg_data_std_vsk),
        .flag_reboot_bram(flag_reboot_bram_vsk),
        .cnt_data_tx    (cnt_data_line_Rx_vsk_tx), 
        .flag_sk_out    (flag_vsk_out),
        .flag_otv       (reg_upr_read_comad[FOUR]),
        //.addr_ram_tx    (),
        .reg_ram_tx     (reg_ram_line_Rx_tx_vsk),
        .soft_demodulated_out (soft_demodulated_v_out),
        .dcod_start_in(start_write_for_ip_snif_v_o)
    
    );
	
//управляющие сигналы для загрузки из bram
	logic [MSB_RAM: NULL] reg_upr_read_comad;
	
//загрузка страницы bram
	logic number_page;
	logic [MSB_CNT_DATA: NULL] weight_pack;
	assign weight_pack = (reg_data_std_nsk || reg_data_std_vsk) ? reg_upr_read_comad [MSB_CNT_DATA + IEGHT: IEGHT] : NULL;
	
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////LINE Rx BRAM NSK
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
 	// 22/08/23 - module bram_Rx_nsk work, check tb	
 	bram   #(
        .RANG_RAM(31),
        .MSB_RAM_WIDTH(31),
        .LENGHT_RAM(LENGHT_BRAM_NSK),
        .WE_REG_CONFIG_CMD(1),
        .MSB_RAN(10)
    
    ) bram_Rx_nsk (
        .clk_in(clk_120),
        .nrst(nrst),
		.reg_config_cmd_rcv_0(reg_config_cmd_rcv_0),
        .reg_config_cmd_rcv_1(reg_config_cmd_rcv_1),
        .reg_config_cmd_rcv_2(reg_config_cmd_rcv_2),
        .mnsk_on(~flag_reboot_bram_nsk),
        .mvsk_on(NULL), //for update addr for begin addr - 0, 
        .flag_down_last_data(flag_down_last_data),//признак выгрузки данных в sv4, end read data for AXI
        .data_std(reg_data_std_nsk),//условие для чтения, 1 - read, 0 - write, 0 - default, input AXI
        .cnt_data(cnt_data_line_Rx_tx_nsk),//последние биты для записи

        .cod_ce_v(NULL),
        .cod_ce_n(clk120_ce_n_out),
        
        .reg_contrl_data_Tx(reg_contrl_data_Tx_line_Rx_nsk),
        .reg_contrl_upr_Rx(reg_contrl_upr_Rx_line_Rx_nsk),
        .data_in_ram_reg_time_axi(data_in_ram_reg_time_axi),

        .reg_data_for_ram(reg_ram_line_Rx_tx_nsk), //обработанные данные для записи в bram
        .reg_addr_for_ram_rx(addr_ram_line_Rx_tx_sk),
        .data_ram_tx_out(data_ram_rx_nsk_out), //запись данных в bram
        .addr_ram_o(addr_ram_rx_nsk_o), //адрес для bram, переключаемый, для чтения и записи
        .we_ram(_we_ram_rx_nsk)    //запись по это  признику
        
    );   
    	
/*(*mark_debug = "true"*)*/	logic _we_ram_rx_nsk;
    assign we_ram_rx_nsk = {FOUR{_we_ram_rx_nsk}};
    
    logic [MSB_RAM: NULL] reg_ram_line_Rx_tx_nsk;
    logic [TEN: NULL] addr_ram_line_Rx_tx_nsk;
        
    logic [FOUR: NULL] cnt_data_line_Rx_tx_nsk;
        
    logic [MSB_RAM: NULL] data_ram_line_Rx_rx; //данные с bram линни Rx 
    assign data_ram_line_Rx_rx = (reg_data_std_vsk == ONE) ? data_ram_rx_vsk_in : data_ram_rx_nsk_in;
	
	logic reg_data_std_nsk;
    assign reg_data_std_nsk = reg_upr_read_comad[ONE];
    
    assign reg_contrl_upr_Rx_line_Rx_nsk [TWO] =  flag_nsk_out;
    assign reg_contrl_upr_Rx_line_Rx_nsk [THREE] =  locked_bram_once_out_nsk;
    
    logic locked_bram_once_in_nsk, locked_bram_once_out_nsk;
    assign locked_bram_once_in_nsk = reg_upr_read_comad [BIT_ONCE_NSK];

// 22/08/23 - module mux_v_n_dcod_in_nsk_1_0 work, check tb	
//запись Tx в bram с линии в sv4
    logic flag_reboot_bram_nsk;
    
    mux_v_n_dcod_in   #(
        .LIMIT_SK_IN(THREE),
        .LEFT_DATA(FOUR),
        .ADD_CNT(FOUR),
        .LENGHT_BRAM(LENGHT_BRAM_NSK),
        .PACKAGE_PACT(NULL),
        .MSB_ADDR(TEN)      
    ) mux_v_n_dcod_in_nsk_1_0    (
        .clk            (clk120_ce_n_out),
        .clk_120        (clk_120),
        .locked_bram_once_in(locked_bram_once_in_nsk),
        .locked_bram_once_out(locked_bram_once_out_nsk),
        .locked_we      (reg_data_std_nsk),
        .flag_reboot_bram(flag_reboot_bram_nsk),
        .cnt_data_tx    (cnt_data_line_Rx_tx_nsk), 
        .flag_sk_out    (flag_nsk_out),
        .flag_otv       (reg_upr_read_comad[FIVE]),
        //.addr_ram_tx    (),
        .reg_ram_tx     (reg_ram_line_Rx_tx_nsk),
        .soft_demodulated_out (soft_demodulated_n_out),
        .dcod_start_in(start_write_for_ip_snif_n_o)
    
    );
	
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////LINE Rx SWITCH VSK AND NSK
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
/*(*mark_debug = "true"*)*/	logic [FIVE: NULL] dcod_data_v_ram;
/*(*mark_debug = "true"*)*/	logic [THREE: NULL] dcod_data_n_ram;
/*(*mark_debug = "true"*)*/	logic dcod_start_v_ram;
/*(*mark_debug = "true"*)*/	logic dcod_start_n_ram;
//22/08/23 - module switch_data_rx_n_v_v_1_0 work, don't use tb
/////////////переключение данных
//сюда грузим данные из/в память на/с линию
	switch_data_rx_n_v switch_data_rx_n_v_v_1_0 (
		.clk_15_o(clk_15_o),
		.end_data(flag_down_last_data),
		.data_std(reg_data_std_vsk || reg_data_std_nsk),
		.vsk_rate(reg_upr_read_comad[THREE: TWO]),
		.dcod_start_v_i_ram(dcod_start_v_ram),
		.dcod_data_v_i_ram(dcod_data_v_ram), 
		.dcod_start_n_i_ram(dcod_start_n_ram),
		.dcod_data_n_i_ram(dcod_data_n_ram), 
		.cod_ce_n_in(cod_ce_n),
		.cod_ce_v_in(cod_ce_v),
		.dcod_start_v_in(dcod_start_v),
		.dcod_start_n_in(dcod_start_n),
		.dcod_data_v_in(dcod_data_v),
		.dcod_data_n_in(dcod_data_n),		
		//.cod_ce_n_ram(cod_ce_n_ram), //can use norm cod_ce_n
		.cod_ce_v_ram(cod_ce_v_ram), //vsk_rate on
		.cod_ce_n_out(cod_ce_n_out),
		.cod_ce_v_out(cod_ce_v_out),
		.dcod_start_v_out(dcod_start_v_out),
		.dcod_start_n_out(dcod_start_n_out),
		.dcod_data_v_out(dcod_data_v_out),
		.dcod_data_n_out(dcod_data_n_out)	
	
	);
	
	logic dcod_start_v_out, dcod_start_n_out;
    
//22/08/23 - check tb, module mux_v_n_dcod_sk_v_1_0 work
//Rx из bram в sv4 
//need to divide tip data vsk and nsk
	mux_v_n_dcod mux_v_n_dcod_sk_v_1_0 (
		.clk_15_o(clk_15_o),
		.clk_120(clk_120),
		.nrst(nrst),
		.data_std(reg_data_std_vsk || reg_data_std_nsk),//условие для чтения
		.weight_pack(weight_pack),
		.flag_down_last_data(flag_down_last_data),
		.cod_ce_v(reg_data_std_vsk && cod_ce_v_ram),
		.cod_ce_n(reg_data_std_nsk && cod_ce_n),// cod_ce_n_ram
		.data_ram_rx_in(data_ram_line_Rx_rx),
		.addr_ram_rx(addr_ram_line_Rx_tx_sk),	
		.dcod_data_v_ram(dcod_data_v_ram),
		.dcod_data_n_ram(dcod_data_n_ram), 
		.dcod_start_v_ram(dcod_start_v_ram), //check start_nsk, need long or short (now short)
		.dcod_start_n_ram(dcod_start_n_ram)//in block give one clk_15_o  //can use, it's good
	
	);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

endmodule