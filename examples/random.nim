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
import weave

proc ray_color(r: Ray, world: Hittable, depth: int): Color =
    if depth <= 0:
        return initVec(0, 0, 0)

    var rec: HitRecord

    const infinity = 1000000000.0
    var material: MaterialType
    if (world.hit(r, 0.01, infinity, rec, material)):
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

proc randomScene(): HittableList =
    let materialGround = MaterialType(kind: LambertianKind, l: Lambertian(
            albedo: initVec(0.5, 0.5, 0.5)))

    result.addSphere(initVec(0, -1000, 0), 1000, materialGround)

    for a in countup(-11, 11):
        for b in countup(-11, 11):
            let chooseMat = rand(1.0)
            let center = initVec(float64(a) + 0.9*rand(1.0), 0.2, float64(b) +
                    0.9*rand(1.0))
            if (center - initVec(4, 0.2, 0)).length() > 0.9:
                var sphereMaterial: MaterialType
                if (chooseMat < 0.8):
                    let albedo = randomVec() * randomVec()
                    sphereMaterial = initLambertian(albedo)
                elif (chooseMat < 0.95):
                    let albedo = randomVec(0.5, 1);
                    let fuzz = rand(0.5);
                    sphereMaterial = initMetal(albedo, fuzz)
                else:
                    sphereMaterial = initDielectric(1.5)

                result.addSphere(center, 0.2, sphereMaterial)


    let m1 = initDielectric(1.5);
    result.addSphere(initVec(0, 1, 0), 1, m1)

    let m2 = initLambertian(initVec(0.4, 0.2, 0.1));
    result.addSphere(initVec(-4, 1, 0), 1, m2)

    let m3 = initMetal(initVec(0.7, 0.6, 0.5), 0.0);
    result.addSphere(initVec(4, 1, 0), 1, m3)

proc main() =
    randomize()
    const aspectRatio: float64 = 3.0/2.0
    const iW = 1200
    const iH = int(float(iW) / aspectRatio)
    var image = newImage(iH, iW)
    const samples_per_pixel = 500
    const maxDepth = 50

    let world: HittableList = randomScene()

    let lookfrom = initVec(13, 2, 3)
    let lookat = initVec(0, 0, 0)
    let vup = initVec(0, 1, 0)
    let distToFocus = 10.0;
    let aperture = 0.1

    let outVec = newSeq[Vec3](iw * ih)
    let bufOut = cast[ptr UncheckedArray[Vec3]](outVec[0].unsafeAddr)
    init(Weave)
    var cam: Camera = initCamera(lookfrom, lookat, vup, 20, aspect_ratio,
            aperture, distToFocus)
    let camPtr: ptr[Camera] = cam.unsafeAddr
    # Fill up the image
    #for y in 0..<ih:
    parallelFor y in 0..<ih:
        captures: {world, image, camPtr, bufOut}
        for x in countup(0, iw-1):
            var pixelColor: Vec3
            for s in countup(0, samples_per_pixel):
                let sx = (float64(x) + rand(1.0)) / float64(iw - 1)
                let sy = (float64(ih - y) + rand(1.0)) / float64(ih - 1)
                let r = ray(camPtr[], sx, sy)
                pixelColor += ray_color(r, world, maxDepth)


            bufOut[y*iw + x] = get_color(pixelColor, samples_per_pixel)
            #updateImage(image, get_color(pixelColor, samples_per_pixel), x, y)

    exit(Weave)

    for y in 0..<ih:
        for x in countup(0, iw-1):
            updateImage(image, bufOut[y*iw + x], x, y)

    image.writeBmpFile("test.bmp")

main()
