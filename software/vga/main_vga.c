/* Black-fill first (visible "program started" marker), then draw the
 * 8 full-screen vertical color bars once. LEDs: 1=boot, 3=cleared, 0x1F=done. */
#include "../_core/utils.h"
#include "../_core/hardware.h"
#define LEDS (*(_IO32 *) (PERIPH_BASE + 4))
#define W 640
#define H 480

int main(){
	volatile uint32_t *vga = &SDRAM;
	const uint16_t bars[8] = {
		0x0000, 0x0F00, 0x00F0, 0x0FF0,
		0x000F, 0x0F0F, 0x00FF, 0x0FFF
	};
	uint32_t i, x, y, bar, cnt, addr;

	LEDS = 0x01;
	for (i = 0; i < W * H; i++)
		vga[i] = 0x0000;
	LEDS = 0x03;

	addr = 0;
	for (y = 0; y < H; y++) {
		bar = 0; cnt = 0;
		for (x = 0; x < W; x++) {
			vga[addr++] = bars[bar];
			if (++cnt == 80) { cnt = 0; bar++; }
		}
	}
	LEDS = 0x1F;

	while (1);
	return 0;
}
