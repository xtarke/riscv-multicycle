#include "raiz.h"

uint16_t raiz_get_input(void)
{
    return (SQRT_INPUT & 0x03FF);
}

uint8_t raiz_get_result(void)
{
    return (SQRT_RESULT & 0x1F);
}

uint8_t raiz_get_remainder(void)
{
    return (SQRT_REMAINDER & 0x3F);
}