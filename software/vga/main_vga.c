/* Blitter demo: the 2D accelerator's FILL_RECT clears the screen and draws a
 * few solid rectangles. The CPU stages the command in the blitter's register
 * block (generic slots P0..P5 + COLOR) and writes CMD to launch; the hardware
 * generates the pixel writes. LEDs: 1=boot, 0x1F=done.
 *
 * Command word (128-bit fifo entry): FILL uses P0=x P1=y P2=w P3=h COLOR=color.
 */
#include "../_core/utils.h"
#include "../_core/hardware.h"
#define LEDS (*(_IO32 *) (PERIPH_BASE + 4))

/* Blitter register block (I/O space, word addresses 256..263) */
#define BLIT_P0    (*(_IO32 *) (PERIPH_BASE + 256 * 4))
#define BLIT_P1    (*(_IO32 *) (PERIPH_BASE + 257 * 4))
#define BLIT_P2    (*(_IO32 *) (PERIPH_BASE + 258 * 4))
#define BLIT_P3    (*(_IO32 *) (PERIPH_BASE + 259 * 4))
#define BLIT_P4    (*(_IO32 *) (PERIPH_BASE + 260 * 4))
#define BLIT_P5    (*(_IO32 *) (PERIPH_BASE + 261 * 4))
#define BLIT_COLOR (*(_IO32 *) (PERIPH_BASE + 262 * 4))
#define BLIT_CMD   (*(_IO32 *) (PERIPH_BASE + 263 * 4))
#define BLIT_STAT  (*(_IO32 *) (PERIPH_BASE + 256 * 4))  /* read: bit0 = busy */
#define OP_FILL 1

static void blit_wait(void) { while (BLIT_STAT & 1) ; }

/* Queue one filled rectangle (blocks until the previous one is done) */
static void blit_fill(uint32_t x, uint32_t y, uint32_t w, uint32_t h, uint16_t color)
{
	blit_wait();
	BLIT_P0 = x;
	BLIT_P1 = y;
	BLIT_P2 = w;
	BLIT_P3 = h;
	BLIT_COLOR = color;
	BLIT_CMD = OP_FILL;      /* launch */
}

int main(){
	LEDS = 0x01;

	blit_fill(0,   0,   640, 480, 0x0000);   /* clear to black        */
	blit_fill(40,  40,  200, 150, 0x0F00);   /* rectangle             */
	blit_fill(320, 90,  260, 200, 0x00F0);   /* rectangle             */
	blit_fill(140, 260, 300, 160, 0x000F);   /* rectangle             */
	blit_fill(260, 180, 120, 120, 0x0FFF);   /* overlapping white box */
	blit_wait();

	LEDS = 0x1F;
	while (1);
	return 0;
}
