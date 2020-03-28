import vectors

const LambertianMaterialType* = 0x1
const MetalMaterialType*      = 0x2
const DielectricMaterialType* = 0x4

type 
    Material* = ref object of RootObj
        materialType: int
        albedo: Vec3
        specular: Vec3

proc materialType*(m: Material): int = m.materialType
proc albedo*(m: Material): Vec3 = m.albedo

type
    Lambertian* = ref object of Material            

proc initLambertian*(a: Vec3): Lambertian = Lambertian(materialType: LambertianMaterialType, albedo: a)


type
    Metal* = ref object of Material    

proc initMetal*(a: Vec3): Metal = Metal(materialType: MetalMaterialType, albedo: a)            

type
    Dielectric* = ref object of Material
        refractIndex*: float64

proc refractIndex*(m: Dielectric): float64 = m.refractIndex

proc initDielectric*(refractIndex: float64): Dielectric = Dielectric(materialType: DielectricMaterialType, refractIndex: refractIndex)    