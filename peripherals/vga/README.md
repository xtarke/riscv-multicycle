## Como funciona

O VGA mostra na tela uma imagem de 640x480 pixels. Essa imagem inteira fica guardada na memória SDRAM (o chamado framebuffer), porque ela é grande demais para caber na memória interna da FPGA.

O problema é que a tela precisa ler os pixels em um ritmo muito rápido e constante, e a SDRAM sozinha nem sempre entrega os dados nessa velocidade na hora exata. Para resolver isso, o VGA usa o cache que fica no periférico da SDRAM. O cache vai lendo os pixels adiantado e guardando em uma fila, de modo que o VGA sempre tem dados prontos para enviar para a tela, sem falhas na imagem.

Desenhar pixel por pixel pelo processador é muito lento. Para dar conta, existe um bloco de aceleração em hardware chamado blitter (arquivo `blitter.vhd`), que desenha formas simples direto na memória, sem o processador ter que escrever cada pixel. Hoje ele sabe desenhar dois tipos de forma: retângulo preenchido e linha.

## Como usar

Tudo o que está descrito aqui é o exemplo rodando com o softcore. É ele que envia os comandos de desenho.

Você comanda o desenho pelo blitter escrevendo em alguns registradores. A ideia é sempre a mesma: preencher os parâmetros da forma, escolher a cor e disparar o comando.

Os registradores são:

| Registrador | O que faz |
|-------------|-----------|
| BLIT_P0..P3 | Os quatro parâmetros da forma (o significado muda conforme a forma) |
| BLIT_COLOR  | A cor da forma |
| BLIT_CMD    | Escreva aqui o número da forma para iniciar o desenho |
| BLIT_STAT   | Leia aqui para saber se o blitter ainda está ocupado (bit 0 ligado = ocupado) |

As formas disponíveis são:

- Retângulo preenchido (comando 1): P0 = x, P1 = y, P2 = largura, P3 = altura.
- Linha (comando 2): P0 = x0, P1 = y0, P2 = x1, P3 = y1.

A cor tem 12 bits, 4 para cada canal, no formato 0xBGR (azul, verde, vermelho). Alguns exemplos: 0xF00 é azul, 0x0F0 é verde, 0x00F é vermelho, 0xFFF é branco e 0x000 é preto.

Fluxo básico para desenhar uma forma:

1. Espere o blitter ficar livre (leia BLIT_STAT até o bit 0 zerar).
2. Escreva os parâmetros em P0..P3 e a cor em BLIT_COLOR.
3. Escreva o número da forma em BLIT_CMD para começar.

Exemplo em C (baseado em `software/vga/main_vga.c`):

```c
// pinta a tela inteira de preto
blit_fill(0, 0, 640, 480, 0x000);

// desenha um retangulo verde de 200x150 na posicao (40, 40)
blit_fill(40, 40, 200, 150, 0x0F0);

// desenha uma linha branca de (0,0) ate (639,479)
blit_line(0, 0, 639, 479, 0xFFF);
```

As funções `blit_fill` e `blit_line` já cuidam de esperar o blitter, preencher os registradores e disparar o comando, então na maioria dos casos basta chamá-las.

## Escrevendo direto no framebuffer

Também é possível escrever direto no framebuffer, ou seja, mudar os pixels na memória sem passar pelo blitter. O problema é que o softcore é muito lento para isso: escrever a tela toda pixel por pixel pelo processador não dá conta de fazer animações ou desenhos grandes em tempo hábil.

Por isso a recomendação é o contrário: em vez de desenhar tudo pelo software, incremente o blitter para fazer em hardware a operação que você precisa (uma nova forma, uma cópia de imagem, etc.) e use o softcore apenas para lançar os comandos. Assim o trabalho pesado fica no hardware, que é rápido, e o software só manda o que desenhar.

## Como funciona escrever no framebuffer

No exemplo, existe uma região da memória SDRAM reservada só para a imagem. Essa região é o framebuffer: ela guarda a cor de cada pixel da tela. O VGA fica lendo essa mesma região o tempo todo, do início ao fim, para desenhar a imagem. Ou seja, o que estiver escrito ali é o que aparece na tela.

A imagem é guardada linha por linha. Cada pixel ocupa uma posição na memória. A primeira linha da tela vem primeiro (os 640 pixels de cima, da esquerda para a direita), depois a segunda linha, e assim por diante até o fim da tela. Como a tela é 640x480, são 640 vezes 480, ou seja, 307200 posições no total.

Para saber em qual posição da memória está um pixel, use a conta:

```
endereco = y * 640 + x
```

Onde x é a coluna (de 0 a 639) e y é a linha (de 0 a 479). Para pintar esse pixel, basta escrever o valor da cor nesse endereço. Por exemplo, para pintar o pixel (10, 5) de branco, você escreve a cor 0xFFF no endereço 5 * 640 + 10, que dá 3210.

É exatamente isso que o blitter faz por dentro: para preencher um retângulo, ele calcula o endereço de cada pixel com essa mesma conta e vai escrevendo a cor um por um. A diferença é que o blitter faz isso em hardware, muito mais rápido do que o softcore conseguiria fazendo pixel por pixel.

## TODO

Adicionar um comando de sprite ao blitter, ou seja, desenhar uma imagem pronta na tela (e não só formas geométricas como retângulo e linha).

O desafio é o cache da SDRAM, que é bem limitado e otimizado para leitura sequencial. Se o sprite for guardado na SDRAM e o blitter tentar lê-lo enquanto o controlador de VGA está desenhando a tela, os dois vão disputar a memória. Isso provoca um cache miss no lado do VGA, que causa um glitch na imagem até o cache se recuperar.

A ideia para resolver isso é o blitter só acessar a SDRAM durante o V_BLANK, que é o intervalo em que a tela não está sendo desenhada. Nesse período o blitter leria de uma vez tudo o que precisa do sprite, antes de o controlador de VGA voltar a pedir dados. Assim o desenho do sprite não atrapalha a leitura do framebuffer e a tela não apresenta glitch.


## Arquivos do VGA

Estes são os arquivos usados no exemplo atual (o que roda na DE10-Lite com a SDRAM):

| Arquivo | O que faz |
|---------|-----------|
| de10_lite.vhd | Projeto de topo. Liga tudo: o processador, o blitter, o framebuffer e o controlador de VGA. |
| blitter.vhd | Aceleração por hardware. Recebe comandos e desenha formas no framebuffer. |
| vga_framebuffer.vhd | Guarda a imagem na SDRAM (via cache) e lê os pixels para a tela. Também tem a porta de escrita usada pelo blitter. |
| vga_controller.vhd | Gera os sinais de sincronismo do VGA e diz a hora certa de mostrar cada pixel. |
| hw_image_generator.vhd | Liga o pixel lido do framebuffer às saídas de cor do VGA. |

Os arquivos abaixo são de uma versão antiga, que guardava a imagem na memória interna da FPGA (IRAM) em vez da SDRAM. Eles não são usados no exemplo atual e ficam aqui só como referência:

| Arquivo | O que faz |
|---------|-----------|
| vga_buffer.vhd | Buffer de vídeo da versão antiga baseada em IRAM. |
| ram_vga.vhd | Memória interna (IRAM) usada por aquela versão. |

## Como adicionar uma forma nova no blitter

O blitter foi feito para ser fácil de estender. Cada forma (retângulo, linha, etc.) é um comando com um número próprio. Para criar uma forma nova, o caminho é sempre o mesmo:

1. Escolha um número para o comando novo e crie uma constante para ele no topo do arquivo, junto de OP_FILL e OP_LINE (por exemplo, OP_CIRCLE).

2. Crie os estados dessa forma na lista de estados do blitter (blit_state_t). Normalmente são dois: um de preparação (INIT), que calcula os valores iniciais, e um de execução, que vai escrevendo os pixels.

3. Na parte de dispatch (estado BLIT_IDLE), adicione uma linha que, ao ver o número do seu comando, pula para o estado de preparação da sua forma.

4. Escreva a lógica da forma nos estados que você criou. Para ler os parâmetros do comando, use as views já prontas (arg_x, arg_y, arg_w, arg_h, arg_color, etc.). Para pintar um pixel, calcule o endereço com a conta y * 640 + x, coloque o endereço em write_address, a cor em write_data e ative write_commit por um ciclo, sempre respeitando o write_busy (só escreva quando ele estiver em 0). Quando terminar, volte para BLIT_IDLE.

O comando de preencher retângulo (OP_FILL) é o exemplo mais simples para usar como base: dá para copiar a estrutura dele e trocar só a lógica de quais pixels são desenhados.

## Como compilar e rodar o exemplo

O exemplo é compilado e gravado pelo Makefile em `software/vga/`. Antes de rodar, confira duas linhas no começo dele e ajuste se necessário:

- `QUARTUS_DIR`: caminho da pasta `bin` do seu Quartus. No Makefile está `/opt/intelFPGA/25.1/quartus/bin/`. Troque para onde o Quartus está instalado na sua máquina.
- `RISCV_TOOLS_PREFIX`: caminho do compilador RISC-V. O padrão aponta para dentro do próprio repositório, então só mude se o seu estiver em outro lugar.

Você também pode passar esses valores direto na linha de comando, sem editar o arquivo, por exemplo:

```sh
make flash QUARTUS_DIR=/opt/intelFPGA/25.1/quartus/bin/
```

Os comandos disponíveis são:

- `make` compila o programa em C e gera o arquivo que a placa carrega.
- `make sint` compila o projeto de hardware no Quartus (o VGA, o processador, etc.). Isso demora e só precisa ser feito quando o hardware muda.
- `make fpga` grava o hardware na placa.
- `make flash` faz tudo de uma vez: compila o programa, grava o hardware na placa e carrega o programa na memória dela.
- `make clean` apaga os arquivos gerados.

Passo a passo mais comum, com a placa DE10-Lite ligada pelo cabo USB:

1. Rode `make sint` uma vez para compilar o hardware (só repita isso se mexer nos arquivos VHDL).
2. Rode `make fpga` para gravar o hardware na placa.
3. Rode `make flash` para carregar o programa e ver o exemplo rodando na tela.

O cabo de gravação (USB-Blaster) é detectado automaticamente, então normalmente não é preciso configurar nada a mais.


### Links Úteis
[Controlador VGA VHDL](https://www.digikey.com/eewiki/pages/viewpage.action?pageId=15925278)


