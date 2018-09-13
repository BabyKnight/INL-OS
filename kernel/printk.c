/*
 * When in kernel-mode, we cannot use printf.
 */

static char buf[1024];

int printk(const char *fmt, ...)
{
	// TODO Implement with asm statement
}
