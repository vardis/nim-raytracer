import strformat, threadpool
import common, vectors, ray
import shapes, camera, materials, shaders

const maxDepth = 10

proc sky_color(r: Ray): Vec3 = 
    let dir = r.dir.unit
    let t = 0.5*(clamp(dir.y, 0.0, 1.0) + 1.0)
    (1.0 - t)*initVec3(1.0, 1.0, 1.0) + t*initVec3(0.5, 0.7, 1.0)

proc ray_color(r: Ray, h: Hitable, depth: int): Vec3 =
    
    if depth == maxDepth: return initVec3(0.0, 0.0, 0.0)

    var hitRec = HitRecord()
    if h.hit(r, 0.0001, infinity, hitRec):
        var attenuation = initVec3()
        var scatteredRay = initRay()
        let hitable = hitRec.hitable
        let shader = getMaterialShader(hitable.material)

        if shader.scatter(r, hitRec, attenuation, scatteredRay):
            attenuation * ray_color(scatteredRay, h, depth + 1)
        else:
            initVec3()
    else:    
        sky_color(r)


proc writeImageBuffer(imageBuffer: seq[float64], file: File): void = 
    let buffLen = (imageBuffer.len / 3).int    

    for i in countdown(buffLen-1,0):
        let xnorm = 256*clamp(imageBuffer[i*3], 0.0, 0.999)
        let ynorm = 256*clamp(imageBuffer[i*3+1], 0.0, 0.999)
        let znorm = 256*clamp(imageBuffer[i*3+2], 0.0, 0.999)
        file.writeLine "{xnorm.int} {ynorm.int} {znorm.int}".fmt

type
    PixelResult = tuple[x,y: int, color: Vec3]

proc computePixel(world: ptr ListOfHitables, cam: Camera, imgWidth, imgHeight, x, y, samples: int) : PixelResult {.thread.} = 
    var color = initVec3()

    for s in 0..samples:
        let u = (x.float64 + random01()) / imgWidth.float64
        let v = (y.float64 + random01()) / imgHeight.float64
        
        let ray = cam.getRay(u, v)
        let rayColor = ray_color(ray, world[], 0)
        
        color += rayColor
    
    # color.zeroNaNs
    color /= samples.float64

    # gamma correction
    color.sqrt()

    (x: x, y: y, color: color)

    
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
                    let r = randomUnitVec()
                    let albedo = r*r
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

proc waitPending(imageBuffer: var seq[float64], width, height: int, pending: seq[FlowVar[PixelResult]]): void =
    for future in pending:
        let pixelRes = ^future
        let pixelIdx = 3*(pixelRes.y*width + (width - pixelRes.x - 1))
        imageBuffer[pixelIdx] = pixelRes.color.x
        imageBuffer[pixelIdx + 1] = pixelRes.color.y
        imageBuffer[pixelIdx + 2] = pixelRes.color.z
        

when isMainModule:
    
    const image_width = 300
    const image_height = 200
    const samplesPerPixel = 10
    const aspectRatio = image_width.toFloat / image_height
    const aperture = 0.1
    const lookFrom = initVec3(13.0, 2.0, 3.0)
    const lookAt = initVec3(0.0, 0.0, 0.0)
    const upVector = initVec3(0.0, 1.0, 0.0)

    var imageBuffer: seq[float64] = newSeq[float64](3*image_width*image_height)

    var world = randomScene()
    let distToFocus = (lookFrom - lookAt).length
    let cam = initCamera(lookFrom, lookAt, upVector, 20, aspectRatio, aperture, distToFocus)

    echo "P3\nimage_width {image_width} image_height {image_height}\n255\n".fmt

    var pending = newSeq[FlowVar[PixelResult]]()

    for j in countdown(image_height, 1):
        let y = j - 1
        stderr.writeLine "\rScanlines remaining: {j} ".fmt
        for i in 0..<image_width:
            let future: FlowVar[PixelResult] = spawn computePixel(addr world, cam, image_width, image_height, i, y, samplesPerPixel)
            pending.add(future)
                        
    sync()

    waitPending(imageBuffer, image_width, image_height, pending)

    writeImageBuffer(imageBuffer, stdout)

    stderr.writeLine "\nDone.\n"
