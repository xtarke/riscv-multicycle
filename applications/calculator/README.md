# Calculadora com teclado matricial em Softcore

## Visão Geral

Este projeto apresenta o desenvolvimento de uma calculadora digital executada sobre um processador **RISC-V Multicycle**, implementado como um **softcore** na FPGA Intel DE10-Lite. O objetivo foi desenvolver uma aplicação capaz de integrar hardware e software, utilizando os recursos da FPGA para receber dados de um teclado matricial, processar as operações matemáticas e apresentar os resultados nos displays de sete segmentos.

A aplicação foi desenvolvida em linguagem C e é executada diretamente pelo processador RISC-V. A comunicação com os periféricos é realizada por meio de **Memory Mapped I/O**, permitindo que dispositivos como o teclado e os displays sejam acessados através de endereços de memória.

Para o desenvolvimento do projeto foi utilizada como base a plataforma **riscv-multicycle**, aproveitando sua infraestrutura de hardware e o periférico responsável pelo teclado matricial. A partir dessa base, foi desenvolvida toda a aplicação da calculadora, integrando os periféricos disponíveis e implementando a lógica necessária para o funcionamento do sistema.

---

# Projeto Base

O projeto foi desenvolvido a partir do repositório:

https://github.com/xtarke/riscv-multicycle

Mais especificamente, foi utilizada como base a implementação do periférico de teclado matricial disponível em:

https://github.com/xtarke/riscv-multicycle/tree/master/peripherals/keyboard


Para o desenvolvimento da calculadora foi utilizado como base o projeto **riscv-multicycle**, que implementa um processador RISC-V multiciclo em FPGA juntamente com diversos periféricos de entrada e saída.

Esse projeto fornece toda a infraestrutura necessária para executar programas em linguagem C, além de disponibilizar periféricos como display de sete segmentos, LEDs, UART, GPIO, temporizador e teclado matricial, facilitando o desenvolvimento de novas aplicações para a plataforma.

Neste trabalho, foi reaproveitado o periférico responsável pelo teclado matricial 4×4, que realiza em hardware a identificação da tecla pressionada e disponibiliza essa informação ao processador. A partir dessa estrutura, foi desenvolvida uma aplicação capaz de interpretar as entradas do usuário, gerenciar o fluxo de funcionamento da calculadora, realizar as operações aritméticas e controlar a exibição dos resultados nos displays de sete segmentos.

---


# Arquitetura do Sistema

O funcionamento geral da aplicação pode ser representado pelo seguinte diagrama.

```text
                Usuário
                   │
                   ▼
          Teclado Matricial 4×4
                   │
                   ▼
        Controlador do Teclado
            (Hardware HDL)
                   │
                   ▼
         Memory Mapped I/O
                   │
                   ▼
         Processador RISC-V
          (Softcore FPGA)
                   │
                   ▼
        Programa em Linguagem C
                   │
                   ▼
      Display de Sete Segmentos
```

O usuário realiza a entrada dos operandos e comandos através do teclado matricial.

O controlador implementado em hardware identifica qual tecla foi pressionada e disponibiliza um código numérico ao processador através do barramento de dados.

O software interpreta esse código, executa a operação correspondente e envia o resultado ao controlador responsável pelos displays de sete segmentos.

---

# Funcionamento do Teclado Matricial

O teclado utilizado é um teclado matricial 4×4, formado por 16 teclas distribuídas em quatro linhas e quatro colunas. Esse tipo de teclado é bastante utilizado em sistemas embarcados porque permite utilizar apenas oito conexões elétricas para identificar todas as teclas.

![Funcionamento](https://github.com/luiz-sene/riscv-multicycle/blob/master/peripherals/keyboard/figures/272_img_5_H.png)

Cada tecla representa uma conexão elétrica entre uma linha e uma coluna. Dessa forma, o teclado necessita de apenas oito conexões elétricas para identificar todas as dezesseis teclas disponíveis.
As ligações com o DE10 são feitas da seguinte maneira:

![circuito](https://github.com/luiz-sene/riscv-multicycle/blob/master/peripherals/keyboard/figures/de10teclado2.png)

* Cabos laranjas = Linhas
* Cabos azuis = Colunas

Internamente, o periférico implementado em hardware realiza continuamente um processo de varredura. Durante esse processo, cada linha é ativada individualmente enquanto as colunas são monitoradas.

Quando uma tecla é pressionada, ocorre a conexão entre uma linha e uma coluna, permitindo identificar exatamente qual tecla foi acionada.

Após identificar a tecla pressionada, o controlador converte essa informação em um código numérico que pode ser lido pelo processador.

No software, essa leitura é realizada através da função:

```c
int ler_teclado() {
    return KEYBOARD_BASE_ADDRESS & 0x1F;
}
```

O endereço `KEYBOARD_BASE_ADDRESS` corresponde ao registrador do periférico do teclado.

A máscara hexadecimal `0x1F` preserva apenas os cinco bits menos significativos, responsáveis por armazenar o código da tecla pressionada.

---

# Desenvolvimento da Aplicação

A calculadora foi desenvolvida em linguagem C utilizando as bibliotecas disponibilizadas pelo pelo professor e também pelo projeto base do Luiz Sene.

Após a inicialização, o programa entra em um laço infinito aguardando que o usuário pressione uma tecla do teclado matricial.

Quando um número é pressionado, ele é incorporado ao operando atual.

Após isso, o usuário seleciona uma operação matemática através das teclas especiais do teclado.

| Tecla | Operação |
|--------|----------|
| A | Soma |
| B | Subtração |
| C | Multiplicação |
| D | Divisão |
| 0 | Limpar |
| # | Executar operação |

Após informar o segundo operando, o usuário pressiona a tecla **#**, responsável por executar o cálculo.

Depois que a operação é executada, o resultado é mostrado no display e também passa a ser o valor atual da calculadora, permitindo realizar novos cálculos em sequência.

---

# Estrutura do Código

O software foi dividido em três partes principais:

## Leitura do teclado

A função `ler_teclado()` realiza a leitura do registrador do periférico do teclado.

A função `esperar_tecla()` implementa o controle de leitura, aguardando até que uma tecla seja pressionada e posteriormente liberada, evitando múltiplas leituras provocadas por uma única pressão.

## Controle da Calculadora

A função principal (`main`) implementa toda a lógica da calculadora.

São utilizadas variáveis para armazenar:

- Primeiro operando;
- Segundo operando;
- Operação selecionada;
- Resultado da operação.

Cada tecla pressionada altera o estado interno da aplicação até que seja solicitado o cálculo.

## Controle do Display

A função `mostrar_numero()` é responsável por converter um número inteiro em dígitos individuais.

Cada dígito é separado utilizando operações de divisão e resto por 10.

Posteriormente, os dígitos são organizados em um único registrador e enviados ao controlador dos displays de sete segmentos através do endereço:

```c
SEGMENTS_BASE_ADDRESS = saida;
```

---

# Fluxo de Funcionamento

O funcionamento da aplicação pode ser resumido pelo seguinte fluxo:

```text
Inicialização

      │

      ▼

Mostrar zero

      │

      ▼

Esperar tecla

      │

      ▼

É número?

 ┌────┴─────┐
 │          │
Sim        Não
 │          │
 ▼          ▼

Atualiza   Verifica
operando   operação

      │

      ▼

Tecla "=" ?

      │

 ┌────┴─────┐
 │          │
Não        Sim
 │          │
 ▼          ▼

 Espera   Executa operação

             │

             ▼

     Atualiza display

             │

             ▼

       Retorna ao início
```

---


# Referências

- Projeto base: https://github.com/xtarke/riscv-multicycle
- Periférico do teclado: https://github.com/xtarke/riscv-multicycle/tree/master/peripherals/keyboard
- Especificação RISC-V: https://riscv.org/
