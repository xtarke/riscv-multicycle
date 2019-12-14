# Controlador TFT

descrição do que é o projeto vai aqui.

![TFT_1](./images/figura1.png "Diagrama de blocos")

Figura 1. Diagrama de blocos do controlador TFT.

* **decoder:** Bloco responsável pela decodificação dos dados de entrada, convertendo em informação para as memórias;
* **boot_mem:** Memória responsável pela inicialização do display LCD;
* **data_mem:** Memória responsável por armazenar a informação que será enviada ao display LCD;
* **controller:** Bloco responsável pelo gerenciamento da leitura das memórias;
* **mux:** Bloco de seleção da entrada do bloco *writer*;
* **writer:** Bloco responsável pela conversão de 32 bits para 8 bits paralelos mais os pinos CS, RS e WR.

### Bibliografia
[ILI9320 Datasheet](https://www.rockbox.org/wiki/pub/Main/GSoCSansaView/ILI9320DS_V0.55.pdf)
