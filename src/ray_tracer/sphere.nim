import ray_tracer/vec3
import ray_tracer/ray
import ray_tracer/hit_record
import ray_tracer/material

import math

type
    Sphere* = object
        center*: Point3
        radius*: float64
        material*: MaterialType


func hit*(s: Sphere, r: Ray, t_min: float64, t_max: float64, rec: var HitRecord,
        material: var MaterialType): bool =
    let oc = r.origin - s.center;
    let a = r.dir.length_squared();
    let half_b = dot(oc, r.dir);
    let c = oc.length_squared() - s.radius * s.radius;

    let discriminant = half_b*half_b - a*c;
    if (discriminant < 0):
        return false;
    let sqrtd = sqrt(discriminant)

    # Find the nearest root that lies in the acceptable range.
    var root = (-half_b - sqrtd) / a;
    if (root < t_min or t_max < root):
        root = (-half_b + sqrtd) / a
        if (root < t_min or t_max < root):
            return false

    rec.t = root
    rec.p = r.at(rec.t)
    let outward_normal = (rec.p - s.center) / s.radius
    rec.set_face_normal(r, outward_normal)
    material = s.material
    return true

