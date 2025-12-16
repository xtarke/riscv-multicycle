#!/usr/bin/env python3
"""
Calculadora de CRC16 Modbus
Ferramenta auxiliar para validar cálculos de CRC na simulação

Uso:
    python3 crc_calculator.py  
Ou importar como módulo:
    from crc_calculator import crc16_modbus
"""

def crc16_modbus(data):
    """
    Calcula CRC-16 Modbus para uma sequência de bytes
    Args:
        data: lista de bytes ou bytearray
        
    Returns:
        int: CRC calculado (16 bits)
    """
    crc = 0xFFFF
    
    for byte in data:
        crc ^= byte
        
        for _ in range(8):
            if crc & 0x0001:
                crc = (crc >> 1) ^ 0xA001
            else:
                crc >>= 1
    
    return crc


def format_frame(address, function, data_bytes):
    """
    Formata um frame Modbus completo com CRC
    
    Args:
        address: endereço do escravo (0x01-0xF7)
        function: código da função (0x01-0x7F)
        data_bytes: lista de bytes de dados
        
    Returns:
        list: frame completo [addr, func, data..., crc_low, crc_high]
    """
    frame = [address, function] + list(data_bytes)
    crc = crc16_modbus(frame)
    
    crc_low = crc & 0xFF
    crc_high = (crc >> 8) & 0xFF
    
    return frame + [crc_low, crc_high]


def print_frame(frame):
    """Imprime frame em formato legível"""
    print("Frame Modbus:")
    print("=" * 60)
    print(f"Hex: {' '.join(f'{b:02X}' for b in frame)}")
    print(f"Dec: {' '.join(f'{b:3d}' for b in frame)}")
    print("=" * 60)
    
    if len(frame) >= 2:
        print(f"Endereço:  0x{frame[0]:02X} ({frame[0]})")
        print(f"Função:    0x{frame[1]:02X} ({frame[1]}) - {function_name(frame[1])}")
    
    if len(frame) >= 4:
        data_end = len(frame) - 2
        data = frame[2:data_end]
        print(f"Dados:     {' '.join(f'{b:02X}' for b in data)}")
    
    if len(frame) >= 2:
        crc_received = frame[-2] | (frame[-1] << 8)
        crc_calculated = crc16_modbus(frame[:-2])
        valid = "✓" if crc_received == crc_calculated else "✗"
        print(f"CRC:       0x{crc_received:04X} {valid}")
        if crc_received != crc_calculated:
            print(f"Esperado:  0x{crc_calculated:04X}")


def function_name(code):
    """Retorna nome da função Modbus"""
    functions = {
        0x01: "Read Coils",
        0x02: "Read Discrete Inputs",
        0x03: "Read Holding Registers",
        0x04: "Read Input Registers",
        0x05: "Write Single Coil",
        0x06: "Write Single Register",
        0x0F: "Write Multiple Coils",
        0x10: "Write Multiple Registers"
    }
    return functions.get(code, "Unknown")


def generate_test_vectors():
    """Gera vetores de teste comuns"""
    test_vectors = [
        # (descrição, endereço, função, dados)
        ("Read 1 register at 0x0000", 0x01, 0x03, [0x00, 0x00, 0x00, 0x01]),
        ("Read 2 registers at 0x0000", 0x01, 0x03, [0x00, 0x00, 0x00, 0x02]),
        ("Write 0x1234 to register 0x0000", 0x01, 0x06, [0x00, 0x00, 0x12, 0x34]),
        ("Write 0xCAFE to register 0x0001", 0x01, 0x06, [0x00, 0x01, 0xCA, 0xFE]),
        ("Broadcast read", 0x00, 0x03, [0x00, 0x00, 0x00, 0x01]),
    ]
    
    print("\n" + "=" * 60)
    print("VETORES DE TESTE MODBUS")
    print("=" * 60 + "\n")
    
    for desc, addr, func, data in test_vectors:
        print(f"\n{desc}")
        print("-" * 60)
        frame = format_frame(addr, func, data)
        print_frame(frame)
        
        # Gerar código VHDL para testbench
        print("\nCódigo VHDL para testbench:")
        print(f"write_bus(BASE_ADDR + x\"0010\", x\"{addr:08X}\", daddress, ddata_w, d_we);")
        print(f"write_bus(BASE_ADDR + x\"0011\", x\"{func:08X}\", daddress, ddata_w, d_we);")
        if len(data) >= 2:
            print(f"write_bus(BASE_ADDR + x\"0012\", x\"{data[0]:08X}\", daddress, ddata_w, d_we);")
            print(f"write_bus(BASE_ADDR + x\"0013\", x\"{data[1]:08X}\", daddress, ddata_w, d_we);")
        
        crc = crc16_modbus([addr, func] + data)
        print(f"-- CRC esperado: 0x{crc:04X}")
        print(f"-- CRC Low: 0x{crc & 0xFF:02X}, CRC High: 0x{(crc >> 8) & 0xFF:02X}")


def interactive_mode():
    """Modo interativo para calcular CRC"""
    print("\n" + "=" * 60)
    print("CALCULADORA INTERATIVA DE CRC16 MODBUS")
    print("=" * 60 + "\n")
    
    while True:
        print("\nOpções:")
        print("1. Calcular CRC de bytes hexadecimais")
        print("2. Gerar frame completo")
        print("3. Validar frame recebido")
        print("4. Gerar vetores de teste")
        print("0. Sair")
        
        choice = input("\nEscolha uma opção: ").strip()
        
        if choice == '0':
            break
            
        elif choice == '1':
            hex_input = input("Digite bytes em hex (ex: 01 03 00 01): ").strip()
            try:
                bytes_data = [int(b, 16) for b in hex_input.split()]
                crc = crc16_modbus(bytes_data)
                print(f"\nCRC: 0x{crc:04X}")
                print(f"CRC Low:  0x{crc & 0xFF:02X}")
                print(f"CRC High: 0x{(crc >> 8) & 0xFF:02X}")
            except ValueError:
                print("Erro: entrada inválida")
                
        elif choice == '2':
            try:
                addr = int(input("Endereço do escravo (hex, ex: 01): "), 16)
                func = int(input("Código da função (hex, ex: 03): "), 16)
                data_input = input("Bytes de dados (hex, ex: 00 00 00 01): ").strip()
                data = [int(b, 16) for b in data_input.split()] if data_input else []
                
                frame = format_frame(addr, func, data)
                print()
                print_frame(frame)
            except ValueError:
                print("Erro: entrada inválida")
                
        elif choice == '3':
            hex_input = input("Digite frame completo (hex): ").strip()
            try:
                frame = [int(b, 16) for b in hex_input.split()]
                if len(frame) < 4:
                    print("Erro: frame muito curto")
                else:
                    print()
                    print_frame(frame)
            except ValueError:
                print("Erro: entrada inválida")
                
        elif choice == '4':
            generate_test_vectors()


def main():
    """Função principal"""
    import sys
    
    if len(sys.argv) > 1:
        # Modo linha de comando
        try:
            bytes_data = [int(b, 16) for b in sys.argv[1:]]
            crc = crc16_modbus(bytes_data)
            print(f"0x{crc:04X}")
        except ValueError:
            print("Uso: python3 crc_calculator.py [bytes em hex]")
            print("Exemplo: python3 crc_calculator.py 01 03 00 01")
            sys.exit(1)
    else:
        # Modo interativo
        try:
            interactive_mode()
        except KeyboardInterrupt:
            print("\n\nEncerrando...")
        except Exception as e:
            print(f"\nErro: {e}")
            import traceback
            traceback.print_exc()


if __name__ == "__main__":
    main()
