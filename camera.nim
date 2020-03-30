import math
import vectors, ray

type
    Camera* = ref object
        vFov: float64
        aspectRatio: float64
        origin*: Vec3
        vpOrigin*: Vec3
        horizontal: Vec3
        vertical: Vec3
        u: Vec3
        v: Vec3
        w: Vec3
        lensRadius: float64

proc initCamera*(origin, lookAt, up: Vec3, vFov: float64, aspectRatio, aperture, focusDist: float64): Camera = 
    let w = (origin - lookAt).unit
    let u = (up ^ w).unit
    let v = w ^ u

    let theta = math.PI * vFov / 180.0
    let halfHeight = tan(theta / 2.0)    
    let halfWidth = aspectRatio * halfHeight
    let vpOrigin = origin - focusDist*halfWidth*u - focusDist*halfHeight*v - focusDist*w

    let horizontal = 2.0*focusDist*halfWidth*u
    let vertical = 2.0*focusDist*halfHeight*v

    Camera(
        origin: origin, 
        vpOrigin: vpOrigin, 
        horizontal: horizontal, 
        vertical: vertical, 
        vFov: vFov, 
        aspectRatio: aspectRatio,
        u: u, v: v, w: v,
        lensRadius : aperture / 2.0)        


proc getRay*(cam: Camera, s, t: float64): Ray = 
    let rd = cam.lensRadius * randomInUnitDisk()
    let offset = rd.x*cam.u + rd.y*cam.v
    initRay(cam.origin + offset, cam.vpOrigin + s*cam.horizontal + t*cam.vertical - cam.origin - offset)    