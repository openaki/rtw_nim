import ray_tracer/color
import ray_tracer/vec3
import ray_tracer/image
import ray_tracer/bmp

proc testImage() =
    let iH = 200
    let iW = 200
    var image = newImage(iH, iW)

    # Fill up the image
    var imageX: int
    for j in countdown(iH-1, 0):
        var imageY: int
        for i in countup(0, iw-1):
            let c = initVec(i/iW, j/ih, 0.25)
            #var c = initVec(0, 1, 0)
            updateImage(image, c, imageX, imageY);
            imageY += 1
        imageX += 1


    # for i in 0..<image.width:
    #     for j in 0..<image.height:
    #         updateImage(image, initVec(1, 0, 0), i, j);
    #         image.buffer[i*image.width + j] = 0x00FF00FFu32


    image.writeBmpFile("test.bmp")

testImage()

