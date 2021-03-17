//

import mips_cpu_pkg::*;

module stage_id
  (
    // interface with rf
    output logic        rfre1,
    output reg_enum     rfra1,
    input  word_t       rfrd1,
    output logic        rfre2,
    output reg_enum     rfra2,
    input  word_t       rfrd2,

    //interface with jump op
    input  im_addr_t    id_i_pc,

    //interface with load dependence
    input  word_t       ex_fwd_rfwd,
    input  reg_enum     ex_fwd_rfwa,
    input  logic        ex_fwd_rfwe,
    input  word_t       mem_fwd_rfwd,
    input  reg_enum     mem_fwd_rfwa,
    input  logic        mem_fwd_rfwe,
    input  word_t       wb_fwd_rfwd,
    input  reg_enum     wb_fwd_rfwa,
    input  logic        wb_fwd_rfwe,

    // interface with res_if
    output word_t       id_o_Jaddr,
    output word_t       id_o_JRaddr,
    output word_t       id_o_Iaddr,
    output logic [2 : 0]jsel,
    // interface with regs_ifid
    input  inst_t       id_i_inst,
    // interface with regs_idexe
    output logic        id_o_dm2rf,
    output logic        id_o_hilowe,
    output logic        id_o_rfwe,
    output alutype_enum id_o_alutype,
    output aluop_struct id_o_aluop,
    output reg_enum     id_o_rfwa,
    output word_t       id_o_src1,
    output word_t       id_o_src2,
    output word_t       id_o_dmdin,
    output memop_struct id_o_memop
  );

  // rearrange inst
  inst_t               rearranged_inst;
  //assign rearranged_inst = inst_t'({id_i_inst[7 : 0],id_i_inst[15 : 8],
  //id_i_inst[23 : 16],id_i_inst[31 : 24]});
  assign rearranged_inst = id_i_inst;
  // extract segments of inst
  opcode_enum          opcode;
  func_enum            func;
  reg_enum             rd;
  reg_enum             rs;
  reg_enum             rt;
  logic       [4 : 0]  sa;
  logic       [15 : 0] imm;
  logic       [25 : 0] index;

  assign opcode          = rearranged_inst.r.op;
  assign func            = rearranged_inst.r.func;
  assign rd              = rearranged_inst.r.rd;
  assign rs              = rearranged_inst.r.rs;
  assign rt              = rearranged_inst.r.rt;
  assign sa              = rearranged_inst.r.sa;
  assign index           = rearranged_inst.j.index;
  assign imm             = rearranged_inst.i.imm;

  // todo : step0 - add the instruction
  logic                is_inst_r;
  // not of type r, using opecode to define
  logic                is_ADDI;
  logic                is_ADDIU;
  logic                is_SLTI;
  logic                is_SLTIU;
  logic                is_ANDI;
  logic                is_ORI;
  logic                is_XORI;
  logic                is_LUI;
  logic                is_LB;
  logic                is_LBU;
  logic                is_LH;
  logic                is_LHU;
  logic                is_LW;
  logic                is_SB;
  logic                is_SH;
  logic                is_SW;
  logic                is_BLTZ;
  logic                is_BEQ;
  logic                is_BNE;
  logic                is_J;
  logic                is_JAL;

  assign is_inst_r       = ~|opcode;

  assign is_ADDI         = opcode == ADDI;
  assign is_ADDIU        = opcode == ADDIU;
  assign is_SLTI         = opcode == SLTI;
  assign is_SLTIU        = opcode == SLTIU;
  assign is_ANDI         = opcode == ANDI;
  assign is_ORI          = opcode == ORI;
  assign is_XORI         = opcode == XORI;
  assign is_LUI          = opcode == LUI;
  assign is_LB           = opcode == LB;
  assign is_LBU          = opcode == LBU;
  assign is_LH           = opcode == LH;
  assign is_LHU          = opcode == LHU;
  assign is_LW           = opcode == LW;
  assign is_SB           = opcode == SB;
  assign is_SH           = opcode == SH;
  assign is_SW           = opcode == SW;
  assign is_BLTZ         = opcode == BLTZ&&(rt==00000);
  assign is_BEQ          = opcode == BEQ;
  assign is_BNE          = opcode == BNE;
  assign is_J            = opcode == J;
  assign is_JAL          = opcode == JAL;

  // of type r, using func to define
  logic                is_EMPTY;
  logic                is_ADD;
  logic                is_ADDU;
  logic                is_SUB;
  logic                is_SUBU;
  logic                is_SLT;
  logic                is_SLTU;
  logic                is_AND;
  logic                is_OR;
  logic                is_NOR;
  logic                is_XOR;
  logic                is_SLL;
  logic                is_SRL;
  logic                is_SRA;
  logic                is_SLLV;
  logic                is_SRLV;
  logic                is_SRAV;
  logic                is_MULT;
  logic                is_MULTU;
  logic                is_DIV;
  logic                is_DIVU;
  logic                is_MFHI;
  logic                is_MFLO;
  logic                is_MTHI;
  logic                is_MTLO;
  logic                is_JR;

  assign is_EMPTY        = (rearranged_inst == 32'h0 );
  assign is_ADD          = (is_inst_r && func == ADD );
  assign is_ADDU         = (is_inst_r && func == ADDU);
  assign is_SUB          = (is_inst_r && func == SUB );
  assign is_SUBU         = (is_inst_r && func == SUBU);
  assign is_SLT          = (is_inst_r && func == SLT );
  assign is_SLTU         = (is_inst_r && func == SLTU);
  assign is_AND          = (is_inst_r && func == AND );
  assign is_OR           = (is_inst_r && func == OR );
  assign is_NOR          = (is_inst_r && func == NOR );
  assign is_XOR          = (is_inst_r && func == XOR );
  assign is_SLL          = (is_inst_r && func == SLL )&&(!is_EMPTY);
  assign is_SRL          = (is_inst_r && func == SRL );
  assign is_SRA          = (is_inst_r && func == SRA );
  assign is_SLLV         = (is_inst_r && func == SLLV);
  assign is_SRLV         = (is_inst_r && func == SRLV);
  assign is_SRAV         = (is_inst_r && func == SRAV);
  assign is_MULT         = (is_inst_r && func == MULT);
  assign is_MULTU        = (is_inst_r && func == MULT);
  assign is_DIV          = (is_inst_r && func == DIV );
  assign is_DIVU         = (is_inst_r && func == DIVU);
  assign is_MFHI         = (is_inst_r && func == MFHI);
  assign is_MFLO         = (is_inst_r && func == MFLO);
  assign is_MTHI         = (is_inst_r && func == MTHI);
  assign is_JR           = (is_inst_r && func == JR);
  assign is_MTLO         = (is_inst_r && func == MTLO);

  // inner switch signal
  logic                jump_equ;

  logic                src2_rt;
  logic                src2_upper_imm;
  logic                src2_zero_ext_imm;
  logic                src2_sign_ext_imm;
  logic                src2_dont_care;

  logic                dst_rd;
  logic                dst_rt;
  logic                dst_hilo;
  logic                dst_REG31;
  logic                dst_dont_care;

  logic                dst_value_rf;
  logic                dst_value_dm;
  logic                dst_value_dont_care;

  logic                rtsel;
  logic                uppersel;
  logic                sextsel;
  logic                shiftsel;
  logic                immsel;
  logic                REG31sel;
  logic                pcsel;

  logic                jump_I;
  logic                jump_J;
  logic                jump_JR;
  logic                jump_seq;

  logic                is_add;
  logic                is_sub;
  logic                is_lt;

  logic                is_and;
  logic                is_or;
  logic                is_xor;
  logic                is_nor;

  logic                is_ll;
  logic                is_rl;
  logic                is_ra;

  logic                is_hi;
  logic                is_lo;

  logic                is_mult;
  logic                is_div;
  logic                is_empty;

  logic                is_load;
  logic                is_store;
  logic                is_none;
  logic                is_word;
  logic                is_half;
  logic                is_byte;

  logic                is_r31;
  
  // data dependence
  logic                rf1_idex_haz;
  logic                rf1_idmem_haz;
  logic                rf1_idwb_haz;

  word_t               new_rfrd1;
  word_t               new_rfrd2;
  logic                rf2_idex_haz;
  logic                rf2_idmem_haz;
  logic                rf2_idwb_haz;
  // passthrogh : none
  assign rfra1           = rs;
  assign rfra2           = rt;
  
  

  assign rf1_idex_haz    = (rfra1 == ex_fwd_rfwa)&&ex_fwd_rfwe;
  assign rf1_idmem_haz   = (rfra1 == mem_fwd_rfwa)&&mem_fwd_rfwe;
  assign rf1_idwb_haz    = (rfra1 == wb_fwd_rfwa)&&wb_fwd_rfwe;

  assign new_rfrd1       = rf1_idex_haz ? ex_fwd_rfwd :
    rf1_idmem_haz ? mem_fwd_rfwd :
    rf1_idwb_haz ? wb_fwd_rfwd : rfrd1;

  assign rf2_idex_haz    = (rfra2 == ex_fwd_rfwa)&&ex_fwd_rfwe;
  assign rf2_idmem_haz   = (rfra2 == mem_fwd_rfwa)&&mem_fwd_rfwe;
  assign rf2_idwb_haz    = (rfra2 == wb_fwd_rfwa)&&wb_fwd_rfwe;

  assign new_rfrd2       = rf2_idex_haz ? ex_fwd_rfwd :
    rf2_idmem_haz ? mem_fwd_rfwd :
    rf2_idwb_haz ? wb_fwd_rfwd : rfrd2;

  //determine source operands and destination register to write 
  always_comb begin
    word_t temp;
    // todo : step1 - determine source 1 [R[rs], sa]
    // only shift instructions will use 'sa' field of the instruction
    shiftsel          = is_SLL; 
    pcsel             = is_JAL;
    // source of src1
    // todo : step2 - determine source 2 [R[rt], SignExtImm, ZeroExtImm, Imm << 16]
    src2_rt           = is_ADD || is_SLT || is_SUBU || is_AND || is_MULT || is_SLL || is_SUB || is_MULTU;
    src2_upper_imm    = is_LUI;
    src2_sign_ext_imm = is_ADDIU || is_ADDI|| is_SLTIU || is_LB || is_LW || is_SB || is_SW || is_SLTI;
    src2_zero_ext_imm = is_ORI || is_XORI;
    src2_dont_care    = is_EMPTY || is_MFHI || is_MFLO;
        // for behavioral sim
    unique casez (1'b1) // fixme : 3-level MUX -> 2-level MUX ?
      src2_rt : {sextsel, uppersel, immsel}           = 3'b000;
      src2_upper_imm : {sextsel, uppersel, immsel}    = 3'b011;
      src2_sign_ext_imm : {sextsel, uppersel, immsel} = 3'b101;
      src2_zero_ext_imm : {sextsel, uppersel, immsel} = 3'b001;
      src2_dont_care : {sextsel, uppersel, immsel}    = 3'b000;
    endcase
    // todo : step3 - determine dst addr value source [R[rd], R[rt], hilo]
    dst_rd            = is_ADD  || is_SLT || is_AND || is_SLL || is_SUBU || is_MFHI|| is_MFLO || is_SUB;
    dst_rt            = is_ADDIU || is_ADDI || is_SLTIU || is_LB || is_LUI || is_LW || is_ORI || is_XORI || is_SLTI;
    dst_hilo          = is_MULT || is _MULTU;
    dst_REG31         = is_JAL;
    dst_dont_care     = is_EMPTY || is_SB || is_SW;
    unique casez (1'b1)
      dst_rd : {rtsel, id_o_rfwe, id_o_hilowe,REG31sel}        = 4'b0100;
      dst_rt : {rtsel, id_o_rfwe, id_o_hilowe,REG31sel}        = 4'b1100;
      dst_hilo : {rtsel, id_o_rfwe, id_o_hilowe,REG31sel}      = 4'b0010;
      dst_dont_care : {rtsel, id_o_rfwe, id_o_hilowe,REG31sel} = 4'b0000;
      dst_REG31 :  {rtsel, id_o_rfwe, id_o_hilowe,REG31sel}    = 4'b0101;
    endcase
    rfre1             = 1'b1;
    rfre2             = 1'b1;
    // datapaths
    id_o_rfwa         = rtsel ? rt : REG31sel? RA : rd;
    id_o_src1         = shiftsel ? sa : pcsel ? id_i_pc+ 4 : new_rfrd1;
    temp              = sextsel ? {{16{imm[15]}},imm} : {16'h0000, imm};
    temp              = uppersel ? (imm << 16) : temp;
    id_o_src2         = immsel ? temp : new_rfrd2;


    assign jump_equ   = (is_BEQ&&new_rfrd1 == new_rfrd2) || 
                        (is_BNE&&new_rfrd1 != new_rfrd2) ||
                        (is_BLTZ&&new_rfrd1 < ZERO)? 1'b1 : 1'b0;
    id_o_Jaddr        = {id_i_pc[31:28], index,2'b00};
    id_o_JRaddr       = new_rfrd1;
    id_o_Iaddr        = id_i_pc + {{14{imm[15]}},imm,2'b00};
    
    jump_J            = is_J || is_JAL;
    jump_JR           = is_JR;
    jump_I            = (is_BNE || is_BQE || is_BLTZ)&&jump_equ;
    jump_seq          = ~equ || ~(is_J || is_JR || is_JAL || is_BNE || is_BEQ);
    unique casez(1'b1)
      jump_J : {jsel[0],jsel[1],jsel[2]}   = 3'b100;
      jump_JR : {jsel[0],jsel[1],jsel[2]}  = 3'b010;
      jump_I : {jsel[0],jsel[1],jsel[2]}   = 3'b001;
      jump_seq : {jsel[0],jsel[1],jsel[2]} = 3'b000;
    endcase 
  end

  
  // alu decode
  always_comb begin
    // todo : step4 - determine alutype
    id_o_alutype[0] = // arith
    is_ADD || is_ADDI || is_SUBU || is_SLT || is_ADDIU || is_SLTIU ||
    is_LB || is_LW || is_SB || is_SW || is_SUB || is_SLTI;
    id_o_alutype[1] = // logic
    is_AND || is_ORI || is_LUI || is_XORI;
    id_o_alutype[2] = // move
    is_MFHI || is_MFLO;
    id_o_alutype[3] = // shift
    is_SLL;
    id_o_alutype[4] =
    is_JAL;
    // todo : step5 - determine aluop
    is_add          = is_ADD || is_ADDI || is_ADDIU || is_LB || is_LW || is_SB || is_SW;
    is_sub          = is_SUBU || is_SUB;
    is_and          = is_AND;
    is_or           = is_ORI || is_LUI;
    is_xor          = is_XORI;
    is_nor          = 1'b0;
    is_lt           = is_SLT ;
    is_lti          = is_SLTI;
    is_ll           = is_SLL;
    is_rl           = 1'b0;
    is_ra           = 1'b0;
    is_hi           = is_MFHI;
    is_lo           = is_MFLO;
    is_mult         = is_MULT || is_MULTU;
    is_div          = 1'b0;
    is_empty        = is_EMPTY;
    is_r31          = is_JAL;
    // fixme : try to take advantage from don't care
    id_o_aluop.sign = is_ADD || is_SLT || is_MULT || is_SUB;
    unique case (id_o_alutype)
      NOP : begin
        unique case (1'b1)
          is_mult : id_o_aluop.op.mult_op  = ALU_MULT;
          is_multi : id_o_aluop.op.multi.op = ALU_MULTI;
          is_div : id_o_aluop.op.mult_op   = ALU_DIV;
          is_empty : id_o_aluop.op.mult_op = ALU_MULT;
        endcase
      end
      ARITH : begin
        unique case(1'b1)
          is_add : id_o_aluop.op.arith_op = ALU_ADD;
          is_sub : id_o_aluop.op.arith_op = ALU_SUB;
          is_lt : id_o_aluop.op.arith_op  = ALU_LT;
          is_lti : id_o_aluop.op.arith_op =ALU_LTI;
        endcase
      end
      LOGIC : begin
        unique case(1'b1)
          is_and : id_o_aluop.op.logic_op = ALU_AND;
          is_or : id_o_aluop.op.logic_op  = ALU_OR;
          is_xor : id_o_aluop.op.logic_op = ALU_XOR;
          is_nor : id_o_aluop.op.logic_op = ALU_NOR;
        endcase
      end
      MOVE : begin
        unique case(1'b1)
          is_hi : id_o_aluop.op.move_op = ALU_HI;
          is_lo : id_o_aluop.op.move_op = ALU_LO;
        endcase
      end
      SHIFT : begin
        unique case(1'b1)
          is_ll : id_o_aluop.op.shift_op = ALU_LL;
          is_rl : id_o_aluop.op.shift_op = ALU_RL;
          is_ra : id_o_aluop.op.shift_op = ALU_RA;
        endcase
      end
      JUMP : begin
        unique case(1'b1)
          is_r31 : id_o_alutype.op.jump_op = ALU_R31;
        endcase
      end
    endcase
  end

  // todo : step6 - determine memop
  always_comb begin
    is_load         = is_LW || is_LB;
    is_store        = is_SW || is_SB;
    is_none         = !(is_load || is_store);
    is_byte         = is_LB || is_LBU || is_SB;
    is_half         = is_LH || is_LHU;
    is_word         = !(is_byte || is_half);
    unique case(1'b1)
      is_load : id_o_memop.ls_type  = MEM_LOAD;
      is_store : id_o_memop.ls_type = MEM_STORE;
      is_none : id_o_memop.ls_type  = MEM_NONE;
    endcase
    unique case(1'b1)
      is_word : id_o_memop.ls_width = MEM_WORD;
      is_half : id_o_memop.ls_width = MEM_HALF;
      is_byte : id_o_memop.ls_width = MEM_BYTE;
    endcase
    id_o_memop.sign = 1'b1;
    id_o_dm2rf      = is_load;
    id_o_dmdin      = rfrd2;
  end

endmodule

