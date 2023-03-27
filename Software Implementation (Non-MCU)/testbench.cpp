#include <iostream>
#include <sstream>
#include "lodepng_helper.h"
#include "floyd_steinberg.h"

using namespace std;

void push_pixels(const string src, vector<unsigned char> &dst) {
    bool afterSpace = false;
    size_t scanned = 0;
    stringstream ss;
    for (auto it = src.begin(); it < src.end(); it++) {
        if (!afterSpace) {
            if (*it == ' ') {
                afterSpace = true;
            }
        }
        else {
            if (*it != ':' && *it != ' ') {
                scanned++;

                ss << hex << *it;

                if (scanned == 2) {
                    scanned = 0;
                    unsigned x;
                    ss >> x;
                    dst.push_back(static_cast<unsigned char>(x));
                    ss.clear();
                    afterSpace = false;
                }
            }
        }
    }
}

int main(void) {
    const string contentString = 
    "0 : e7 7c 9c 1c e8 a7 16 c4 00 59 f8 fb 11 a2 fc a5"
    "16 : de 96 90 17 de 83 86 14 cd 5c 4f b2 97 ff 1e ac"
    "32 : 2c e4 9e 85 b2 9b 52 ad 31 18 99 c0 02 8c e1 88" 
    "48 : 2f 35 14 0f 11 2d 48 d7 1d c1 f5 98 82 82 71 c1" 
    "64 : 15 53 7e 8f 39 5e 38 ab a1 7a 18 81 b8 81 e1 f8" 
    "80 : a2 2f 0d 97 38 43 c1 4d 1a 75 c9 d6 d3 01 d6 89" 
    "96 : 2a bf e0 0f a5 d4 3f a3 7e 59 7d 4e 18 ba e2 db" 
    "112 : 33 13 fc 71 bd 82 89 29 81 5e ad 57 94 a8 7d 74" 
    "128 : a8 4a af 59 4d a1 1e 1c fe 48 25 6a 49 ce 00 33" 
    "144 : c3 fe 5e bb 1b 8a 41 3b ed 08 79 21 c4 7e ac 93" 
    "160 : b2 88 8f 06 03 d6 b5 45 fc e9 b0 ff 01 bd aa 20" 
    "176 : 0b d9 d2 2d 85 4f f8 ac c4 00 78 74 3d 38 59 80" 
    "192 : cb 05 55 e0 35 fd af 2c 1e 44 0d 4b 7c b2 63 e5" 
    "208 : 47 72 80 dd 3e da 8a 23 91 20 95 a2 91 ed 55 ef"
    "224 : f1 5f 38 f0 a1 28 bc fc e1 5f ba 60 fd d2 39 26" 
    "240 : 0f 9f 1a af e0 59 64 b1 98 73 9b b8 81 1c 00 00";

    vector<unsigned char> init_img;
    unsigned w = 16, h = 16;
    push_pixels(contentString, init_img);

    
    cout << "Done (A)" << endl;
    cout << init_img.size() << endl;

    size_t i = 0;

    for (auto it = init_img.begin(); it < init_img.end(); it++) {
        if (i % w == 0) {
            cout << "\n" << dec << i << " :";
        }
        cout << " ";
        unsigned char tmp = *it;
        cout << hex << (int) tmp;
        i++;
    }

    cout << endl;

    
    cout << "Done (I)" << endl;
    cout << init_img.size() << endl;

    floyd_steinberg_dithering_serial1(init_img, w, h, true);

    cout << "Done (P)" << endl;
    cout << init_img.size() << endl;

    //lodepng::encode("testbench_after_NONCLAMP.png", init_img, w, h, LodePNGColorType::LCT_GREY, 8);
    
    i = 0;

    for (auto it = init_img.begin(); it < init_img.end(); it++) {
        if (i % w == 0) {
            cout << "\n" << dec << i << " :";
        }
        cout << " ";
        unsigned char tmp = *it;
        cout << hex << (int) tmp;
        i++;
    }
    return 0;
}