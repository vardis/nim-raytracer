import random 

randomize(1234)

const infinity* = 100000000000.0'f64

proc random01*(): float64 = rand(10000).toFloat / 10000.0

proc randomMinMax*(min: float64, max: float64): float64 = rand(min..max) 

proc clamp*(val: float64, min: float64, max: float64): float64 = 
    if val < min: min elif val > max: max else: val 
    