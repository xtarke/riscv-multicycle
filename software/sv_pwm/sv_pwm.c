#include "sv_pwm.h"

void sv_pwm_set_vbus(uint32_t v_bar) {
    SV_PWM_0->v_bar = v_bar;
}

void sv_pwm_set_vcmd(int32_t u_cmd) {
    SV_PWM_0->u_cmd = u_cmd;
}

void sv_pwm_set_fsw(uint32_t f_sw) {
    SV_PWM_0->f_sw = f_sw;
}

void sv_pwm_start(void) {
    SV_PWM_0->ctrl = SV_PWM_CTRL_START;
}

uint32_t sv_pwm_get_vbus(void) {
    return SV_PWM_0->v_bar;
}

int32_t sv_pwm_get_vcmd(void) {
    return SV_PWM_0->u_cmd;
}

uint32_t sv_pwm_get_fsw(void) {
    return SV_PWM_0->f_sw;
}

uint32_t sv_pwm_get_status(void) {
    return SV_PWM_0->status;
}

uint32_t sv_pwm_get_ctrl(void) {
    return SV_PWM_0->ctrl;
}
