import vectors

type
    Ray* = object
        origin: Vec3
        direction: Vec3

proc initRay*(): Ray = Ray(origin: initVec3(), direction: initVec3(0.0, 0.0, 1.0))

proc initRay*(o: Vec3, d: Vec3): Ray = Ray(origin: o, direction: d.unit)

proc org*(r: Ray): Vec3 = r.origin

proc dir*(r: Ray): Vec3 = r.direction

proc at*(r: Ray, t: float): Vec3 = r.origin + t*r.direction
