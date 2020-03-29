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

proc initCamera*(origin, lookAt, up: Vec3, vFov: float64, aspectRatio: float64): Camera = 
    let w = (origin - lookAt).unit
    let u = (up ^ w).unit
    let v = w ^ u

    let theta = math.PI * vFov / 180.0
    let halfHeight = tan(theta / 2.0)    
    let halfWidth = aspectRatio * halfHeight
    let vpOrigin = origin - halfWidth*u - halfHeight*v - w

    let horizontal = 2.0*halfWidth*u
    let vertical = 2.0*halfHeight*v

    Camera(origin: origin, vpOrigin: vpOrigin, horizontal: horizontal, vertical: vertical, vFov: vFov, aspectRatio: aspectRatio)        

proc getRay*(cam: Camera, u, v: float64): Ray = 
    initRay(cam.origin, cam.vpOrigin + u*cam.horizontal + v*cam.vertical - cam.origin)    