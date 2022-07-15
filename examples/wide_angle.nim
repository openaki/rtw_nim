import ray_tracer/image
import ray_tracer/color
import ray_tracer/vec3
import ray_tracer/sphere
import ray_tracer/ray
import ray_tracer/bmp
import ray_tracer/camera
import ray_tracer/hittable
import ray_tracer/hit_record
import ray_tracer/material

import std/random
import math

proc ray_color(r: Ray, world: Hittable, depth: int): Color =
    if depth <= 0:
        return initVec(0, 0, 0)

    var rec: HitRecord

    const infinity = 1000000000.0
    var material: MaterialType
    if (world.hit(r, 0.0001, infinity, rec, material)):
        var scattered: Ray
        var attenuation: Color
        if material.scatter(r, rec, attenuation, scattered):
            return attenuation * ray_color(scattered, world, depth - 1);
        return initVec(0, 0, 0)

    let unit_direction = r.dir.unit_vector()
    let t = 0.5*(unit_direction.y() + 1.0)
    result = initVec(1, 1, 1) * (1-t) + initVec(0.5, 0.7, 1)*t

proc get_color(color: Vec3, samples_per_pixel: int): Vec3 =
    let scale: float64 = 1.0 / float64(samples_per_pixel)
    result.v[0] = sqrt(color.v[0] * scale)
    result.v[1] = sqrt(color.v[1] * scale)
    result.v[2] = sqrt(color.v[2] * scale)


proc main() =
    randomize()
    let aspectRatio: float64 = 16.0/9.0
    let R = cos(PI/4)
    let iW = 400
    let iH = int(float(iW) / aspectRatio)
    var image = newImage(iH, iW)
    const samples_per_pixel = 100
    let maxDepth = 50

    var cam: Camera = initCamera(90, aspectRatio)

    var world: HittableList

    let materialLeft = MaterialType(kind: LambertianKind, l: Lambertian(
            albedo: initVec(0.0, 0.0, 1)))
    let materialRight = MaterialType(kind: LambertianKind, l: Lambertian(
            albedo: initVec(1, 0, 0.0)))

    let s4 = Sphere(center: initVec(-R, 0, -1), radius: R,
            material: materialLeft)
    let s5 = Sphere(center: initVec(R, 0, -1), radius: R,
            material: materialRight)
    world.add(HittableType(kind: SphereType, s: s4))
    world.add(HittableType(kind: SphereType, s: s5))


    # Fill up the image
    for y in countup(0, ih-1):
        for x in countup(0, iw-1):
            var pixelColor: Vec3
            for s in countup(0, samples_per_pixel):
                let sx = (float64(x) + rand(1.0)) / float64(iw - 1)
                let sy = (float64(ih - y) + rand(1.0)) / float64(ih - 1)
                let r = cam.ray(sx, sy)
                pixelColor += ray_color(r, world, maxDepth)


            updateImage(image, get_color(pixelColor, samples_per_pixel), x, y)

    image.writeBmpFile("test.bmp")

main()
