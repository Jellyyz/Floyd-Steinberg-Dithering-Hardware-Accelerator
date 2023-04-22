from PIL import Image
import numpy

image = Image.open("expected.png")
data = numpy.asarray(image)
img_as_bytes = data.tobytes() # img_as_bytes contains new numpy -> bytes array for downscaled image

with open("smth.txt", "w") as f:
    for i in range(len(img_as_bytes)):
        f.write(f"""
        else if(i == {i})begin 
                temp = 8'd{img_as_bytes[i]}; 
                external_SPI_data = temp;
                test_vector_sram[i][RGB_SIZE - 1:0] = temp;
                // $display("Inserting %h at addr %h.", external_SPI_data, i); 
                #2;
            end
        """)