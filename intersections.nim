#[


import math
import vectors, ray

proc hit_sphere*(ray: Ray, center: Vec3, radius: float): float64 =
    let oc = ray.org - center 
    let a = ray.dir.lengthSq
    let half_b = oc.dot(ray.dir)
    let c = oc.lengthSq - radius*radius
    let discriminant = half_b*half_b - a*c 
    
    if discriminant > 0.0:
        result = (-half_b - sqrt(discriminant)) / a 
    else:
        result = -1.0


]#