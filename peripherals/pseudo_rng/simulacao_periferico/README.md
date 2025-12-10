# Simulação do RNG (Pseudo-Random Number Generator) no ModelSim

## Objetivo

Esta simulação tem como objetivo **verificar o funcionamento lógico do gerador de números pseudoaleatórios (RNG)** desenvolvido em VHDL antes da síntese e integração com o sistema da FPGA.

O módulo utiliza um **registrador de deslocamento com realimentação linear (LFSR)** de 16 bits para gerar números pseudoaleatórios.  
O teste foi feito inteiramente no **ModelSim – Intel FPGA Edition**.

---

## ⚙️ Arquivos Utilizados

| Arquivo | Função |
|----------|--------|
| `rng.vhd` | Implementa o núcleo LFSR de 16 bits. |
| `tb_rng.vhd` | Testbench da simulação. |


<img src="imagens/simulacao_rng.png" title="" alt="Bloco rng e rng_bus" data-align="center">



