int main(void) __attribute__ ((section ("entry")));

typedef void call(void);

int main() {
	int i = 0;
	i += 1;

	register call* ptr = (call*) 0x4070;
	asm volatile ("addi x4, x0, 1");
	asm volatile("ecall");
	ptr();
}
