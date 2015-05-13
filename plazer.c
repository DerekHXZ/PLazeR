/*
 * Device driver for the plazer max-convolution accelerator
 *
 * A Platform device implemented using the misc subsystem
 *
 * Robert Ying, Xingzhou He, Peiqian Li, Minh Trang Nguyen
 * Columbia University
 *
 * References:
 * Linux source: Documentation/driver-model/platform.txt
 *               drivers/misc/arm-charlcd.c
 * http://www.linuxforu.com/tag/linux-device-drivers/
 * http://free-electrons.com/docs/
 *
 * "make" to build
 * insmod plazer.ko
 *
 * Check code style with
 * checkpatch.pl --file --no-tree plazer.c
 */

#include <linux/module.h>
#include <linux/init.h>
#include <linux/errno.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>
#include <linux/miscdevice.h>
#include <linux/slab.h>
#include <linux/io.h>
#include <linux/of.h>
#include <linux/of_address.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include "plazer.h"

#define DRIVER_NAME "plazer"

/*
 * Information about our device
 */
struct plazer_dev {
    struct resource res; /* Resource: our registers */
    void __iomem *virtbase; /* Where registers can be accessed in memory */
    u8 buffer[PLAZER_SIZE];
} dev;

static long plazer_conv_max(plazer_arg_t * user_arg_ptr) {
    plazer_arg_t arg;
    if (copy_from_user(&arg, user_arg_ptr, sizeof(plazer_arg_t))) {
        return -EACCES;
    }

    memcpy(dev.buffer + DATA_START, &arg, DATA_END - DATA_START);
    iowrite32_rep(dev.virtbase + DATA_START, dev.buffer + DATA_START, (DATA_END - DATA_START) / 4);

    dev.buffer[RESULT_LOC] = ioread32(dev.buffer + RESULT_LOC);

    arg.convmax = (dev.buffer[RESULT_LOC] & MAXVAL_MASK) >> MAXVAL_OFFSET;
    arg.maxpos = (dev.buffer[RESULT_LOC] & MAXPOS_MASK) >> MAXPOS_OFFSET;

    if (copy_to_user(user_arg_ptr, &arg, sizeof(plazer_arg_t))) {
        return -EACCES;
    }
    return 0;
}

static long plazer_set_convolution(plazer_conv_t * user_arg_ptr) {
    plazer_conv_t arg;
    if (copy_from_user(&arg, user_arg_ptr, sizeof(plazer_conv_t))) {
        return -EACCES;
    }

    memcpy(dev.buffer + FILTER_START, arg.conv, FILTER_END - FILTER_START);

    int i;
    printk(KERN_INFO "---\n");
    for (i = FILTER_START; i < FILTER_END; i++) {
        printk(KERN_INFO "%x\n", dev.buffer[i]);
    }
    printk(KERN_INFO "---\n");

    iowrite32_rep(dev.virtbase + FILTER_START, dev.buffer + FILTER_START, (FILTER_END - FILTER_START) / 4);

    return 0;
}

static long plazer_read_memory(plazer_mem_t *user_arg_ptr) {
    plazer_mem_t arg;

    if (copy_from_user(&arg, user_arg_ptr, sizeof(plazer_mem_t))) {
        return -EACCES;
    }

    ioread32_rep(dev.virtbase, dev.buffer, PLAZER_SIZE_32);

    memcpy(arg.data.left_fill, dev.buffer, DATA_CONV_START - DATA_START);
    memcpy(arg.data.data, dev.buffer + DATA_CONV_START, DATA_CONV_END - DATA_CONV_START);
    memcpy(arg.data.right_fill, dev.buffer + DATA_CONV_END, DATA_END - DATA_CONV_END);
    memcpy(arg.conv.conv, dev.buffer + FILTER_START, FILTER_END - FILTER_START);

    arg.data.convmax = (dev.buffer[RESULT_LOC] & MAXVAL_MASK) >> MAXVAL_OFFSET;
    arg.data.maxpos = (dev.buffer[RESULT_LOC] & MAXPOS_MASK) >> MAXPOS_OFFSET;

    int i;
    printk(KERN_INFO "---\n");
    for (i = FILTER_START; i < FILTER_END; i++) {
        printk(KERN_INFO "%x\n", dev.buffer[i]);
    }
    printk(KERN_INFO "---\n");

    if (copy_to_user(user_arg_ptr, &arg, sizeof(plazer_mem_t))) {
        return -EACCES;
    }
    return 0;
}

static long plazer_reset() {
    memset(dev.buffer, 0, PLAZER_SIZE);
    iowrite32_rep(dev.virtbase, dev.buffer, PLAZER_SIZE_32);
    ioread32_rep(dev.virtbase, dev.buffer, PLAZER_SIZE_32);
    return 0;
}

/*
 * Handle ioctl() calls from userspace:
 * Read or write the segments on single digits.
 * Note extensive error checking of arguments
 */
static long plazer_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
{
    switch (cmd) {
        case PLAZER_CONV_MAX:
            return plazer_conv_max(arg);
        case PLAZER_SET_CONV:
            return plazer_set_convolution(arg);
        case PLAZER_READ_MEMORY:
            return plazer_read_memory(arg);
        case PLAZER_RESET:
            return plazer_reset();
        default:
            return -EINVAL;
    }
    return 0;
}

static int plazer_open(struct inode *i, struct file *f) {
    return 0;
}

static int plazer_close(struct inode *i, struct file *f) {
    return 0;
}

/* The operations our device knows how to do */
static const struct file_operations plazer_fops = {
    .owner      = THIS_MODULE,
    .open       = plazer_open,
    .release    = plazer_close,
    .unlocked_ioctl = plazer_ioctl,
};

/* Information about our device for the "misc" framework -- like a char dev */
static struct miscdevice plazer_misc_device = {
    .minor      = MISC_DYNAMIC_MINOR,
    .name       = DRIVER_NAME,
    .fops       = &plazer_fops,
};

/*
 * Initialization code: get resources (registers) and display
 * a welcome message
 */
static int __init plazer_probe(struct platform_device *pdev)
{
    static unsigned char welcome_message[PLAZER_DIGITS] = {
        0x3E, 0x7D, 0x77, 0x08, 0x38, 0x79, 0x5E, 0x00};
    int i, ret;

    /* Register ourselves as a misc device: creates /dev/plazer */
    ret = misc_register(&plazer_misc_device);

    /* Get the address of our registers from the device tree */
    ret = of_address_to_resource(pdev->dev.of_node, 0, &dev.res);
    if (ret) {
        ret = -ENOENT;
        goto out_deregister;
    }

    /* Make sure we can use these registers */
    if (request_mem_region(dev.res.start, resource_size(&dev.res),
                   DRIVER_NAME) == NULL) {
        ret = -EBUSY;
        goto out_deregister;
    }

    /* Arrange access to our registers */
    dev.virtbase = of_iomap(pdev->dev.of_node, 0);
    if (dev.virtbase == NULL) {
        ret = -ENOMEM;
        goto out_release_mem_region;
    }
    
    /* Display a welcome message */
    // for (i = 0; i < PLAZER_DIGITS; i++)
    //    write_digit(i, welcome_message[i]);
    
    return 0;

out_release_mem_region:
    release_mem_region(dev.res.start, resource_size(&dev.res));
out_deregister:
    misc_deregister(&plazer_misc_device);
    return ret;
}

/* Clean-up code: release resources */
static int plazer_remove(struct platform_device *pdev)
{
    iounmap(dev.virtbase);
    release_mem_region(dev.res.start, resource_size(&dev.res));
    misc_deregister(&plazer_misc_device);
    return 0;
}

/* Which "compatible" string(s) to search for in the Device Tree */
#ifdef CONFIG_OF
static const struct of_device_id plazer_of_match[] = {
    { .compatible = "altr,plazer" },
    {},
};
MODULE_DEVICE_TABLE(of, plazer_of_match);
#endif

/* Information for registering ourselves as a "platform" driver */
static struct platform_driver plazer_driver = {
    .driver = {
        .name   = DRIVER_NAME,
        .owner  = THIS_MODULE,
        .of_match_table = of_match_ptr(plazer_of_match),
    },
    .remove = __exit_p(plazer_remove),
};

/* Called when the module is loaded: set things up */
static int __init plazer_init(void)
{
    pr_info(DRIVER_NAME ": init\n");
    return platform_driver_probe(&plazer_driver, plazer_probe);
}

/* Called when the module is unloaded: release resources */
static void __exit plazer_exit(void)
{
    platform_driver_unregister(&plazer_driver);
    pr_info(DRIVER_NAME ": exit\n");
}

module_init(plazer_init);
module_exit(plazer_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Robert Ying, Xingzhou He, Peiqian Li, Minh Trang Nguyen");
MODULE_DESCRIPTION("Convolution accelerator");
