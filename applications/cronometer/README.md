# Cronômetro com Funcionalidades 

## Descrição

Este projeto implementa um cronômetro, que possui diferentes funcionalidades como salvar o tempo em diferentes displays. 
O cronômetro é controlado por um sistema de interrupção e pode ser manipulado através de entradas de hardware (chaves). 
O sistema permite iniciar, parar, zerar o cronômetro e salvar tempos intermediários (splits) em displays específicos.

## Funcionalidades

1. **Iniciar/Pausar Cronômetro**:  
   - **Chave 1**: Controla a contagem do cronômetro. Quando ativada, o cronômetro começa a contar. Quando desativada, o cronômetro pausa.

2. **Zerar Contagem**:  
   - **Chave 2**: Ao ser ativada, esta chave zera a contagem dos displays 1 e 2, isso é feito ao zerar os contadores atrelados a esses displays.

3. **Salvar Split (Tempo Intermediário)**:  
   - **Chave 3**: Salva o primeiro tempo intermediário (split) nos displays 3 e 4.
   - **Chave 4**: Salva o segundo tempo intermediário (split) nos displays 5 e 6.

4. **Limpar Displays e Splits**:  
   - **Chave 5**: Quando ativada, esta chave limpa todos os contadores, incluindo os splits, e reinicia o sistema.
  
A indicação da ordem das chaves e displays é mostrada na figura abaixo:

FOTO

## Estrutura do Código

## Instâncias

Para executar esse código são necessários uma série de arquivos de cabeçalho que fornecem definições e funções auxiliares:

- **`utils.h`**: Utilitários gerais usados em diversas partes do código.
- **`hardware.h`**: Definições e funções específicas do hardware, incluindo manipulação de GPIOs e outros periféricos.
- **`timer.h`**: Configuração e controle do temporizador.
- **`interrupt.h`**: Controle das interrupções, incluindo habilitação e desabilitação.
- **`gpio.h`**: Controle das entradas e saídas digitais (GPIOs) usadas para ler o estado das chaves.

### Variáveis

- `seconds_1`: Contador para o display 1.
- `seconds_2`: Contador para o display 2.
- `counting`: Flag que indica se o cronômetro está ativo/contando (1) ou pausado (0).
- `split_count`: Contador para registrar o número de splits salvos (0, 1 ou 2).
- `split_time_1`: Armazena o primeiro tempo intermediário (split) salvo.
- `split_time_2`: Armazena o segundo tempo intermediário (split) salvo.
- `SEGMENTS`: Variável de saída que recebe os valores combinados da contagem e splits e escreve eles no display.
- `INBUS`: Variável de entrada que representa o estado das chaves de controle.

### Funções

#### `TIMER0_0A_IRQHandler(void)`

Esta é a rotina de tratamento de interrupção do temporizador (TIMER0). Suas principais funções incluem:

- **Início/Pausa da Contagem**: Verifica o estado da Chave 1 para iniciar ou parar o cronômetro.
- **Zerar Contagem**: Zera os contadores dos displays 1 e 2 quando a Chave 2 é ativada.
- **Salva os Splits**: Armazena o tempo atual em `split_time_1` ou `split_time_2` quando as Chaves 3 ou 4 são ativadas, respectivamente.
- **Limpeza de Displays**: Reseta todos os contadores e splits ao ativar a Chave 5.
- **Contagem do Cronômetro**: Incrementa o contador do display 1 a cada segundo. Se o contador atingir 9, o display 1 é resetado e o display 2 é incrementado (contagem BCD).
- **Atualização dos Displays**: Combina os tempos atuais e os splits para formar o valor final a ser exibido nos displays, usando a variável `SEGMENTS`.

#### `init_timer0(void)`: Configura o temporizador (TIMER0) para controlar a geração das interrupções de tempo. Especificamente:

#### `main(void)`: Inicializa o temporizador e as interrupções globais, e entra em um loop infinito que mantém o sistema em operação, permitindo que as interrupções controlem a lógica do cronômetro.

## Instâncias

Para executar esse código são necessários uma série de arquivos de cabeçalho que fornecem definições e funções auxiliares:

- **`utils.h`**: Utilitários gerais usados em diversas partes do código.
- **`hardware.h`**: Definições e funções específicas do hardware, incluindo manipulação de GPIOs e outros periféricos.
- **`timer.h`**: Configuração e controle do temporizador.
- **`interrupt.h`**: Controle das interrupções, incluindo habilitação e desabilitação.
- **`gpio.h`**: Controle das entradas e saídas digitais (GPIOs) usadas para ler o estado das chaves.
