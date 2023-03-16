#include "floyd_steinberg.h"
#include <iostream>
using namespace std;

// Assumes grayscale input `img`
// clamp => whether to clamp intermediate values (actually looks dithered on larger images, looks like trash on small images?)
// !clamp => looks like cell-shaded with no dithering at all
void floyd_steinberg_dithering_serial(vector<unsigned char> &img, unsigned int w, unsigned int h, bool clamp) {
  /*
  Wikipedia pseudocode (inplace)
  for each y from top to bottom do
    for each x from left to right do
        oldpixel := pixels[x][y]
        newpixel := find_closest_palette_color(oldpixel)
        pixels[x][y] := newpixel
        quant_error := oldpixel - newpixel
        pixels[x + 1][y    ] := pixels[x + 1][y    ] + quant_error × 7 / 16
        pixels[x - 1][y + 1] := pixels[x - 1][y + 1] + quant_error × 3 / 16
        pixels[x    ][y + 1] := pixels[x    ][y + 1] + quant_error × 5 / 16
        pixels[x + 1][y + 1] := pixels[x + 1][y + 1] + quant_error × 1 / 16

  */
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      unsigned char old_pixel = img[y * w + x];
      img[y * w + x] = (old_pixel > 127) ? 255 : 0;
      char quant_error = (char) old_pixel - (char) img[y * w + x];
      if (x % w != w - 1) {
        if (!clamp)
          img[y * w + (x + 1)] += quant_error * (7 / 16);
        else
          CLAMP(1, 0, 7);
      }
      if (y != h - 1) {
        if (x % w) {
          if (!clamp)
            img[(y + 1) * w + (x - 1)] += quant_error * (3 / 16);
          else
            CLAMP(-1, 1, 3);
        }
        if (!clamp)
          img[(y + 1) * w + x] += quant_error * (5 / 16);
        else
          CLAMP(0, 1, 5);
        if (x % w != w - 1) {
          if (!clamp)
            img[(y + 1) * w + (x + 1)] += quant_error * (1 / 16);
          else 
            CLAMP(1, 1, 1);
        }
      } 
    }
  }
}