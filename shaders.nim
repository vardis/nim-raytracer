import strformat, math
import common, vectors, shapes, ray, materials


type 
    MaterialShader* = ref object of RootObj

method scatter*(shader: MaterialShader, ray: Ray, hit: var HitRecord, attenuation: var Vec3, scatterRay: var Ray): bool {.base, locks: "unknown".} =
    discard


#==========================================
#                    
# Lambert
#
#==========================================
type
    LambertianShader* = ref object of MaterialShader    

method scatter*(shader: LambertianShader, ray: Ray, hit: var HitRecord, attenuation: var Vec3, scatterRay: var Ray): bool =
    let scatterDir = hit.normal + randomUnitVec()
    scatterRay = initRay(hit.point, scatterDir)
    attenuation = hit.hitable.material.albedo
    true


#==========================================
#                    
# Metal
#
#==========================================
type
    MetalShader* = ref object of MaterialShader    

method scatter*(shader: MetalShader, ray: Ray, hit: var HitRecord, attenuation: var Vec3, scatterRay: var Ray): bool =
    let reflectedDir = ray.dir.unit.reflect(hit.normal)
    scatterRay = initRay(hit.point, reflectedDir)
    attenuation = hit.hitable.material.albedo
    reflectedDir.dot(hit.normal) > 0.0

#==========================================
#                    
# Dielectric
#
#==========================================
type
    DielectricShader* = ref object of MaterialShader

proc schlick(cosine: float64, index_ratio: float64): float64 =
    var r0 = (1.0 - index_ratio) / (1 + index_ratio)
    r0 *= r0
    r0 + (1.0 - r0)*pow(1 - cosine, 5)

method scatter*(shader: DielectricShader, ray: Ray, hit: var HitRecord, attenuation: var Vec3, scatterRay: var Ray): bool =
    let dielectricMat = hit.hitable.material.Dielectric    
    let index_ratio = if hit.frontFace: 1.0 / dielectricMat.refractIndex else: dielectricMat.refractIndex

    let unit_dir = ray.dir.unit
    let cos_theta = min((-1.0*unit_dir).dot(hit.normal), 1.0)
    let sin_theta = sqrt(1.0 - cos_theta*cos_theta)

    # total internal reflection or Schlick approximation for angle-varied reflectivity
    let schlickProb = random01() < schlick(cos_theta, index_ratio)
    let tir = index_ratio * sin_theta > 1.0
    if (tir or schlickProb):
        let reflected = unit_dir.reflect(hit.normal)
        scatterRay = initRay(hit.point, reflected)
    else:
        let refracted = unit_dir.refract(hit.normal, index_ratio)
        scatterRay = initRay(hit.point, refracted)
    
    attenuation = initVec3(1.0, 1.0, 1.0)
    true

#==========================================
#                    
# Supporting methods
#
#==========================================
proc getMaterialShader*(mat: Material): MaterialShader = 
    case mat.materialType
    of LambertianMaterialType:
        LambertianShader()
    of MetalMaterialType:
        MetalShader()
    of DielectricMaterialType:
        DielectricShader()
    else:
        quit "Unhandled material type {mat.materialType}".fmt
