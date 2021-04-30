`include "processor.v"

module tb;

    parameter nInst = 6;

    reg clk;
    integer i, j;

    // Wires to hold the instructions and the delays
    wire [319:0] instructions [nInst-1:0];
    wire [31:0] index [nInst-1:0];

	assign instructions[0] = {32'b00000_00010_00001_00011_000000000000, 32'b00100_01000_0000000000000001111101_01111_01010_0, 32'b00101_00111_0000000000000000111011_01010_0, 32'b0, 32'b0, 32'b0, 32'b10011_10110000110011000100101000_0000001111111101011111_0, 32'b10100_00011_10000110111100010010111011_0};
	assign instructions[1] = {32'b00010_00100_00010_00110_000000000000, 32'b0, 32'b0, 32'b0, 32'b01011_10100_00110_00111_000000000000, 32'b0, 32'b0, 32'b0};
	assign instructions[2] = {32'b00000_10111_00010_11000_000000000000, 32'b0, 32'b0, 32'b0, 32'b0, 32'b10010_00100_0000000000000000000000, 32'b0, 32'b0};
	assign instructions[3] = {32'b00000_00010_00010_01000_000000000000, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0};
	assign instructions[4] = {32'b00000_00101_00001_00100_000000000000, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b10011_00010_10110_00000000000000000, 32'b10100_01000_0000000000001000001100};
	assign instructions[5] = {32'b0, 32'b0, 32'b0, 32'b01001_10101_00100_00101_000000000000, 32'b0, 32'b0, 32'b0, 32'b0};


	assign index[0] = 0;
	assign index[1] = 8;
	assign index[2] = 16;
	assign index[3] = 26;
	assign index[4] = 34;
	assign index[5] = 42;


    processor proc (clk);

    always #1 clk = ~clk;

    initial begin
        clk = 1'b1;
        // Initialize the program counter, register files, memory blocks
        proc.initPC();
        proc.rf.initialize();
        proc.mem.initialize();
        proc.initInst();
        // Write the instructions to the processor
        for (j = 0; j < nInst; j = j + 1) begin
            proc.writeInst(instructions[j], index[j]);
        end
        #180 $finish; 
    end

    // Monitor the register files
    always @(clk) begin
        $display("{\n \"time\": ", $time, ",");
        for (i = 0; i < 32; i = i + 1)
            if (i == 31)
                $display("\"%d\": \"%d\"", i, proc.rf.registerFile[i]);
            else
                $display("\"%d\": \"%d\",", i, proc.rf.registerFile[i]);
        $display("}");
    end
    
endmodule

