import ray_tracer/image
import ray_tracer/bmp

proc testImage() =
    var image = newImage(800, 800)

    # Fill up the image
    for i in 0..<image.width:
        for j in 0..<image.height:
            image.buffer[i*image.width + j] = 0x00FF0000u32


    image.writeBmpFile()

testImage()
