#ifndef FLOYD_STEINBERG_H
#define FLOYD_STEINBERG_H

#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define MAX(a,b) ((a) > (b) ? (a) : (b))
#define CLAMP(dx, dy, num) if (quant_error > 0)\
    img[(y + (dy)) * w + (x + (dx))] = (img[(y + (dy)) * w + (x + (dx))] + quant_error * (float) (num) / (float) 16 < img[(y + (dy)) * w + (x + (dx))]) ? 255 : img[(y + (dy)) * w + (x + (dx))] + quant_error * (float) (num) / (float) 16;\
    else\
    img[(y + (dy)) * w + (x + (dx))] = (img[(y + (dy)) * w + (x + (dx))] + quant_error * (float) (num) / (float) 16 > img[(y + (dy)) * w + (x + (dx))]) ? 0 : img[(y + (dy)) * w + (x + (dx))] + quant_error * (float) (num) / (float) 16;

#include <vector>
using namespace std;

void floyd_steinberg_dithering_serial(vector<unsigned char> &img, unsigned int w, unsigned int h, bool clamp);
void floyd_steinberg_dithering_serial1(vector<unsigned char> &img, unsigned int w, unsigned int h);

void bound(int &pixel);

#endif