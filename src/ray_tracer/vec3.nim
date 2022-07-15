import math
import std/random

type
    Vec3* = object
        v*: array[3, float64]

    Point3* = Vec3

proc initVec*(x, y, z: float64): Vec3 {.inline.} =
    result.v[0] = x
    result.v[1] = y
    result.v[2] = z

proc x*(v: Vec3): float64 {.inline.} = v.v[0]
proc y*(v: Vec3): float64 {.inline.} = v.v[1]
proc z*(v: Vec3): float64 {.inline.} = v.v[2]

proc `[]`*(v: Vec3, i: int): float64 {.inline.} =
    v.v[i]

proc `-`*(v: Vec3): Vec3 {.inline.} =
    result.v[0] = -v.v[0]
    result.v[1] = -v.v[1]
    result.v[2] = -v.v[2]

proc clampV*(v: Vec3, minV, maxV: float64): Vec3 {.inline.} =
    result.v[0] = clamp(v.v[0], minV, maxV)
    result.v[1] = clamp(v.v[1], minV, maxV)
    result.v[2] = clamp(v.v[2], minV, maxV)

template generateUnaryOverrides(op: untyped) =
    proc op*(a: var Vec3, b: Vec3) {.inline.} =
        op(a.v[0], b.v[0])
        op(a.v[1], b.v[1])
        op(a.v[2], b.v[2])

template generateUnaryOverridesFloat(op: untyped) =
    proc op*(a: var Vec3, b: float64) {.inline.} =
        op(a.v[0], b)
        op(a.v[1], b)
        op(a.v[2], b)

template generateBinaryOverrides(op: untyped) =
    proc op*(a: Vec3, b: Vec3): Vec3 {.inline.} =
        result.v[0] = op(a.v[0], b.v[0])
        result.v[1] = op(a.v[1], b.v[1])
        result.v[2] = op(a.v[2], b.v[2])

template generateBinaryOverridesFloat(op: untyped) =
    proc op*(a: Vec3, b: float64): Vec3 {.inline.} =
        result.v[0] = op(a.v[0], b)
        result.v[1] = op(a.v[1], b)
        result.v[2] = op(a.v[2], b)

generateUnaryOverrides(`+=`)
generateUnaryOverrides(`-=`)
generateUnaryOverridesFloat(`*=`)
generateUnaryOverridesFloat(`/=`)

generateBinaryOverrides(`+`)
generateBinaryOverrides(`-`)
generateBinaryOverrides(`*`)

generateBinaryOverridesFloat(`*`)
generateBinaryOverridesFloat(`/`)


proc lengthSquared*(v: Vec3): float64 {.inline.} =
    result = v.v[0] * v.v[0] +
              v.v[1] * v.v[1] +
              v.v[2] * v.v[2]

proc length*(v: Vec3): float64 {.inline.} =
    v.length_squared().sqrt()

proc dot*(a, b: Vec3): float64 {.inline.} =
    a.v[0] * b.v[0] + a.v[1] * b.v[1] + a.v[2] * b.v[2]

proc cross*(a, b: Vec3): Vec3 {.inline.} =
    initVec(a.v[1] * b.v[2] - a.v[2] * b.v[1],
                a.v[2] * b.v[0] - a.v[0] * b.v[2],
                a.v[0] * b.v[1] - a.v[1] * b.v[0]);

proc unitVector*(v: Vec3): Vec3 {.inline.} =
    v / v.length();

proc randomVec*(): Vec3 {.inline.} =
    initVec(rand(1.0), rand(1.0), rand(1.0))

proc randomVec*(min, max: float64): Vec3 {.inline.} =
    let t = max - min
    initVec(min + t * rand(1.0), min + t * rand(1.0), min + t * rand(1.0))

proc randomUnitVec*(): Vec3 {.inline.} =
    randomVec().unitVector()

proc nearZero*(v: Vec3): bool {.inline.} =
    result = true
    let epsilon = 1e-8
    result = result and (abs(v.v[0]) < epsilon)
    result = result and (abs(v.v[1]) < epsilon)
    result = result and (abs(v.v[2]) < epsilon)

proc reflect*(v: Vec3, n: Vec3): Vec3 {.inline.} =
    result = v - n*dot(v, n)*2

proc randomVecUnitSphere*(): Vec3 {.inline.} =
    while true:
        let p = randomVec(-1, 1)
        if p.length_squared >= 1:
            continue
        return p

proc refract*(uv: Vec3, n: Vec3, etai_over_etat: float64): Vec3 =
    let cos_theta = min(dot(-uv, n), 1.0)
    let r_out_perp = (uv + (n * cos_theta)) * etai_over_etat
    let r_out_parallel = n * -sqrt(abs(1.0 - r_out_perp.length_squared()))
    return r_out_perp + r_out_parallel

proc random_in_unit_disk*(): Vec3 =
    while true:
        let p = initVec(rand(2.0) - 1, rand(2.0) - 1, 0)
        if (p.length_squared() >= 1):
            continue
        return p

when isMainModule:
    import std/unittest

    echo randomVec()
    echo randomVec(-1, 1)

    suite "Create Vec3":
        test "default constructtor":
            var v: Vec3
            doAssert v[0] == 0
            doAssert v[1] == 0
            doAssert v[2] == 0

            doAssert v.x == 0
            doAssert v.y == 0
            doAssert v.z == 0

        test "init constructtor":
            var v: Vec3 = initVec(10, 9, 8)
            doAssert v[0] == 10
            doAssert v[1] == 9
            doAssert v[2] == 8

            doAssert v.x == 10
            doAssert v.y == 9
            doAssert v.z == 8

    suite "Vec3 Operations":
        test "negation ":
            var v: Vec3 = initVec(10, 9, 8)
            v = -v;
            doAssert v[0] == -10
            doAssert v[1] == -9
            doAssert v[2] == -8

        test "add":
            var a: Vec3 = initVec(10, 9, 8)
            let b: Vec3 = initVec(1, -1, 5)
            let c = a + b
            a += b
            doAssert a[0] == 11
            doAssert a[1] == 8
            doAssert a[2] == 13
            doAssert c == a

        test "sub assignment":
            var a: Vec3 = initVec(10, 9, 8)
            let b: Vec3 = initVec(1, -1, 5)
            let c = a - b
            a -= b
            doAssert a[0] == 9
            doAssert a[1] == 10
            doAssert a[2] == 3
            doAssert c == a

        test "div assignment":
            var a: Vec3 = initVec(10, 9, 8)
            let c = a / 2
            a /= 2
            doAssert a[0] == 5
            doAssert a[1] == 4.5
            doAssert a[2] == 4
            doAssert c == a

        test "length":
            var a: Vec3 = initVec(10, 9, 8)
            doAssert a.length_squared() == 100 + 81 + 64
            doAssert a.length() == sqrt(100.0 + 81.0 + 64.0)

        test "nearzero":
            var a: Vec3 = initVec(0, 0, 0)
            doAssert a.nearZero()

            var b: Vec3 = initVec(0.1, 0, 0)
            doAssert not b.nearZero()
