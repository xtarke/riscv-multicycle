# Algoritmo CORDIC para cálculo de seno e cosseno em hardware

Este projeto apresenta a implementação do algoritmo CORDIC – uma técnica iterativa que utiliza operações de deslocamento e adição para o cálculo de funções trigonométricas – com foco na aplicação em sistemas de hardware. A proposta deste trabalho é demonstrar como o algoritmo pode ser aplicado para calcular de forma eficiente os valores de seno e cosseno, constituindo uma alternativa interessante para implementações em FPGA ou sistemas embarcados.

## Introdução

O algoritmo CORDIC (COordinate Rotation DIgital Computer) é conhecido por sua simplicidade e eficiência, eliminando a necessidade de operações complexas como multiplicação ou divisão. Neste projeto, foi desenvolvida uma implementação em linguagem C, na qual o cálculo dos valores de seno e cosseno é efetuado a partir de um ângulo fornecido. Além disso, foi incluído um script em Python (Localizado em `software/cordic/scripts/angle_calc.py`) que auxilia na conversão de ângulos (de graus para radianos) e na preparação de valores escalados e formatados em hexadecimal, facilitando a verificação e a integração com sistemas de hardware.

## Funcionamento do projeto

O componente `cordic_bus.vhd` instancia um componente `cordic_core`, definido em `cordic_core.vhd`, Definido da seguinte maneira: foram estabelecidas as portas de entrada e saída para permitir a interação com outros módulos. As entradas incluem o sinal de clock (`clk_bus`), reset (`rst_bus`), sinal de início (`start`) e o ângulo de entrada (`angle_in`). As saídas são o valor do seno (`sin_out`), o valor do cosseno (`cos_out`) e um sinal de validade (`valid`) que indica quando o cálculo foi concluído.

Foi incluída uma tabela de ângulos pré-computados (constante `angles`) que armazena os valores das arctangentes correspondentes a cada iteração. Esses valores, representados em formato fixo (hexadecimal), são utilizados para ajustar o ângulo ao longo do processamento iterativo.

Foram declarados sinais internos (`x_reg`, `y_reg` e `z_reg`) para armazenar os valores intermediários dos cálculos, além de um contador de iterações (`iteration`). Durante o estado de reset, os sinais são inicializados e o sistema é colocado no estado IDLE.

O processamento foi organizado em uma máquina de estados com três estados principais:

- Estado IDLE:
        O sistema aguarda a ativação do sinal start.
        Quando iniciado, é atribuído a x_reg o valor correspondente à constante de correção (aproximadamente 0.60725 convertida para o formato fixo), enquanto y_reg é zerado e z_reg recebe o ângulo de entrada.
        O contador de iteração é zerado e o sistema passa para o estado PROCESSING.
- Estado PROCESSING:
        Enquanto o contador de iteração for menor que N_ITER, o processamento iterativo é realizado.
        Em cada ciclo de clock, são efetuadas duas iterações do algoritmo:
    - Primeira Iteração:
                O sinal z_reg é avaliado; se for positivo, os sinais x_reg e y_reg são atualizados realizando subtrações e adições com deslocamentos à direita (função shift_right), e z_reg é reduzido pelo valor da tabela de ângulos na iteração corrente.
                Se z_reg for negativo, as operações de adição e subtração são invertidas, e z_reg é incrementado com o respectivo valor.
    - Segunda Iteração:
                O procedimento é repetido para a iteração seguinte (utilizando iteration+1), com os valores intermediários gerados na primeira iteração.
                Os sinais são atualizados novamente e o contador de iteração é incrementado em 2.
- Estado DONE:
        Quando o número de iterações atinge ou excede N_ITER, o estado muda para DONE.
        Os valores finais de x_reg e y_reg são atribuídos a cos_out e sin_out, respectivamente, e o sinal valid é ativado para indicar que os resultados estão prontos.
        O sistema é retornado ao estado IDLE, aguardando a próxima operação.

Foram utilizadas operações de deslocamento à direita para efetuar divisões por potências de 2, o que é essencial para a execução das multiplicações e divisões necessárias no algoritmo CORDIC. Essa abordagem simplifica o hardware e melhora a eficiência dos cálculos.

Com todo o `cordic_core.vhd` explicado, sobra somente o `cordic_bus.vhd`, que simplesmente instancia o core e faz o link do barramento do Softcore com os ângulos de entrada e saída.

## Passo a passo para compilar

### Compilar o projeto em C

Para compilar o projeto, siga os passos abaixo:

- Pré-requisitos:
    - Certifique-se de que um compilador C (como o GCC) esteja instalado.
    - Verifique se a ferramenta make encontra-se instalada em seu sistema.

- Compilação:
    - Abra um terminal na pasta raiz do software.
    - Execute o comando:
```
cd riscv-multicycle/software/cordic/
make
```

O Makefile provido será utilizado para compilar os arquivos cordic.c, main_cordic.c e demais dependências, e irá gerar um arquivo `quartus_main_cordic.hex` para ser utilizado na FPGA.

### Sintetizar a FPGA

Para sintetizar a FPGA deve-se abrir o projeto do CORDIC no Quartus (`riscv-multicycle/peripherals/cordic/sint/de10_lite/de10_lite.qpf`) e clicar em Start Compilation, e após compilar enviar para a placa com a interface do Programmer. Atualmente, o caminho de todos os arquivos incluídos no projeto do de10_lite está correto, não sendo necessário a mudança de nenhum caminho.

## Funcionamento em C

A implementação em C do algoritmo CORDIC está distribuída em três arquivos principais:

- cordic.h:
    Contém as definições, constantes e protótipos de funções utilizados para a implementação do algoritmo CORDIC.

- cordic.c:
    Contém as funções que enviam e recebem os dados do barramento da FPGA relacionados ao valor do ângulo de entrada e da saída do seno e cosseno calculado. Atualmente por um problema no compilador o endereço do barramento é calculado manualmente, mas na teoria esse offset do endereço era para ser calculado automaticamente. De qualquer forma, funciona.

- main_cordic.c:
    Funciona como ponto de entrada do programa, onde um ângulo de entrada pode ser informado para que os valores de seno e cosseno sejam calculados pelo algoritmo. O arquivo `main_cordic.c` hoje faz o loop entre 3 testes de ângulo e imprime nos quatro primeiros displays de 7 segmentos os valores do cosseno e seno, nessa ordem, para cada teste. 

## Exemplos

### Testbenches

É possível testar os componentes do projeto separadamente utilizando os testbenches dedicados para os componentes .vhd. Para o `cordic_bus.vhd` pode-se utilizar o `tb_cordic.do` e para testar o Softcore pode ser utilizado o `testbench.do`. É importante lembrar que, para testar com o Softcore, é necessário modificar o caminho do arquivo `.hex` que fica dentro de `riscv-multicycle/memory/iram_quartus.vhd`. Sem incluir o caminho do arquivo correto ele não vai ser testado corretamente. O caminho atualmente é `./../../software/cordic/quartus_main_cordic.hex`.

### Teste prático

É possível também testar o Softcore na prática com a FPGA sintetizada, só abrir no Quartus a aba `Tools -> In-System Memory Content Editor` e importar o arquivo `.hex` que foi compilado no projeto nessa aba.

Dessa maneira, é apresentado nos 4 primeiros displays os valores de cosseno e seno, sempre nessa sequência, dos cálculos feitos no `main_cordic.c`, que são:

- Ângulo de 45 graus
- Ângulo de 30 graus
- Ângulo de -45 graus

Caso prefira pode ser modificado o ângulo de entrada, para isso é só utilizar o script localizado em `riscv-multicycle/software/cordic/scripts/angle_calc.py` para calcular o valor de entrada e os valores de saída esperados, passando como argumento o valor de ângulo em graus que deseja, da seguinte forma:

Quero mandar um ângulo de 63 graus, por exemplo, vou fazer o seguinte:

```
python3 angle_calc.py 63
```

O programa irá me retornar o seguinte:

```
Angle (rads): 1.0996
Scaled values: 
Angle in: 18015
Fixed values: 14598 7438
HEX values: 0x3906 0x1d0e
```

O ângulo passado para a função `cordic_angle_in()` será `18015`. Por fim é possível aproveitar esse script para checar se o retorno da função está correto, da seguinte forma:

O nosso interesse aqui é verificar se o ângulo apresentado nos displays de 7 segmentos é próximo aos valores HEX que são apresentados (nesse caso, 0x3906 e 0x1d0e). Caso os valores estejam próximos, é porque deu certo. Nesse exemplo, qualquer valor entre, por exemplo, 0x38fa e 0x3910 está aceitável para o seno e 0x1d00 e 0x1d19 está aceitável para o cosseno.