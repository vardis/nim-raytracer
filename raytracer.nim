import strformat
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


when isMainModule:
    
    const image_width = 200
    const image_height = 100
    const samplesPerPixel = 100

    var world = initListOfHitables()
    world.add(initSphere(initVec3(0.0, 0.0, -1.0), 0.5, initLambertian( initVec3(0.1, 0.2, 0.5)))) 
    world.add(initSphere(initVec3(0.0, -100.5, -1.0), 100.0, initLambertian( initVec3(0.8, 0.8, 0.0))))
    
    world.add(initSphere(initVec3(1.0, 0.0, -1.0), 0.5, initMetal( initVec3(0.8, 0.6, 0.2))))
    world.add(initSphere(initVec3(-1.0, 0.0, -1.0), 0.5, initDielectric(1.5)))
    # world.add(initSphere(initVec3(-1.0, 0.0, -1.0), -0.45, initDielectric(1.5)))
    
    world.add(initSphere(initVec3(0.0, -0.15, -0.25), 0.05, initDielectric(1.5)))
    world.add(initSphere(initVec3(0.0, -0.15, -0.25), -0.045, initDielectric(1.5)))

    let cam = initCamera()

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
