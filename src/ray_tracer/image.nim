type
    Image* = object
        width*: int
        height*: int
        buffer*: seq[uint32]


proc newImage*(height: int, width: int): Image =
    result.width = width
    result.height = height
    result.buffer = newSeq[uint32](width * height * 4)

proc size*(image: Image): int =
    result = image.width * image.height * 4

