from math import e
def twos_complement(val: int, n_bits: int) -> str:
    val = 2**n_bits + val
    return f"{{0:0{n_bits}b}}".format(val)[-n_bits:]

def sigmoidal(val: float) -> float:
    return 1 / (1 + e**-val)

def tanh(val: float) -> float:
    raise NotImplementedError()

def heaviside(val: float) -> float:
    if val > 0:
        return 1
    else:
        return 0

def scale_to_full_range(val: float, n_bits) -> int:
    return int(val * (2**n_bits//2 -1))

n_bits: int = 8
#f = sigmoidal
f = heaviside
prefix = '			'
for i in range(-2**n_bits//2, 2**n_bits//2):
    #print(i, twos_complement(i, n_bits))
    #print(i, scale_to_full_range(f(i), n_bits))
    val = scale_to_full_range(f(i), n_bits)
    print(f'{prefix}when "{twos_complement(i, n_bits)}" => output <= "{twos_complement(val, n_bits)}";	-- {i}')