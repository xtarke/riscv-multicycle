# Geração de Música com Motor de Passo

## Descrição

Este projeto utiliza um motor de passo para gerar sons em diferentes frequências, permitindo a criação de músicas através do controle da velocidade de rotação do motor. A proposta é transformar movimentos mecânicos em sons audíveis, que são organizados para formar melodias como, por exemplo, a **Marcha Imperial**.

## Funcionamento

O sistema controla o motor de passo programaticamente, definindo:

- **Velocidade de rotação** (corresponde à nota musical)
- **Tempo de execução da nota**
- **Tempo de pausa entre as notas**
- **Modo de acionamento** (full step ou half step)
- **Sentido de rotação**

A geração de som ocorre porque o motor, ao vibrar em diferentes velocidades, produz frequências audíveis. A mudança de velocidade altera a nota musical percebida.

## Funcionalidades

1. **Tocar Nota**  
   - Função `t_tocar_nota(velocidade, t_nota, t_pausa)`  
     Define a velocidade (nota), o tempo da nota e o tempo da pausa.
   - Função `tocar_nota(velocidade)`  
     Versão simplificada com tempos fixos.

2. **Controle do Motor** (via `step_motor.h`):  
   - `change_speed()`: altera a velocidade do motor  
   - `stop_motor(0 ou 1)`: inicia ou para o motor  
   - `reset_motor()`: reinicializa o motor  
   - `change_step()`: define o modo de passo (ex: full step)  
   - `reverse_rotation()`: muda o sentido da rotação  
   - `delay_()`: insere um atraso no tempo (nota ou pausa)

3. **Mapeamento das Notas**  
   As notas musicais são associadas a velocidades específicas:
   ```c
   // DO RE MI FA SOL LA SI DO
   //  0  1  2  3  4   5  6  7

4. **Estrutura do Código main()**
  - Reinicia o motor
  - Configura para full step e rotação anti-horária
  - Executa uma sequência de notas com t_tocar_nota() para formar a melodia
  - Após uma pausa, toca a Marcha Imperial, utilizando novamente a função t_tocar_nota() com velocidades diferentes para representar cada nota

5. **Exemplo de trecho musical**
    ```c
    t_tocar_nota(5,120000,1000); // LA
    t_tocar_nota(3,100000,2000); // FA
    t_tocar_nota(0,50000,500);  // DO
    
Esse padrão se repete para compor toda a música.

   **Conclusão**

  Este projeto demonstra como é possível transformar um motor de passo em uma ferramenta musical através do controle preciso de sua velocidade. Ao variar a frequência de acionamento, é possível gerar notas distintas e formar melodias completas. É um excelente exemplo de aplicação interdisciplinar, envolvendo eletrônica, programação e música, com grande potencial didático e criativo.