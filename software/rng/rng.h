#ifndef __RNG_H
#define __RNG_H

#include "../_core/hardware.h"

/*
 * Mapeamento baseado no seu rng.vhd:
 * Addr "00" (Base)   -> Leitura do RNG
 * Addr "01" (Base+4) -> Escrita da Seed
 * Addr "10" (Base+8) -> Controle (Enable)
 */

// Endereço Base (0x4000640) - Apenas Leitura no seu VHDL
#define RNG_VAL_READ   *(_IO32 *) (RNG_BASE_ADDRESS)

// Endereço Base + 4 bytes (0x4000644) - Para escrever a Seed
#define RNG_SEED_WRITE *(_IO32 *) (RNG_BASE_ADDRESS + 4)

// Endereço Base + 8 bytes (0x4000648) - Para Ligar/Desligar
#define RNG_CTRL       *(_IO32 *) (RNG_BASE_ADDRESS + 8)

#endif // __RNG_H