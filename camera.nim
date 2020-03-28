import vectors, ray

type
    Camera* = ref object
        vFov: float64
        aspectRatio: float64
        origin*: Vec3
        vpOrigin*: Vec3
        vpDim*: Vec3

proc initCamera*(vFov: float64, aspectRatio: float64): Camera =     
    Camera(origin: initVec3(), vpOrigin: initVec3(-2.0, -1.0, -1.0), vpDim: initVec3(4.0, 2.0, 0.0))        

proc getRay*(cam: Camera, u: float64, v: float64): Ray = 
    initRay(cam.origin, (cam.vpOrigin + initVec3(u, v, 0.0)*cam.vpDim) - cam.origin)    