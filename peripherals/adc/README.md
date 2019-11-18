

DOCUMENTAÇÃO ADC E DISPLAY 7 SEGMENTOS DE-10LITE


1- O HARDWARE


A implementação do ADC trata-se de um bloco IP da Altera, é configurado pelo arquivo "adc_qsys.qsys" utilizando-se a ferramenta própria da Altera.
Maiores informações em https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/max-10/archives/ug-m10-adc-16.1.pdf

No arquivo "Top-level Hierarchy", "de0_lite.vhd", pode-se observar a Instancia do Componente ADC bem como o Port Map e Sinais necessários para o seu funcionamento.

No process "-- Output register" o softcore envia ao hardware o número do canal que deve ser lido o ADC e também o registrador com os dígitos separados em hexadecimal que devem ser enviados aos displays de 7 segmentos do kit.

No process "-- Input register" envia-se o valor do ADC para o registrador de I/O do softcore, onde os 12 bits menos significativos do registrador de I/O recebe o valor bruto do ADC e os bits 12 a 15 recebem o número do canal cujo valor foi lido, conforme ilustrado abaixo:

					input_in(11 downto 0) <= adc_sample_data;
					input_in(15 downto 12) <= cur_adc_ch(3 downto 0);
					

Também neste mesmo arquivo foi declarado os componentes "displays()" que são responsáveis por receber um dígito hexadecimal e codifiar para os respectivos displays de 7 segmentos presentes no Kit DE-10LITE.


2- SOFTWARE

No arquivo "hardware.h" estão definidos os nomes e endereços dos registradores de I/O:

INDATA_ADC -> recebe o valor do ADC e respectivo canal.
SEL_CH_ADC -> envia ao hardware o número do canal ADC a ser lido
OUT_SEGS -> envia os dvalores em hexadecimal aos displays de 7 segmentos. São 6 displays ordenados nos 24bits mais significativos.


No arquivo "hardware_ADC_7SEG.h" estão definidos uma estrutura de dados para armazenar o valor lido do ADC e seu respectivo canal, bem como a declaração das funções para ler o ADC e escrever nos displays de 7 segmentos.


3- Valor ADC.

O valor lido do ADC é bruto, devendo-se fazer as devidas conversões de acordo com a conveniencia pretendida.
No exemplo do arquivo "firmware.c" o valor foi convertido em mV.
 