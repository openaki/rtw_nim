import ray
import vec3
import sphere
import hit_record
import material

type

    Hittable* = concept self
        self.hit(Ray, float64, float64, var HitRecord, var Material) is bool

    HittableKind* = enum SphereType, HittableListType
    HittableType* = object
        case kind*: HittableKind
        of SphereType: s*: Sphere
        of HittableListType: l*: HittableList

    HittableList* = object
        l*: seq[HittableType]


func add*(ls: var HittableList, t: HittableType) =
    ls.l.add(t)


func hit*(t: HittableType, r: Ray, t_min, t_max: float64, h: var HitRecord,
        material: var MaterialType): bool =
    case t.kind
    of SphereType: result = t.s.hit(r, t_min, t_max, h, material)
    of HittableListType:

        var hit_anything = false
        var closest_yet = t_max
        var tempH: HitRecord
        for e in t.l.l:
            if e.hit(r, t_min, closest_yet, tempH, material):
                hit_anything = true;
                closest_yet = tempH.t
                h = tempH
        result = hit_anything

func hit*(ls: HittableList, r: Ray, t_min, t_max: float64, h: var HitRecord,
        m: var MaterialType): bool =
    var hit_anything = false
    var closest_yet = t_max
    var tempH: HitRecord
    for e in ls.l:
        if e.hit(r, t_min, closest_yet, tempH, m):
            hit_anything = true;
            closest_yet = tempH.t
            h = tempH
    result = hit_anything


func addSphere*(h: var HittableList, center: Vec3, radius: float64,
        m: MaterialType) =
    let s1 = Sphere(center: center, radius: radius, material: m)
    h.add(HittableType(kind: SphereType, s: s1))

