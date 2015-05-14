/*
 * Userspace program
 * PLazeR
 * Columbia University
 */

#include <stdio.h>
#include "plazer.h"
#include <math.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

int plazer_fd;

int emulation_mode = 1;

plazer_mem_t emulation_buffer;

void print_buf(unsigned char * buf, size_t length) {
    int i;
    printf("\n---------------------------------------------\n");
    for (i = 0; i < length; ++i) {
        if (i % 8 == 0) {
            printf(" %02d: ", i);
        }

        printf("0x%02x ", buf[i]);

        if (i % 8 == 7) {
            printf("\n");
        }
    }
    if (i % 8 != 0) {
        printf("\n");
    }
    printf("---------------------------------------------\n");
}

void plazer_reset() {
    if (emulation_mode) {
        memset(&emulation_buffer, 0, sizeof(plazer_mem_t));
    } else {
        if (ioctl(plazer_fd, PLAZER_RESET, 0)) {
            perror("ioctl(PLAZER_RESET) failed");
            return;
        }
    }
}

void plazer_read_memory() {
    plazer_mem_t mem;

    if (emulation_mode) {
        memcpy(&mem, &emulation_buffer, sizeof(plazer_mem_t));
    } else {
        if (ioctl(plazer_fd, PLAZER_READ_MEMORY, &mem)) {
            perror("ioctl(PLAZER_READ_MEMORY) failed");
            return;
        }
    }

    printf("left fill:\n");
    print_buf(mem.data.left_fill, sizeof(mem.data.left_fill));

    printf("data:\n");
    print_buf(mem.data.data, sizeof(mem.data.data));

    printf("right fill:\n");
    print_buf(mem.data.right_fill, sizeof(mem.data.right_fill));

    printf("conv matrix:\n");
    print_buf(mem.conv.conv, sizeof(mem.conv.conv));

    printf("result:\n");
    printf("max: %d at position %d\n", mem.data.convmax, mem.data.maxpos);
}

void plazer_set_convolution(unsigned char * convdat) {
    plazer_conv_t conv;
    memcpy(conv.conv, convdat, sizeof(conv.conv));

    if (emulation_mode) {
        memcpy(&emulation_buffer.conv, &conv, sizeof(plazer_conv_t));
    } else {
        if (ioctl(plazer_fd, PLAZER_SET_CONV, &conv)) {
            perror("ioctl(PLAZER_SET_CONV) failed");
            return;
        }
    }
}

void plazer_conv_max(plazer_arg_t * arg) {
    int i, j;
    if (emulation_mode) {
        memcpy(&emulation_buffer.data, arg, sizeof(plazer_arg_t));

        arg->convmax = 0;
        arg->maxpos = 0;

        for (i = 0; i < (DATA_CONV_END - DATA_CONV_START); ++i) {
            unsigned int accum = 0;

            unsigned char * dptr = (unsigned char *) arg;

            for (j = 0; j < FILTER_END - FILTER_START; ++j) {
                unsigned int filter_val = emulation_buffer.conv.conv[j];
                accum += dptr[i + j] * filter_val;
                accum += dptr[i + (FILTER_END - FILTER_START) * 2 - j] * filter_val;
            }

            if (accum > arg->convmax) {
                arg->convmax = accum;
                arg->maxpos = i;
            }
        }
    } else {
        if (ioctl(plazer_fd, PLAZER_CONV_MAX, arg)) {
            perror("ioctl(PLAZER_CONV_MAX) failed");
        }
    }
    memcpy(&emulation_buffer.data, arg, sizeof(plazer_arg_t));
}

void generate_gaussian(float sigma, unsigned char * buffer, size_t buflen) {
    int i;
    double s2 = sigma * sigma;
    for (i = 0; i < buflen; ++i) {
        double x = buflen - i;
        double val = exp(-(x * x) / s2) / sqrt(2 * M_PI * s2);

        buffer[i] = val * 0xff;
    }
}

int main(int argc, char **argv) {
    if(argc != 2) {
	fprintf(stderr, "Usage: %s image-file\n", argv[0]);
	return 1;
    }

    static const char dev_filename[] = "/dev/plazer";
    unsigned char conv[8];
    plazer_arg_t arg;

    if ((plazer_fd = open(dev_filename, O_RDWR)) == -1) {
        fprintf(stderr, "could not open %s\n", dev_filename);
        emulation_mode = 1;
    }

    printf("plazer userspace program started\n");

    cv::Mat image = cv::imread(argv[1], CV_LOAD_IMAGE_GRAYSCALE);
    unsigned char raw[image.rows][image.cols];
    for(int i=0; i<image.rows; ++i)
	for(int j=0; j<image.cols; ++j)
	    raw[i][j] = image.at<uchar>(i, j);

    plazer_reset();
    plazer_read_memory();

    generate_gaussian(3, conv, sizeof(conv));

    printf("gaussian matrix:");
    print_buf(conv, sizeof(conv));

    plazer_set_convolution(conv);

    plazer_read_memory();

    memset(&arg, 0, sizeof(plazer_arg_t));

    size_t size_leftfill = sizeof(arg.left_fill);
    size_t size_data = sizeof(arg.data);
    size_t size_rightfill = sizeof(arg.right_fill);
    for(int i = 0; i < image.rows; ++i) {
	int row_convmax = -1;
	int row_maxpos = -1;
	for(int j = 0; j < image.cols; j += size_data) {
	    memcpy(arg.data, raw[i] + j, size_data);
	    
	    //left filler
	    if(j) {
		memcpy(arg.left_fill, raw[i] + j - size_leftfill, size_leftfill);
	    } else {
		memset(arg.left_fill, 0, size_leftfill);
	    }

	    //right filler
	    if(j + size_data < image.cols) {
		memcpy(arg.right_fill, raw[i] + j + size_data, size_rightfill);
	    } else {
		memset(arg.right_fill, 0, size_rightfill);
	    }

	    plazer_conv_max(&arg);

	    if(arg.convmax > row_convmax) {
		row_convmax = arg.convmax;
		row_maxpos = j + arg.maxpos;
	    }
	}
	printf("row = %d; maxpos = %d; convmax = %d\n", i, row_maxpos, row_convmax);
    }
    printf("plazer userspace program terminating\n");

    return 0;
}

