#include <err.h>
#include <libusb.h>

#define die(...) err(1, __VA_ARGS__)

int main(void) {
	libusb_context* ctx = NULL;
	if(libusb_init_context(&ctx, NULL, 0) != 0) die("init ctx");

	libusb_device_handle* handle = libusb_open_device_with_vid_pid(ctx, 0x10f5, 0x7001);
	if(handle == NULL) die("failed to open device");

	if(libusb_set_auto_detach_kernel_driver(handle, true) != LIBUSB_SUCCESS) die("detach");

	if(libusb_claim_interface  (handle, 1) != 0) die("claim   iface 1");
	if(libusb_release_interface(handle, 1) != 0) die("release iface 1");

	return 0;
}
