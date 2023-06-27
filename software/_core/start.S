#include "csr_encoding.h"
#define LOG_REGBYTES 2
#define REGBYTES (1 << LOG_REGBYTES)

###############################################
###############################################
# Disable Interrupt
#
.macro DISABLE_MIE
	csrc CSR_MSTATUS, MSTATUS_MIE
.endm


###############################################
###############################################
# Save caller registers
.macro SAVE_CONTEXT
	addi sp, sp, -20*REGBYTES
	sw x1, 0*REGBYTES(sp)
	sw x4, 1*REGBYTES(sp)
	sw x5, 2*REGBYTES(sp)
	sw x6, 3*REGBYTES(sp)
	sw x7, 4*REGBYTES(sp)
	sw x10, 5*REGBYTES(sp)
	sw x11, 6*REGBYTES(sp)
	sw x12, 7*REGBYTES(sp)
	sw x13, 8*REGBYTES(sp)
	sw x14, 9*REGBYTES(sp)
	sw x15, 10*REGBYTES(sp)
	sw x16, 11*REGBYTES(sp)
	sw x17, 12*REGBYTES(sp)
	sw x28, 13*REGBYTES(sp)
	sw x29, 14*REGBYTES(sp)
	sw x30, 15*REGBYTES(sp)
	sw x31, 16*REGBYTES(sp)
.endm


###############################################
###############################################
# Restore caller registers
.macro RESTORE_CONTEXT
	lw x1, 0*REGBYTES(sp)
	lw x4, 1*REGBYTES(sp)
	lw x5, 2*REGBYTES(sp)
	lw x6, 3*REGBYTES(sp)
	lw x7, 4*REGBYTES(sp)
	lw x10, 5*REGBYTES(sp)
	lw x11, 6*REGBYTES(sp)
	lw x12, 7*REGBYTES(sp)
	lw x13, 8*REGBYTES(sp)
	lw x14, 9*REGBYTES(sp)
	lw x15, 10*REGBYTES(sp)
	lw x16, 11*REGBYTES(sp)
	lw x17, 12*REGBYTES(sp)
	lw x28, 13*REGBYTES(sp)
	lw x29, 14*REGBYTES(sp)
	lw x30, 15*REGBYTES(sp)
	# De-allocate the stack space
	addi sp, sp, 20*REGBYTES
.endm

###############################################
###############################################
# Restore caller registers
.macro RESTORE_CONTEXT_EXCPT_X5
	lw x1,  0*REGBYTES(sp)
	lw x6,  2*REGBYTES(sp)
	lw x7,  3*REGBYTES(sp)
	lw x10, 4*REGBYTES(sp)
	lw x11, 5*REGBYTES(sp)
	lw x12, 6*REGBYTES(sp)
	lw x13, 7*REGBYTES(sp)
	lw x14, 8*REGBYTES(sp)
	lw x15, 9*REGBYTES(sp)
	lw x16, 10*REGBYTES(sp)
	lw x17, 11*REGBYTES(sp)
	lw x28, 12*REGBYTES(sp)
	lw x29, 13*REGBYTES(sp)
	lw x30, 14*REGBYTES(sp)
	lw x31, 15*REGBYTES(sp)
.endm

###############################################
###############################################
# Restore caller registers
.macro RESTORE_CONTEXT_ONLY_X5
	lw x5,  1*REGBYTES(sp)
.endm

###############################################
###############################################
# Save the mepc and mstatus
.macro SAVE_EPC_STATUS
	csrr x5, CSR_MEPC
	sw x5,  16*REGBYTES(sp)
	csrr x5, CSR_MSTATUS
	sw x5,  17*REGBYTES(sp)
	csrr x5, CSR_MSUBM
	sw x5,  18*REGBYTES(sp)
.endm

###############################################
###############################################
# Restore the mepc and mstatus
.macro RESTORE_EPC_STATUS
	lw x5,  16*REGBYTES(sp)
	csrw CSR_MEPC, x5
	lw x5,  17*REGBYTES(sp)
	csrw CSR_MSTATUS, x5
	lw x5,  18*REGBYTES(sp)
	csrw CSR_MSUBM, x5
.endm

###############################################
###############################################
# Trap entry point
.section      .text.trap
.align 2
.global trap_entry
.weak trap_entry
trap_entry:
	# Allocate the stack space
	# addi sp, sp, -19*REGBYTES
	# Save the caller saving registers (context)
	SAVE_CONTEXT
	# Save the MEPC/Mstatus/Msubm reg
	SAVE_EPC_STATUS
	# Set the function argument
	csrr a0, mcause
	mv a1, sp
	# Call the function
	# Call handle_trap
	# Restore the MEPC/Mstatus/Msubm reg
	RESTORE_EPC_STATUS
	# Restore the caller saving registers (context)
	RESTORE_CONTEXT
	# De-allocate the stack space
	# addi sp, sp, 19*REGBYTES
	# Return to regular code
	mret


###############################################
###############################################
# IRQ entry point
.section      .text.irq
.align 2
.global irq_entry
.weak irq_entry
	irq_entry: # -------------> This label will be set to MTVT2 register
	#  Allocate the stack space
	SAVE_CONTEXT # Save 16 regs

	csrr	a2,CSR_MCAUSE # Machine trap cause.
	csrr	a4,CSR_MTVT   # Machine irq-handler base address

	slli a2,a2,0x2
	add a4,a4,a2
	lw a4,0(a4)
	jalr x1,0(a4)

	# RESTORE_CONTEXT_EXCPT_X5

	#---- Critical section with interrupts disabled -----------------------
	# DISABLE_MIE # Disable interrupts

	RESTORE_CONTEXT

	# Return to regular code
	mret

###############################################
###############################################
# Vector table
.section .init
.weak  EXTI0_IRQHandler
.weak  EXTI1_IRQHandler
.weak  EXTI2_IRQHandler
.weak  EXTI3_IRQHandler
.weak  EXTI4_IRQHandler
.weak  EXTI5_9_IRQHandler
.weak  EXTI10_15_IRQHandler
.weak  TIMER0_0A_IRQHandler
.weak  TIMER0_0B_IRQHandler
.weak  TIMER0_1A_IRQHandler
.weak  TIMER0_1B_IRQHandler
.weak  TIMER0_2A_IRQHandler
.weak  TIMER0_2B_IRQHandler
.weak  UART_IRQHandler
# TODO: Add more IRQ Handlers
#    .weak  SPI0_IRQHandler
#    .weak  I2C0_IRQHandler
.weak  ADC0_IRQHandler

vector_base:
	j _start
	.align    2
	.word     0
	.word     0
	.word     0
	.word     0
	.word     0
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word 	  0
	.word  	  0
	.word  	  0
	.word     ADC0_IRQHandler           # 17
	.word     EXTI0_IRQHandler          # 18
	.word     EXTI1_IRQHandler          # 19
	.word     EXTI2_IRQHandler          # 20
	.word     EXTI3_IRQHandler          # 21
	.word     EXTI4_IRQHandler          # 22
	.word     EXTI5_9_IRQHandler        # 23
	.word     EXTI10_15_IRQHandler      # 24
	.word     TIMER0_0A_IRQHandler      # 25
	.word     TIMER0_0B_IRQHandler      # 26
	.word     TIMER0_1A_IRQHandler      # 27
	.word     TIMER0_1B_IRQHandler      # 28
	.word     TIMER0_2A_IRQHandler      # 29
	.word     TIMER0_2B_IRQHandler      # 30
	.word     UART_IRQHandler           # 31
					    # TODO: Add more IRQ Handlers
					    #    .word     UART0_IRQHandler          // 32
					    #    .word     SPI0_IRQHandler           // 33
					    #    .word     I2C0_IRQHandler           // 34

					    # ...

###############################################
###############################################
# Reset vector
.section .text
.global _start
.global _start
.global _pvstart
.global init_data_section

_pvstart:
	# Debug: zero-initialize all registers */
	# addi x1, zero, 0
	# addi x2, zero, 0
	# addi x3, zero, 0
	# addi x4, zero, 0
	# addi x5, zero, 0
	# addi x6, zero, 0
	# addi x7, zero, 0
	# addi x8, zero, 0
	# addi x9, zero, 0
	# addi x10, zero, 0
	# addi x11, zero, 0
	# addi x12, zero, 0
	# addi x13, zero, 0
	# addi x14, zero, 0
	# addi x15, zero, 0
	# addi x16, zero, 0
	# addi x17, zero, 0
	# addi x18, zero, 0
	# addi x19, zero, 0
	# addi x20, zero, 0
	# addi x21, zero, 0
	# addi x22, zero, 0
	# addi x23, zero, 0
	# addi x24, zero, 0
	# addi x25, zero, 0
	# addi x26, zero, 0
	# addi x27, zero, 0
	# addi x28, zero, 0
	# addi x29, zero, 0
	# addi x30, zero, 0
	# addi x31, zero, 0 

	# Disable Interrupts 
	csrc 0x300, 0x00000008

	#  Intial the mtvt 
	la t0, vector_base
	csrw CSR_MTVT, t0

	# Intial the mtvt2 and enable it 
	la t0, irq_entry
	csrw CSR_MTVT2, t0
	csrs CSR_MTVT2, 0x1

	# Intial the CSR MTVEC for the Trap ane NMI base addr 
	la t0, trap_entry
	csrw CSR_MTVEC, t0

	#  set stack pointer: ram(rwx) : ORIGIN = 0x0002000000, LENGTH = 2k = 0x2000800  = 33556480 
	lui sp, %hi(33556480)
	addi sp, sp,%lo(33556480)

	# Set Global pointer: RAM init @  ORIGIN = 0x0002000000 
	lui gp, %hi(33554432)
	addi gp, gp, %lo(33554432)

	# lui	a5,0x2000
	# li	a4,0x123456F8
	# sw a4, 0(a5)
	# sb a4, 4(a5)
	# sh a4, 6(a5)
	# lhu	a6,0(a5)
	# lh	a7,2(a5)
	# 
	# lb s2, 0(a5)
	# lb s3, 1(a5)
	# lb s4, 2(a5)
	# lb s5, 3(a5) 

	/* jal init_data_section */

	/* push zeros on the stack for argc and argv */
	/* (stack is aligned to 16 bytes in riscv calling convention) */
	addi sp,sp,-16
	sw zero,0(sp)
	sw zero,4(sp)
	sw zero,8(sp)
	sw zero,12(sp)

	/* j _start */
	jal main
	ebreak
