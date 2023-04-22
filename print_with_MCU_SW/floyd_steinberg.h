#ifndef FLOYD_STEINBERG_H
#define FLOYD_STEINBERG_H

#include <vector>
using namespace std;

#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define MAX(a,b) ((a) > (b) ? (a) : (b))
#define CLAMP(dx, dy, num) if (quant_error > 0)\
    img[(y + (dy)) * w + (x + (dx))] = img[(y + (dy)) * w + (x + (dx))] + quant_error * (num) / 16 < img[(y + (dy)) * w + (x + (dx))] ? 255 : img[(y + (dy)) * w + (x + (dx))] + quant_error * (num) / 16;\
    else\
    img[(y + (dy)) * w + (x + (dx))] = img[(y + (dy)) * w + (x + (dx))] + quant_error * (num) / 16 > img[(y + (dy)) * w + (x + (dx))] ? 0 : img[(y + (dy)) * w + (x + (dx))] + quant_error * (num) / 16;

void floyd_steinberg_dithering_serial(vector<unsigned char> &img, unsigned int w, unsigned int h);
void floyd_steinberg_dithering_serial(unsigned char *img, unsigned int w, unsigned int h);
void floyd_steinberg_dithering_serial_no_float(unsigned char *img, unsigned int w, unsigned int h);
void floyd_steinberg_dithering_serial_no_float2(unsigned char *img, unsigned int w, unsigned int h);
void floyd_steinberg_dithering_serial_no_float3(unsigned char *img, unsigned int w, unsigned int h);

#endif