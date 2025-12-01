#include <linux/usb.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Stephen Sekula Noah Baker");
MODULE_DESCRIPTION("USB detection logger");

static int usb_notify(struct notifier_block *self, unsigned long action, void *dev)
{
    struct usb_device *udev = dev;

    switch (action) {
    case USB_DEVICE_ADD:
        printk(KERN_INFO "usb_logger: USB device connected\n");
        printk(KERN_INFO "usb_logger: vendor=%04x product=%04x\n",
               udev->descriptor.idVendor,
               udev->descriptor.idProduct);
        break;

    case USB_DEVICE_REMOVE:
        printk(KERN_INFO "usb_logger: USB device removed\n");
        break;

    default:
        break;
    }

    return NOTIFY_OK;
}

static struct notifier_block usb_nb = {
    .notifier_call = usb_notify,
};

static int __init usb_logger_init(void)
{
    printk(KERN_INFO "usb_logger: loaded\n");

    usb_register_notify(&usb_nb);
    printk(KERN_INFO "usb_logger: notifier registered\n");

    return 0;
}

static void __exit usb_logger_exit(void)
{
    usb_unregister_notify(&usb_nb);
    printk(KERN_INFO "usb_logger: unloaded\n");
}

module_init(usb_logger_init);
module_exit(usb_logger_exit);
