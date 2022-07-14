import vec3

type
    Ray* = object
        origin*: Point3
        dir*: Vec3

proc initRay*(origin, dir: Vec3): Ray =
    result.origin = origin
    result.dir = dir

proc at*(r: Ray, t: float64): Point3 =
    r.origin + (r.dir * t)


