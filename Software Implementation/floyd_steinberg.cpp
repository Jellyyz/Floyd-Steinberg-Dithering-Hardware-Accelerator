#include "floyd_steinberg.h"


void floyd_steinberg_dithering_serial(vector<unsigned char> &img, unsigned int w, unsigned int h) {
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
      for (int rgb = 0; rgb < 3; rgb++) {
        unsigned char old_pixel = img[y * w * 3 + x * 3 + rgb];
        unsigned char new_pixel = (old_pixel + 127) / 255;
        img[y * w * 3 + x * 3 + rgb] = new_pixel * 255;
        int quant_error = old_pixel - new_pixel * 255;
        if (x + 1 < w) {
          img[y * w * 3 + (x + 1) * 3 + rgb] += (quant_error * 7 / 16);
        }
        if (y + 1 < h) {
          img[(y + 1) * w * 3 + x * 3 + rgb] += (quant_error * 5 / 16);
          if (x - 1 > 0) {
            img[(y + 1) * w * 3 + (x - 1) * 3 + rgb] += (quant_error * 3 / 16);
          }
          if (x + 1 < w) {
            img[(y + 1) * w * 3 + (x + 1) * 3 + rgb] += (quant_error * 1 / 16);
          }
        }
      }
    }
  }
}