#include "floyd_steinberg.h"
#include <iostream>
using namespace std;


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
 vector<int> copy(img.begin(), img.end());
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      unsigned char old_pixel = img[y * w + x];
      img[y * w + x] = (old_pixel > 127) ? 255 : 0;
      char quant_error = (char) old_pixel - (char) img[y * w + x];
      if (x % w != w - 1) {
        if (!clamp)
          img[y * w + (x + 1)] += quant_error * ((float) 7 / (float) 16);
        else
          CLAMP(1, 0, 7);
      }
      if (y != h - 1) {
        if (x % w) {
          if (!clamp)
            img[(y + 1) * w + (x - 1)] += (char) quant_error * ((float) 3 / (float) 16);
          else
            CLAMP(-1, 1, 3);
        }
        if (!clamp)
          img[(y + 1) * w + x] += quant_error * ((float) 5 / (float) 16);
        else
          CLAMP(0, 1, 5);
        if (x % w != w - 1) {
          if (!clamp)
            img[(y + 1) * w + (x + 1)] += quant_error * ((float) 1 / (float) 16);
          else 
            CLAMP(1, 1, 1);
        }
      } 
    }
  }
}


void floyd_steinberg_dithering_serial1(vector<unsigned char> &img, unsigned int w, unsigned int h) {
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
 vector<int> copy(img.begin(), img.end());
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int old_pixel = copy[y * w + x];
      copy[y * w + x] = (old_pixel > 127) ? 255 : 0;
      img[y * w + x] = copy[y * w + x];
      int quant_error = old_pixel - copy[y * w + x];
      if (x % w != w - 1) {
          int new_pixel = (copy[y * w + (x + 1)] + quant_error) * (7.0f / 16.0f);
          bound(new_pixel);
          copy[y * w + (x + 1)] = new_pixel;
      }
      if (y != h - 1) {
        if (x % w) {
          int new_pixel = (copy[(y + 1) * w + (x - 1)] + quant_error) * (3.0f / 16.0f);
          bound(new_pixel);
          copy[(y + 1) * w + (x - 1)] = new_pixel;
        }
        int new_pixel = (copy[(y + 1) * w + x] + quant_error) * (5.0f / 16.0f);
        bound(new_pixel);
        copy[(y + 1) * w + x] = new_pixel;
        if (x % w != w - 1) {
          int new_pixel = (copy[(y + 1) * w + (x + 1)] + quant_error) * (1.0f / 16.0f);
          bound(new_pixel);
          copy[(y + 1) * w + (x + 1)] = new_pixel;
        }
      } 
    }
  }
}

void bound(int &pixel) {
  return;
  if (pixel > 255) {
    pixel = 255;
  }
  else if (pixel < 0) {
    pixel = 0;
  }
}