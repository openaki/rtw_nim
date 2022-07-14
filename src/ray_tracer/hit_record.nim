import vec3
import ray

type
    HitRecord* = object
        p*: Point3
        normal*: Vec3
        t*: float64
        front_face*: bool

func set_face_normal*(h: var HitRecord, r: Ray, outward_normal: Vec3) =
    h.front_face = dot(r.dir, outward_normal) < 0
    if h.front_face:
        h.normal = outward_normal
    else:
        h.normal = -outward_normal

