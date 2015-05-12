module process_device(
    input logic                 reset,
    input logic                 clk,
    input logic                 write,
    input logic                 read,
    input logic [10:0]          address,
    input logic [3:0]           byteenable,
    input logic [31:0]          writedata,
    output logic [31:0]         readdata,
    output logic                waitrequest
);

// memory layout
// address = 0x00
// byteenable = 1111
// [image data ][gaussian ]
// [144 x 8 bit][8 x 8 bit  ]
// [0......1151][1152...1216]
// note that this is only the left half of the gaussian, since
// the gaussian kernel is symmetric about 0

// readdata layout
// address = 0x00
// byteenable = 1110
// [1 x 16 bit][1 x 8 bit]
// [0.......15][16.....23]

logic [15:0]        maxval;
logic [7:0]         maxpos;
logic               ready;
logic [151:0][7:0] memory;

convmax cm1(.clk        (clk),
            .indata     (memory[143:0]),
            .gauss      (memory[151:144]),
            .maxval     (maxval),
            .maxpos     (maxpos),
            .ready      (ready)
            );


always_ff @(posedge clk)
begin
	if (reset) memory <= 0;
	if (write) begin
		if (byteenable[0]) memory[address] <= writedata[7:0];
		if (byteenable[1]) memory[address+1] <= writedata[15:8];
		if (byteenable[2]) memory[address+2] <= writedata[23:16];
		if (byteenable[3]) memory[address+3] <= writedata[31:24];
	end
end

assign waitrequest = ~ready;
assign readdata[15:0] = maxval;
assign readdata[23:16] = maxpos;

endmodule
