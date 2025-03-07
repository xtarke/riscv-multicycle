import math
import sys

if len(sys.argv) != 2:
    print("Usage: python3 angle_calc.py <angle_in_degrees>")
    sys.exit(1)

try:
    angle_deg = float(sys.argv[1])
except ValueError:
    print("Error: The argument must be a valid number.")
    sys.exit(1)

angle_radians = math.radians(angle_deg)

print(f'Angle (rads): {angle_radians:.4f}')


sine = math.sin(angle_radians)
cosine = math.cos(angle_radians)

scale = 16384
sine_scaled = int(sine * scale)
cosine_scaled = int(cosine * scale)

def to_signed_16bit(val):
    if val < 0:
        val = (1 << 16) + val  # Convert negative to 2's complement
    return val

sine_scaled = to_signed_16bit(sine_scaled)
cosine_scaled = to_signed_16bit(cosine_scaled)

# print(f'Hex in: {hex(int(to_signed_16bit(angle_radians)))}')
print("Scaled values: ")
print(f"Angle in: {int(scale*angle_radians)}")

sine_hex = hex(sine_scaled)
cosine_hex = hex(cosine_scaled)

print(f"Fixed values: {sine_scaled} {cosine_scaled}")
print(f"HEX values: {sine_hex} {cosine_hex}")
