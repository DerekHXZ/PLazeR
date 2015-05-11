module process_device(
    input logic                 reset,
    input logic                 clk,
    input logic                 write,
    input logic                 read,
    input logic [7:0]           address,
    input logic [127:0]         byteenable,
    input logic [1023:0]        writedata,
    output logic [1023:0]       readdata,
    output logic                waitrequest
);

// writedata layout
// address = 0x00
// byteenable = 111111111...
// [image data ][gaussian ]
// [120 x 8 bit][8 x 8 bit]
// [0.......959][960..1023]
// note that this is only the left half of the gaussian, since
// the gaussian kernel is symmetric about 0

// readdata layout
// address = 0x01
// byteenable = 111000000...
// [1 x 16 bit][1 x 8 bit]
// [0.......15][16.....23]

logic [15:0]    maxval;
logic [7:0]     maxpos;
logic           ready;

convmax cm1(.clk        (clk),
            .indata     (writedata[959:0]),
            .gauss      (writedata[1023:960]),
            .maxval     (maxval),
            .maxpos     (maxpos),
            .ready      (ready)
            );

assign readdata[15:0] = maxval;
assign readdata[23:16] = maxpos;

endmodule
