import vec3
export vec3
import image
type
    Color* = Vec3
    Pixel* {.borrow: `.`.} = distinct Color


proc updateImage*(image: var Image, pixelI: Color, x: int, y: int) =
    var bitMap: uint32
    let pixel = pixelI.clampV(0.0, 0.9999)
    bitMap = bitMap or (uint32(pixel[0] * 255) shl 16)
    bitMap = bitMap or (uint32(pixel[1] * 255) shl 8)
    bitMap = bitMap or (uint32(pixel[2] * 255))
    image.buffer[y*image.width + x] = bitMap
