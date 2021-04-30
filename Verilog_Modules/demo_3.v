`include "processor.v"

module tb;

    parameter nInst = 5;

    reg clk;
    integer i, j;

    // Wires to hold the instructions and the delays
    wire [319:0] instructions [nInst-1:0];
    wire [31:0] index [nInst-1:0];

	assign instructions[0] = {32'b00000_00010_00001_00011_000000000000, 32'b00100_01000_10011_01111_01010_0000000, 32'b00101_00111_00101_01010_000000000000, 32'b0, 32'b0, 32'b0, 32'b10011_0000000000110111000100_10110, 32'b0};
	assign instructions[1] = {32'b00010_00100_0000001011010100010100_00110_0, 32'b0, 32'b0, 32'b0, 32'b01011_10100_00110_00111_000000000000, 32'b0, 32'b0, 32'b10100_01000_0000000000001000001100};
	assign instructions[2] = {32'b00000_10111_00010_11000_000000000000, 32'b0, 32'b0, 32'b0, 32'b0, 32'b10010_00100_1000001_000000000000000, 32'b0, 32'b0};
	assign instructions[3] = {32'b00000_00010_00010_0000000000000111010000_0, 32'b0, 32'b0, 32'b01001_10101_00100_00101_000000000000, 32'b0, 32'b0, 32'b0, 32'b0};
	assign instructions[4] = {32'b00000_0000000001000100000100_00001_00100_0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0};


	assign index[0] = 0;
	assign index[1] = 26;
	assign index[2] = 34;
	assign index[3] = 42;
	assign index[4] = 50;


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
        #150 $finish; 
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

