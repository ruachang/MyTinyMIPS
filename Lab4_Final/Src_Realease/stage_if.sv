//

import mips_cpu_pkg::*;

module stage_if (
		input  logic     cpu_clk_50M,
		input  logic     cpu_rst_n,
		//interface with id
		input  logic  [2 : 0] jsel,
		input  word_t  if_i_Jaddr,
		input  word_t  if_i_Iaddr,
		input  word_t  if_i_JRaddr,
		// interface with im
		output im_addr_t if_o_pc,
		output logic     imce
	);

	im_addr_t addr_next;

	always_ff @ (posedge cpu_clk_50M) begin
		if(!cpu_rst_n) begin
			if_o_pc <= PC_INIT;
			imce   <= 1'b1;
		end
		else begin
			case (jsel)
				000:begin 
						if_o_pc <= addr_next;
						imce   <= 1'b1; 
					end
				001:begin 
						if_o_pc <= id_o_Jaddr;
						imce   <= 1'b1; 
					end
				010:begin 
						if_o_pc <= id_o_Iaddr;
						imce   <= 1'b1; 
					end
				100:begin 
						if_o_pc <= id_o_JRaddr;
						imce   <= 1'b1; 
					end
			endcase
		end
    end
    
    always_comb begin
        addr_next = if_o_pc + 4;
    end

endmodule
