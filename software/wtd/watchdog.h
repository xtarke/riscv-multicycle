/* 
 * Instituto Federal de Santa Catarina - Câmpus Florianópolis
 * Departamento Acadêmico de Eletrônica
 * Curso de Engenharia Eletrônica
 * Unidade Curricular: Dispositivos Lógico-Programáveis (PLD)
 * Professor: 
 * -	Renan Augusto Starke	- renan.starke@ifsc.edu.br
 * Estudantes: 
 * -	Heloiza Schaberle 		- heloizaschaberle@gmail.com
 * -	Vítor Faccio 			- vitorfaccio.ifsc@gmail.com
 * 
 * watchdog.h
 * 
 */ 

#ifndef __WATCHDOG_H
#define __WATCHDOG_H

#include <stdint.h>
#include "../_core/hardware.h"

typedef struct {
	
	/*
	In:
	signal wtd_reset 			: std_logic;
	signal wtd_mode  			: unsigned(1 downto 0);
	signal prescaler   			: unsigned(prescaler_size - 1 downto 0);
	signal top_counter 			: unsigned(prescaler_size - 1 downto 0);
	signal wtd_clear			: std_logic;
	signal wtd_hold				: std_logic;
	signal wtd_interrupt_clr	: std_logic;
	
	Out:
	signal wtd_interrupt		: std_logic;
	signal wtd_out				: std_logic;
	signal wtd_notcnt			: std_logic;
	 */
	 
	 // In:
	_IO32 wtd_reset;      		// 0x00 + TIMER_BASE_ADDRESS
    _IO32 wtd_mode;       		// 0x04 ...    ....
    _IO32 prescaler;        	// 0x08
    _IO32 top_counter;      	// 0x0C
    _IO32 wtd_clear;      		// 0x10
    _IO32 wtd_hold;      		// 0x14
    _IO32 wtd_interrupt_clr;	// 0x18
    
    
	// Out:
	_IO32 wtd_interrupt : 1;    // 0x1C, bit 4
    _IO32           	: 31;
	
} WTD_TYPE;

#define WTD ((WTD_TYPE *) &WTD_BASE_ADDRESS)

void wtd_config(uint32_t wtd_mode, uint32_t prescaler, uint32_t top_counter);
void wtd_enable(void);
void wtd_disable(void);
void wtd_hold(uint32_t hold);
uint32_t wtd_interrupt_read(void);
void wtd_clearoutputs(void);



#endif		//WATCHDOG_H