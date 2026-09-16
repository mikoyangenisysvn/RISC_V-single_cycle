OUTPUT_ARCH(riscv)
ENTRY(_start)

/*
 * The RTL uses separate 1 KiB instruction and data memories.
 *
 * IMEM is addressed by PC[31:2], so executable code must stay below 0x400.
 * DMEM uses addr[9:2] and therefore repeats every 0x400 bytes. Giving data
 * a VMA of 0x400 maps its first word to DMEM word 0 while keeping ELF code
 * and data sections at non-overlapping virtual addresses.
 *
 * crt0.S initializes sp to 0x400. The stack grows downward into the upper
 * DMEM words while .data/.bss grow upward from DMEM word 0.
 */
MEMORY
{
    IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 0x400
    DMEM (rw) : ORIGIN = 0x00000400, LENGTH = 0x400
}

SECTIONS
{
    .text : ALIGN(4)
    {
        KEEP(*(.text.init))
        *(.text .text.*)
    } > IMEM

    . = ALIGN(4);
    __text_end = .;

    .data : ALIGN(4)
    {
        data_start = .;
        *(.sdata .sdata.*)
        *(.data .data.*)
        *(.rodata .rodata.*)
        data_end = .;
    } > DMEM

    .bss (NOLOAD) : ALIGN(4)
    {
        bss_start = .;
        *(.sbs sbs sbs.*)
        *(.bss .bss.*)
        *(COMMON)
        bss_end = .;
    } > DMEM

    /* Kept for toolchain compatibility; this lab builds with small data off. */
    __global_pointer$ = ORIGIN(DMEM) + 0x200;
    __stack_top = ORIGIN(DMEM);

    /DISCARD/ :
    {
        *(.comment)
        *(.note*)
        *(.eh_frame*)
    }

    .riscv.attributes 0 :
    {
        *(.riscv.attributes)
    }
}

ASSERT(__text_end <= ORIGIN(IMEM) + LENGTH(IMEM),
    "ERROR: program does not fit in the 1 KiB instruction memory")

ASSERT(bss_end <= ORIGIN(DMEM) + 0x200,
    "ERROR: data uses the half of DMEM reserved for the stack")
