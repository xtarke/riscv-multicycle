import math
import sys

# Check if an argument was provided
if len(sys.argv) != 2:
    print("Usage: python3 angle_calc.py <angle_in_degrees>")
    sys.exit(1)

# Get the angle from the command-line argument
try:
    angle_deg = float(sys.argv[1])
except ValueError:
    print("Error: The argument must be a valid number.")
    sys.exit(1)

angle_radians = math.radians(angle_deg)

print(f'Angle (rads): {angle_radians:.4f}')

sine = math.sin(angle_radians)
cosine = math.cos(angle_radians)

# 16-bit scaling
scale = 16384
sine_scaled = int(sine * scale)
cosine_scaled = int(cosine * scale)

sine_hex = hex(sine_scaled)
cosine_hex = hex(cosine_scaled)

print(f"Fixed values: {sine_scaled} {cosine_scaled}\nHEX values: {sine_hex} {cosine_hex}")
