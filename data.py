import matplotlib.pyplot as plt
import numpy as np

from mpl_toolkits.mplot3d import Axes3D

def printTimeNormal(w : int, h : int) -> float:
    assert(w * h <= 65536)
    numBytes = w * h
    BAUDRATE = 9600
    
    # Seconds to send bits through UART to printer line
    issueTime = (numBytes / 8) * (((11 * 1000000) + (BAUDRATE / 2)) / BAUDRATE) * 10 ** -6
    
    #print(issueTime)
    
    # Seconds to go down by a dot 
    verticalTime = h * 30000 * 10 ** -6
    
    return issueTime + verticalTime

fig = plt.figure(figsize=(16,16))

ax = fig.add_subplot(111, projection='3d')
ax.set_title("Printing time distribution")
ax.set_xlabel("Width (px)")

ax.set_ylabel("Height (px)")

ax.set_zlabel("Time (s)")

ax.set_xlim(1, 384)
BAUDRATE = 9600
ax.set_ylim(1, 384)
ax.set_zlim(0, 25)

for w in range(1, 384, 16):
    x = np.array([w] * 9)
    max_h = int(65536 / w)
    interval = max_h / 8
    y = np.array([interval * i for i in range(0, 9)])
    z = (((x * y) / 8) * (((11 * 1000000) + (BAUDRATE / 2)) / BAUDRATE) * 10 ** -6) + (y * 30000 * 10 ** -6)
    print(x[1])
    print(y[1])
    print(z[1])
    ax.plot(x, y, z)

    #max_h = int(65536 / w)
    #for h in range(1, max_h, 32):
    #    ax.scatter(w, h, printTimeNormal(w = w, h = h))

x = y = np.arange(1, 384, 0.1)
X, Y = np.meshgrid(x, y)

def f(x, y):
    return x**2 + y**2

Z = f(X,Y)
#To plot the surface at 100, use your same grid but make all your numbers zero
Z2 = Z*0.+20
ax.plot_surface(X, Y, Z2, color='r', alpha=0.3) #plot the surface

plt.show()