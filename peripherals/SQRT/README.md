## Periférico de Raiz Quadrada

Este projeto implementa um periférico capaz de calcular a raiz quadrada inteira de um número utilizando a _megafunction_ `ALTSQRT` do Quartus. O valor de entrada é definido pelas chaves da placa, enquanto o resultado ou o resto da operação é exibido nos displays de sete segmentos da FPGA.

## Código

O periférico recebe pelas chaves físicas da FPGA um valor entre 0 e 511. No arquivo `raiz.vhd`, esse valor é enviado ao módulo `sqrt`, responsável pelo cálculo da raiz quadrada inteira e do resto.

Os valores obtidos satisfazem a relação:

$$
\text{entrada} = \text{resultado}^2 + \text{resto}
$$

Por exemplo, para uma entrada igual a 26:

$$
\sqrt{26} \approx 5{,}10
$$

Logo:

$$
\text{resultado} = 5
$$

$$
\text{resto} = 26 - 5^2 = 1
$$

Portanto:

$$
26 = 5^2 + 1
$$

## Simulação

Foi elaborada uma simulação no ModelSim, antes da integração do periférico à síntese, para verificar se o arquivo `raiz.vhd` realizava corretamente o cálculo da raiz quadrada e do resto.

<img width="1632" height="260" alt="image" src="https://github.com/user-attachments/assets/d120983e-a2da-4b35-a179-af0f15cc968f" />

## Fluxograma do periférico

O fluxograma apresenta a integração entre o hardware e o software. 

<img width="1654" height="1785" alt="fluxograma_raiz" src="https://github.com/user-attachments/assets/430bcdbf-44a1-4c68-bf00-6b26d248bf42" />

## Funcionamento na FPGA

Na placa, as chaves `SW0`–`SW8` representam o número de entrada em binário e `SW9` sendo o reset. Assim, a configuração `000000100` corresponde ao valor 4. Esse valor é enviado ao periférico, que calcula sua raiz quadrada inteira. Como $\sqrt{4} = 2$, o display apresenta o número 2.

O botão `KEY0` permite alternar a informação exibida. Com o botão solto, os displays mostram o resultado da raiz quadrada. Enquanto o botão estiver pressionado, mostram o resto da operação para a entrada 4, sendo que o resto é zero, pois $4 = 2^2 + 0$.

Vale notar que os displays de sete segmentos exibem os valores sempre em **hexadecimal**. Para entradas pequenas isso passa despercebido, como no exemplo acima, mas a diferença aparece a partir de resultados de dois dígitos em hexadecimal. Ligando todas as chaves de entrada, o valor de entrada é 511:

$$
\sqrt{511} \approx 22{,}6 \implies \text{resultado} = 22, \quad \text{resto} = 511 - 22^2 = 27
$$

Como o display mostra em hexadecimal, o resultado (22 em decimal) aparece como `16`, e o resto (27 em decimal) aparece como `1b`.
