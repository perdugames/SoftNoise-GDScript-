# SoftNoise2D-GDScript-
GDScript function set generating noise (value noise, perlin noise ...).

## Example of how to use:

*other_script.gd*

```
extends Node

var preScript = preload("res://scripts/softnoise2d.gd")
var softnoise

func _ready():
	softnoise = preScript.softnoise2d.new()
	
	softnoise.simple_noise(x)
	softnoise.simple_noise2d(x, y)
	
	softnoise.value_noise(x, y)
	softnoise.perlin_noise2d(x, y)
	
```
### Preview
Map generated using the **perlin_noise2d()** function.

![SofNoise2D screenshot](map_sofnoise2d_perdugames.png)




