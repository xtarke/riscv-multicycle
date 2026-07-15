/*
 * sv_pwm.h
 *
 *  Space Vector PWM peripheral driver
 *  Instituto Federal de Santa Catarina
 *
 * Mapa de registradores (MY_WORD_ADDRESS = 0x0190):
 *   +0  v_bar   [W/R]  Tensão do barramento DC [V], uint32
 *   +1  u_cmd   [W/R]  Tensão de saída desejada [V], int32 (com sinal)
 *   +2  f_sw    [W/R]  Frequência de chaveamento [Hz], uint32
 *   +3  status  [R]    Estado dos gates: bits 3:0 = gate_s4..gate_s1
 *   +4  ctrl    [W/R]  bit0 = enable (1 = start, 0 = stop: gates em 0)
 */

#ifndef __SV_PWM_H
#define __SV_PWM_H

#include <stdint.h>
#include "../_core/hardware.h"

typedef struct {
    _IO32  v_bar;   /* +0: tensão do barramento DC [V]           */
    _IO32S u_cmd;   /* +1: tensão de saída desejada [V] (signed) */
    _IO32  f_sw;    /* +2: frequência de chaveamento [Hz]        */
    _IO32  status;  /* +3: read-only — bits 3:0 = gate_s4..s1   */
    _IO32  ctrl;    /* +4: bit0 = enable (1=start, 0=stop)       */
} SV_PWM_TYPE;

#define SV_PWM_0 ((SV_PWM_TYPE *) &SV_PWM_BASE_ADDRESS)

/* Máscaras do registrador status */
#define SV_PWM_GATE_S1  (1u << 0)
#define SV_PWM_GATE_S2  (1u << 1)
#define SV_PWM_GATE_S3  (1u << 2)
#define SV_PWM_GATE_S4  (1u << 3)

/* Máscara do registrador ctrl (bit0 = enable) */
#define SV_PWM_CTRL_START (1u << 0)
#define SV_PWM_CTRL_STOP  (0u)

/* Configuração */
void     sv_pwm_set_vbus(uint32_t v_bar);
void     sv_pwm_set_vcmd(int32_t  u_cmd);
void     sv_pwm_set_fsw (uint32_t f_sw);

/* Controle */
void     sv_pwm_start(void);
void     sv_pwm_stop (void);

/* Leitura */
uint32_t sv_pwm_get_vbus  (void);
int32_t  sv_pwm_get_vcmd  (void);
uint32_t sv_pwm_get_fsw   (void);
uint32_t sv_pwm_get_status(void);
uint32_t sv_pwm_get_ctrl  (void);

#endif /* __SV_PWM_H */
