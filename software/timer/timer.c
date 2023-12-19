#include "timer.h"

void timer_config(uint32_t mode, uint32_t prescaler, uint32_t top_counter) {
	TIMER_0->timer_mode = mode;
	TIMER_0->prescaler = prescaler;
	TIMER_0->top_counter = top_counter;
}
void timer_reset(void) {
	TIMER_0->timer_reset = 1;
	TIMER_0->timer_reset = 0;
}

void timer_set_compare0A(uint32_t comp_value) {
	TIMER_0->compare_0A = comp_value;
}
void timer_set_compare0B(uint32_t comp_value) {
	  TIMER_0->compare_0B = comp_value;
}
void timer_set_compare1A(uint32_t comp_value) {
	TIMER_0->compare_1A = comp_value;
}
void timer_set_compare1B(uint32_t comp_value) {
	 TIMER_0->compare_1B = comp_value;
}
void timer_set_compare2A(uint32_t comp_value) {
	TIMER_0->compare_2A = comp_value;
}
void timer_set_compare2B(uint32_t comp_value) {
	TIMER_0->compare_2B = comp_value;
}

void timer_set_dead_time(uint32_t dead_time){
	TIMER_0->dead_time = dead_time;
}

uint32_t timer_get_output0A(void) {
	return TIMER_0->output_0A;
}
uint32_t timer_get_output0B(void) {
	return TIMER_0->output_0B;
}
uint32_t timer_get_output1A(void) {
	return TIMER_0->output_1A;
}
uint32_t timer_get_output1B(void) {
	return TIMER_0->output_1B;
}
uint32_t timer_get_output2A(void) {
	return TIMER_0->output_2A;
}
uint32_t timer_get_output2B(void) {
	return TIMER_0->output_2B;
}

uint32_t timer_get_capture(void){
    return TIMER_0->capture_value;
}
