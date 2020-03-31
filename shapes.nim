import math
import vectors, ray, materials

# kind of a forward declaration...
type
    Hitable* = ref object of RootObj
        material: Material

#==========================================
#                    
# HitRecord
#
#==========================================
type
    HitRecord* = object 
        point: Vec3
        normal: Vec3
        t: float64
        frontFace: bool
        hitable: Hitable

proc `point=`*(h: var HitRecord, p: Vec3): void = h.point = p
proc point*(h: var HitRecord): Vec3 = h.point 

proc `normal=`*(h: var HitRecord, n: Vec3): void = h.normal = n
proc normal*(h: var HitRecord): Vec3 = h.normal 

proc `t=`*(h: var HitRecord, t: float64): void = h.t = t
proc t*(h: var HitRecord): float64 = h.t 

proc hitable*(h: HitRecord): Hitable = h.hitable
proc hitable*(h: var HitRecord): Hitable = h.hitable

proc frontFace*(h: HitRecord): bool = h.frontFace

proc setFaceNormal*(h: var HitRecord, ray: Ray, outwardNormal: Vec3): void = 
    h.frontFace = ray.dir.dot(outwardNormal) < 0.0
    h.normal = if h.frontFace: outwardNormal else: -1.0 * outwardNormal


#==========================================
#                    
# Hitable methods
#
#==========================================
method hit*(h: Hitable, ray: Ray, tmin: float64, tmax: float64, hit: var HitRecord): bool {.base, locks: "unknown".} = 
    quit "Hitable.hit must be overridden by all subtypes"    

proc `material=`*(h: var Hitable, m: Material): void = h.material = m
proc material*(h: Hitable): Material = h.material
    

#==========================================
#                    
# Sphere shape
#
#==========================================
type 
    Sphere* = ref object of Hitable
        center: Vec3
        radius: float64

proc initSphere*(c: Vec3, r: float64, m: Material): Sphere = Sphere(center: c, radius: r, material: m)

proc c*(s: Sphere): Vec3 = s.center

proc r*(s: Sphere): float64 = s.radius

proc hit_point_at(s: Sphere, r: Ray, t: float64, hit: var HitRecord): void =
    hit.point = r.at(t)
    hit.t = t 
    let outwardNormal = (hit.point - s.center) / s.radius
    hit.setFaceNormal(r, outwardNormal)
    hit.hitable = s

method hit*(s: Sphere, ray: Ray, tmin: float64, tmax: float64, hit: var HitRecord): bool = 
    let oc = ray.org - s.c
    let a = ray.dir.lengthSq
    let half_b = oc.dot(ray.dir)
    let c = oc.lengthSq - s.radius*s.radius
    let discriminant = half_b*half_b - a*c 

    result = false

    if discriminant > 0.0:
        let root = sqrt(discriminant)
        var temp = (-half_b - root) / a #(a + 0.00001)
        if temp > tmin and temp < tmax:
            hit_point_at(s, ray, temp, hit)
            result = true 
    
        else:
            temp = (-half_b + root) / a #(a + 0.00001) 
            if temp > tmin and temp < tmax:
                hit_point_at(s, ray, temp, hit)
                result = true

#==========================================
#                    
# List of hitables
#
#==========================================
type 
    ListOfHitables* = ref object of Hitable
        hitables*: seq[Hitable]            

proc initListOfHitables*(): ListOfHitables = ListOfHitables(hitables: @[])

proc add*(list: var ListOfHitables, h: Hitable): void = list.hitables.add(h)

method hit*(listOfHitables: ListOfHitables, ray: Ray, tmin: float64, tmax: float64, hit: var HitRecord): bool =         
    var tempHit = HitRecord()
    var closestSoFar = tmax
    var hitSomething = false

    for h in listOfHitables.hitables:
        if h.hit(ray, tmin, closestSoFar, tempHit):
            hitSomething = true
            closestSoFar = tempHit.t 
            hit = tempHit

    hitSomething