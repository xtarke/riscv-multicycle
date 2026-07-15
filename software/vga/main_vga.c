#include "../_core/utils.h"
#include "../_core/hardware.h"
#define LEDS (*(_IO32 *) (PERIPH_BASE + 4))

#define BLIT_P0    (*(_IO32 *) (PERIPH_BASE + 256 * 4))
#define BLIT_P1    (*(_IO32 *) (PERIPH_BASE + 257 * 4))
#define BLIT_P2    (*(_IO32 *) (PERIPH_BASE + 258 * 4))
#define BLIT_P3    (*(_IO32 *) (PERIPH_BASE + 259 * 4))
#define BLIT_COLOR (*(_IO32 *) (PERIPH_BASE + 262 * 4))
#define BLIT_CMD   (*(_IO32 *) (PERIPH_BASE + 263 * 4))
#define BLIT_STAT  (*(_IO32 *) (PERIPH_BASE + 256 * 4))
#define OP_FILL 1
#define OP_LINE 2

#define FRAME_30HZ 1334

static void blit_wait(void) { while (BLIT_STAT & 1) ; }

static void push_fill(uint32_t x, uint32_t y, uint32_t w, uint32_t h, uint16_t color)
{
	BLIT_P0 = x; BLIT_P1 = y; BLIT_P2 = w; BLIT_P3 = h;
	BLIT_COLOR = color;
	BLIT_CMD = OP_FILL;
}

static void blit_fill(uint32_t x, uint32_t y, uint32_t w, uint32_t h, uint16_t color)
{
	blit_wait();
	push_fill(x, y, w, h, color);
}

static voi2d blit_line(uint32_t x0, uint32_t y0, uint32_t x1, uint32_t y1, uint16_t color)
{
	blit_wait();
	BLIT_P0 = x0; BLIT_P1 = y0; BLIT_P2 = x1; BLIT_P3 = y1;
	BLIT_COLOR = color;
	BLIT_CMD = OP_LINE;
}

/* Wireframe cube: front square + back square (offset up-right) + 4 edges */
static void draw_cube(uint32_t x, uint32_t y, uint32_t s, uint32_t d, uint16_t color)
{
	/* front face */
	blit_line(x,     y,     x + s, y,     color);
	blit_line(x + s, y,     x + s, y + s, color);
	blit_line(x + s, y + s, x,     y + s, color);
	blit_line(x,     y + s, x,     y,     color);
	/* back face (shifted by +d,-d) */
	blit_line(x + d,     y - d,     x + s + d, y - d,     color);
	blit_line(x + s + d, y - d,     x + s + d, y + s - d, color);
	blit_line(x + s + d, y + s - d, x + d,     y + s - d, color);
	blit_line(x + d,     y + s - d, x + d,     y - d,     color);
	/* connecting edges */
	blit_line(x,     y,     x + d,     y - d,     color);
	blit_line(x + s, y,     x + s + d, y - d,     color);
	blit_line(x,     y + s, x + d,     y + s - d, color);
	blit_line(x + s, y + s, x + s + d, y + s - d, color);
}

int main(){
	int rx, ry, dx, dy;
	int cr = 15, cg = 15, cb = 15;   /* R/G/B channels (0..15), start at max */
	int rc = 0, gc = 0, bc = 0;      /* per-channel frame counters           */
	uint16_t rect_col;
	const int RW = 60, RH = 40;

	LEDS = 0x01;

	/* --- FILL test --- */
	blit_fill(0,   0,   640, 480, 0x0000);   /* clear */
	blit_fill(40,  40,  200, 150, 0x0F00);
	blit_fill(320, 90,  260, 200, 0x00F0);
	blit_fill(140, 260, 300, 160, 0x000F);
	blit_fill(260, 180, 120, 120, 0x0FFF);
	blit_wait();
	LEDS = 0x03;

	delay_(80000);

	/* --- CUBE (drawn with lines) --- */
	blit_fill(0, 0, 640, 480, 0x0000);       /* clear */
	draw_cube(200, 180, 160, 80, 0x0FFF);
	blit_wait();
	LEDS = 0x1F;

	delay_(200000);

	blit_fill(0, 0, 640, 480, 0x0000);       /* clear */
	rx = 100; ry = 100; dx = 5; dy = 4;
	rect_col = (cb << 8) | (cg << 4) | cr;
	blit_fill(rx, ry, RW, RH, rect_col);
	while (1) {
		int ox = rx, oy = ry;
		rx += dx; ry += dy;
		if (rx < 0)         { rx = 0;         dx = -dx; }
		if (rx > 640 - RW)  { rx = 640 - RW;  dx = -dx; }
		if (ry < 0)         { ry = 0;         dy = -dy; }
		if (ry > 480 - RH)  { ry = 480 - RH;  dy = -dy; }
		rect_col = (cb << 8) | (cg << 4) | cr;
		push_fill(ox, oy, RW, RH, 0x0000);
		push_fill(rx, ry, RW, RH, rect_col);
		delay_(FRAME_30HZ);
		blit_wait();

		if (++rc >= 8) { 
			rc = 0;
			cr = (cr - 1) & 0x0F; 
		}
		if (++gc >= 12) {
			gc = 0;
			cg = (cg - 1) & 0x0F;
		}
		if (++bc >= 16) {
			bc = 0;
			cb = (cb - 1) & 0x0F;
		}
	}
	return 0;
}
