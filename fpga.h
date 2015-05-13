#ifndef FPGA_H_
#define FPGA_H_

#define FPGA_BASE_ADDRESS  (0x00)

// end is 1 past the end, so we can use < comparison
#define DATA_START          (FPGA_BASE_ADDRESS + 0x00)
#define DATA_CONV_START     (DATA_START + 8)
#define DATA_CONV_END       (DATA_CONV_START + 32)
#define DATA_END            (DATA_START + 44)

#define FILTER_START        (DATA_END)
#define FILTER_END          (DATA_END + 8)

#define RESULT_LOC          (FPGA_BASE_ADDRESS + 56)
#define READY_MASK          (0x00000001)
#define MAXVAL_MASK         (0xffff0000)
#define MAXVAL_OFFSET       (16)
#define MAXPOS_MASK         (0x0000ff00)
#define MAXPOS_OFFSET       (8)

#define PLAZER_SIZE         (60)
#define PLAZER_SIZE_32      (15)

#endif
