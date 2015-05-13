#ifndef FPGA_H_
#define FPGA_H_

const static int FPGA_BASE_ADDRESS = 0x00;

// end is 1 past the end, so we can use < comparison
const static int DATA_START         = FPGA_BASE_ADDRESS + 0x00;
const static int DATA_CONV_START    = DATA_START + 8;
const static int DATA_CONV_END      = DATA_CONV_START + 32;
const static int DATA_END           = DATA_START + 44;

const static int FILTER_START       = DATA_END;
const static int FILTER_END         = DATA_END + 8;

const static int RESULT_LOC         = FPGA_BASE_ADDRESS + 56;
const static int READY_MASK         = 0x00000001;
const static int MAXVAL_MASK        = 0xffff0000;
const static int MAXVAL_OFFSET      = 16;
const static int MAXPOS_MASK        = 0x0000ff00;
const static int MAXPOS_OFFSET      = 8;

const static int PLAZER_SIZE        = 60;
const static int PLAZER_SIZE_32     = 15;

#endif
