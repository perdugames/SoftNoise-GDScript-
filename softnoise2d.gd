#SOFTNOISE2D 
#softnoise2d.gd by perdugames
#Based on the studies on this page:
#http://www.angelcode.com/dev/perlin/perlin.html
#I recommend reading, to understand more about perlin noise.
#Example of how to use:
#https://github.com/PerduGames/SoftNoise2D-GDScript-

class softnoise2d:

	#Permutation table
	var p = []
	#Gradient x table
	var gx = []
	#Gradient y table
	var gy = []

	func _init():
		generateTable()
	
	#---------PSEUDO-RANDOM NUMBER GENERATOR------------------------------------
	func simple_noise(var x):
		x = (x >> 13) ^ x
		var _x = int((x * (x * x * 60493 + 19990303) + 1376312589) & 0x7fffffff)
		return 1.0 - (float(_x) / 1073741824.0)
	
	func simple_noise2d(var x, var y):
		var n=int(x)+int(y)*57
		n=(n<<13)^n
		var nn=(n*(n*n*60493+19990303)+1376312589)&0x7fffffff
		return 1.0-(float(nn/1073741824.0))
	
	#---------INTERPOLATION-----------------------------------------------------
	func cosineInterpolation(var v1, var v2, var mu):
		var mu2 = (1.0 - cos( mu * PI ))/2
		return(v1 * (1.0 - mu2) + v2 * mu2)
	
	func linearInterpolation(var v1, var v2, var mu):
		return (1.0-mu)*v1 + mu * v2
		
	#---------NOISE-----------------------------------------------------
	func value_noise(var x,var y):
		var floor_x = x
		var floor_y = y
		
		var g1=simple_noise2d(floor_x,floor_y)
		var g2=simple_noise2d(floor_x+1,floor_y)
		var g3=simple_noise2d(floor_x,floor_y+1)
		var g4=simple_noise2d(floor_x+1,floor_y+1)
		
		var int1 = cosineInterpolation(g1, g2, x - floor_x)
		var int2 = cosineInterpolation(g3 , g4, x - floor_x)
		return cosineInterpolation(int1, int2, y - floor_y)
		
	func generateTable():
		#Start the permutation table
		for i in range(256):
			p.append(i)
		for i in range(256):
			var j = randi() % 256
			var nSwap = p[i]
			p[i]  = p[j]
			p[j]  = nSwap
			
		#Start the gradients table
		for i in range(256):
			gx.append(float(randf())/(32767/2) - 1.0)
			gy.append(float(randf())/(32767/2) - 1.0)
	
	func perlin_noise2d(var x, var y):
		#Compute the integer positions of the four surrounding points
		var qx0 = int(floor(x))
		var qx1 = qx0 + 1
		var qy0 = int(floor(y))
		var qy1 = qy0 + 1
		#Permutate values to get indices to use with the gradient look-up tables
		var q00 = int(p[(qy0 + p[qx0 % 256]) % 256])
		var q01 = int(p[(qy0 + p[qx1 % 256]) % 256])
		var q10 = int(p[(qy1 + p[qx0 % 256]) % 256])
		var q11 = int(p[(qy1 + p[qx1 % 256]) % 256])
		#Vectors from the four points to the input point
		var tx0 = x - floor(x)
		var tx1 = tx0 - 1
		var ty0 = y - floor(y)
		var ty1 = ty0 - 1
		#Dot-product between the vectors and the gradients
		var v00 = gx[q00]*tx0 + gy[q00]*ty0
		var v01 = gx[q01]*tx1 + gy[q01]*ty0
		var v10 = gx[q10]*tx0 + gy[q10]*ty1
		var v11 = gx[q11]*tx1 + gy[q11]*ty1
		#Bi-cubic interpolation
		var wx = (3 - 2*tx0)*tx0*tx0
		var v0 = v00 - wx*(v00 - v01)
		var v1 = v10 - wx*(v10 - v11)
	
		var wy = (3 - 2*ty0)*ty0*ty0
		var v = v0 - wy*(v0 - v1)
		return v