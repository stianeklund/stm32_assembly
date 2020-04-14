# stm32_assembly
Blinky for the STM32F429 Discovery written in Assembly

To compile & run:
* arm-none-eabi-as -mcpu=cortex-m4 blinky.s -o blinky.o
* arm-none-eabi-ld -v -T stm32.ld -nostartfiles -o blinky.elf blinky.o
* gdb -q blinky.elf
* Use openOCD and connect to the discovery board and load the elf file

Alternatively you can use stlink to flash the binary to the board.
