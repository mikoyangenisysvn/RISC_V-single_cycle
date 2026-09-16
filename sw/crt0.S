section .text.init, "ax", @progbits
.align 2

.globl _start
.type _start, @function

/* 
* Minimal RV32I startup code for the Lab 6 single-cycle core.
* 
* Data memory covers byte addresses 0x00000000 through 0x000003ff.
* Initializing sp to 0x400 lets a downward-growing stack start at the
* first address below the top of that memory.
*/

_start:
addi sp, zero, 1024

/* main() returns its status in a0. */
call main

/* There is no operating system to receive main's return value. */
Lhalt:
j .Lhalt

.size _start, . - _start

.section .note.GNU-stack, "", @progbits
