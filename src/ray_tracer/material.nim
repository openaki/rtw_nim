import vec3
import ray
import hit_record
import math
import random

type
    Material* = concept self
        self.scatter(Ray, HitRecord, var Vec3, var Ray) is bool
    Lambertian* = object
        albedo*: Vec3
    Metal* = object
        albedo*: Vec3
        fuzz*: float64

    Dielectric* = object
        indexOfRefraction*: float64

    MaterialKind* = enum LambertianKind, MetalKind, DielectricKind
    MaterialType* = object
        case kind*: MaterialKind
        of LambertianKind: l*: Lambertian
        of MetalKind: m*: Metal
        of DielectricKind: d*: Dielectric


proc initLambertian*(albedo: Vec3): MaterialType =
    return MaterialType(kind: LambertianKind, l: Lambertian(albedo: albedo))

proc initMetal*(albedo: Vec3, fuzz: float64): MaterialType =
    return MaterialType(kind: MetalKind, m: Metal(albedo: albedo, fuzz: fuzz))

proc initDielectric*(indexOfRefraction: float64): MaterialType =
    return MaterialType(kind: DielectricKind, d: Dielectric(indexOfRefraction: indexOfRefraction))

proc reflectance(cosine: float64, ref_idx: float64): float64 =
    # Use Schlick's approximation for reflectance.
    var r0 = (1-ref_idx) / (1+ref_idx)
    r0 = r0*r0
    return r0 + (1-r0)*pow((1 - cosine),5)

proc scatter*(m: Lambertian, r: Ray, rec: HitRecord, attenuation: var Vec3, scattered: var Ray): bool=
    var scatter_direction = rec.normal + randomUnitVec()

    if scatter_direction.nearZero():
        scatter_direction = rec.normal

    scattered = initRay(rec.p, scatter_direction)
    attenuation = m.albedo
    return true

proc scatter*(m: Metal, r: Ray, rec: HitRecord, attenuation: var Vec3, scattered: var Ray): bool=
    let reflected = r.dir.unit_vector().reflect(rec.normal)
    scattered = initRay(rec.p, reflected + randomVecUnitSphere() * m.fuzz)
    attenuation = m.albedo
    return (scattered.dir.dot(rec.normal) > 0)

proc scatter*(m: Dielectric, r: Ray, rec: HitRecord, attenuation: var Vec3, scattered: var Ray): bool =
    attenuation = initVec(1,1,1)
    var refractionRatio = m.indexOfRefraction
    if rec.front_face:
        refractionRatio = 1.0 / m.indexOfRefraction

    let unitDirection = r.dir.unit_vector()
    let cos_theta = min(dot(-unit_direction, rec.normal), 1.0)
    let sin_theta = sqrt(1.0 - cos_theta*cos_theta);

    let cannot_refract = (refraction_ratio * sin_theta) > 1.0;
    var direction: Vec3;

    if cannot_refract or reflectance(cos_theta, refraction_ratio) > rand(1.0):
        direction = reflect(unit_direction, rec.normal)
    else:
        direction = refract(unit_direction, rec.normal, refraction_ratio);

    scattered = initRay(rec.p, direction);
    return true

proc scatter*(m: MaterialType, r: Ray, rec: HitRecord, attenuation: var Vec3, scattered: var Ray): bool=
    case m.kind
    of LambertianKind: return m.l.scatter(r, rec, attenuation, scattered)
    of MetalKind: return m.m.scatter(r, rec, attenuation, scattered)
    of DielectricKind: return m.d.scatter(r, rec, attenuation, scattered)
