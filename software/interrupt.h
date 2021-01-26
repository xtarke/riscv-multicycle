#ifndef __INTERRUPT_H
#define __INTERRUPT_H


typedef int bool;
#define true 1
#define false 0

void global_interrupt_enable(bool val);
void extern_interrupt_enable(bool val);
void timer_interrupt_enable(bool val);


#endif