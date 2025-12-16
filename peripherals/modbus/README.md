# Implementação Modbus RTU em VHDL

## Índice
1. [Visão Geral](#visão-geral)
2. [Arquitetura do modbus_rtu.vhd](#arquitetura-do-modbus_rtuvhd)
3. [Máquina de Estados](#máquina-de-estados)
4. [Interface de Barramento](#interface-de-barramento)
5. [Cálculo de CRC](#cálculo-de-crc)
6. [Testbench (tb_modbus.vhd)](#testbench-tb_modbusvhd)
7. [Fluxo de Operação](#fluxo-de-operação)
8. [Casos de Uso](#casos-de-uso)
9. [Script Python: CRC Calculator](#script-python-crc-calculator-crc_calculatorpy)
10. [Análise de Desempenho](#análise-de-desempenho)
11. [Limitações e Melhorias Futuras](#limitações-e-melhorias-futuras)
12. [Referências](#referências)

---

## Visão Geral

Este projeto implementa um **protocolo Modbus RTU simplificado** em VHDL para simulação em FPGAs. O Modbus RTU é um protocolo de comunicação serial amplamente utilizado em sistemas industriais para comunicação entre dispositivos mestre e escravos.

### Características Principais:
- **Protocolo**: Modbus RTU (modo escravo)
- **Funções Suportadas**:
  - `0x03`: Read Holding Registers (leitura de registradores)
  - `0x06`: Write Single Register (escrita em registrador)
- **Validação CRC**: CRC-16 Modbus (polinômio 0xA001)
- **Interface**: Barramento de dados de 32 bits com chip select
- **Registradores**: 4 Holding Registers de 16 bits cada

---

## Arquitetura do modbus_rtu.vhd

### Parâmetros Genéricos

```vhdl
MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10"
MY_WORD_ADDRESS   : unsigned(15 downto 0) := x"0040"
DADDRESS_BUS_SIZE : integer := 32
SLAVE_ADDRESS     : std_logic_vector(7 downto 0) := x"01"
```

- **MY_CHIPSELECT**: Identificador único do periférico no barramento (padrão: "10")
- **MY_WORD_ADDRESS**: Endereço base no mapa de memória (padrão: 0x0040)
- **DADDRESS_BUS_SIZE**: Largura do barramento de endereços em bits (32 bits)
- **SLAVE_ADDRESS**: Endereço Modbus do dispositivo escravo (padrão: 0x01)

### Interface de Portas

#### Sinais de Clock e Reset
- `clk`: Clock do sistema
- `rst`: Reset assíncrono ativo em nível alto

#### Barramento de Dados do Core
- `daddress`: Barramento de endereços (32 bits)
- `ddata_w`: Dados para escrita (32 bits)
- `ddata_r`: Dados de leitura (32 bits)
- `d_we`: Write Enable (habilitação de escrita)
- `d_rd`: Read Enable (habilitação de leitura)
- `dcsel`: Chip Select (seleção do periférico)
- `dmask`: Máscara de bytes (4 bits para 32 bits)

#### Sinais de Debug
- `debug_state`: Estado atual da máquina de estados (4 bits)
- `debug_crc`: CRC calculado em tempo real (16 bits)

---

## Máquina de Estados

A implementação utiliza uma **máquina de estados finita (FSM)** para controlar o fluxo de recepção e processamento de frames Modbus.

### Estados da FSM

```
IDLE → RX_ADDR → RX_FUNC → RX_DATA_H → RX_DATA_L → RX_CRC_L → RX_CRC_H → PROCESS_CMD → TX_RESPONSE → DONE
```

#### 1. **IDLE** (Estado Ocioso)
- **Função**: Aguarda início de nova recepção
- **Condição de saída**: `ENABLE_BIT` = '1' AND `START_RX_BIT` = '1'
- **Ações**:
  - Limpa flags de status
  - Reseta CRC para 0xFFFF
  - Zera contador de bytes

#### 2. **RX_ADDR** (Recepção de Endereço)
- **Função**: Recebe e valida o endereço do escravo
- **Operações**:
  - Calcula CRC do byte de endereço recebido
  - Compara com `SLAVE_ADDRESS` ou broadcast (0x00)
  - Se válido: seta `ADDR_MATCH_BIT` e avança
  - Se inválido: retorna para IDLE

#### 3. **RX_FUNC** (Recepção de Função)
- **Função**: Recebe o código da função Modbus
- **Operações**:
  - Atualiza CRC com o byte de função
  - Armazena em `rx_function`
  - Avança para recepção de dados

#### 4. **RX_DATA_H** (Recepção de Byte Alto de Dados)
- **Função**: Recebe o byte mais significativo dos dados
- **Operações**:
  - Atualiza CRC
  - Armazena em `rx_data_high`

#### 5. **RX_DATA_L** (Recepção de Byte Baixo de Dados)
- **Função**: Recebe o byte menos significativo dos dados
- **Operações**:
  - Atualiza CRC
  - Armazena em `rx_data_low`

#### 6. **RX_CRC_L** (Recepção de CRC Baixo)
- **Função**: Recebe byte menos significativo do CRC
- **Operações**:
  - Armazena em `rx_crc_low`
  - Não atualiza o CRC calculado

#### 7. **RX_CRC_H** (Recepção de CRC Alto)
- **Função**: Recebe byte mais significativo do CRC e valida
- **Operações**:
  - Armazena em `rx_crc_high`
  - Compara `calculated_crc` com `(rx_crc_high & rx_crc_low)`
  - Se válido: `crc_valid` = '1', avança para PROCESS_CMD
  - Se inválido: seta `CRC_ERROR_BIT` e vai para DONE

#### 8. **PROCESS_CMD** (Processamento de Comando)
- **Função**: Executa a operação solicitada
- **Operações por Função**:
  - **0x03 (Read Holding Registers)**:
    - Lê valor do holding register especificado
    - Prepara resposta em `tx_data`
  - **0x06 (Write Single Register)**:
    - Escrita é feita via barramento (não diretamente aqui)
    - Prepara resposta de confirmação
  - **Outras funções**: Seta erro e vai para DONE

#### 9. **TX_RESPONSE** (Transmissão de Resposta)
- **Função**: Prepara resposta para transmissão
- **Operações**:
  - Seta `response_ready` = '1'
  - Avança para DONE

#### 10. **DONE** (Finalização)
- **Função**: Sinaliza conclusão da transação
- **Operações**:
  - Seta `RX_COMPLETE_BIT` = '1'
  - Seta `TX_COMPLETE_BIT` se resposta pronta
  - Retorna para IDLE quando `START_RX_BIT` = '0'

### Diagrama de Transições

```
┌─────────┐
│  IDLE   │ ◄─────────────────────────┐
└────┬────┘                           │
     │ START_RX                       │
     ▼                                │
┌─────────┐                           │
│ RX_ADDR │ ─► (addr inválido)        │
└────┬────┘                           │
     │ (addr válido)                  │
     ▼                                │
┌─────────┐                           │
│ RX_FUNC │                           │
└────┬────┘                           │
     ▼                                │
┌──────────┐                          │
│RX_DATA_H │                          │
└────┬─────┘                          │
     ▼                                │
┌──────────┐                          │
│RX_DATA_L │                          │
└────┬─────┘                          │
     ▼                                │
┌─────────┐                           │
│RX_CRC_L │                           │
└────┬────┘                           │
     ▼                                │
┌─────────┐                           │
│RX_CRC_H │ ─► (CRC inválido) ────┐   │
└────┬────┘                       │   │
     │ (CRC válido)               │   │
     ▼                            │   │
┌─────────────┐                   │   │
│PROCESS_CMD  │                   │   │
└────┬────────┘                   │   │
     │                            │   │
     ▼                            │   │
┌─────────────┐                   │   │
│TX_RESPONSE  │                   │   │
└────┬────────┘                   │   │
     │                            │   │
     ▼                            ▼   │
┌─────────┐                           │
│  DONE   │ ──────────────────────────┘
└─────────┘
```

---

## Interface de Barramento

### Mapa de Memória

A interface é acessada através de um barramento mapeado em memória. Endereço base: `MY_WORD_ADDRESS` (0x0040)

| Offset | Endereço | Tipo | Nome | Descrição |
|--------|----------|------|------|-----------|
| 0x0000 | 0x0040 | R/W | Control/Status | Controle e Status |
| 0x0001 | 0x0041 | R/W | Data TX/RX | Dados TX/RX |
| 0x0002 | 0x0042 | R | Func/Addr | Função e Endereço recebidos |
| 0x0003 | 0x0043 | R/W | Holding Reg 0-1 | Registradores 0 e 1 |
| 0x0004 | 0x0044 | R/W | Holding Reg 2-3 | Registradores 2 e 3 |
| 0x0010 | 0x0050 | W | RX Addr | Simula recepção de endereço |
| 0x0011 | 0x0051 | W | RX Func | Simula recepção de função |
| 0x0012 | 0x0052 | W | RX Data H | Simula recepção de dado alto |
| 0x0013 | 0x0053 | W | RX Data L | Simula recepção de dado baixo |

### Registrador de Controle (0x0040)

**Escrita (Control Register)**

| Bit | Nome | Descrição |
|-----|------|-----------|
| 0 | START_RX_BIT | Inicia recepção de frame (auto-clear) |
| 1 | START_TX_BIT | Inicia transmissão (auto-clear) |
| 2 | ENABLE_BIT | Habilita módulo Modbus |
| 3-31 | - | Reservado |

**Leitura (Status Register)**

| Bit | Nome | Descrição |
|-----|------|-----------|
| 0 | RX_COMPLETE_BIT | Recepção completa |
| 1 | TX_COMPLETE_BIT | Transmissão completa |
| 2 | CRC_ERROR_BIT | Erro de CRC detectado |
| 3 | ADDR_MATCH_BIT | Endereço válido |
| 4-31 | - | Reservado |

### Registrador de Dados (0x0041)

**Leitura**: `[CRC_H][CRC_L][DATA_H][DATA_L]`
- Bits 31-24: CRC High recebido
- Bits 23-16: CRC Low recebido
- Bits 15-8: Data High recebido
- Bits 7-0: Data Low recebido

### Registrador de Função/Endereço (0x0042)

**Leitura**: `[0x0000][FUNCTION][ADDRESS]`
- Bits 15-8: Código da função recebida
- Bits 7-0: Endereço do escravo recebido

### Holding Registers (0x0043 - 0x0044)

Quatro registradores de 16 bits empacotados em duas palavras de 32 bits:
- **0x0043**: `[Reg1][Reg0]` - Registradores 1 e 0
- **0x0044**: `[Reg3][Reg2]` - Registradores 3 e 2

---

## Cálculo de CRC

### Algoritmo CRC-16 Modbus

O protocolo Modbus RTU utiliza **CRC-16** com polinômio **0xA001** (representação reversa de 0x8005).

#### Função `crc16_update`

```vhdl
function crc16_update(
    crc_in  : std_logic_vector(15 downto 0); 
    data_in : std_logic_vector(7 downto 0)
) return std_logic_vector
```

**Algoritmo**:
1. Inicializa CRC com valor anterior (`crc_in`)
2. XOR com o byte de dados
3. Para cada um dos 8 bits:
   - Se bit LSB = '1': shift right e XOR com 0xA001
   - Se bit LSB = '0': apenas shift right
4. Retorna CRC atualizado

**Características**:
- Valor inicial: **0xFFFF**
- Processamento: byte a byte, LSB primeiro
- Polinômio: **0xA001**
- O CRC transmitido é: **Low Byte, High Byte**

#### Exemplo de Cálculo

Para o frame `[01 03 00 01]`:

```
CRC = 0xFFFF
CRC = crc16_update(0xFFFF, 0x01)  // Processa endereço
CRC = crc16_update(CRC, 0x03)     // Processa função
CRC = crc16_update(CRC, 0x00)     // Processa data high
CRC = crc16_update(CRC, 0x01)     // Processa data low
// CRC final = 0xD5CA (exemplo)
// Transmitido como: [CA][D5]
```

---

## Testbench (tb_modbus.vhd)

### Arquitetura do Testbench

O testbench valida todas as funcionalidades do módulo Modbus RTU através de testes automatizados.

#### Constantes e Sinais

```vhdl
CLK_PERIOD : time := 20 ns  -- Clock de 50 MHz
BASE_ADDR  : unsigned := x"0040"
```

### Procedures Auxiliares

#### 1. `write_bus` - Escrita no Barramento

```vhdl
procedure write_bus(
    constant addr : in unsigned(15 downto 0);
    constant data : in std_logic_vector(31 downto 0)
)
```

**Funcionamento**:
1. Coloca endereço em `daddress`
2. Coloca dados em `ddata_w`
3. Ativa `d_we` por 1 ciclo
4. Aguarda estabilização

#### 2. `read_bus` - Leitura do Barramento

```vhdl
procedure read_bus(
    constant addr : in unsigned(15 downto 0)
)
```

**Funcionamento**:
1. Coloca endereço em `daddress`
2. Ativa `d_rd` por 1 ciclo
3. Dados aparecem em `ddata_r`
4. Aguarda estabilização

### Sequência de Testes

#### **Teste 1: Verificação de Reset**
```vhdl
-- Objetivo: Validar condições iniciais
rst <= '1';
wait 100 ns;
rst <= '0';
read_bus(0x0040);
assert ddata_r = x"00000000"
```
- Verifica se status register está zerado após reset
- Valida inicialização correta

#### **Teste 2: Escrita em Holding Registers**
```vhdl
-- Objetivo: Testar escrita e leitura de registradores
write_bus(0x0043, x"CAFEBEEF");  -- Reg0=0xBEEF, Reg1=0xCAFE
write_bus(0x0044, x"DEAD1234");  -- Reg2=0x1234, Reg3=0xDEAD
read_bus(0x0043);
assert ddata_r = x"CAFEBEEF"
```
- Escreve valores nos holding registers
- Lê de volta para confirmar gravação
- Valida integridade dos dados

#### **Teste 3: Simulação de Recepção Modbus**
```vhdl
-- Objetivo: Simular frame Modbus completo
write_bus(0x0050, x"00000001");  -- Endereço = 0x01
write_bus(0x0051, x"00000003");  -- Função = 0x03 (Read)
write_bus(0x0052, x"00000000");  -- Data High = 0x00
write_bus(0x0053, x"00000001");  -- Data Low = 0x01
```
- Simula recepção byte a byte de um frame Modbus
- Frame: Read Holding Register no endereço 0x0001

#### **Teste 4: Habilitação e Processamento**
```vhdl
-- Objetivo: Processar frame recebido
write_bus(0x0040, x"00000005");  -- ENABLE=1, START_RX=1
wait 500 ns;
read_bus(0x0040);  -- Lê status
```
- Habilita módulo Modbus
- Inicia processamento do frame
- Verifica conclusão através do status

#### **Teste 5: Simulação com Função Write**
```vhdl
-- Objetivo: Testar função 0x06 (Write Single Register)
write_bus(0x0050, x"00000001");  -- Addr
write_bus(0x0051, x"00000006");  -- Func = 0x06
write_bus(0x0052, x"00000000");  -- Register address
write_bus(0x0053, x"000000FF");  -- Value = 0xFF
write_bus(0x0040, x"00000005");  -- Processa
```
- Testa comando de escrita em registrador
- Valida processamento da função 0x06

#### **Teste 6: Validação de Endereço Inválido**
```vhdl
-- Objetivo: Verificar rejeição de endereço incorreto
write_bus(0x0050, x"00000099");  -- Addr inválido (0x99)
write_bus(0x0040, x"00000005");  -- Tenta processar
read_bus(0x0040);
-- Deve retornar para IDLE sem processar
```
- Envia frame com endereço não correspondente
- Verifica que FSM rejeita e retorna a IDLE
- Valida bit `ADDR_MATCH_BIT` = '0'

#### **Teste 7: Visualização de Debug**
```vhdl
-- Objetivo: Monitorar sinais de debug
-- debug_state e debug_crc visíveis na forma de onda
```
- Permite análise visual da FSM
- Monitora cálculo de CRC em tempo real

### Process de Monitoramento

```vhdl
monitor : process(clk)
begin
    if rising_edge(clk) then
        if debug_state /= "0000" then
            report "Estado: " & integer'image(to_integer(unsigned(debug_state)));
        end if;
    end if;
end process;
```

Imprime no console de simulação sempre que há mudança de estado.

---

## Fluxo de Operação

### Operação Típica de Leitura (Função 0x03)

#### 1. **Preparação do Sistema**
```
Processador → Escreve valores nos Holding Registers (0x0043-0x0044)
```

#### 2. **Recepção de Frame Modbus**
```
Mestre Modbus → [Addr=0x01][Func=0x03][RegAddr_H=0x00][RegAddr_L=0x01][CRC_L][CRC_H]
```

#### 3. **Processamento no VHDL**
```
a) Testbench simula recepção:
   write_bus(0x0050, 0x01)  // Endereço
   write_bus(0x0051, 0x03)  // Função
   write_bus(0x0052, 0x00)  // Registro High
   write_bus(0x0053, 0x01)  // Registro Low

b) Habilita processamento:
   write_bus(0x0040, 0x05)  // ENABLE + START_RX

c) FSM processa:
   IDLE → RX_ADDR (valida addr) → RX_FUNC → RX_DATA_H → RX_DATA_L 
   → RX_CRC_L → RX_CRC_H (valida CRC) → PROCESS_CMD 
   → TX_RESPONSE → DONE
```

#### 4. **Leitura de Resultado**
```
Processador → read_bus(0x0040)  // Verifica status
            → read_bus(0x0042)  // Lê função/endereço
            → read_bus(0x0043)  // Lê valor do registro
```

### Operação Típica de Escrita (Função 0x06)

#### 1. **Recepção de Frame Modbus**
```
Mestre → [Addr=0x01][Func=0x06][RegAddr=0x00][Value=0x1234][CRC]
```

#### 2. **Processamento**
```
FSM → Valida endereço → Valida CRC → PROCESS_CMD
```

#### 3. **Escrita no Registrador**
```
Processador → write_bus(0x0043, novo_valor)
```

#### 4. **Resposta**
```
FSM → Prepara confirmação → TX_RESPONSE → DONE
```

---

## Casos de Uso

### Caso 1: Sistema de Monitoramento Industrial

**Cenário**: Monitorar temperatura e pressão de um processo

```vhdl
-- Setup inicial
holding_registers(0) <= temperatura (16 bits)
holding_registers(1) <= pressao (16 bits)

-- Mestre Modbus envia:
[01][03][00][00][CRC]  // Lê registrador 0 (temperatura)

-- Processamento:
FSM → Valida → Retorna valor de temperatura

-- Próxima leitura:
[01][03][00][01][CRC]  // Lê registrador 1 (pressão)
```

### Caso 2: Controle de Atuador

**Cenário**: Controlar válvula através de comando Modbus

```vhdl
-- Mestre envia comando:
[01][06][00][02][00][FF][CRC]  // Escreve 0xFF no registro 2

-- Processamento:
FSM → Valida CRC → PROCESS_CMD
Processador → Escreve 0xFF no holding_register(2)
FPGA → Ativa válvula baseado no valor do registro

-- Confirmação:
FSM → TX_RESPONSE com echo do comando
```

### Caso 3: Broadcast

**Cenário**: Envio de comando para múltiplos dispositivos

```vhdl
-- Mestre envia com endereço broadcast:
[00][06][00][00][12][34][CRC]  // Addr = 0x00 (broadcast)

-- Todos dispositivos:
FSM → Aceita (addr_match) → Processa comando
      Não envia resposta (característica de broadcast)
```

---

## Análise de Desempenho

### Timing da FSM

- **Ciclos por estado**: 1 ciclo de clock
- **Latência total** (IDLE → DONE): ~10 ciclos
- **Throughput**: Limitado pela simulação de recepção serial

### Recursos FPGA Estimados

- **Flip-flops**: ~200-300 (registradores + FSM)
- **LUTs**: ~150-250 (lógica combinacional + CRC)
- **Block RAM**: 0 (registradores implementados em FF)
- **Frequência máxima**: >100 MHz (dependente da FPGA)

---

## Limitações e Melhorias Futuras

### Limitações Atuais

1. **Simulação de Recepção**: Bytes são escritos via barramento ao invés de interface UART real
2. **Transmissão**: Não há implementação completa de TX serial
3. **Funções Limitadas**: Apenas 0x03 e 0x06 implementadas
4. **Sem Buffer**: Não há buffer FIFO para múltiplos frames
5. **CRC Manual**: CRC não é automaticamente validado na recepção real

### Melhorias Propostas

1. **Interface UART Real**
   - Adicionar módulo UART RX/TX
   - Implementar detecção de frame (timeout 3.5 caracteres)

2. **Mais Funções Modbus**
   - 0x01: Read Coils
   - 0x02: Read Discrete Inputs
   - 0x04: Read Input Registers
   - 0x05: Write Single Coil
   - 0x0F: Write Multiple Coils
   - 0x10: Write Multiple Registers

3. **Buffer FIFO**
   - Implementar buffer para recepção
   - Buffer de transmissão para respostas

4. **Modo Mestre**
   - Adicionar capacidade de iniciar transações
   - Gerenciamento de múltiplos escravos

5. **Exceções Modbus**
   - Implementar códigos de exceção (0x01-0x04)
   - Tratamento de erros mais robusto

---

## Script Python: CRC Calculator (crc_calculator.py)

### Visão Geral

O `crc_calculator.py` é uma ferramenta auxiliar desenvolvida em Python para facilitar o desenvolvimento, validação e testes do periférico Modbus RTU em VHDL. Este script oferece funcionalidades para calcular e validar CRC-16 Modbus, gerar frames completos e criar vetores de teste para uso em testbenches.

### Objetivo no Projeto

O script tem três objetivos principais:

1. **Validação de Implementação**: Confirmar que o algoritmo CRC implementado em VHDL está correto comparando resultados
2. **Geração de Vetores de Teste**: Criar automaticamente frames Modbus válidos para usar em testbenches
3. **Debug Interativo**: Permitir análise rápida de frames durante desenvolvimento e depuração

### Funcionalidades

#### 1. Cálculo de CRC-16 Modbus

```python
from crc_calculator import crc16_modbus

data = [0x01, 0x03, 0x00, 0x00, 0x00, 0x01]
crc = crc16_modbus(data)  # Retorna: 0x840A
```

O algoritmo implementa o padrão CRC-16 Modbus:
- **Polinômio**: 0xA001 (reverso de 0x8005)
- **Valor inicial**: 0xFFFF
- **Reflexão**: LSB primeiro
- **XOR final**: Nenhum

#### 2. Formatação de Frames Completos

```python
from crc_calculator import format_frame

# Gera frame: [endereço, função, dados..., crc_low, crc_high]
frame = format_frame(
    address=0x01,      # Endereço do escravo
    function=0x03,     # Read Holding Registers
    data_bytes=[0x00, 0x00, 0x00, 0x01]  # Dados
)
# Resultado: [0x01, 0x03, 0x00, 0x00, 0x00, 0x01, 0x0A, 0x84]
```

#### 3. Modo Interativo

Execute o script sem argumentos para acessar o modo interativo:

```bash
python3 crc_calculator.py
```

Opções disponíveis:
- **Opção 1**: Calcular CRC de bytes hexadecimais
- **Opção 2**: Gerar frame Modbus completo com CRC
- **Opção 3**: Validar frame recebido (verifica CRC)
- **Opção 4**: Gerar vetores de teste pré-definidos

#### 4. Modo Linha de Comando

Cálculo rápido de CRC via linha de comando:

```bash
python3 crc_calculator.py 01 03 00 00 00 01
# Output: 0x840A
```

#### 5. Geração de Vetores de Teste

A função `generate_test_vectors()` cria frames Modbus comuns e gera código VHDL pronto para uso em testbenches:

```python
generate_test_vectors()
```

Saída exemplo:
```
Read 1 register at 0x0000
------------------------------------------------------------
Frame Modbus:
============================================================
Hex: 01 03 00 00 00 01 0A 84
Dec:   1   3   0   0   0   1  10 132
============================================================

Código VHDL para testbench:
write_bus(BASE_ADDR + x"0010", x"00000001", daddress, ddata_w, d_we);
write_bus(BASE_ADDR + x"0011", x"00000003", daddress, ddata_w, d_we);
write_bus(BASE_ADDR + x"0012", x"00000000", daddress, ddata_w, d_we);
write_bus(BASE_ADDR + x"0013", x"00000000", daddress, ddata_w, d_we);
-- CRC esperado: 0x840A
-- CRC Low: 0x0A, CRC High: 0x84
```

### Casos de Uso no Desenvolvimento

#### Caso 1: Validar Implementação VHDL

```bash
# Durante simulação no ModelSim, você observa:
# calculated_crc = 0x840A para frame [01 03 00 00 00 01]

# Validar com Python:
python3 crc_calculator.py 01 03 00 00 00 01
# Output: 0x840A ✓ Implementação correta!
```

#### Caso 2: Criar Teste para Testbench

```python
# Gerar frame Write Single Register
frame = format_frame(0x01, 0x06, [0x00, 0x00, 0x12, 0x34])
print_frame(frame)

# Copiar código VHDL gerado diretamente para tb_modbus.vhd
```

#### Caso 3: Debug de Frame Incorreto

```bash
# Frame recebido na simulação parece estar com CRC errado
python3 crc_calculator.py
# Opção 3: Validar frame recebido
# Digite: 01 03 00 00 00 01 FF FF
# Output: CRC: 0xFFFF ✗
#         Esperado: 0x840A
```

### Integração com o Testbench

O script foi projetado para trabalhar em conjunto com `tb_modbus.vhd`:

1. **Geração de Estímulos**: Cria frames válidos para teste
2. **Validação de Resultados**: Confirma CRCs calculados pelo VHDL
3. **Documentação**: Gera comentários explicativos para testbench

### Funções Modbus Suportadas

O script identifica e documenta as seguintes funções:

| Código | Nome | Descrição |
|--------|------|-----------|
| 0x01 | Read Coils | Leitura de coils (saídas digitais) |
| 0x02 | Read Discrete Inputs | Leitura de entradas discretas |
| 0x03 | Read Holding Registers | Leitura de registradores |
| 0x04 | Read Input Registers | Leitura de registradores de entrada |
| 0x05 | Write Single Coil | Escrita de coil único |
| 0x06 | Write Single Register | Escrita de registrador único |
| 0x0F | Write Multiple Coils | Escrita de múltiplos coils |
| 0x10 | Write Multiple Registers | Escrita de múltiplos registradores |

### Exemplo de Uso Completo

```bash
# 1. Gerar vetores de teste
python3 crc_calculator.py
> 4

# 2. Copiar código VHDL gerado para testbench

# 3. Executar simulação no ModelSim

# 4. Validar CRCs observados na simulação
python3 crc_calculator.py 01 06 00 01 CA FE
# Confirmar que match com calculated_crc no VHDL
```

### Dependências

- Python 3.6 ou superior
- Sem bibliotecas externas (usa apenas biblioteca padrão)

### Executável como Módulo

Pode ser importado em outros scripts Python:

```python
from crc_calculator import crc16_modbus, format_frame, print_frame

# Uso programático
frame = format_frame(0x01, 0x03, [0x00, 0x00, 0x00, 0x01])
crc = crc16_modbus(frame[:-2])
```

---

## Referências

- **Modbus Protocol Specification**: [modbus.org](http://www.modbus.org)
- **CRC-16 Modbus**: Polynomial 0xA001 (reversed 0x8005)
- **VHDL IEEE Std 1076-2008**

---
