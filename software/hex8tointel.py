#!/usr/bin/env python3

import fileinput
import itertools

ptr = 0
data = []
hexAddr = 0

def write_data():
    
    global hexAddr
    
    if len(data) != 0:
        # print("@%08x" % (ptr >> 2))
        while len(data) % 4 != 0:
            data.append(0)
        for word_bytes in zip(*([iter(data)]*4)):
            # print('---')
            
            crc = 0
            for byte in reversed(word_bytes):
                crc = crc + byte             
                        
            crc = ~(4 + (hexAddr & 0x00ff) + ((hexAddr >> 8) & 0x00ff) + crc) + 1            
            crc = crc & (0xff)            
                                    
            # :04 00 0400 240c0000 c8            
            print(':04' + ''.join(["%04x" % hexAddr]) + '00' + 
                                  ''.join(["%02x" % b for b in reversed(word_bytes)]) + 
                                  ''.join(['%02x' % crc]))
            # print(word_bytes)
            # print(''.join('{:02x}'.format(x) for x in hexAddr) + "'")
            #print(''.join(["%04x" % hexAddr]))            
            hexAddr = hexAddr + 1        
            

for line in fileinput.input():
    if line.startswith("@"):
        addr = int(line[1:], 16)
        if addr > ptr+4:
            write_data()
            ptr = addr
            data = []
            while ptr % 4 != 0:
                data.append(0)
                ptr -= 1
        else:
            while ptr + len(data) < addr:
                data.append(0)
    else:
        data += [int(tok, 16) for tok in line.split()]

write_data()
print(':00000001FF')


 
