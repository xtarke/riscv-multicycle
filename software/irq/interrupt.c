#include "interrupt.h"

void global_interrupt_enable(bool val) {
	if(val){
  	__asm__(
	"  csrs 0x300, 0x00000008\n");}else
	{	  __asm__( 
	"  csrc 0x300, 0x00000008\n");}
}
void extern_interrupt_enable(bool val) {
	__asm__( 
	"	li t0,0x00000800 \n");
	if(val){
  	__asm__( 
	"	csrs 0x304,t0 \n");}else
	{	  __asm__( 
	"	csrc 0x304,t0 \n");}
}
void timer_interrupt_enable(bool val) {
	__asm__( 
	"	li t0,0x00000080 \n");
	if(val){
  	__asm__(
	"	csrs 0x304,t0 \n");}else
	{	  __asm__( 
	"	csrc 0x304,t0 \n");}
}
