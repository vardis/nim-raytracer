import strformat, threadpool
import common, vectors, ray
import shapes, camera, materials, shaders

const maxDepth = 50

proc sky_color(r: Ray): Vec3 = 
    let dir = r.dir.unit
    let t = 0.5*(dir.y + 1.0)
    (1.0 - t)*initVec3(1.0, 1.0, 1.0) + t*initVec3(0.5, 0.7, 1.0)

proc ray_color(r: Ray, h: Hitable, depth: int): Vec3 =
    
    if depth == 0: return initVec3(0.0, 0.0, 0.0)

    var hitRec = HitRecord()
    if h.hit(r, 0.0001, infinity, hitRec):
        var attenuation = initVec3()
        var scatteredRay = initRay()
        let hitable = hitRec.hitable
        let shader = getMaterialShader(hitable.material)

        if shader.scatter(r, hitRec, attenuation, scatteredRay):
            attenuation * ray_color(scatteredRay, h, depth - 1)
        else:
            initVec3()
    else:    
        sky_color(r)


proc writeColor(file: File, col: Vec3): void =
    let norm = 256*col.clamp(0.0, 0.999)
    file.write "{norm.x.int} {norm.y.int} {norm.z.int}\n".fmt

proc computePixel(world: var Hitable, cam: var Camera, imgWidth, imgHeight, x, y, samples: uint): void = 
    var color = initVec3()

    for s in 0..samples:
        let u = (x.float64 + random01()) / imgWidth.float64
        let v = (y.float64 + random01()) / imgHeight.float64
        
        let ray = cam.getRay(u, v)
        let rayColor = ray_color(ray, world, maxDepth)
        
        color += rayColor
    
    color /= samples.float64

    # gamma correction
    color.sqrt()


proc randomScene(): ListOfHitables = 
    var world = initListOfHitables()
    world.add(initSphere(initVec3(0, -1000.0, 0), 1000, initLambertian(initVec3(0.5, 0.5, 0.5))))

    for a in -11..11:
        for b in -11..11:
            let chooseMat = random01()
            let center = initVec3(a.toFloat + 0.9*random01(), 0.2, b.toFloat + 0.9*random01())
            if ((center - initVec3(4, 0.2, 0)).length > 0.9):
                if chooseMat < 0.8:
                    # diffuse
                    let albedo = randomUnitVec() * randomUnitVec()
                    world.add(initSphere(center, 0.2, initLambertian(albedo)))
                elif chooseMat < 0.95:
                    let albedo = initVec3(randomMinMax(0.5, 1.0), randomMinMax(0.5, 1.0), randomMinMax(0.5, 1.0))
                    let fuzz = randomMinMax(0.0, 0.5)
                    world.add(initSphere(center, 0.2, initMetal(albedo, fuzz)))
                else:
                    world.add(initSphere(center, 0.2, initDielectric(1.5)))
    
    world.add(initSphere(initVec3(0.0, 1.0, 0.0), 1.0, initDielectric(1.5)))
    world.add(initSphere(initVec3(-4.0, 1.0, 0.0), 1.0, initLambertian(initVec3(0.4, 0.2, 0.1))))
    world.add(initSphere(initVec3(4.0, 1.0, 0.0), 1.0, initMetal(initVec3(0.7, 0.6, 0.5), 0.0)))
    
    world


when isMainModule:
    
    const image_width = 1200
    const image_height = 800
    const samplesPerPixel = 100
    const aspectRatio = image_width.toFloat / image_height
    const aperture = 0.1
    const lookFrom = initVec3(13.0, 2.0, 3.0)
    const lookAt = initVec3(0.0, 0.0, 0.0)
    const upVector = initVec3(0.0, 1.0, 0.0)

    var imageBuffer: array[image_width*image_height, uint8]
    imageBuffer[10] = 1

    var world = initListOfHitables()
    world.add(initSphere(initVec3(0.0, 0.0, -1.0), 0.5, initLambertian( initVec3(0.1, 0.2, 0.5)))) 
    world.add(initSphere(initVec3(0.0, -100.5, -1.0), 100.0, initLambertian( initVec3(0.8, 0.8, 0.0))))
    
    world.add(initSphere(initVec3(1.0, 0.0, -1.0), 0.5, initMetal(initVec3(0.8, 0.6, 0.2), 0.3)))
    world.add(initSphere(initVec3(-1.0, 0.0, -1.0), 0.5, initDielectric(1.5)))
    # world.add(initSphere(initVec3(-1.0, 0.0, -1.0), -0.45, initDielectric(1.5)))
    
    world.add(initSphere(initVec3(0.0, -0.15, -0.25), 0.1, initDielectric(1.5)))
    world.add(initSphere(initVec3(0.0, -0.15, -0.25), -0.095, initDielectric(1.5)))

    world = randomScene()
    let distToFocus = (lookFrom - lookAt).length
    let cam = initCamera(lookFrom, lookAt, upVector, 20, aspectRatio, aperture, distToFocus)

    echo "P3\nimage_width {image_width} image_height {image_height}\n255\n".fmt

    for j in countdown(image_height-1, 0):
        stderr.writeLine "\rScanlines remaining: {j} ".fmt
        for i in 0..<image_width:
            var color = initVec3()

            for s in 0..samplesPerPixel:
                let u = (i.float64 + random01()) / image_width
                let v = (j.float64 + random01()) / image_height
                
                let ray = cam.getRay(u, v)
                let rayColor = ray_color(ray, world, maxDepth)
                
                color += rayColor
            
            color /= samplesPerPixel

            # gamma correction
            color.sqrt()

            writeColor stdout, color 

    stderr.writeLine "\nDone.\n"
