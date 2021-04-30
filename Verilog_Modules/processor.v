`include "include.v"

module processor (input clk);

    // Required parameters for the processor
    parameter instMemSize = 1024;
    parameter instSize = 256;
    
    // Insitantiation of the register file and memory nlock
    RegisterFile rf ();
    memory mem();

    // Instruction memory for the processor
    reg [instSize-1:0] inst [instMemSize-1:0];

    // Task to initialize the program counter
    task initPC;
        pc = 32'b0;
    endtask

    // Task to initialize the instruction register
    task initInst;
        integer i;
        for (i = 0; i < instMemSize; i = i + 1) begin : intiialize_instructions
            inst[i] = {instSize{1'b0}};
        end
    endtask

    // Task to write the given instruction packet to instruction register
    task writeInst(input [instSize:0] packet, input [31:0] index);
        inst[index] = packet;
    endtask
    
    /*--------------------------------------------------------------------------------------------
    Reg Declarations for IF
    --------------------------------------------------------------------------------------------*/
    reg [31:0] pc;
    reg [0:7][31:0] currentInst;

    /*--------------------------------------------------------------------------------------------
    Reg Declarations for ID
    --------------------------------------------------------------------------------------------*/
    reg [31:0] add_inst;
    reg [4:0] add_out;
    wire [4:0] add_out_d;

    reg [31:0] mul_inst;
    reg [4:0] mul_out1, mul_out2;
    wire [4:0]  mul_out1_d, mul_out2_d;
    
    reg [31:0] fadd_inst;
    reg [4:0] fadd_out;
    wire [4:0] fadd_out_d;
    
    reg [31:0] fmul_inst;
    reg [4:0] fmul_out;
    wire [4:0] fmul_out_d;
    
    reg [31:0] logic_inst;
    reg [4:0] logic_out;
    wire [4:0] logic_out_d;
        
    reg [31:0] ldr_inst;
    
    reg [31:0] str_inst, str_data;
    
    reg [31:0] mov_inst;

    reg [7:0][4:0] op;
    reg [5:0][4:0] out;
    reg [9:0][31:0] operandData;
    reg [2:0][53:0] memoryData;

    /*--------------------------------------------------------------------------------------------
    Reg Declarations for MEM
    --------------------------------------------------------------------------------------------*/
    reg [31:0] data0;

    /*============================================================================================
    Module instantiation for Add instruction
    ============================================================================================*/
    reg [31:0] a0, b0;
    reg cin;
    wire [31:0] out0;
    wire cout;
    CLA add0 (clk, out0, cout, a0, b0, cin);
    delay #(4, 5) delayAdd0 (clk, add_out, add_out_d);

    /*============================================================================================
    Module instantiation for Mul instruction
    ============================================================================================*/
    reg [31:0] a1, b1;
    wire [63:0] out1;
    WallaceMul mul (clk, a1, b1, out1);
    delay #(13, 5) delayMul1 (clk, mul_out1, mul_out1_d);
    delay #(13, 5) delayMul2 (clk, mul_out2, mul_out2_d);

    /*============================================================================================
    Module instantiation for Fadd instruction
    ============================================================================================*/
    reg [31:0] a2, b2;
    wire [31:0] out2;
    FPAdder fadd0 (clk, a2, b2, out2); 
    delay #(3, 5) delayFadd0(clk, fadd_out, fadd_out_d);

    /*============================================================================================
    Module instantiation for Fmul instruction
    ============================================================================================*/
    reg [31:0] a3, b3;
    wire [31:0] out3;
    FPMul fmul (clk, a3, b3, out3); 
    delay #(13, 5) delayFmul (clk, fmul_out, fmul_out_d);

    /*============================================================================================
    Module instantiation for Logic instruction
    ============================================================================================*/
    reg [31:0] a4, b4;
    wire [31:0] out4;
    reg [4:0] sel;
    logicUnit #(32) lu (a4, b4, sel, out4);

    /*============================================================================================
    Module instantiation for DFF OP Codes
    ============================================================================================*/
    wire [7:0][4:0] op_d, op_d_d;
    dff #(40) dff_op1 (op, clk, 1'b1, op_d);
    dff #(40) dff_op2 (op_d, clk, 1'b1, op_d_d);

    /*============================================================================================
    Module instantiation for DFF Operand data
    ============================================================================================*/
    wire [9:0][31:0] operandData_d;
    dff #(10*32) dff_opData (operandData, clk, 1'b1, operandData_d);

    /*============================================================================================
    Module instantiation for DFF Memory data
    ============================================================================================*/
    wire [2:0][53:0]memoryData_d;
    delay #(2, 54*3) delay_mem (clk, memoryData, memoryData_d);

    /*============================================================================================
    Output Pipeline 
    ============================================================================================*/
    wire [5:0][4:0] out_d;
    dff #(6*5) dff_out (out, clk, 1'b1, out_d);

    /*============================================================================================
    Processor Pipeline
    ============================================================================================*/
    
    always @(posedge clk) begin

        /*========================================================================================
        Instruction Fetch (IF)
        ========================================================================================*/
        
        rf.registerFile[31] = pc;
        currentInst = inst[pc];
        pc = pc + 1'b1;

    end

    always @(clk) begin

        /*========================================================================================
        Instruction Decode (ID)
        ========================================================================================*/
        
        // ADD ID

        add_inst = currentInst[0];
        op[0] = add_inst[31:27];
        out[0] = add_inst[26:22];
        rf.readReg(add_inst[21:17], operandData[0]);
        rf.readReg(add_inst[16:12], operandData[1]);
        
        // MUL ID
        
        mul_inst = currentInst[1];
        op[1] = mul_inst[31:27];
        out[1] = mul_inst[26:22];
        out[2] = mul_inst[21:17];
        rf.readReg(mul_inst[16:12], operandData[2]);
        rf.readReg(mul_inst[11:7], operandData[3]);
        
        // FADD ID
        
        fadd_inst = currentInst[2];
        op[2] = fadd_inst[31:27];
        out[3] = fadd_inst[26:22];
        rf.readReg(fadd_inst[21:17], operandData[4]);
        rf.readReg(fadd_inst[16:12], operandData[5]);
        
        // FMUL ID
        
        fmul_inst = currentInst[3];
        op[3] = fmul_inst[31:27];
        out[4] = fmul_inst[26:22];
        rf.readReg(fmul_inst[21:17], operandData[6]);
        rf.readReg(fmul_inst[16:12], operandData[7]);
        
        // LOGIC ID
        
        logic_inst = currentInst[4];
        op[4] = logic_inst[31:27];
        out[5] = logic_inst[26:22];
        rf.readReg(logic_inst[21:17], operandData[8]);
        rf.readReg(logic_inst[16:12], operandData[9]);
        
        // LOAD ID
        
        ldr_inst = currentInst[5];
        op[5] = ldr_inst[31:27];
        // dest, data
        memoryData[0] = {ldr_inst[26:22], ldr_inst[21:0]};
        
        // STORE ID
        
        str_inst = currentInst[6];
        op[6] = str_inst[31:27];
        rf.readReg(str_inst[4:0], str_data);
        // src, data
        memoryData[1] = {str_inst[26:5], str_data};
        
        // MOV ID
        
        mov_inst = currentInst[7];
        op[7] = mov_inst[31:27];
        // dest, data
        memoryData[2] = {mov_inst[26:22], mov_inst[21:0]};
        
    end
        
    always @(clk) begin
        
        /*========================================================================================
        Execute (EX)
        ========================================================================================*/
        
        // ADD EX

        a0 = operandData_d[0];
        if (op_d[0][1] == 1'b1)
            b0 = ~operandData_d[1] + 1;
        else
            b0 = operandData_d[1];
        if (op_d[0][0] == 1'b1)
            cin = 1'b1;
        else
            cin = 1'b0;
        add_out = out_d[0];

        // MUL EX
        
        a1 = operandData_d[2];
        b1 = operandData_d[3];
        mul_out1 = out_d[1];
        mul_out2 = out_d[2];
        
        // FADD EX
        
        a2 = operandData_d[4];
        b2 = operandData_d[5];
        fadd_out = out_d[3];

        // FMUL EX

        a3 = operandData_d[6];
        b3 = operandData_d[7];
        fmul_out = out_d[4];
        
        // LOGIC EX
        
        a4 = operandData_d[8];
        b4 = operandData_d[9];
        sel = op_d[4];
        logic_out = out_d[5];

    end

    always @(posedge clk ) begin
        
        /*========================================================================================
        Memory Access (MEM)
        ========================================================================================*/
        
        // LDR MEM

        mem.readMem(memoryData_d[0][21:0], data0);
        if (op_d_d[5] == 5'b10010)
            rf.writeReg(memoryData_d[0][26:22], data0);
        
        // STR MEM
        if (op_d_d[6] == 5'b10011)
            mem.writeMem(memoryData_d[1][53:32], memoryData_d[1][31:0]);
    
        // MOV MEM
        if (op_d_d[7] == 5'b10100)
            rf.writeReg(memoryData_d[2][26:22], memoryData_d[2][21:0]);

    end

    always @(posedge clk) begin
        /*========================================================================================
        Write Back (WB)
        ========================================================================================*/
        
        // ADD WB
        
        rf.writeReg(add_out_d, out0);
        
        // MUL WB
        
        rf.writeReg(mul_out1_d, out1[63:32]);
        rf.writeReg(mul_out2_d, out1[31:0]);

        // FADD WB

        rf.writeReg(fadd_out_d, out2);

        // FMUL WB
        
        rf.writeReg(fmul_out_d, out3);
        
        // LOGIC WB
        
        rf.writeReg(logic_out, out4);

        rf.registerFile[0] = 32'b0;
    end

endmodule
