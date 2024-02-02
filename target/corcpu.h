#ifndef CORPU_H
#define CORCPU_H

void ecall(void) {
	asm volatile ("ecall");
}

#endif
