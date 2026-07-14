#include "_core/utils.h"
#include "_core/hardware.h"
#include "gpio/gpio.h"


#define SEM_TECLA 16
#define TECLA_A 10
#define TECLA_B 11
#define TECLA_C 12
#define TECLA_D 13
#define TECLA_ZERO 15


#define TECLA_IGUAL 14

#define SOMA 1
#define SUB 2
#define MUL 3
#define DIV 4
#define ZERAR 5


// FUNCOES DO TECLADO

int ler_teclado() {
    return KEYBOARD_BASE_ADDRESS & 0x1F;
}

int esperar_tecla() {
    int tecla;
    
    do {
        tecla = ler_teclado();
    } while (tecla == SEM_TECLA);
    
    delay_(100);
    
    while (ler_teclado() != SEM_TECLA) {
        delay_(50);
    }
    
    delay_(100);
    return tecla;
}

// FUNCOES DO DISPLAY

void mostrar_numero(int valor) {
    unsigned int saida = 0;
    int pos = 0;
    int digito;
    
    if (valor < 0) valor = -valor;
    if (valor == 0) {
        SEGMENTS_BASE_ADDRESS = 0;
        return;
    }
    
    while (valor > 0 && pos < 6) {
        digito = valor % 10;
        saida = saida | (digito << (pos * 4));
        valor = valor / 10;
        pos++;
    }
    
    SEGMENTS_BASE_ADDRESS = saida;
}

// FUNCOES DO LED/GPIO

int valor_led_operacao(int op) {
    if (op == SOMA) {
        return 0x01;   // LED 0
    } else if (op == SUB) {
        return 0x02;   // LED 1
    } else if (op == MUL) {
        return 0x04;   // LED 2
    } else if (op == DIV) {
        return 0x08;   // LED 3
    } else {
        return 0x00;
    }
}



void mostrar_operacao_led(int op) {
    int valor;
    int i;

    valor = valor_led_operacao(op);

    if (valor == 0x00) {
        OUTBUS = 0x00;
        return;
    }

    for (i = 0; i < 3; i++) {
        OUTBUS = valor;
        delay_(300);
        OUTBUS = 0x00;
        delay_(300);
    }

    OUTBUS = valor;
}




// MAIN


int main() {


    int tecla;
    int num_atual = 0;
    int num_ant = 0;
    int op = 0;
    int res = 0;

    OUTBUS = 0x00;    
    mostrar_numero(0);
    
    
    while (1) {
        tecla = esperar_tecla();

        
        // Numeros 0-9
        if (tecla >= 0 && tecla <= 9) {
            num_atual = num_atual * 10 + tecla;
            mostrar_numero(num_atual);
        }
        
        // Operacao SOMA (tecla A)
        else if (tecla == TECLA_A) {
            num_ant = num_atual;
            num_atual = 0;
            op = SOMA;
            mostrar_numero(num_ant);
	    mostrar_operacao_led(op);
        }

	// Operacao SUB (tecla B)
        else if (tecla == TECLA_B) {
            num_ant = num_atual;
            num_atual = 0;
            op = SUB;
            mostrar_numero(num_ant);
	    mostrar_operacao_led(op);
        }
        
	// Operacao MUL (tecla C)
        else if (tecla == TECLA_C) {
            num_ant = num_atual;
            num_atual = 0;
            op = MUL;
            mostrar_numero(num_ant);
	    mostrar_operacao_led(op);
        }

	// Operacao MUL (tecla D)
        else if (tecla == TECLA_D) {
            num_ant = num_atual;
            num_atual = 0;
            op = DIV;
            mostrar_numero(num_ant);
	    mostrar_operacao_led(op);
        }

	// Operacao ZERAR (tecla ZERO)
        else if (tecla == TECLA_ZERO) {
            num_ant = num_atual;
            num_atual = 0;
            op = ZERAR;
            mostrar_numero(num_ant);
            OUTBUS = 0x00;
        }

        // Igual
        else if (tecla == TECLA_IGUAL) {
	    if (op == SOMA) {
            res = num_ant + num_atual;
	  } else if (op == SUB) {
	    res = num_ant - num_atual;
	  } else if (op == MUL) {
	    res = num_ant * num_atual;
	  } else if (op == DIV) {
	    res = num_ant / num_atual;
	  } else if (op == ZERAR) {
	    res = 0;
	  }
	
            num_atual = res;
            mostrar_numero(res);
            num_ant = 0;
            op = 0;
	    OUTBUS = 0x00;
        }
    }
    
    return 0;
}