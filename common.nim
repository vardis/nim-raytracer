import random 

randomize(1234)

const infinity* = 100000000000.0'f64

proc random01*(): float64 = rand(10000).toFloat / 10000.0

proc randomMinMax*(min: float64, max: float64): float64 = 
    min + (max - min)*random01()

proc clamp*(val: float64, min: float64, max: float64): float64 = 
    if val < min: min elif val > max: max else: val 

when isMainModule:
    doAssert clamp(0.7, 0, 1.0) == 0.7    
    
    for i in 0..100:
        let r = randomMinMax(0.5, 1.0) 
        doAssert r >= 0.5 and r <= 1.0