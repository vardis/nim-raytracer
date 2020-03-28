import strformat, math
import common

#==========================================
#                    
# Vec3 type
#
#==========================================
type
    Vec3* = object
        xyz: array[3, float64]

proc initVec3*(): Vec3 = Vec3(xyz: [0.0, 0.0, 0.0])

proc initVec3*(x, y, z: float64): Vec3 = Vec3(xyz: [x, y, z])

proc `$`*(v: Vec3): string = "[{v.xyz[0]}, {v.xyz[1]}, {v.xyz[2]}]".fmt

proc `+`*(v1: Vec3, v2: Vec3): Vec3 = initVec3(v1.xyz[0] + v2.xyz[0], v1.xyz[
        1] + v2.xyz[1], v1.xyz[2] + v2.xyz[2])
proc `-`*(v1: Vec3, v2: Vec3): Vec3 = initVec3(v1.xyz[0] - v2.xyz[0], v1.xyz[
        1] - v2.xyz[1], v1.xyz[2] - v2.xyz[2])

proc `*`*(v1: Vec3, v2: Vec3): Vec3 =
    initVec3(v1.xyz[0] * v2.xyz[0], v1.xyz[1] * v2.xyz[1], v1.xyz[2] * v2.xyz[2])

proc `[]`*(v: Vec3, i: int): float64 = v.xyz[i]
proc `[]=`*(v: var Vec3, i: int, val: float64): void =
    v.xyz[i] = val
proc x*(v: Vec3): float64 = v.xyz[0]
proc y*(v: Vec3): float64 = v.xyz[1]
proc z*(v: Vec3): float64 = v.xyz[2]
proc `+=`*(v1: var Vec3, v2: Vec3): void =
    v1.xyz[0] += v2.xyz[0]
    v1.xyz[1] += v2.xyz[1]
    v1.xyz[2] += v2.xyz[2]

proc `*=`*(v1: var Vec3, t: float64): void =
    v1.xyz[0] *= t
    v1.xyz[1] *= t
    v1.xyz[2] *= t

proc `/=`*(v1: var Vec3, t: float64): void =
    v1 *= 1.0/t

proc `*`*(v1: Vec3, t: float64): Vec3 =
    initVec3(v1.xyz[0] * t, v1.xyz[1] * t, v1.xyz[2] * t)

proc `/`*(v1: Vec3, t: float64): Vec3 =
    v1 * (1.0/t)

proc `*`*(t: float64, v1: Vec3): Vec3 =
    initVec3(v1.xyz[0] * t, v1.xyz[1] * t, v1.xyz[2] * t)

proc length*(v1: Vec3): float64 = math.sqrt(v1.xyz[0]*v1.xyz[0] + v1.xyz[
        1]*v1.xyz[1] + v1.xyz[2]*v1.xyz[2])
proc lengthSq*(v1: Vec3): float64 = v1.xyz[0]*v1.xyz[0] + v1.xyz[1]*v1.xyz[1] +
        v1.xyz[2]*v1.xyz[2]

proc asColor*(v: Vec3): string = 
    "{(255.999*v.xyz[0]).int} {(255.999*v.xyz[1]).int} {(255.999*v.xyz[2]).int}\n".fmt

proc dot*(v1: Vec3, v2: Vec3): float64 = v1.xyz[0]*v2.xyz[0] + v1.xyz[1]*v2.xyz[
        1] + v1.xyz[2]*v2.xyz[2]

proc `^`*(v1: Vec3, v2: Vec3): Vec3 =
    initVec3(
        v1.xyz[1] * v2.xyz[2] - v1.xyz[2] * v2.xyz[1],
        v1.xyz[2] * v2.xyz[0] - v1.xyz[0] * v2.xyz[2],
        v1.xyz[0] * v2.xyz[1] - v1.xyz[1] * v2.xyz[0])

proc unit*(v: Vec3): Vec3 = v * (1.0/v.length)

proc clamp*(v: var Vec3, min: float64 = 0.0, max: float64 = 1.0) = 
    v.xyz[0] = clamp(v.xyz[0], min, max)
    v.xyz[1] = clamp(v.xyz[1], min, max)
    v.xyz[2] = clamp(v.xyz[2], min, max)

proc clamp*(v: Vec3, min: float64 = 0.0, max: float64 = 1.0): Vec3 = 
    initVec3(
        clamp(v.xyz[0], min, max),
        clamp(v.xyz[1], min, max),
        clamp(v.xyz[2], min, max))

proc sqrt*(v: var Vec3) = 
    v.xyz[0] = sqrt(v.xyz[0])
    v.xyz[1] = sqrt(v.xyz[1])
    v.xyz[2] = sqrt(v.xyz[2])

proc exp*(v: var Vec3, e: float64) = 
    v.xyz[0] = pow(v.xyz[0], e)
    v.xyz[1] = pow(v.xyz[1], e)
    v.xyz[2] = pow(v.xyz[2], e)

proc reflect*(v, n: Vec3): Vec3 = v - 2.0*v.dot(n)*n

proc refract*(v, n: Vec3, index_ratio: float64): Vec3 =
    let cos_theta = (-1.0*v).dot(n)
    let R_par = index_ratio * (v + cos_theta*n)
    let R_vert = -sqrt(1.0 - R_par.lengthSq)*n
    R_par + R_vert

#==========================================
#                    
# Vector related methods
#
#==========================================
proc randomUnitVec*(): Vec3 =
    let a = randomMinMax(0.0, PI)
    let z = randomMinMax(-1.0, 1.0)
    let r = sqrt(1.0 - z*z)
    initVec3(r*cos(a), r*sin(a), z)

when isMainModule:
    var v = initVec3()
    doAssert v.xyz == [0.0, 0.0, 0.0]

    var v2 = initVec3(1.0, 2.0, 3.0)
    doAssert v2.x == 1.0
    doAssert v2.y == 2.0
    doAssert v2.z == 3.0

    doAssert (4.0 * v2).xyz == [4.0, 8.0, 12.0]
    doAssert (v2 * 4.0).xyz == [4.0, 8.0, 12.0]

    doAssert (v + v2).xyz == [1.0, 2.0, 3.0]

    doAssert (v - v2).xyz == [-1.0, -2.0, -3.0]

    doAssert (v * v2).xyz == [0.0, 0.0, 0.0]

    doAssert v2[1] == 2.0

    v2[1] = 4.0
    doAssert v2[1] == 4.0

    v += v2
    doAssert v.xyz == [1.0, 4.0, 3.0]

    v *= 2.0
    doAssert v.xyz == [2.0, 8.0, 6.0]

    v /= 2.0
    doAssert v.xyz == [1.0, 4.0, 3.0]

    let v3 = initVec3(0.0, 4.0, 3.0)
    doAssert v3.length == 5.0
    doAssert v3.lengthSq == 25.0

    let col = initVec3(0.5, 0.1, 1.0)
    doAssert col.asColor == "127 25 255\n"

    doAssert initVec3(1.0, 1.0, 1.0).dot(initVec3(2.0, 3.0, 4.0)) == 9.0

    doAssert (initVec3(1.0, 0.0, 0.0) ^ initVec3(0.0, 1.0, 0.0)).xyz == [0.0,
            0.0, 1.0]

    doAssert (initVec3(2.0, 0.0, 0.0).unit()).xyz == [1.0, 0.0, 0.0]
