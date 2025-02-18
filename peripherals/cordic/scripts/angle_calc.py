import math

# Definindo o ângulo de 45 graus
angulo_graus = 45
angulo_radianos = math.radians(angulo_graus)

print(angulo_radianos)

# Calculando seno e cosseno
seno = math.sin(angulo_radianos)
cosseno = math.cos(angulo_radianos)

# Escalonando para 16 bits (multiplicando por 16384)
escala = 16384
seno_esc = int(seno * escala)
cosseno_esc = int(cosseno * escala)

# Convertendo para hexadecimal
seno_hex = hex(seno_esc)
cosseno_hex = hex(cosseno_esc)

print(seno_esc, cosseno_esc, seno_hex, cosseno_hex)
