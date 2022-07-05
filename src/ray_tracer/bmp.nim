import ray_tracer/image

type
    BitMapHeader {.packed.} = object
        magic: int16
        fileSize: int32
        reserved1: int16
        reserved2: int16
        imageOffset: int32
        # start of dib header
        dibHeaderSize: int32 # should be 40 bytes
        width: int32
        hegiht: int32
        colorPanes: int16
        bitsPerPixel: int16
        compression: int32
        bitMapSize: int32
        printHorizontalMetre: int32
        printVerticlelMetre: int32
        nunColors: int32
        importantColors: int32

        #redMask: int32
        #greeMask: int32
        #blueMask: int32

proc writeBmpFile*(image: Image) =

    let imageSize = image.size()

    var header : BitMapHeader
    header.magic = 0x4d42
    header.fileSize = cast[int32](imageSize + (sizeof(BitMapHeader)))
    header.imageOffset = cast[int32](sizeof(BitMapHeader))
    header.dibHeaderSize = sizeof(BitMapHeader) - 14
    header.width = cast[int32](image.width)
    header.hegiht = cast[int32](image.height)
    header.colorPanes = 1
    header.bitsPerPixel = 32 # rbga
    header.compression = 0
    header.bitMapSize = cast[int32](imageSize)
    #header.redMask =  0x00FF0000
    #header.greeMask = 0x0000FF00
    #header.blueMask = 0x000000FF

    var fp = open("test.bmp", fmWrite);
    defer: fp.close()
    discard fp.writeBuffer(unsafeAddr(header), sizeof(header))
    #var x = cast[ptr UncheckedArray[uint8]](imageBuffer)
    discard fp.writeBuffer(unsafeAddr(image.buffer[0]), imageSize)
    #strm.writeData(unsafeAddr(a), sizeof(a))


