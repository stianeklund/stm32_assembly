@ Blinky for the STM32F429-i Discovery board
@ References used:
@ https://sites.google.com/site/johnkneenmicrocontrollers/input_output/stm32f429_io
@ Written by Stian Eklund, github.com/stianeklund

.thumb
.syntax unified

@ Equates
    .equ STACKINIT, 0x20005000

@ Peripheral definitions
    .equ PERIPH_BASE, 0x40000000
    .equ PERIPHBASE_AHB1, PERIPH_BASE + 0x20000
    .equ GPIOG_BASE, PERIPHBASE_AHB1 + 0x1800

@ Register definitions
    .equ RCC_BASE, PERIPHBASE_AHB1 + 0x3800
    .equ RCC_AHB1ENR, RCC_BASE + 0x30     @ Clock control for AHB1 peripherals

@ GPIO-G Control registers
    .equ GPIOG_MODER,   GPIOG_BASE + 0x00 @ GPIO Mode Register
    .equ GPIOG_OTYPER,  GPIOG_BASE + 0x04 @ GPIO Output type register
    .equ GPIOG_OSPEEDR, GPIOG_BASE + 0x08 @ GPIO pin switching speed
    .equ GPIOG_PUPDR,   GPIOG_BASE + 0x0c @ Pull up / pull down configuration
    .equ GPIOG_ODR,     GPIOG_BASE + 0x14 @ Output register
    .equ LEDDELAY, 0x80000

    .section .text
    .org 0

@ Vectors
_vectors:
    .word STACKINIT
    .word _start + 1
    .word _nmi_handler + 1
    .word _hard_fault + 1
    .word _memory_fault + 1
    .word _bus_fault + 1
    .word _usage_fault + 1

_start:
    @ Enable GPIOG Perpherial Clock (Bit 6)
    ldr r1, =RCC_AHB1ENR  @ Load address into R1.
    ldr r0, [r1]          @ Load r0 with value at address
    orr r0, #(1<<6)       @ GPIOGEN (bit 6)
    str r0, [r1]          @ Store the result in perph clock reg

    @ Set GPIO Port G register mode to output (01)
    ldr r1, =GPIOG_MODER
    ldr r0, [r1]
    orr.w r0, (1 << (13 * 2)); @ Set pin13 as output
    orr.w r0, (1 << (14 * 2)); @ set pin14 as output
    and.w r0, #0xffffffff @ clear bits
    str r0, [r1]

    @ Set GPIOG Mode to Push pull
    ldr r1, =GPIOG_OTYPER
    ldr r0, [r1]
    and.w r0, #0xfff0fff @ Clear bits 12 through 15
    str r0,  [r1]

    @ Set GPIOG output switching speed
    ldr r1, =GPIOG_OSPEEDR
    ldr r0, [r1]
    and.w r0, #0x00ffffff @ Clear bits 31..24
    str r0, [r1]

    @ Disable pull-up / pull-down for pins 15..12
    ldr r1, =GPIOG_PUPDR
    ldr r0,  [r1]
    and.w r0, #0x00ffffff
    str r0, [r1]

    @ Turn on PG14 (Red LED)
    @ ldr r1, =GPIOG_ODR     @ Load GPIOG output data register
    @ldr r0, [r1]            @ Read value at address to r0
    @ orr.w r0, (1<<14)      @ Set pin 14 to high
    @ str r0, [r1]
    @ ldr r2, =LEDDELAY

    @ Turn on PG13 (Green LED)
    @ ldr r1, =GPIOG_ODR     @ Load GPIOG output data register
    @ ldr r0, [r1]           @ Read value at address to r0
    @ orr.w r0, (1<<13)      @ Set pin 13 to high
    @ str r0, [r1]
    @ ldr r2, =LEDDELAY

    @ Turn off PG14 (Red LED)
    @ ldr r1, =GPIOG_ODR
    @ ldr r0,  [r1]
    @ and.w r0, (1<<14)
    @ str r0, [r1]
    @ ldr r2, =LEDDELAY

    @ Turn off PG13 (Red LED)
    @ ldr r1, =GPIOG_ODR
    @ ldr r0,  [r1]
    @ and.w r0, (1<<13)
    @ str r0, [r1]
    @ ldr r2, =LEDDELAY

blink:
    ldr r2, =LEDDELAY
    bl ledsON
    bl delay
    bl ledsOFF
    bl delay
    b blink
delay:
    ldr r2, =LEDDELAY
    1: subs r2, r2, #1     @ using the cbz instruction here instad is too fast
    bne 1b                 @ loop if not 0
    bx lr
ledsON:
    ldr r1, =GPIOG_ODR
    ldr r0, [r1]
    orr.w r0, #0x6000
    str r0, [r1]
    ldr r2, =LEDDELAY
    bx lr
ledsOFF:
    ldr r1, =GPIOG_ODR
    ldr r0, [r1]
    and.w r0, #0x0000
    str r0, [r1]
    ldr r2, =LEDDELAY
    bx lr

@ Ignore interrupts
 _dummy:
 _nmi_handler:
 _hard_fault:
 _memory_fault:
 _bus_fault:
_usage_fault:
        nop


