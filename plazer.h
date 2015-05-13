#ifndef _PLAZER_DRIVER_H
#define _PLAZER_DRIVER_H

#include <linux/ioctl.h>
#include "fpga.h"

#define VGA_LED_DIGITS 8

typedef struct {
    unsigned char   left_fill[DATA_CONV_START - DATA_START];
    unsigned char   data[DATA_CONV_END - DATA_CONV_START];
    unsigned char   right_fill[DATA_END - DATA_CONV_END];

    unsigned short  convmax;
    unsigned char   maxpos;
} plazer_arg_t;

typedef struct {
    unsigned char   conv[FILTER_END - FILTER_START];
} plazer_conv_t;

typedef struct {
    plazer_arg_t    data;
    plazer_conv_t   conv;
} plazer_mem_t;

#define PLAZER_MAGIC 'q'

/* ioctls and their arguments */
#define PLAZER_CONV_MAX     _IOWR(PLAZER_MAGIC, 1, plazer_arg_t *)
#define PLAZER_SET_CONV     _IOW (PLAZER_MAGIC, 2, plazer_conv_t *)
#define PLAZER_READ_MEMORY  _IOWR(PLAZER_MAGIC, 3, plazer_mem_t *)
#define PLAZER_RESET        _IOW (PLAZER_MAGIC, 4)

#endif
