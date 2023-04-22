from PIL import Image
import numpy as np
from math import floor

def is_power_of_two(n):
    return (n != 0) and (n & (n-1) == 0)

img = Image.open('Probably_0_255_512.png').convert('L')

data = np.asarray(img)

print(data.shape)

h, w = data.shape

assert(w % 8 == 0)
assert(is_power_of_two(int(w / 8 * h)))

bitmap_img = np.zeros((h, int(w / 8)))
print(data)

bit_index = 7
for i in range(h):
    for j in range(w):
        if data[i][j] == 0:
            bitmap_img[i][floor(j / 8)] = bitmap_img[i][floor(j / 8)].astype(np.uint8) | (1 << bit_index)
        bit_index = (bit_index - 1) % 8

print(bitmap_img)

new_img = Image.fromarray(bitmap_img.astype(np.uint8))
new_img.save("Probably_main.jpg")