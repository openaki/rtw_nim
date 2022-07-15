import vec3
import ray
import utils
import math

type
    Camera* = object
        origin*: Point3
        lowerLeftCorner*: Point3
        horizontal*: Vec3
        vertical*: Vec3
        u*, v*, w*: Vec3
        lensRadius: float64

proc initCamera*(lookFrom, lookAt, vup: Vec3, vfov, aspectRatio, aperture,
        focusDist: float64): Camera =
    let theta = degree_to_radians(vfov)
    let h = tan(theta / 2.0)
    let viewPortH = 2.0 * h
    let viewPortW = aspectRatio * viewPortH

    let w = unit_vector(lookfrom - lookat);
    let u = unit_vector(cross(vup, w));
    let v = cross(w, u);
    result.lensRadius = aperture / 2.0

    result.origin = lookFrom
    result.horizontal = u * viewPortW * focusDist
    result.vertical = v * viewPortH * focusDist
    result.lowerLeftCorner = result.origin - (result.horizontal / 2) - (
            result.vertical / 2) - (w * focusDist)
    result.u = u
    result.v = v
    result.w = w


proc ray*(c: Camera, s, t: float64): Ray =
    let rd = random_in_unit_disk() * c.lensRadius
    let offset = c.u * rd[0] + c.v * rd[1]

    return initRay(c.origin + offset, c.lower_left_corner + (c.horizontal * s) +
            (c.vertical * t) - c.origin - offset)

