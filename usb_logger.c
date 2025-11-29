#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/usb.h>

#define VENDOR_ID  0x0781
#define PRODUCT_ID 0x5575

static int usb_logger_probe(struct usb_interface *interface,
                            const struct usb_device_id *id)
{
    printk(KERN_INFO "usb_logger: USB inserted (VID=%04X PID=%04X)\n",
           id->idVendor, id->idProduct);
    kobject_uevent(&interface->dev.kobj, KOBJ_CHANGE);
    return 0;
}

static void usb_logger_disconnect(struct usb_interface *interface)
{
    printk(KERN_INFO "usb_logger: USB removed\n");
    kobject_uevent(&interface->dev.kobj, KOBJ_CHANGE);
}

static struct usb_device_id usb_table[] = {
    { USB_DEVICE(VENDOR_ID, PRODUCT_ID) },
    {}
};

MODULE_DEVICE_TABLE(usb, usb_table);

static struct usb_driver usb_logger_driver = {
    .name       = "usb_logger",
    .id_table   = usb_table,
    .probe      = usb_logger_probe,
    .disconnect = usb_logger_disconnect,
};

static int __init usb_logger_init(void)
{
    printk(KERN_INFO "usb_logger: loaded\n");
    return usb_register(&usb_logger_driver);
}

static void __exit usb_logger_exit(void)
{
    usb_deregister(&usb_logger_driver);
    printk(KERN_INFO "usb_logger: unloaded\n");
}

module_init(usb_logger_init);
module_exit(usb_logger_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Simple USB encryption trigger driver");
MODULE_AUTHOR("Student");
