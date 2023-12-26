	module ip_snif_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here
        input wire clk_15_0,
        input wire clk_120,
        input wire nrst, 
        input wire [1: 0] vsk_rate,
        input wire cod_data_v,
        input wire cod_data_n,
        input wire mvsk_on,
        input wire mnsk_on,
        input wire start_write_for_ip_snif_v_o,
        input wire start_write_for_ip_snif_n_o,
        input wire inf_clk_out,
        input wire [5: 0] soft_demodulated_v_out,
        input wire clk120_ce_n_out,
        input wire [3: 0] soft_demodulated_n_out,
        input wire cod_ce_n,
        input wire cod_ce_v,
        input wire dcod_start_v,
        input wire dcod_start_n,
        input wire [5: 0] dcod_data_v,
        input wire [3: 0] dcod_data_n,
        output wire cod_ce_n_out,
        output wire cod_ce_v_out,
        output wire dcod_start_v_out,
        output wire dcod_start_n_out,
        output wire [5: 0]  dcod_data_v_out,
        output wire [3: 0] dcod_data_n_out,
        
        input wire [31: 0] data_ram_rx_vsk_in,
        input wire [31: 0] data_ram_rx_nsk_in,
        output wire [31: 0] data_ram_tx_out,
        output wire [31: 0] data_ram_rx_vsk_out,
        output wire [31: 0] data_ram_rx_nsk_out,
        output wire [12: 0] addr_ram_tx_o,
        output wire [16: 0] addr_ram_rx_vsk_o,
        output wire [10: 0] addr_ram_rx_nsk_o,
        output wire [3: 0] we_ram_tx,
        output wire [3: 0] we_ram_rx_vsk,
        output wire [3: 0] we_ram_rx_nsk,
        
        input wire [31:0] rx0_modes_reg,
        input wire [7:0] irl_bpsk_bpatf_var_delay,
        input wire [3:0] irl_bpsk_sts_var_delay,
        input wire [3:0] irl_bpsk_rate01_sts_var_delay,
        input wire [3:0] irl_bpsk_rate10_sts_var_delay,
        input wire [4:0] irl_bpsk_accum_div_sig,
        input wire [4:0] irl_bpsk_sts_accum_div_sig,
        input wire [31:0] agc_parameters_reg,
        input wire [31:0] agc_sec_params_reg,

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
	ip_snif_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) ip_snif_v1_0_S00_AXI_inst (

	     .clk_15_o(clk_15_0),
	     .clk_120(clk_120),
         .nrst(nrst), //if Hihg - rst, low - no rst
    // coder interface
         .vsk_rate(vsk_rate),
         .cod_data_v(cod_data_v),
         .cod_data_n(cod_data_n),
         .mvsk_on(mvsk_on),
         .mnsk_on(mnsk_on),
         .cod_ce_n(cod_ce_n),
         .cod_ce_v(cod_ce_v),
         .dcod_start_v(dcod_start_v),
         .dcod_start_n(dcod_start_n),
         .dcod_data_v(dcod_data_v),
         .dcod_data_n(dcod_data_n),
         .cod_ce_n_out(cod_ce_n_out),
         .cod_ce_v_out(cod_ce_v_out),
         .dcod_start_v_out(dcod_start_v_out),
         .dcod_start_n_out(dcod_start_n_out),
         .dcod_data_v_out(dcod_data_v_out),
         .dcod_data_n_out(dcod_data_n_out),
         .inf_clk_out(inf_clk_out),
         .soft_demodulated_v_out(soft_demodulated_v_out),
         .clk120_ce_n_out(clk120_ce_n_out),
         .soft_demodulated_n_out(soft_demodulated_n_out),
         .start_write_for_ip_snif_v_o(start_write_for_ip_snif_v_o),
         .start_write_for_ip_snif_n_o(start_write_for_ip_snif_n_o),
         
         .rx0_modes_reg(rx0_modes_reg),
         .irl_bpsk_bpatf_var_delay(irl_bpsk_bpatf_var_delay),
         .irl_bpsk_sts_var_delay(irl_bpsk_sts_var_delay),
         .irl_bpsk_rate01_sts_var_delay(irl_bpsk_rate01_sts_var_delay),
         .irl_bpsk_rate10_sts_var_delay(irl_bpsk_rate10_sts_var_delay),
         .irl_bpsk_accum_div_sig(irl_bpsk_accum_div_sig),
         .irl_bpsk_sts_accum_div_sig(irl_bpsk_sts_accum_div_sig),
         .agc_parameters_reg(agc_parameters_reg),
         .agc_sec_params_reg(agc_sec_params_reg),

    // bram interface
         .data_ram_tx_out(data_ram_tx_out),
         .data_ram_rx_vsk_out(data_ram_rx_vsk_out),
         .data_ram_rx_nsk_out(data_ram_rx_nsk_out),
         .data_ram_rx_vsk_in(data_ram_rx_vsk_in),
         .data_ram_rx_nsk_in(data_ram_rx_nsk_in),
         .addr_ram_tx_o(addr_ram_tx_o),
         .addr_ram_rx_vsk_o(addr_ram_rx_vsk_o),
         .addr_ram_rx_nsk_o(addr_ram_rx_nsk_o),
         .we_ram_tx(we_ram_tx),
         .we_ram_rx_vsk(we_ram_rx_vsk),
         .we_ram_rx_nsk(we_ram_rx_nsk),

		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
