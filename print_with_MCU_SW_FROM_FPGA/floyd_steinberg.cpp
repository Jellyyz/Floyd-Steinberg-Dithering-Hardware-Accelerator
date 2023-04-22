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
      unsigned char old_pixel = img[y * w + x];
      img[y * w + x] = (old_pixel > 127) ? 255 : 0;
      char quant_error = (char) old_pixel - (char) img[y * w + x];
      if (x % w != w - 1) {
        img[y * w + (x + 1)] += quant_error * (7.0f / 16.0f);
        //CLAMP(1, 0, 7);
      }
      if (y != h - 1) {
        if (x % w) {
          img[(y + 1) * w + (x - 1)] += quant_error * (3.0f / 16.0f);
          //CLAMP(-1, 1, 3);
        }
        img[(y + 1) * w + x] += quant_error * (5.0f / 16.0f);
        //CLAMP(0, 1, 5);
        if (x % w != w - 1) {
          //CLAMP(1, 1, 1);
          img[(y + 1) * w + (x + 1)] += quant_error * (1.0f / 16.0f);
        }
      } 
    }
  }
}

void floyd_steinberg_dithering_serial(unsigned char *img, unsigned int w, unsigned int h) {
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
        img[y * w + (x + 1)] += quant_error * (7.0f / 16.0f);
        //CLAMP(1, 0, 7);
      }
      if (y != h - 1) {
        if (x % w) {
          img[(y + 1) * w + (x - 1)] += quant_error * (3.0f / 16.0f);
          //CLAMP(-1, 1, 3);
        }
        img[(y + 1) * w + x] += quant_error * (5.0f / 16.0f);
        //CLAMP(0, 1, 5);
        if (x % w != w - 1) {
          //CLAMP(1, 1, 1);
          img[(y + 1) * w + (x + 1)] += quant_error * (1.0f / 16.0f);
        }
      } 
    }
  }
}
void floyd_steinberg_dithering_serial_no_float2(unsigned char *img, unsigned int w, unsigned int h) {
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
        img[y * w + (x + 1)] += (quant_error * 7) >> 4;
        //CLAMP(1, 0, 7);
      }
      if (y != h - 1) {
        if (x % w) {
          img[(y + 1) * w + (x - 1)] += (quant_error * 3) >> 4;
          //CLAMP(-1, 1, 3);
        }
        img[(y + 1) * w + x] += (quant_error * 5) >> 4;
        //CLAMP(0, 1, 5);
        if (x % w != w - 1) {
          //CLAMP(1, 1, 1);
          img[(y + 1) * w + (x + 1)] += quant_error >> 4;
        }
      } 
    }
  }
}

void floyd_steinberg_dithering_serial_no_float3(unsigned char *img, unsigned int w, unsigned int h) {
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
        img[y * w + (x + 1)] += (quant_error * 7) >> 4;
        //CLAMP(1, 0, 7);
      }
      if (y != h - 1) {
        if (x % w) {
          img[(y + 1) * w + (x - 1)] += (quant_error >> 4) * 3;
          //CLAMP(-1, 1, 3);
        }
        img[(y + 1) * w + x] += (quant_error >> 4) * 5;
        //CLAMP(0, 1, 5);
        if (x % w != w - 1) {
          //CLAMP(1, 1, 1);
          img[(y + 1) * w + (x + 1)] += quant_error >> 4;
        }
      } 
    }
  }
}
void floyd_steinberg_dithering_serial_no_float(unsigned char *img, unsigned int w, unsigned int h) {
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
        img[y * w + (x + 1)] += quant_error * (int) (7 >> 4);
        //CLAMP(1, 0, 7);
      }
      if (y != h - 1) {
        if (x % w) {
          img[(y + 1) * w + (x - 1)] += quant_error * (int) (3 >> 4);
          //CLAMP(-1, 1, 3);
        }
        img[(y + 1) * w + x] += quant_error * (int) (5 >> 4);
        //CLAMP(0, 1, 5);
        if (x % w != w - 1) {
          //CLAMP(1, 1, 1);
          img[(y + 1) * w + (x + 1)] += quant_error * (int) (1 >> 4);
        }
      } 
    }
  }
}