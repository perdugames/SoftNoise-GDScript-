#SOFTNOISE
#MIT License
#
#Copyright (c) 2017 PerduGames
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
#softnoise.gd by perdugames
#Based on the studies on this page:
#http://www.angelcode.com/dev/perlin/perlin.html
#I recommend reading, to understand more about perlin noise.
#Original implementation opensimplex in java:
#https://gist.github.com/KdotJPG/b1270127455a94ac5d19
#Example of how to use:
#https://github.com/PerduGames/SoftNoise-GDScript-

class SoftNoise:

	#Permutation table
	var perm = []
	#Gradient x table
	var gx = []
	#Gradient y table
	var gy = []
	
	#--------------OPENSIMPLEX-----------------------------------
	const STRETCH_CONSTANT_2D = -0.211324865405187 # (1/Math.sqrt(2+1)-1)/2
	const SQUISH_CONSTANT_2D  = 0.366025403784439  # (Math.sqrt(2+1)-1)/2
	const STRETCH_CONSTANT_3D = -1.0 / 6           # (1/Math.sqrt(3+1)-1)/3
	const SQUISH_CONSTANT_3D  = 1.0 / 3            # (Math.sqrt(3+1)-1)/3
	const STRETCH_CONSTANT_4D = -0.138196601125011 # (1/Math.sqrt(4+1)-1)/4
	const SQUISH_CONSTANT_4D  = 0.309016994374947  # (Math.sqrt(4+1)-1)/4
	
	const NORM_CONSTANT_2D = 47
	const NORM_CONSTANT_3D = 103
	const NORM_CONSTANT_4D = 30
	
	const DEFAULT_SEED = 0
	
	var permGradIndex3D = []
	
	#Gradients for 2D. They approximate the directions to the
	#vertices of an octagon from the center.
	var gradients2D = [
			 5,  2,    2,  5,
			-5,  2,   -2,  5,
			 5, -2,    2, -5,
			-5, -2,   -2, -5
		]
	
	#Gradients for 3D. They approximate the directions to the
	#vertices of a rhombicuboctahedron from the center, skewed so
	#that the triangular and square facets can be inscribed inside
	#circles of the same radius.
	var gradients3D = [
		-11,  4,  4,     -4,  11,  4,    -4,  4,  11,
		 11,  4,  4,      4,  11,  4,     4,  4,  11,
		-11, -4,  4,     -4, -11,  4,    -4, -4,  11,
		 11, -4,  4,      4, -11,  4,     4, -4,  11,
		-11,  4, -4,     -4,  11, -4,    -4,  4, -11,
		 11,  4, -4,      4,  11, -4,     4,  4, -11,
		-11, -4, -4,     -4, -11, -4,    -4, -4, -11,
		 11, -4, -4,      4, -11, -4,     4, -4, -11
	]

	#Gradients for 4D. They approximate the directions to the
	#vertices of a disprismatotesseractihexadecachoron from the center,
	#skewed so that the tetrahedral and cubic facets can be inscribed inside
	#spheres of the same radius.
	var gradients4D = [
	     3,  1,  1,  1,      1,  3,  1,  1,      1,  1,  3,  1,      1,  1,  1,  3,
	    -3,  1,  1,  1,     -1,  3,  1,  1,     -1,  1,  3,  1,     -1,  1,  1,  3,
	     3, -1,  1,  1,      1, -3,  1,  1,      1, -1,  3,  1,      1, -1,  1,  3,
	    -3, -1,  1,  1,     -1, -3,  1,  1,     -1, -1,  3,  1,     -1, -1,  1,  3,
	     3,  1, -1,  1,      1,  3, -1,  1,      1,  1, -3,  1,      1,  1, -1,  3,
	    -3,  1, -1,  1,     -1,  3, -1,  1,     -1,  1, -3,  1,     -1,  1, -1,  3,
	     3, -1, -1,  1,      1, -3, -1,  1,      1, -1, -3,  1,      1, -1, -1,  3,
	    -3, -1, -1,  1,     -1, -3, -1,  1,     -1, -1, -3,  1,     -1, -1, -1,  3,
	     3,  1,  1, -1,      1,  3,  1, -1,      1,  1,  3, -1,      1,  1,  1, -3,
	    -3,  1,  1, -1,     -1,  3,  1, -1,     -1,  1,  3, -1,     -1,  1,  1, -3,
	     3, -1,  1, -1,      1, -3,  1, -1,      1, -1,  3, -1,      1, -1,  1, -3,
	    -3, -1,  1, -1,     -1, -3,  1, -1,     -1, -1,  3, -1,     -1, -1,  1, -3,
	     3,  1, -1, -1,      1,  3, -1, -1,      1,  1, -3, -1,      1,  1, -1, -3,
	    -3,  1, -1, -1,     -1,  3, -1, -1,     -1,  1, -3, -1,     -1,  1, -1, -3,
	     3, -1, -1, -1,      1, -3, -1, -1,      1, -1, -3, -1,      1, -1, -1, -3,
	    -3, -1, -1, -1,     -1, -3, -1, -1,     -1, -1, -3, -1,     -1, -1, -1, -3
	]
	
	func _init(var _seed=0):
		generateTable(_seed)
		for i in range(256):
			#Since 3D has 24 gradients, simple bitmask won't work, so precompute modulo array.
			permGradIndex3D.append(int(((perm[i] % (gradients3D.size() / 3)) * 3)))
	
	#---------PSEUDO-RANDOM NUMBER GENERATOR------------------------------------
	func simple_noise1d(var x):
		x = (int(x) >> 13) ^ int(x)
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
	func value_noise2d(var x,var y):
		var floor_x = x
		var floor_y = y
		
		var g1=simple_noise2d(floor_x,floor_y)
		var g2=simple_noise2d(floor_x+1,floor_y)
		var g3=simple_noise2d(floor_x,floor_y+1)
		var g4=simple_noise2d(floor_x+1,floor_y+1)
		
		var int1 = cosineInterpolation(g1, g2, x - floor_x)
		var int2 = cosineInterpolation(g3 , g4, x - floor_x)
		return cosineInterpolation(int1, int2, y - floor_y)
		
	func generateTable(var _seed):
		#Start the permutation table
		for i in range(256):
			perm.append(i)
		for i in range(256):
			var j
			if _seed == 0:
				randomize()
				j = randi() % 256
			else:
				j = int(simple_noise1d(_seed) * 32767) % 256
			var nSwap = perm[i]
			perm[i]  = perm[j]
			perm[j]  = nSwap
			
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
		var q00 = int(perm[(qy0 + perm[qx0 % 256]) % 256])
		var q01 = int(perm[(qy0 + perm[qx1 % 256]) % 256])
		var q10 = int(perm[(qy1 + perm[qx0 % 256]) % 256])
		var q11 = int(perm[(qy1 + perm[qx1 % 256]) % 256])
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
		
	#2D OpenSimplex Noise.
	func openSimplex2D(var x, var y):
		
		#Place input coordinates onto grid.
		var stretchOffset = (x + y) * STRETCH_CONSTANT_2D
		var xs = x + stretchOffset
		var ys = y + stretchOffset
		
		#Floor to get grid coordinates of rhombus (stretched square) super-cell origin.
		var xsb = int(floor(xs))
		var ysb = int(floor(ys))
		
		#Skew out to get actual coordinates of rhombus origin. We'll need these later.
		var squishOffset = (xsb + ysb) * SQUISH_CONSTANT_2D
		var xb = xsb + squishOffset
		var yb = ysb + squishOffset
		
		#Compute grid coordinates relative to rhombus origin.
		var xins = xs - xsb
		var yins = ys - ysb
		
		#Sum those together to get a value that determines which region we're in.
		var inSum = xins + yins
	
		#Positions relative to origin point.
		var dx0 = x - xb
		var dy0 = y - yb
		
		#We'll be defining these inside the next block and using them afterwards.
		var dx_ext
		var dy_ext
		var xsv_ext
		var ysv_ext
		
		var value = 0
	
		#Contribution (1,0)
		var dx1 = dx0 - 1 - SQUISH_CONSTANT_2D
		var dy1 = dy0 - 0 - SQUISH_CONSTANT_2D
		var attn1 = 2 - dx1 * dx1 - dy1 * dy1
		if(attn1 > 0):
			attn1 *= attn1
			value += attn1 * attn1 * extrapolate2d(xsb + 1, ysb + 0, dx1, dy1)
	
		#Contribution (0,1)
		var dx2 = dx0 - 0 - SQUISH_CONSTANT_2D
		var dy2 = dy0 - 1 - SQUISH_CONSTANT_2D
		var attn2 = 2 - dx2 * dx2 - dy2 * dy2
		if(attn2 > 0):
			attn2 *= attn2
			value += attn2 * attn2 * extrapolate2d(xsb + 0, ysb + 1, dx2, dy2)
		
		if(inSum <= 1): #We're inside the triangle (2-Simplex) at (0,0)
			var zins = 1 - inSum
			if(zins > xins || zins > yins): #(0,0) is one of the closest two triangular vertices
				if(xins > yins):
					xsv_ext = xsb + 1
					ysv_ext = ysb - 1
					dx_ext = dx0 - 1
					dy_ext = dy0 + 1
				else:
					xsv_ext = xsb - 1
					ysv_ext = ysb + 1
					dx_ext = dx0 + 1
					dy_ext = dy0 - 1
			else: #(1,0) and (0,1) are the closest two vertices.
				xsv_ext = xsb + 1
				ysv_ext = ysb + 1
				dx_ext = dx0 - 1 - 2 * SQUISH_CONSTANT_2D
				dy_ext = dy0 - 1 - 2 * SQUISH_CONSTANT_2D
	
		else: #We're inside the triangle (2-Simplex) at (1,1)
			var zins = 2 - inSum
			if(zins < xins || zins < yins): #(0,0) is one of the closest two triangular vertices
				if(xins > yins):
					xsv_ext = xsb + 2
					ysv_ext = ysb + 0
					dx_ext = dx0 - 2 - 2 * SQUISH_CONSTANT_2D
					dy_ext = dy0 + 0 - 2 * SQUISH_CONSTANT_2D
				else:
					xsv_ext = xsb + 0
					ysv_ext = ysb + 2
					dx_ext = dx0 + 0 - 2 * SQUISH_CONSTANT_2D
					dy_ext = dy0 - 2 - 2 * SQUISH_CONSTANT_2D
					
			else: #(1,0) and (0,1) are the closest two vertices.
				dx_ext = dx0
				dy_ext = dy0
				xsv_ext = xsb
				ysv_ext = ysb
				
			xsb += 1
			ysb += 1
			dx0 = dx0 - 1 - 2 * SQUISH_CONSTANT_2D
			dy0 = dy0 - 1 - 2 * SQUISH_CONSTANT_2D
		
		#Contribution (0,0) or (1,1)
		var attn0 = 2 - dx0 * dx0 - dy0 * dy0
		if(attn0 > 0):
			attn0 *= attn0
			value += attn0 * attn0 * extrapolate2d(xsb, ysb, dx0, dy0)
		
		#Extra Vertex
		var attn_ext = 2 - dx_ext * dx_ext - dy_ext * dy_ext
		if(attn_ext > 0):
			attn_ext *= attn_ext
			value += attn_ext * attn_ext * extrapolate2d(xsv_ext, ysv_ext, dx_ext, dy_ext)
		
		return value / NORM_CONSTANT_2D
		
#	3D OpenSimplex Noise.
	func openSimplex3D(var x, var y, var z):
	
		#Place input coordinates on simplectic honeycomb.
		var stretchOffset = (x + y + z) * STRETCH_CONSTANT_3D
		var xs = x + stretchOffset
		var ys = y + stretchOffset
		var zs = z + stretchOffset
		
		#Floor to get simplectic honeycomb coordinates of rhombohedron (stretched cube) super-cell origin.
		var xsb = int(floor(xs))
		var ysb = int(floor(ys))
		var zsb = int(floor(zs))
		
		#Skew out to get actual coordinates of rhombohedron origin. We'll need these later.
		var squishOffset = (xsb + ysb + zsb) * SQUISH_CONSTANT_3D
		var xb = xsb + squishOffset
		var yb = ysb + squishOffset
		var zb = zsb + squishOffset
		
		#Compute simplectic honeycomb coordinates relative to rhombohedral origin.
		var xins = xs - xsb
		var yins = ys - ysb
		var zins = zs - zsb
		
		#Sum those together to get a value that determines which region we're in.
		var inSum = xins + yins + zins

		#Positions relative to origin point.
		var dx0 = x - xb
		var dy0 = y - yb
		var dz0 = z - zb
		
		#We'll be defining these inside the next block and using them afterwards.
		var dx_ext0
		var dy_ext0
		var dz_ext0
		var dx_ext1
		var dy_ext1
		var dz_ext1
		var xsv_ext0
		var ysv_ext0
		var zsv_ext0
		var xsv_ext1
		var ysv_ext1
		var zsv_ext1
		
		var value = 0
		if(inSum <= 1):#We're inside the tetrahedron (3-Simplex) at (0,0,0)
			
			#Determine which two of (0,0,1), (0,1,0), (1,0,0) are closest.
			var aPoint = 0x01
			var aScore = xins
			var bPoint = 0x02
			var bScore = yins
			if(aScore >= bScore && zins > bScore):
				bScore = zins
				bPoint = 0x04
			elif(aScore < bScore && zins > aScore):
				aScore = zins
				aPoint = 0x04
			
			#Now we determine the two lattice points not part of the tetrahedron that may contribute.
			#This depends on the closest two tetrahedral vertices, including (0,0,0)
			var wins = 1 - inSum
			if(wins > aScore || wins > bScore): #(0,0,0) is one of the closest two tetrahedral vertices.
				var c
				#Our other closest vertex is the closest out of a and b.
				if(bScore > aScore):
					c = bPoint
				else:
					c = aPoint
				
				if((c & 0x01) == 0):
					xsv_ext0 = xsb - 1
					xsv_ext1 = xsb
					dx_ext0 = dx0 + 1
					dx_ext1 = dx0
				else:
					xsv_ext1 = xsb + 1
					xsv_ext0 = xsv_ext1 
					dx_ext1 = dx0 - 1
					dx_ext0 = dx_ext1 

				if((c & 0x02) == 0):
					ysv_ext1 = ysb
					ysv_ext0 = ysv_ext1 
					dy_ext1 = dy0
					dy_ext0 = dy_ext1 
					if((c & 0x01) == 0):
						ysv_ext1 -= 1
						dy_ext1 += 1
					else:
						ysv_ext0 -= 1
						dy_ext0 += 1
		
				else:
					ysv_ext1 = ysb + 1
					ysv_ext0 = ysv_ext1 
					dy_ext1 = dy0 - 1
					dy_ext0 = dy_ext1 

				if((c & 0x04) == 0):
					zsv_ext0 = zsb
					zsv_ext1 = zsb - 1
					dz_ext0 = dz0
					dz_ext1 = dz0 + 1
				else:
					zsv_ext1 = zsb + 1
					zsv_ext0 = zsv_ext1 
					dz_ext1 = dz0 - 1
					dz_ext0 = dz_ext1

			else: #(0,0,0) is not one of the closest two tetrahedral vertices.
				var c = int(aPoint | bPoint) #Our two extra vertices are determined by the closest two.
				
				if((c & 0x01) == 0):
					xsv_ext0 = xsb
					xsv_ext1 = xsb - 1
					dx_ext0 = dx0 - 2 * SQUISH_CONSTANT_3D
					dx_ext1 = dx0 + 1 - SQUISH_CONSTANT_3D
				else:
					xsv_ext1 = xsb + 1
					xsv_ext0 = xsv_ext1 
					dx_ext0 = dx0 - 1 - 2 * SQUISH_CONSTANT_3D
					dx_ext1 = dx0 - 1 - SQUISH_CONSTANT_3D

				if((c & 0x02) == 0):
					ysv_ext0 = ysb
					ysv_ext1 = ysb - 1
					dy_ext0 = dy0 - 2 * SQUISH_CONSTANT_3D
					dy_ext1 = dy0 + 1 - SQUISH_CONSTANT_3D
				else:
					ysv_ext1 = ysb + 1
					ysv_ext0 = ysv_ext1 
					dy_ext0 = dy0 - 1 - 2 * SQUISH_CONSTANT_3D
					dy_ext1 = dy0 - 1 - SQUISH_CONSTANT_3D

				if((c & 0x04) == 0):
					zsv_ext0 = zsb
					zsv_ext1 = zsb - 1
					dz_ext0 = dz0 - 2 * SQUISH_CONSTANT_3D
					dz_ext1 = dz0 + 1 - SQUISH_CONSTANT_3D
				else:
					zsv_ext1 = zsb + 1
					zsv_ext0 = zsv_ext1
					dz_ext0 = dz0 - 1 - 2 * SQUISH_CONSTANT_3D
					dz_ext1 = dz0 - 1 - SQUISH_CONSTANT_3D

			#Contribution (0,0,0)
			var attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0
			if(attn0 > 0):
				attn0 *= attn0
				value += attn0 * attn0 * extrapolate3d(xsb + 0, ysb + 0, zsb + 0, dx0, dy0, dz0)

			#Contribution (1,0,0)
			var dx1 = dx0 - 1 - SQUISH_CONSTANT_3D
			var dy1 = dy0 - 0 - SQUISH_CONSTANT_3D
			var dz1 = dz0 - 0 - SQUISH_CONSTANT_3D
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1
			if(attn1 > 0):
				attn1 *= attn1
				value += attn1 * attn1 * extrapolate3d(xsb + 1, ysb + 0, zsb + 0, dx1, dy1, dz1)

			#Contribution (0,1,0)
			var dx2 = dx0 - 0 - SQUISH_CONSTANT_3D
			var dy2 = dy0 - 1 - SQUISH_CONSTANT_3D
			var dz2 = dz1
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2
			if(attn2 > 0):
				attn2 *= attn2
				value += attn2 * attn2 * extrapolate3d(xsb + 0, ysb + 1, zsb + 0, dx2, dy2, dz2)

			#Contribution (0,0,1)
			var dx3 = dx2
			var dy3 = dy1
			var dz3 = dz0 - 1 - SQUISH_CONSTANT_3D
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3
			if(attn3 > 0):
				attn3 *= attn3
				value += attn3 * attn3 * extrapolate3d(xsb + 0, ysb + 0, zsb + 1, dx3, dy3, dz3)
		elif(inSum >= 2): #We're inside the tetrahedron (3-Simplex) at (1,1,1)
		
			#Determine which two tetrahedral vertices are the closest, out of (1,1,0), (1,0,1), (0,1,1) but not (1,1,1).
			var aPoint = 0x06
			var aScore = xins
			var bPoint = 0x05
			var bScore = yins
			if(aScore <= bScore && zins < bScore):
				bScore = zins
				bPoint = 0x03
			elif (aScore > bScore && zins < aScore):
				aScore = zins
				aPoint = 0x03
			
			#Now we determine the two lattice points not part of the tetrahedron that may contribute.
			#This depends on the closest two tetrahedral vertices, including (1,1,1)
			var wins = 3 - inSum
			if (wins < aScore || wins < bScore): #(1,1,1) is one of the closest two tetrahedral vertices.
				var c
				#Our other closest vertex is the closest out of a and b.
				if(bScore < aScore):
					c = bPoint
				else:
					c = aPoint
				
				if((c & 0x01) != 0):
					xsv_ext0 = xsb + 2
					xsv_ext1 = xsb + 1
					dx_ext0 = dx0 - 2 - 3 * SQUISH_CONSTANT_3D
					dx_ext1 = dx0 - 1 - 3 * SQUISH_CONSTANT_3D
				else:
					xsv_ext1 = xsb
					xsv_ext0 = xsv_ext1
					dx_ext1 = dx0 - 3 * SQUISH_CONSTANT_3D
					dx_ext0 = dx_ext1

				if((c & 0x02) != 0):
					ysv_ext1 = ysb + 1
					ysv_ext0 = ysv_ext1
					dy_ext1 = dy0 - 1 - 3 * SQUISH_CONSTANT_3D
					dy_ext0 = dy_ext1
					if((c & 0x01) != 0):
						ysv_ext1 += 1
						dy_ext1 -= 1
					else:
						ysv_ext0 += 1
						dy_ext0 -= 1
				else:
					ysv_ext1 = ysb
					ysv_ext0 = ysv_ext1
					dy_ext1 = dy0 - 3 * SQUISH_CONSTANT_3D
					dy_ext0 = dy_ext1 

				if((c & 0x04) != 0):
					zsv_ext0 = zsb + 1
					zsv_ext1 = zsb + 2
					dz_ext0 = dz0 - 1 - 3 * SQUISH_CONSTANT_3D
					dz_ext1 = dz0 - 2 - 3 * SQUISH_CONSTANT_3D
				else:
					zsv_ext1 = zsb
					zsv_ext0 = zsv_ext1
					dz_ext1 = dz0 - 3 * SQUISH_CONSTANT_3D
					dz_ext0 = dz_ext1
			else: #(1,1,1) is not one of the closest two tetrahedral vertices.
				var c = int(aPoint & bPoint) #Our two extra vertices are determined by the closest two.
				
				if((c & 0x01) != 0):
					xsv_ext0 = xsb + 1
					xsv_ext1 = xsb + 2
					dx_ext0 = dx0 - 1 - SQUISH_CONSTANT_3D
					dx_ext1 = dx0 - 2 - 2 * SQUISH_CONSTANT_3D
				else:
					xsv_ext1 = xsb
					xsv_ext0 = xsv_ext1 
					dx_ext0 = dx0 - SQUISH_CONSTANT_3D
					dx_ext1 = dx0 - 2 * SQUISH_CONSTANT_3D

				if((c & 0x02) != 0):
					ysv_ext0 = ysb + 1
					ysv_ext1 = ysb + 2
					dy_ext0 = dy0 - 1 - SQUISH_CONSTANT_3D
					dy_ext1 = dy0 - 2 - 2 * SQUISH_CONSTANT_3D
				else:
					ysv_ext1 = ysb
					ysv_ext0 = ysv_ext1
					dy_ext0 = dy0 - SQUISH_CONSTANT_3D
					dy_ext1 = dy0 - 2 * SQUISH_CONSTANT_3D

				if((c & 0x04) != 0):
					zsv_ext0 = zsb + 1
					zsv_ext1 = zsb + 2
					dz_ext0 = dz0 - 1 - SQUISH_CONSTANT_3D
					dz_ext1 = dz0 - 2 - 2 * SQUISH_CONSTANT_3D
				else:
					zsv_ext1 = zsb
					zsv_ext0 = zsv_ext1 
					dz_ext0 = dz0 - SQUISH_CONSTANT_3D
					dz_ext1 = dz0 - 2 * SQUISH_CONSTANT_3D

			#Contribution (1,1,0)
			var dx3 = dx0 - 1 - 2 * SQUISH_CONSTANT_3D
			var dy3 = dy0 - 1 - 2 * SQUISH_CONSTANT_3D
			var dz3 = dz0 - 0 - 2 * SQUISH_CONSTANT_3D
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3
			if(attn3 > 0):
				attn3 *= attn3
				value += attn3 * attn3 * extrapolate3d(xsb + 1, ysb + 1, zsb + 0, dx3, dy3, dz3)

			#Contribution (1,0,1)
			var dx2 = dx3
			var dy2 = dy0 - 0 - 2 * SQUISH_CONSTANT_3D
			var dz2 = dz0 - 1 - 2 * SQUISH_CONSTANT_3D
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2
			if(attn2 > 0):
				attn2 *= attn2
				value += attn2 * attn2 * extrapolate3d(xsb + 1, ysb + 0, zsb + 1, dx2, dy2, dz2)

			#Contribution (0,1,1)
			var dx1 = dx0 - 0 - 2 * SQUISH_CONSTANT_3D
			var dy1 = dy3
			var dz1 = dz2
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1
			if(attn1 > 0):
				attn1 *= attn1
				value += attn1 * attn1 * extrapolate3d(xsb + 0, ysb + 1, zsb + 1, dx1, dy1, dz1)

			#Contribution (1,1,1)
			dx0 = dx0 - 1 - 3 * SQUISH_CONSTANT_3D
			dy0 = dy0 - 1 - 3 * SQUISH_CONSTANT_3D
			dz0 = dz0 - 1 - 3 * SQUISH_CONSTANT_3D
			var attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0
			if(attn0 > 0):
				attn0 *= attn0
				value += attn0 * attn0 * extrapolate3d(xsb + 1, ysb + 1, zsb + 1, dx0, dy0, dz0)
		else: #We're inside the octahedron (Rectified 3-Simplex) in between.
			var aScore
			var aPoint
			var aIsFurtherSide
			var bScore
			var bPoint
			var bIsFurtherSide

			#Decide between point (0,0,1) and (1,1,0) as closest
			var p1 = xins + yins
			if(p1 > 1):
				aScore = p1 - 1
				aPoint = 0x03
				aIsFurtherSide = true
			else:
				aScore = 1 - p1
				aPoint = 0x04
				aIsFurtherSide = false

			#Decide between point (0,1,0) and (1,0,1) as closest
			var p2 = xins + zins
			if(p2 > 1):
				bScore = p2 - 1
				bPoint = 0x05
				bIsFurtherSide = true
			else:
				bScore = 1 - p2
				bPoint = 0x02
				bIsFurtherSide = false
			
			#The closest out of the two (1,0,0) and (0,1,1) will replace the furthest out of the two decided above, if closer.
			var p3 = yins + zins
			if(p3 > 1):
				var score = p3 - 1
				if(aScore <= bScore && aScore < score):
					aScore = score
					aPoint = 0x06
					aIsFurtherSide = true
				elif(aScore > bScore && bScore < score):
					bScore = score
					bPoint = 0x06
					bIsFurtherSide = true
			else:
				var score = 1 - p3
				if(aScore <= bScore && aScore < score):
					aScore = score
					aPoint = 0x01
					aIsFurtherSide = false
				elif(aScore > bScore && bScore < score):
					bScore = score
					bPoint = 0x01
					bIsFurtherSide = false
			
			#Where each of the two closest points are determines how the extra two vertices are calculated.
			if(aIsFurtherSide == bIsFurtherSide):
				if(aIsFurtherSide): #Both closest points on (1,1,1) side

					#One of the two extra points is (1,1,1)
					dx_ext0 = dx0 - 1 - 3 * SQUISH_CONSTANT_3D
					dy_ext0 = dy0 - 1 - 3 * SQUISH_CONSTANT_3D
					dz_ext0 = dz0 - 1 - 3 * SQUISH_CONSTANT_3D
					xsv_ext0 = xsb + 1
					ysv_ext0 = ysb + 1
					zsv_ext0 = zsb + 1

					#Other extra point is based on the shared axis.
					var c = int(aPoint & bPoint)
					if((c & 0x01) != 0):
						dx_ext1 = dx0 - 2 - 2 * SQUISH_CONSTANT_3D
						dy_ext1 = dy0 - 2 * SQUISH_CONSTANT_3D
						dz_ext1 = dz0 - 2 * SQUISH_CONSTANT_3D
						xsv_ext1 = xsb + 2
						ysv_ext1 = ysb
						zsv_ext1 = zsb
					elif((c & 0x02) != 0):
						dx_ext1 = dx0 - 2 * SQUISH_CONSTANT_3D
						dy_ext1 = dy0 - 2 - 2 * SQUISH_CONSTANT_3D
						dz_ext1 = dz0 - 2 * SQUISH_CONSTANT_3D
						xsv_ext1 = xsb
						ysv_ext1 = ysb + 2
						zsv_ext1 = zsb
					else:
						dx_ext1 = dx0 - 2 * SQUISH_CONSTANT_3D
						dy_ext1 = dy0 - 2 * SQUISH_CONSTANT_3D
						dz_ext1 = dz0 - 2 - 2 * SQUISH_CONSTANT_3D
						xsv_ext1 = xsb
						ysv_ext1 = ysb
						zsv_ext1 = zsb + 2
				else: #Both closest points on (0,0,0) side

					#One of the two extra points is (0,0,0)
					dx_ext0 = dx0
					dy_ext0 = dy0
					dz_ext0 = dz0
					xsv_ext0 = xsb
					ysv_ext0 = ysb
					zsv_ext0 = zsb

					#Other extra point is based on the omitted axis.
					var c = int(aPoint | bPoint)
					if((c & 0x01) == 0):
						dx_ext1 = dx0 + 1 - SQUISH_CONSTANT_3D
						dy_ext1 = dy0 - 1 - SQUISH_CONSTANT_3D
						dz_ext1 = dz0 - 1 - SQUISH_CONSTANT_3D
						xsv_ext1 = xsb - 1
						ysv_ext1 = ysb + 1
						zsv_ext1 = zsb + 1
					elif ((c & 0x02) == 0):
						dx_ext1 = dx0 - 1 - SQUISH_CONSTANT_3D
						dy_ext1 = dy0 + 1 - SQUISH_CONSTANT_3D
						dz_ext1 = dz0 - 1 - SQUISH_CONSTANT_3D
						xsv_ext1 = xsb + 1
						ysv_ext1 = ysb - 1
						zsv_ext1 = zsb + 1
					else:
						dx_ext1 = dx0 - 1 - SQUISH_CONSTANT_3D
						dy_ext1 = dy0 - 1 - SQUISH_CONSTANT_3D
						dz_ext1 = dz0 + 1 - SQUISH_CONSTANT_3D
						xsv_ext1 = xsb + 1
						ysv_ext1 = ysb + 1
						zsv_ext1 = zsb - 1

			else: #One point on (0,0,0) side, one point on (1,1,1) side
				var c1
				var c2
				if(aIsFurtherSide):
					c1 = aPoint
					c2 = bPoint
				else:
					c1 = bPoint
					c2 = aPoint

				#One contribution is a permutation of (1,1,-1)
				if((c1 & 0x01) == 0):
					dx_ext0 = dx0 + 1 - SQUISH_CONSTANT_3D
					dy_ext0 = dy0 - 1 - SQUISH_CONSTANT_3D
					dz_ext0 = dz0 - 1 - SQUISH_CONSTANT_3D
					xsv_ext0 = xsb - 1
					ysv_ext0 = ysb + 1
					zsv_ext0 = zsb + 1
				elif((c1 & 0x02) == 0):
					dx_ext0 = dx0 - 1 - SQUISH_CONSTANT_3D
					dy_ext0 = dy0 + 1 - SQUISH_CONSTANT_3D
					dz_ext0 = dz0 - 1 - SQUISH_CONSTANT_3D
					xsv_ext0 = xsb + 1
					ysv_ext0 = ysb - 1
					zsv_ext0 = zsb + 1
				else:
					dx_ext0 = dx0 - 1 - SQUISH_CONSTANT_3D
					dy_ext0 = dy0 - 1 - SQUISH_CONSTANT_3D
					dz_ext0 = dz0 + 1 - SQUISH_CONSTANT_3D
					xsv_ext0 = xsb + 1
					ysv_ext0 = ysb + 1
					zsv_ext0 = zsb - 1

				#One contribution is a permutation of (0,0,2)
				dx_ext1 = dx0 - 2 * SQUISH_CONSTANT_3D
				dy_ext1 = dy0 - 2 * SQUISH_CONSTANT_3D
				dz_ext1 = dz0 - 2 * SQUISH_CONSTANT_3D
				xsv_ext1 = xsb
				ysv_ext1 = ysb
				zsv_ext1 = zsb
				if((c2 & 0x01) != 0):
					dx_ext1 -= 2
					xsv_ext1 += 2
				elif((c2 & 0x02) != 0):
					dy_ext1 -= 2
					ysv_ext1 += 2
				else:
					dz_ext1 -= 2
					zsv_ext1 += 2

			#Contribution (1,0,0)
			var dx1 = dx0 - 1 - SQUISH_CONSTANT_3D
			var dy1 = dy0 - 0 - SQUISH_CONSTANT_3D
			var dz1 = dz0 - 0 - SQUISH_CONSTANT_3D
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1
			if(attn1 > 0):
				attn1 *= attn1
				value += attn1 * attn1 * extrapolate3d(xsb + 1, ysb + 0, zsb + 0, dx1, dy1, dz1)

			#Contribution (0,1,0)
			var dx2 = dx0 - 0 - SQUISH_CONSTANT_3D
			var dy2 = dy0 - 1 - SQUISH_CONSTANT_3D
			var dz2 = dz1
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2
			if(attn2 > 0):
				attn2 *= attn2
				value += attn2 * attn2 * extrapolate3d(xsb + 0, ysb + 1, zsb + 0, dx2, dy2, dz2)

			#Contribution (0,0,1)
			var dx3 = dx2
			var dy3 = dy1
			var dz3 = dz0 - 1 - SQUISH_CONSTANT_3D
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3
			if(attn3 > 0):
				attn3 *= attn3
				value += attn3 * attn3 * extrapolate3d(xsb + 0, ysb + 0, zsb + 1, dx3, dy3, dz3)

			#Contribution (1,1,0)
			var dx4 = dx0 - 1 - 2 * SQUISH_CONSTANT_3D
			var dy4 = dy0 - 1 - 2 * SQUISH_CONSTANT_3D
			var dz4 = dz0 - 0 - 2 * SQUISH_CONSTANT_3D
			var attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4
			if(attn4 > 0):
				attn4 *= attn4
				value += attn4 * attn4 * extrapolate3d(xsb + 1, ysb + 1, zsb + 0, dx4, dy4, dz4)

			#/Contribution (1,0,1)
			var dx5 = dx4
			var dy5 = dy0 - 0 - 2 * SQUISH_CONSTANT_3D
			var dz5 = dz0 - 1 - 2 * SQUISH_CONSTANT_3D
			var attn5 = 2 - dx5 * dx5 - dy5 * dy5 - dz5 * dz5
			if(attn5 > 0):
				attn5 *= attn5
				value += attn5 * attn5 * extrapolate3d(xsb + 1, ysb + 0, zsb + 1, dx5, dy5, dz5)

			#Contribution (0,1,1)
			var dx6 = dx0 - 0 - 2 * SQUISH_CONSTANT_3D
			var dy6 = dy4
			var dz6 = dz5
			var attn6 = 2 - dx6 * dx6 - dy6 * dy6 - dz6 * dz6
			if(attn6 > 0):
				attn6 *= attn6
				value += attn6 * attn6 * extrapolate3d(xsb + 0, ysb + 1, zsb + 1, dx6, dy6, dz6)
 
		#First extra vertex
		var attn_ext0 = 2 - dx_ext0 * dx_ext0 - dy_ext0 * dy_ext0 - dz_ext0 * dz_ext0
		if(attn_ext0 > 0):
			attn_ext0 *= attn_ext0
			value += attn_ext0 * attn_ext0 * extrapolate3d(xsv_ext0, ysv_ext0, zsv_ext0, dx_ext0, dy_ext0, dz_ext0)

		#Second extra vertex
		var attn_ext1 = 2 - dx_ext1 * dx_ext1 - dy_ext1 * dy_ext1 - dz_ext1 * dz_ext1
		if(attn_ext1 > 0):
			attn_ext1 *= attn_ext1
			value += attn_ext1 * attn_ext1 * extrapolate3d(xsv_ext1, ysv_ext1, zsv_ext1, dx_ext1, dy_ext1, dz_ext1)
		
		return value / NORM_CONSTANT_3D

	#4D OpenSimplex Noise.
	func openSimplex4D(var x, var y, var z, var w):
	
		#Place input coordinates on simplectic honeycomb.
		var stretchOffset = (x + y + z + w) * STRETCH_CONSTANT_4D
		var xs = x + stretchOffset
		var ys = y + stretchOffset
		var zs = z + stretchOffset
		var ws = w + stretchOffset
		
		#Floor to get simplectic honeycomb coordinates of rhombo-hypercube super-cell origin.
		var xsb = int(floor(xs))
		var ysb = int(floor(ys))
		var zsb = int(floor(zs))
		var wsb = int(floor(ws))
		
		#Skew out to get actual coordinates of stretched rhombo-hypercube origin. We'll need these later.
		var squishOffset = (xsb + ysb + zsb + wsb) * SQUISH_CONSTANT_4D
		var xb = xsb + squishOffset
		var yb = ysb + squishOffset
		var zb = zsb + squishOffset
		var wb = wsb + squishOffset
		
		#Compute simplectic honeycomb coordinates relative to rhombo-hypercube origin.
		var xins = xs - xsb
		var yins = ys - ysb
		var zins = zs - zsb
		var wins = ws - wsb
		
		#Sum those together to get a value that determines which region we're in.
		var inSum = xins + yins + zins + wins

		#Positions relative to origin point.
		var dx0 = x - xb
		var dy0 = y - yb
		var dz0 = z - zb
		var dw0 = w - wb
		
		#We'll be defining these inside the next block and using them afterwards.
		var dx_ext0
		var dy_ext0
		var dz_ext0
		var dw_ext0
		var dx_ext1
		var dy_ext1
		var dz_ext1
		var dw_ext1
		var dx_ext2
		var dy_ext2
		var dz_ext2
		var dw_ext2
		var xsv_ext0
		var ysv_ext0
		var zsv_ext0
		var wsv_ext0
		var xsv_ext1
		var ysv_ext1
		var zsv_ext1
		var wsv_ext1
		var xsv_ext2
		var ysv_ext2
		var zsv_ext2
		var wsv_ext2
		
		var value = 0
		if(inSum <= 1): #We're inside the pentachoron (4-Simplex) at (0,0,0,0)

			#Determine which two of (0,0,0,1), (0,0,1,0), (0,1,0,0), (1,0,0,0) are closest.
			var aPoint = 0x01
			var aScore = xins
			var bPoint = 0x02
			var bScore = yins
			if(aScore >= bScore && zins > bScore):
				bScore = zins
				bPoint = 0x04
			elif(aScore < bScore && zins > aScore):
				aScore = zins
				aPoint = 0x04
			if(aScore >= bScore && wins > bScore):
				bScore = wins
				bPoint = 0x08
			elif(aScore < bScore && wins > aScore):
				aScore = wins
				aPoint = 0x08
			
			#Now we determine the three lattice points not part of the pentachoron that may contribute.
			#This depends on the closest two pentachoron vertices, including (0,0,0,0)
			var uins = 1 - inSum
			if(uins > aScore || uins > bScore): #(0,0,0,0) is one of the closest two pentachoron vertices.
				var c
				#Our other closest vertex is the closest out of a and b.
				if(bScore > aScore):
					c = bPoint
				else:
					c = aPoint

				if((c & 0x01) == 0):
					xsv_ext0 = xsb - 1
					xsv_ext2 = xsb
					xsv_ext1 = xsv_ext2 
					dx_ext0 = dx0 + 1
					dx_ext2 = dx0
					dx_ext1 = dx_ext2 
				else:
					xsv_ext2 = xsb + 1
					xsv_ext1 = xsv_ext2 
					xsv_ext0 = xsv_ext1 
					dx_ext2 = dx0 - 1
					dx_ext1 = dx_ext2 
					dx_ext0 = dx_ext1 

				if((c & 0x02) == 0): 
					ysv_ext2 = ysb
					ysv_ext1 = ysv_ext2
					ysv_ext0 = ysv_ext1
					dy_ext2 = dy0
					dy_ext1 = dy_ext2 
					dy_ext0 = dy_ext1 
					if((c & 0x01) == 0x01):
						ysv_ext0 -= 1
						dy_ext0 += 1
					else:
						ysv_ext1 -= 1
						dy_ext1 += 1
				else:
					ysv_ext2 = ysb + 1
					ysv_ext1 = ysv_ext2
					ysv_ext0 = ysv_ext1 
					dy_ext2 = dy0 - 1
					dy_ext1 = dy_ext2
					dy_ext0 = dy_ext1 
				
				if((c & 0x04) == 0):
					zsv_ext2 = zsb
					zsv_ext1 = zsv_ext2
					zsv_ext0 = zsv_ext1
					dz_ext2 = dz0
					dz_ext1 = dz_ext2
					dz_ext0 = dz_ext1 
					if((c & 0x03) != 0):
						if((c & 0x03) == 0x03):
							zsv_ext0 -= 1
							dz_ext0 += 1
						else:
							zsv_ext1 -= 1
							dz_ext1 += 1
					else:
						zsv_ext2 -= 1
						dz_ext2 += 1
				else:
					zsv_ext2 = zsb + 1
					zsv_ext1 = zsv_ext2
					zsv_ext0 = zsv_ext1 
					dz_ext2 = dz0 - 1
					dz_ext1 = dz_ext2
					dz_ext0 = dz_ext1 
				
				if((c & 0x08) == 0):
					wsv_ext1 = wsb
					wsv_ext0 = wsv_ext1
					wsv_ext2 = wsb - 1
					dw_ext1 = dw0
					dw_ext0 = dw_ext1 
					dw_ext2 = dw0 + 1
				else:
					wsv_ext2 = wsb + 1
					wsv_ext1 = wsv_ext2
					wsv_ext0 = wsv_ext1 
					dw_ext2 = dw0 - 1
					dw_ext1 = dw_ext2
					dw_ext0 = dw_ext1 
			else: #(0,0,0,0) is not one of the closest two pentachoron vertices.
				var c = int(aPoint | bPoint) #Our three extra vertices are determined by the closest two.
				
				if((c & 0x01) == 0):
					xsv_ext2 = xsb
					xsv_ext0 = xsv_ext2 
					xsv_ext1 = xsb - 1
					dx_ext0 = dx0 - 2 * SQUISH_CONSTANT_4D
					dx_ext1 = dx0 + 1 - SQUISH_CONSTANT_4D
					dx_ext2 = dx0 - SQUISH_CONSTANT_4D
				else:
					xsv_ext2 = xsb + 1
					xsv_ext1 = xsv_ext2
					xsv_ext0 = xsv_ext1 
					dx_ext0 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
					dx_ext2 = dx0 - 1 - SQUISH_CONSTANT_4D
					dx_ext1 = dx_ext2
				
				if((c & 0x02) == 0):
					ysv_ext2 = ysb
					ysv_ext1 = ysv_ext2
					ysv_ext0 = ysv_ext1 
					dy_ext0 = dy0 - 2 * SQUISH_CONSTANT_4D
					dy_ext2 = dy0 - SQUISH_CONSTANT_4D
					dy_ext1 = dy_ext2 
					if((c & 0x01) == 0x01):
						ysv_ext1 -= 1
						dy_ext1 += 1
					else:
						ysv_ext2 -= 1
						dy_ext2 += 1
				else:
					ysv_ext2 = ysb + 1
					ysv_ext1 = ysv_ext2
					ysv_ext0 = ysv_ext1 
					dy_ext0 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
					dy_ext2 = dy0 - 1 - SQUISH_CONSTANT_4D
					dy_ext1 = dy_ext2 
				
				if((c & 0x04) == 0):
					zsv_ext2 = zsb
					zsv_ext1 = zsv_ext2
					zsv_ext0 = zsv_ext1 
					dz_ext0 = dz0 - 2 * SQUISH_CONSTANT_4D
					dz_ext2 = dz0 - SQUISH_CONSTANT_4D
					dz_ext1 = dz_ext2 
					if((c & 0x03) == 0x03):
						zsv_ext1 -= 1
						dz_ext1 += 1
					else:
						zsv_ext2 -= 1
						dz_ext2 += 1
				else:
					zsv_ext2 = zsb + 1
					zsv_ext1 = zsv_ext2
					zsv_ext0 = zsv_ext1 
					dz_ext0 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
					dz_ext2 = dz0 - 1 - SQUISH_CONSTANT_4D
					dz_ext1 = dz_ext2 
				
				if((c & 0x08) == 0):
					wsv_ext1 = wsb
					wsv_ext0 = wsv_ext1 
					wsv_ext2 = wsb - 1
					dw_ext0 = dw0 - 2 * SQUISH_CONSTANT_4D
					dw_ext1 = dw0 - SQUISH_CONSTANT_4D
					dw_ext2 = dw0 + 1 - SQUISH_CONSTANT_4D
				else:
					wsv_ext2 = wsb + 1
					wsv_ext1 = wsv_ext2 
					wsv_ext0 = wsv_ext1 
					dw_ext0 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
					dw_ext2 = dw0 - 1 - SQUISH_CONSTANT_4D
					dw_ext1 = dw_ext2

			#Contribution (0,0,0,0)
			var attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0 - dw0 * dw0
			if(attn0 > 0):
				attn0 *= attn0
				value += attn0 * attn0 * extrapolate4d(xsb + 0, ysb + 0, zsb + 0, wsb + 0, dx0, dy0, dz0, dw0)

			#Contribution (1,0,0,0)
			var dx1 = dx0 - 1 - SQUISH_CONSTANT_4D
			var dy1 = dy0 - 0 - SQUISH_CONSTANT_4D
			var dz1 = dz0 - 0 - SQUISH_CONSTANT_4D
			var dw1 = dw0 - 0 - SQUISH_CONSTANT_4D
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1
			if(attn1 > 0):
				attn1 *= attn1
				value += attn1 * attn1 * extrapolate4d(xsb + 1, ysb + 0, zsb + 0, wsb + 0, dx1, dy1, dz1, dw1)

			#Contribution (0,1,0,0)
			var dx2 = dx0 - 0 - SQUISH_CONSTANT_4D
			var dy2 = dy0 - 1 - SQUISH_CONSTANT_4D
			var dz2 = dz1
			var dw2 = dw1
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2
			if(attn2 > 0):
				attn2 *= attn2
				value += attn2 * attn2 * extrapolate4d(xsb + 0, ysb + 1, zsb + 0, wsb + 0, dx2, dy2, dz2, dw2)

			#Contribution (0,0,1,0)
			var dx3 = dx2
			var dy3 = dy1
			var dz3 = dz0 - 1 - SQUISH_CONSTANT_4D
			var dw3 = dw1
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3
			if(attn3 > 0):
				attn3 *= attn3
				value += attn3 * attn3 * extrapolate4d(xsb + 0, ysb + 0, zsb + 1, wsb + 0, dx3, dy3, dz3, dw3)

			#Contribution (0,0,0,1)
			var dx4 = dx2
			var dy4 = dy1
			var dz4 = dz1
			var dw4 = dw0 - 1 - SQUISH_CONSTANT_4D
			var attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4
			if(attn4 > 0):
				attn4 *= attn4
				value += attn4 * attn4 * extrapolate4d(xsb + 0, ysb + 0, zsb + 0, wsb + 1, dx4, dy4, dz4, dw4)
		elif(inSum >= 3): #We're inside the pentachoron (4-Simplex) at (1,1,1,1)
			#Determine which two of (1,1,1,0), (1,1,0,1), (1,0,1,1), (0,1,1,1) are closest.
			var aPoint = 0x0E
			var aScore = xins
			var bPoint = 0x0D
			var bScore = yins
			if(aScore <= bScore && zins < bScore):
				bScore = zins
				bPoint = 0x0B
			elif (aScore > bScore && zins < aScore):
				aScore = zins
				aPoint = 0x0B

			if(aScore <= bScore && wins < bScore):
				bScore = wins
				bPoint = 0x07
			elif(aScore > bScore && wins < aScore):
				aScore = wins
				aPoint = 0x07
			
			#Now we determine the three lattice points not part of the pentachoron that may contribute.
			#This depends on the closest two pentachoron vertices, including (0,0,0,0)
			var uins = 4 - inSum
			if (uins < aScore || uins < bScore): #(1,1,1,1) is one of the closest two pentachoron vertices.
				var c 
				#Our other closest vertex is the closest out of a and b.
				if(bScore < aScore):
					c = bPoint
				else:
					c = aPoint
				
				if((c & 0x01) != 0):
					xsv_ext0 = xsb + 2
					xsv_ext2 = xsb + 1
					xsv_ext1 = xsv_ext2
					dx_ext0 = dx0 - 2 - 4 * SQUISH_CONSTANT_4D
					dx_ext2 = dx0 - 1 - 4 * SQUISH_CONSTANT_4D
					dx_ext1 = dx_ext2 
				else: 
					xsv_ext2 = xsb
					xsv_ext1 = xsv_ext2
					xsv_ext0 = xsv_ext1
					dx_ext2 = dx0 - 4 * SQUISH_CONSTANT_4D
					dx_ext1 = dx_ext2
					dx_ext0 = dx_ext1 

				if((c & 0x02) != 0):
					ysv_ext2 = ysb + 1
					ysv_ext1 = ysv_ext2
					ysv_ext0 = ysv_ext1
					dy_ext2 = dy0 - 1 - 4 * SQUISH_CONSTANT_4D
					dy_ext1 = dy_ext2
					dy_ext0 = dy_ext1  
					if((c & 0x01) != 0):
						ysv_ext1 += 1
						dy_ext1 -= 1
					else:
						ysv_ext0 += 1
						dy_ext0 -= 1
				else:
					ysv_ext2 = ysb
					ysv_ext1 = ysv_ext2
					ysv_ext0 = ysv_ext1  	
					dy_ext2 = dy0 - 4 * SQUISH_CONSTANT_4D
					dy_ext1 = dy_ext2
					dy_ext0 = dy_ext1 
				
				if((c & 0x04) != 0):
					zsv_ext2 = zsb + 1
					zsv_ext1 = zsv_ext2
					zsv_ext0 = zsv_ext1  
					dz_ext2 = dz0 - 1 - 4 * SQUISH_CONSTANT_4D
					dz_ext1 = dz_ext2
					dz_ext0 = dz_ext1 
					if((c & 0x03) != 0x03):
						if((c & 0x03) == 0):
							zsv_ext0 += 1
							dz_ext0 -= 1
						else:
							zsv_ext1 += 1
							dz_ext1 -= 1
					else:
						zsv_ext2 += 1
						dz_ext2 -= 1
				else:
					zsv_ext2 = zsb
					zsv_ext1 = zsv_ext2
					zsv_ext0 = zsv_ext1
					dz_ext2 = dz0 - 4 * SQUISH_CONSTANT_4D
					dz_ext1 = dz_ext2
					dz_ext0 = dz_ext1 
				
				if((c & 0x08) != 0):
					wsv_ext1 = wsb + 1
					wsv_ext0 = wsv_ext1 
					wsv_ext2 = wsb + 2
					dw_ext1 = dw0 - 1 - 4 * SQUISH_CONSTANT_4D
					dw_ext0 = dw_ext1 
					dw_ext2 = dw0 - 2 - 4 * SQUISH_CONSTANT_4D
				else:
					wsv_ext2 = wsb
					wsv_ext1 = wsv_ext2
					wsv_ext0 = wsv_ext1 
					dw_ext2 = dw0 - 4 * SQUISH_CONSTANT_4D
					dw_ext1 = dw_ext2
					dw_ext0 = dw_ext1 
			else: #(1,1,1,1) is not one of the closest two pentachoron vertices.
				var c = int(aPoint & bPoint) #//Our three extra vertices are determined by the closest two.
				
				if((c & 0x01) != 0):
					xsv_ext2 = xsb + 1
					xsv_ext0 = xsv_ext2 
					xsv_ext1 = xsb + 2
					dx_ext0 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
					dx_ext1 = dx0 - 2 - 3 * SQUISH_CONSTANT_4D
					dx_ext2 = dx0 - 1 - 3 * SQUISH_CONSTANT_4D
				else:
					xsv_ext2 = xsb
					xsv_ext1 = xsv_ext2
					xsv_ext0 = xsv_ext1 
					dx_ext0 = dx0 - 2 * SQUISH_CONSTANT_4D
					dx_ext2 = dx0 - 3 * SQUISH_CONSTANT_4D
					dx_ext1 = dx_ext2
				
				if((c & 0x02) != 0):
					ysv_ext2 = ysb + 1
					ysv_ext1 = ysv_ext2
					ysv_ext0 = ysv_ext1 
					dy_ext0 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
					dy_ext2 = dy0 - 1 - 3 * SQUISH_CONSTANT_4D
					dy_ext1 = dy_ext2 
					if((c & 0x01) != 0):
						ysv_ext2 += 1
						dy_ext2 -= 1
					else:
						ysv_ext1 += 1
						dy_ext1 -= 1
				else:
					ysv_ext2 = ysb
					ysv_ext1 = ysv_ext2
					ysv_ext0 = ysv_ext1 
					dy_ext0 = dy0 - 2 * SQUISH_CONSTANT_4D
					dy_ext2 = dy0 - 3 * SQUISH_CONSTANT_4D
					dy_ext1 = dy_ext2
				
				if((c & 0x04) != 0):
					zsv_ext2 = zsb + 1
					zsv_ext1 = zsv_ext2
					zsv_ext0 = zsv_ext1 
					dz_ext0 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
					dz_ext2 = dz0 - 1 - 3 * SQUISH_CONSTANT_4D
					dz_ext1 = dz_ext2 
					if((c & 0x03) != 0):
						zsv_ext2 += 1
						dz_ext2 -= 1
					else:
						zsv_ext1 += 1
						dz_ext1 -= 1
				else:
					zsv_ext2 = zsb
					zsv_ext1 = zsv_ext2
					zsv_ext0 = zsv_ext1 
					dz_ext0 = dz0 - 2 * SQUISH_CONSTANT_4D
					dz_ext2 = dz0 - 3 * SQUISH_CONSTANT_4D
					dz_ext1 = dz_ext2
				
				if((c & 0x08) != 0):
					wsv_ext1 = wsb + 1
					wsv_ext0 = wsv_ext1
					wsv_ext2 = wsb + 2
					dw_ext0 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
					dw_ext1 = dw0 - 1 - 3 * SQUISH_CONSTANT_4D
					dw_ext2 = dw0 - 2 - 3 * SQUISH_CONSTANT_4D
				else:
					wsv_ext2 = wsb
					wsv_ext1 = wsv_ext2
					wsv_ext0 = wsv_ext1 
					dw_ext0 = dw0 - 2 * SQUISH_CONSTANT_4D
					dw_ext2 = dw0 - 3 * SQUISH_CONSTANT_4D
					dw_ext1 = dw_ext2

			#Contribution (1,1,1,0)
			var dx4 = dx0 - 1 - 3 * SQUISH_CONSTANT_4D
			var dy4 = dy0 - 1 - 3 * SQUISH_CONSTANT_4D
			var dz4 = dz0 - 1 - 3 * SQUISH_CONSTANT_4D
			var dw4 = dw0 - 3 * SQUISH_CONSTANT_4D
			var attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4
			if(attn4 > 0):
				attn4 *= attn4
				value += attn4 * attn4 * extrapolate4d(xsb + 1, ysb + 1, zsb + 1, wsb + 0, dx4, dy4, dz4, dw4)

			#Contribution (1,1,0,1)
			var dx3 = dx4
			var dy3 = dy4
			var dz3 = dz0 - 3 * SQUISH_CONSTANT_4D
			var dw3 = dw0 - 1 - 3 * SQUISH_CONSTANT_4D
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3
			if(attn3 > 0):
				attn3 *= attn3
				value += attn3 * attn3 * extrapolate4d(xsb + 1, ysb + 1, zsb + 0, wsb + 1, dx3, dy3, dz3, dw3)

			#Contribution (1,0,1,1)
			var dx2 = dx4
			var dy2 = dy0 - 3 * SQUISH_CONSTANT_4D
			var dz2 = dz4
			var dw2 = dw3
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2
			if(attn2 > 0):
				attn2 *= attn2
				value += attn2 * attn2 * extrapolate4d(xsb + 1, ysb + 0, zsb + 1, wsb + 1, dx2, dy2, dz2, dw2)

			#Contribution (0,1,1,1)
			var dx1 = dx0 - 3 * SQUISH_CONSTANT_4D
			var dz1 = dz4
			var dy1 = dy4
			var dw1 = dw3
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1
			if(attn1 > 0):
				attn1 *= attn1
				value += attn1 * attn1 * extrapolate4d(xsb + 0, ysb + 1, zsb + 1, wsb + 1, dx1, dy1, dz1, dw1)

			#Contribution (1,1,1,1)
			dx0 = dx0 - 1 - 4 * SQUISH_CONSTANT_4D
			dy0 = dy0 - 1 - 4 * SQUISH_CONSTANT_4D
			dz0 = dz0 - 1 - 4 * SQUISH_CONSTANT_4D
			dw0 = dw0 - 1 - 4 * SQUISH_CONSTANT_4D
			var attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0 - dw0 * dw0
			if(attn0 > 0):
				attn0 *= attn0
				value += attn0 * attn0 * extrapolate4d(xsb + 1, ysb + 1, zsb + 1, wsb + 1, dx0, dy0, dz0, dw0)
				
		elif (inSum <= 2): #We're inside the first dispentachoron (Rectified 4-Simplex)
			var aScore
			var aPoint
			var aIsBiggerSide = true
			var bScore
			var bPoint
			var bIsBiggerSide = true
			
			#Decide between (1,1,0,0) and (0,0,1,1)
			if(xins + yins > zins + wins):
				aScore = xins + yins
				aPoint = 0x03
			else:
				aScore = zins + wins
				aPoint = 0x0C
			
			#Decide between (1,0,1,0) and (0,1,0,1)
			if(xins + zins > yins + wins):
				bScore = xins + zins
				bPoint = 0x05
			else:
				bScore = yins + wins
				bPoint = 0x0A
			
			#Closer between (1,0,0,1) and (0,1,1,0) will replace the further of a and b, if closer.
			if(xins + wins > yins + zins):
				var score = xins + wins
				if(aScore >= bScore && score > bScore):
					bScore = score
					bPoint = 0x09
				elif(aScore < bScore && score > aScore):
					aScore = score
					aPoint = 0x09
			else:
				var score = yins + zins
				if(aScore >= bScore && score > bScore):
					bScore = score
					bPoint = 0x06
				elif(aScore < bScore && score > aScore):
					aScore = score
					aPoint = 0x06
			
			#Decide if (1,0,0,0) is closer.
			var p1 = 2 - inSum + xins
			if(aScore >= bScore && p1 > bScore):
				bScore = p1
				bPoint = 0x01
				bIsBiggerSide = false
			elif(aScore < bScore && p1 > aScore):
				aScore = p1
				aPoint = 0x01
				aIsBiggerSide = false
			
			#Decide if (0,1,0,0) is closer.
			var p2 = 2 - inSum + yins
			if(aScore >= bScore && p2 > bScore):
				bScore = p2
				bPoint = 0x02
				bIsBiggerSide = false
			elif(aScore < bScore && p2 > aScore):
				aScore = p2
				aPoint = 0x02
				aIsBiggerSide = false
			
			#Decide if (0,0,1,0) is closer.
			var p3 = 2 - inSum + zins
			if(aScore >= bScore && p3 > bScore):
				bScore = p3
				bPoint = 0x04
				bIsBiggerSide = false
			elif(aScore < bScore && p3 > aScore):
				aScore = p3
				aPoint = 0x04
				aIsBiggerSide = false
			
			#Decide if (0,0,0,1) is closer.
			var p4 = 2 - inSum + wins
			if(aScore >= bScore && p4 > bScore):
				bScore = p4
				bPoint = 0x08
				bIsBiggerSide = false
			elif(aScore < bScore && p4 > aScore):
				aScore = p4
				aPoint = 0x08
				aIsBiggerSide = false
			
			#Where each of the two closest points are determines how the extra three vertices are calculated.
			if(aIsBiggerSide == bIsBiggerSide):
				if(aIsBiggerSide): #Both closest points on the bigger side
					var c1 = int(aPoint | bPoint)
					var c2 = int(aPoint & bPoint)
					if((c1 & 0x01) == 0):
						xsv_ext0 = xsb
						xsv_ext1 = xsb - 1
						dx_ext0 = dx0 - 3 * SQUISH_CONSTANT_4D
						dx_ext1 = dx0 + 1 - 2 * SQUISH_CONSTANT_4D
					else:
						xsv_ext1 = xsb + 1
						xsv_ext0 = xsv_ext1 
						dx_ext0 = dx0 - 1 - 3 * SQUISH_CONSTANT_4D
						dx_ext1 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
					
					if((c1 & 0x02) == 0):
						ysv_ext0 = ysb
						ysv_ext1 = ysb - 1
						dy_ext0 = dy0 - 3 * SQUISH_CONSTANT_4D
						dy_ext1 = dy0 + 1 - 2 * SQUISH_CONSTANT_4D
					else:
						ysv_ext1 = ysb + 1
						ysv_ext0 = ysv_ext1 
						dy_ext0 = dy0 - 1 - 3 * SQUISH_CONSTANT_4D
						dy_ext1 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
					
					if((c1 & 0x04) == 0):
						zsv_ext0 = zsb
						zsv_ext1 = zsb - 1
						dz_ext0 = dz0 - 3 * SQUISH_CONSTANT_4D
						dz_ext1 = dz0 + 1 - 2 * SQUISH_CONSTANT_4D
					else:
						zsv_ext1 = zsb + 1
						zsv_ext0 = zsv_ext1 
						dz_ext0 = dz0 - 1 - 3 * SQUISH_CONSTANT_4D
						dz_ext1 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
					
					if((c1 & 0x08) == 0):
						wsv_ext0 = wsb
						wsv_ext1 = wsb - 1
						dw_ext0 = dw0 - 3 * SQUISH_CONSTANT_4D
						dw_ext1 = dw0 + 1 - 2 * SQUISH_CONSTANT_4D
					else:
						wsv_ext1 = wsb + 1
						wsv_ext0 = wsv_ext1 
						dw_ext0 = dw0 - 1 - 3 * SQUISH_CONSTANT_4D
						dw_ext1 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
					
					#One combination is a permutation of (0,0,0,2) based on c2
					xsv_ext2 = xsb
					ysv_ext2 = ysb
					zsv_ext2 = zsb
					wsv_ext2 = wsb
					dx_ext2 = dx0 - 2 * SQUISH_CONSTANT_4D
					dy_ext2 = dy0 - 2 * SQUISH_CONSTANT_4D
					dz_ext2 = dz0 - 2 * SQUISH_CONSTANT_4D
					dw_ext2 = dw0 - 2 * SQUISH_CONSTANT_4D
					if((c2 & 0x01) != 0):
						xsv_ext2 += 2
						dx_ext2 -= 2
					elif((c2 & 0x02) != 0):
						ysv_ext2 += 2
						dy_ext2 -= 2
					elif((c2 & 0x04) != 0):
						zsv_ext2 += 2
						dz_ext2 -= 2
					else:
						wsv_ext2 += 2
						dw_ext2 -= 2
					
				else: #Both closest points on the smaller side
					#One of the two extra points is (0,0,0,0)
					xsv_ext2 = xsb
					ysv_ext2 = ysb
					zsv_ext2 = zsb
					wsv_ext2 = wsb
					dx_ext2 = dx0
					dy_ext2 = dy0
					dz_ext2 = dz0
					dw_ext2 = dw0
					
					#Other two points are based on the omitted axes.
					var c = int(aPoint | bPoint)
					
					if((c & 0x01) == 0):
						xsv_ext0 = xsb - 1
						xsv_ext1 = xsb
						dx_ext0 = dx0 + 1 - SQUISH_CONSTANT_4D
						dx_ext1 = dx0 - SQUISH_CONSTANT_4D
					else:
						xsv_ext1 = xsb + 1
						xsv_ext0 = xsv_ext1 
						dx_ext1 = dx0 - 1 - SQUISH_CONSTANT_4D
						dx_ext0 = dx_ext1 
					
					if((c & 0x02) == 0):
						ysv_ext1 = ysb
						ysv_ext0 = ysv_ext1 
						dy_ext1 = dy0 - SQUISH_CONSTANT_4D
						dy_ext0 = dy_ext1 
						if((c & 0x01) == 0x01):
							ysv_ext0 -= 1
							dy_ext0 += 1
						else:
							ysv_ext1 -= 1
							dy_ext1 += 1
					else:
						ysv_ext1 = ysb + 1
						ysv_ext0 = ysv_ext1 
						dy_ext1 = dy0 - 1 - SQUISH_CONSTANT_4D
						dy_ext0 = dy_ext1
					
					if((c & 0x04) == 0):
						zsv_ext1 = zsb
						zsv_ext0 = zsv_ext1 
						dz_ext1 = dz0 - SQUISH_CONSTANT_4D
						dz_ext0 = dz_ext1 
						if((c & 0x03) == 0x03):
							zsv_ext0 -= 1
							dz_ext0 += 1
						else:
							zsv_ext1 -= 1
							dz_ext1 += 1
					else:
						zsv_ext1 = zsb + 1
						zsv_ext0 = zsv_ext1 
						dz_ext1 = dz0 - 1 - SQUISH_CONSTANT_4D
						dz_ext0 = dz_ext1 
					
					if((c & 0x08) == 0):
						wsv_ext0 = wsb
						wsv_ext1 = wsb - 1
						dw_ext0 = dw0 - SQUISH_CONSTANT_4D
						dw_ext1 = dw0 + 1 - SQUISH_CONSTANT_4D
					else: 
						wsv_ext1 = wsb + 1
						wsv_ext0 = wsv_ext1
						dw_ext1 = dw0 - 1 - SQUISH_CONSTANT_4D
						dw_ext0 = dw_ext1 
					
			else: #One point on each "side"
				var c1
				var c2
				if(aIsBiggerSide):
					c1 = aPoint
					c2 = bPoint
				else:
					c1 = bPoint
					c2 = aPoint
				
				#Two contributions are the bigger-sided point with each 0 replaced with -1.
				if((c1 & 0x01) == 0):
					xsv_ext0 = xsb - 1
					xsv_ext1 = xsb
					dx_ext0 = dx0 + 1 - SQUISH_CONSTANT_4D
					dx_ext1 = dx0 - SQUISH_CONSTANT_4D
				else:
					xsv_ext1 = xsb + 1
					xsv_ext0 = xsv_ext1 
					dx_ext1 = dx0 - 1 - SQUISH_CONSTANT_4D
					dx_ext0 = dx_ext1
				
				if((c1 & 0x02) == 0):
					ysv_ext1 = ysb
					ysv_ext0 = ysv_ext1 
					dy_ext1 = dy0 - SQUISH_CONSTANT_4D
					dy_ext0 = dy_ext1 
					if((c1 & 0x01) == 0x01):
						ysv_ext0 -= 1
						dy_ext0 += 1
					else:
						ysv_ext1 -= 1
						dy_ext1 += 1
				else:
					ysv_ext1 = ysb + 1
					ysv_ext0 = ysv_ext1 
					dy_ext1 = dy0 - 1 - SQUISH_CONSTANT_4D
					dy_ext0 = dy_ext1 
				
				if((c1 & 0x04) == 0):
					zsv_ext1 = zsb
					zsv_ext0 = zsv_ext1
					dz_ext1 = dz0 - SQUISH_CONSTANT_4D
					dz_ext0 = dz_ext1 
					if((c1 & 0x03) == 0x03):
						zsv_ext0 -= 1
						dz_ext0 += 1
					else:
						zsv_ext1 -= 1
						dz_ext1 += 1
				else:
					zsv_ext1 = zsb + 1
					zsv_ext0 = zsv_ext1
					dz_ext1 = dz0 - 1 - SQUISH_CONSTANT_4D
					dz_ext0 = dz_ext1 
				
				if((c1 & 0x08) == 0):
					wsv_ext0 = wsb
					wsv_ext1 = wsb - 1
					dw_ext0 = dw0 - SQUISH_CONSTANT_4D
					dw_ext1 = dw0 + 1 - SQUISH_CONSTANT_4D
				else:
					wsv_ext1 = wsb + 1
					wsv_ext0 = wsv_ext1
					dw_ext1 = dw0 - 1 - SQUISH_CONSTANT_4D
					dw_ext0 = dw_ext1

				#One contribution is a permutation of (0,0,0,2) based on the smaller-sided point
				xsv_ext2 = xsb
				ysv_ext2 = ysb
				zsv_ext2 = zsb
				wsv_ext2 = wsb
				dx_ext2 = dx0 - 2 * SQUISH_CONSTANT_4D
				dy_ext2 = dy0 - 2 * SQUISH_CONSTANT_4D
				dz_ext2 = dz0 - 2 * SQUISH_CONSTANT_4D
				dw_ext2 = dw0 - 2 * SQUISH_CONSTANT_4D
				if((c2 & 0x01) != 0):
					xsv_ext2 += 2
					dx_ext2 -= 2
				elif((c2 & 0x02) != 0):
					ysv_ext2 += 2
					dy_ext2 -= 2
				elif((c2 & 0x04) != 0):
					zsv_ext2 += 2
					dz_ext2 -= 2
				else:
					wsv_ext2 += 2
					dw_ext2 -= 2
			
			#Contribution (1,0,0,0)
			var dx1 = dx0 - 1 - SQUISH_CONSTANT_4D
			var dy1 = dy0 - 0 - SQUISH_CONSTANT_4D
			var dz1 = dz0 - 0 - SQUISH_CONSTANT_4D
			var dw1 = dw0 - 0 - SQUISH_CONSTANT_4D
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1
			if(attn1 > 0):
				attn1 *= attn1
				value += attn1 * attn1 * extrapolate4d(xsb + 1, ysb + 0, zsb + 0, wsb + 0, dx1, dy1, dz1, dw1)

			#Contribution (0,1,0,0)
			var dx2 = dx0 - 0 - SQUISH_CONSTANT_4D
			var dy2 = dy0 - 1 - SQUISH_CONSTANT_4D
			var dz2 = dz1
			var dw2 = dw1
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2
			if(attn2 > 0):
				attn2 *= attn2
				value += attn2 * attn2 * extrapolate4d(xsb + 0, ysb + 1, zsb + 0, wsb + 0, dx2, dy2, dz2, dw2)

			#Contribution (0,0,1,0)
			var dx3 = dx2
			var dy3 = dy1
			var dz3 = dz0 - 1 - SQUISH_CONSTANT_4D
			var dw3 = dw1
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3
			if(attn3 > 0):
				attn3 *= attn3
				value += attn3 * attn3 * extrapolate4d(xsb + 0, ysb + 0, zsb + 1, wsb + 0, dx3, dy3, dz3, dw3)

			#Contribution (0,0,0,1)
			var dx4 = dx2
			var dy4 = dy1
			var dz4 = dz1
			var dw4 = dw0 - 1 - SQUISH_CONSTANT_4D
			var attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4
			if(attn4 > 0):
				attn4 *= attn4
				value += attn4 * attn4 * extrapolate4d(xsb + 0, ysb + 0, zsb + 0, wsb + 1, dx4, dy4, dz4, dw4)
			
			#Contribution (1,1,0,0)
			var dx5 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dy5 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dz5 = dz0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dw5 = dw0 - 0 - 2 * SQUISH_CONSTANT_4D
			var attn5 = 2 - dx5 * dx5 - dy5 * dy5 - dz5 * dz5 - dw5 * dw5
			if(attn5 > 0):
				attn5 *= attn5
				value += attn5 * attn5 * extrapolate4d(xsb + 1, ysb + 1, zsb + 0, wsb + 0, dx5, dy5, dz5, dw5)
			
			#Contribution (1,0,1,0)
			var dx6 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dy6 = dy0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dz6 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dw6 = dw0 - 0 - 2 * SQUISH_CONSTANT_4D
			var attn6 = 2 - dx6 * dx6 - dy6 * dy6 - dz6 * dz6 - dw6 * dw6
			if(attn6 > 0):
				attn6 *= attn6
				value += attn6 * attn6 * extrapolate4d(xsb + 1, ysb + 0, zsb + 1, wsb + 0, dx6, dy6, dz6, dw6)

			#Contribution (1,0,0,1)
			var dx7 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dy7 = dy0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dz7 = dz0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dw7 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
			var attn7 = 2 - dx7 * dx7 - dy7 * dy7 - dz7 * dz7 - dw7 * dw7
			if(attn7 > 0):
				attn7 *= attn7
				value += attn7 * attn7 * extrapolate4d(xsb + 1, ysb + 0, zsb + 0, wsb + 1, dx7, dy7, dz7, dw7)
			
			#Contribution (0,1,1,0)
			var dx8 = dx0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dy8 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dz8 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dw8 = dw0 - 0 - 2 * SQUISH_CONSTANT_4D
			var attn8 = 2 - dx8 * dx8 - dy8 * dy8 - dz8 * dz8 - dw8 * dw8
			if(attn8 > 0):
				attn8 *= attn8
				value += attn8 * attn8 * extrapolate4d(xsb + 0, ysb + 1, zsb + 1, wsb + 0, dx8, dy8, dz8, dw8)
			
			#Contribution (0,1,0,1)
			var dx9 = dx0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dy9 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dz9 = dz0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dw9 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
			var attn9 = 2 - dx9 * dx9 - dy9 * dy9 - dz9 * dz9 - dw9 * dw9
			if(attn9 > 0):
				attn9 *= attn9
				value += attn9 * attn9 * extrapolate4d(xsb + 0, ysb + 1, zsb + 0, wsb + 1, dx9, dy9, dz9, dw9)
			
			#Contribution (0,0,1,1)
			var dx10 = dx0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dy10 = dy0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dz10 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dw10 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
			var attn10 = 2 - dx10 * dx10 - dy10 * dy10 - dz10 * dz10 - dw10 * dw10
			if(attn10 > 0):
				attn10 *= attn10
				value += attn10 * attn10 * extrapolate4d(xsb + 0, ysb + 0, zsb + 1, wsb + 1, dx10, dy10, dz10, dw10)
				
		else: #We're inside the second dispentachoron (Rectified 4-Simplex)
			var aScore
			var aPoint
			var aIsBiggerSide = true
			var bScore
			var bPoint
			var bIsBiggerSide = true
			
			#Decide between (0,0,1,1) and (1,1,0,0)
			if(xins + yins < zins + wins):
				aScore = xins + yins
				aPoint = 0x0C
			else:
				aScore = zins + wins
				aPoint = 0x03
			
			#Decide between (0,1,0,1) and (1,0,1,0)
			if(xins + zins < yins + wins):
				bScore = xins + zins
				bPoint = 0x0A
			else:
				bScore = yins + wins
				bPoint = 0x05
			
			#Closer between (0,1,1,0) and (1,0,0,1) will replace the further of a and b, if closer.
			if(xins + wins < yins + zins):
				var score = xins + wins
				if(aScore <= bScore && score < bScore):
					bScore = score
					bPoint = 0x06
				elif(aScore > bScore && score < aScore):
					aScore = score
					aPoint = 0x06
			else:
				var score = yins + zins
				if(aScore <= bScore && score < bScore):
					bScore = score
					bPoint = 0x09
				elif(aScore > bScore && score < aScore):
					aScore = score
					aPoint = 0x09
			
			#Decide if (0,1,1,1) is closer.
			var p1 = 3 - inSum + xins
			if(aScore <= bScore && p1 < bScore):
				bScore = p1
				bPoint = 0x0E
				bIsBiggerSide = false
			elif(aScore > bScore && p1 < aScore):
				aScore = p1
				aPoint = 0x0E
				aIsBiggerSide = false
			
			#Decide if (1,0,1,1) is closer.
			var p2 = 3 - inSum + yins
			if(aScore <= bScore && p2 < bScore):
				bScore = p2
				bPoint = 0x0D
				bIsBiggerSide = false
			elif(aScore > bScore && p2 < aScore):
				aScore = p2
				aPoint = 0x0D
				aIsBiggerSide = false
			
			#Decide if (1,1,0,1) is closer.
			var p3 = 3 - inSum + zins
			if(aScore <= bScore && p3 < bScore):
				bScore = p3
				bPoint = 0x0B
				bIsBiggerSide = false
			elif(aScore > bScore && p3 < aScore):
				aScore = p3
				aPoint = 0x0B
				aIsBiggerSide = false
			
			#Decide if (1,1,1,0) is closer.
			var p4 = 3 - inSum + wins
			if(aScore <= bScore && p4 < bScore):
				bScore = p4
				bPoint = 0x07
				bIsBiggerSide = false
			elif(aScore > bScore && p4 < aScore):
				aScore = p4
				aPoint = 0x07
				aIsBiggerSide = false
			
			#Where each of the two closest points are determines how the extra three vertices are calculated.
			if(aIsBiggerSide == bIsBiggerSide):
				if(aIsBiggerSide): #Both closest points on the bigger side
					var c1 = int(aPoint & bPoint)
					var c2 = int(aPoint | bPoint)
					
					#Two contributions are permutations of (0,0,0,1) and (0,0,0,2) based on c1
					xsv_ext1 = xsb
					xsv_ext0 = xsv_ext1 
					ysv_ext1 = ysb
					ysv_ext0 = ysv_ext1 
					zsv_ext1 = zsb
					zsv_ext0 = zsv_ext1 
					wsv_ext1 = wsb
					wsv_ext0 = wsv_ext1 
					dx_ext0 = dx0 - SQUISH_CONSTANT_4D
					dy_ext0 = dy0 - SQUISH_CONSTANT_4D
					dz_ext0 = dz0 - SQUISH_CONSTANT_4D
					dw_ext0 = dw0 - SQUISH_CONSTANT_4D
					dx_ext1 = dx0 - 2 * SQUISH_CONSTANT_4D
					dy_ext1 = dy0 - 2 * SQUISH_CONSTANT_4D
					dz_ext1 = dz0 - 2 * SQUISH_CONSTANT_4D
					dw_ext1 = dw0 - 2 * SQUISH_CONSTANT_4D
					if((c1 & 0x01) != 0):
						xsv_ext0 += 1
						dx_ext0 -= 1
						xsv_ext1 += 2
						dx_ext1 -= 2
					elif((c1 & 0x02) != 0):
						ysv_ext0 += 1
						dy_ext0 -= 1
						ysv_ext1 += 2
						dy_ext1 -= 2
					elif((c1 & 0x04) != 0):
						zsv_ext0 += 1
						dz_ext0 -= 1
						zsv_ext1 += 2
						dz_ext1 -= 2
					else:
						wsv_ext0 += 1
						dw_ext0 -= 1
						wsv_ext1 += 2
						dw_ext1 -= 2
					
					#One contribution is a permutation of (1,1,1,-1) based on c2
					xsv_ext2 = xsb + 1
					ysv_ext2 = ysb + 1
					zsv_ext2 = zsb + 1
					wsv_ext2 = wsb + 1
					dx_ext2 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
					dy_ext2 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
					dz_ext2 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
					dw_ext2 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
					if((c2 & 0x01) == 0):
						xsv_ext2 -= 2
						dx_ext2 += 2
					elif((c2 & 0x02) == 0):
						ysv_ext2 -= 2
						dy_ext2 += 2
					elif ((c2 & 0x04) == 0):
						zsv_ext2 -= 2
						dz_ext2 += 2
					else:
						wsv_ext2 -= 2
						dw_ext2 += 2
				else: #Both closest points on the smaller side
					#One of the two extra points is (1,1,1,1)
					xsv_ext2 = xsb + 1
					ysv_ext2 = ysb + 1
					zsv_ext2 = zsb + 1
					wsv_ext2 = wsb + 1
					dx_ext2 = dx0 - 1 - 4 * SQUISH_CONSTANT_4D
					dy_ext2 = dy0 - 1 - 4 * SQUISH_CONSTANT_4D
					dz_ext2 = dz0 - 1 - 4 * SQUISH_CONSTANT_4D
					dw_ext2 = dw0 - 1 - 4 * SQUISH_CONSTANT_4D
					
					#Other two points are based on the shared axes.
					var c = int(aPoint & bPoint)
					
					if((c & 0x01) != 0):
						xsv_ext0 = xsb + 2
						xsv_ext1 = xsb + 1
						dx_ext0 = dx0 - 2 - 3 * SQUISH_CONSTANT_4D
						dx_ext1 = dx0 - 1 - 3 * SQUISH_CONSTANT_4D
					else:	
						xsv_ext1 = xsb
						xsv_ext0 = xsv_ext1 
						dx_ext1 = dx0 - 3 * SQUISH_CONSTANT_4D
						dx_ext0 = dx_ext1
					
					if((c & 0x02) != 0):
						ysv_ext1 = ysb + 1
						ysv_ext0 = ysv_ext1 
						dy_ext1 = dy0 - 1 - 3 * SQUISH_CONSTANT_4D
						dy_ext0 = dy_ext1
						if((c & 0x01) == 0):
							ysv_ext0 += 1
							dy_ext0 -= 1
						else:
							ysv_ext1 += 1
							dy_ext1 -= 1
					else:
						ysv_ext1 = ysb
						ysv_ext0 = ysv_ext1 
						dy_ext1 = dy0 - 3 * SQUISH_CONSTANT_4D
						dy_ext0 = dy_ext1
					
					if((c & 0x04) != 0):
						zsv_ext1 = zsb + 1
						zsv_ext0 = zsv_ext1 
						dz_ext1 = dz0 - 1 - 3 * SQUISH_CONSTANT_4D
						dz_ext0 = dz_ext1 
						if((c & 0x03) == 0):
							zsv_ext0 += 1
							dz_ext0 -= 1
						else:
							zsv_ext1 += 1
							dz_ext1 -= 1
					else:
						zsv_ext1 = zsb
						zsv_ext0 = zsv_ext1 
						dz_ext1 = dz0 - 3 * SQUISH_CONSTANT_4D
						dz_ext0 = dz_ext1
					
					if((c & 0x08) != 0):
						wsv_ext0 = wsb + 1
						wsv_ext1 = wsb + 2
						dw_ext0 = dw0 - 1 - 3 * SQUISH_CONSTANT_4D
						dw_ext1 = dw0 - 2 - 3 * SQUISH_CONSTANT_4D
					else:
						wsv_ext1 = wsb
						wsv_ext0 = wsv_ext1
						dw_ext1 = dw0 - 3 * SQUISH_CONSTANT_4D
						dw_ext0 = dw_ext1 
						
			else: #One point on each "side"
				var c1
				var c2
				if(aIsBiggerSide):
					c1 = aPoint
					c2 = bPoint
				else:
					c1 = bPoint
					c2 = aPoint
				
				#Two contributions are the bigger-sided point with each 1 replaced with 2.
				if((c1 & 0x01) != 0):
					xsv_ext0 = xsb + 2
					xsv_ext1 = xsb + 1
					dx_ext0 = dx0 - 2 - 3 * SQUISH_CONSTANT_4D
					dx_ext1 = dx0 - 1 - 3 * SQUISH_CONSTANT_4D
				else:
					xsv_ext1 = xsb
					xsv_ext0 = xsv_ext1
					dx_ext1 = dx0 - 3 * SQUISH_CONSTANT_4D
					dx_ext0 = dx_ext1
				
				if((c1 & 0x02) != 0):
					ysv_ext1 = ysb + 1
					ysv_ext0 = ysv_ext1
					dy_ext1 = dy0 - 1 - 3 * SQUISH_CONSTANT_4D
					dy_ext0 = dy_ext1
					if((c1 & 0x01) == 0):
						ysv_ext0 += 1
						dy_ext0 -= 1
					else:
						ysv_ext1 += 1
						dy_ext1 -= 1
						
				else:
					ysv_ext1 = ysb
					ysv_ext0 = ysv_ext1
					dy_ext1 = dy0 - 3 * SQUISH_CONSTANT_4D
					dy_ext0 = dy_ext1
				
				if((c1 & 0x04) != 0):
					zsv_ext1 = zsb + 1
					zsv_ext0 = zsv_ext1 
					dz_ext1 = dz0 - 1 - 3 * SQUISH_CONSTANT_4D
					dz_ext0 = dz_ext1
					if((c1 & 0x03) == 0):
						zsv_ext0 += 1
						dz_ext0 -= 1
					else:
						zsv_ext1 += 1
						dz_ext1 -= 1
						
				else:
					zsv_ext1 = zsb
					zsv_ext0 = zsv_ext1
					dz_ext1 = dz0 - 3 * SQUISH_CONSTANT_4D
					dz_ext0 = dz_ext1
				
				if((c1 & 0x08) != 0):
					wsv_ext0 = wsb + 1
					wsv_ext1 = wsb + 2
					dw_ext0 = dw0 - 1 - 3 * SQUISH_CONSTANT_4D
					dw_ext1 = dw0 - 2 - 3 * SQUISH_CONSTANT_4D
				else:
					wsv_ext1 = wsb
					wsv_ext0 = wsv_ext1
					dw_ext1 = dw0 - 3 * SQUISH_CONSTANT_4D
					dw_ext0 = dw_ext1

				#One contribution is a permutation of (1,1,1,-1) based on the smaller-sided point
				xsv_ext2 = xsb + 1
				ysv_ext2 = ysb + 1
				zsv_ext2 = zsb + 1
				wsv_ext2 = wsb + 1
				dx_ext2 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
				dy_ext2 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
				dz_ext2 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
				dw_ext2 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
				if((c2 & 0x01) == 0):
					xsv_ext2 -= 2
					dx_ext2 += 2
				elif((c2 & 0x02) == 0):
					ysv_ext2 -= 2
					dy_ext2 += 2
				elif((c2 & 0x04) == 0):
					zsv_ext2 -= 2
					dz_ext2 += 2
				else:
					wsv_ext2 -= 2
					dw_ext2 += 2

			#Contribution (1,1,1,0)
			var dx4 = dx0 - 1 - 3 * SQUISH_CONSTANT_4D
			var dy4 = dy0 - 1 - 3 * SQUISH_CONSTANT_4D
			var dz4 = dz0 - 1 - 3 * SQUISH_CONSTANT_4D
			var dw4 = dw0 - 3 * SQUISH_CONSTANT_4D
			var attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4
			if(attn4 > 0):
				attn4 *= attn4
				value += attn4 * attn4 * extrapolate4d(xsb + 1, ysb + 1, zsb + 1, wsb + 0, dx4, dy4, dz4, dw4)

			#Contribution (1,1,0,1)
			var dx3 = dx4
			var dy3 = dy4
			var dz3 = dz0 - 3 * SQUISH_CONSTANT_4D
			var dw3 = dw0 - 1 - 3 * SQUISH_CONSTANT_4D
			var attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3
			if(attn3 > 0):
				attn3 *= attn3
				value += attn3 * attn3 * extrapolate4d(xsb + 1, ysb + 1, zsb + 0, wsb + 1, dx3, dy3, dz3, dw3)

			#Contribution (1,0,1,1)
			var dx2 = dx4
			var dy2 = dy0 - 3 * SQUISH_CONSTANT_4D
			var dz2 = dz4
			var dw2 = dw3
			var attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2
			if(attn2 > 0):
				attn2 *= attn2
				value += attn2 * attn2 * extrapolate4d(xsb + 1, ysb + 0, zsb + 1, wsb + 1, dx2, dy2, dz2, dw2)

			#Contribution (0,1,1,1)
			var dx1 = dx0 - 3 * SQUISH_CONSTANT_4D
			var dz1 = dz4
			var dy1 = dy4
			var dw1 = dw3
			var attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1
			if(attn1 > 0):
				attn1 *= attn1
				value += attn1 * attn1 * extrapolate4d(xsb + 0, ysb + 1, zsb + 1, wsb + 1, dx1, dy1, dz1, dw1)
			
			#Contribution (1,1,0,0)
			var dx5 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dy5 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dz5 = dz0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dw5 = dw0 - 0 - 2 * SQUISH_CONSTANT_4D
			var attn5 = 2 - dx5 * dx5 - dy5 * dy5 - dz5 * dz5 - dw5 * dw5
			if(attn5 > 0):
				attn5 *= attn5
				value += attn5 * attn5 * extrapolate4d(xsb + 1, ysb + 1, zsb + 0, wsb + 0, dx5, dy5, dz5, dw5)
			
			#Contribution (1,0,1,0)
			var dx6 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dy6 = dy0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dz6 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dw6 = dw0 - 0 - 2 * SQUISH_CONSTANT_4D
			var attn6 = 2 - dx6 * dx6 - dy6 * dy6 - dz6 * dz6 - dw6 * dw6
			if(attn6 > 0):
				attn6 *= attn6
				value += attn6 * attn6 * extrapolate4d(xsb + 1, ysb + 0, zsb + 1, wsb + 0, dx6, dy6, dz6, dw6)

			#Contribution (1,0,0,1)
			var dx7 = dx0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dy7 = dy0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dz7 = dz0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dw7 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
			var attn7 = 2 - dx7 * dx7 - dy7 * dy7 - dz7 * dz7 - dw7 * dw7
			if(attn7 > 0):
				attn7 *= attn7
				value += attn7 * attn7 * extrapolate4d(xsb + 1, ysb + 0, zsb + 0, wsb + 1, dx7, dy7, dz7, dw7)
			
			#Contribution (0,1,1,0)
			var dx8 = dx0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dy8 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dz8 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dw8 = dw0 - 0 - 2 * SQUISH_CONSTANT_4D
			var attn8 = 2 - dx8 * dx8 - dy8 * dy8 - dz8 * dz8 - dw8 * dw8
			if(attn8 > 0):
				attn8 *= attn8
				value += attn8 * attn8 * extrapolate4d(xsb + 0, ysb + 1, zsb + 1, wsb + 0, dx8, dy8, dz8, dw8)
			
			#Contribution (0,1,0,1)
			var dx9 = dx0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dy9 = dy0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dz9 = dz0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dw9 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
			var attn9 = 2 - dx9 * dx9 - dy9 * dy9 - dz9 * dz9 - dw9 * dw9
			if(attn9 > 0):
				attn9 *= attn9
				value += attn9 * attn9 * extrapolate4d(xsb + 0, ysb + 1, zsb + 0, wsb + 1, dx9, dy9, dz9, dw9)
			
			#Contribution (0,0,1,1)
			var dx10 = dx0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dy10 = dy0 - 0 - 2 * SQUISH_CONSTANT_4D
			var dz10 = dz0 - 1 - 2 * SQUISH_CONSTANT_4D
			var dw10 = dw0 - 1 - 2 * SQUISH_CONSTANT_4D
			var attn10 = 2 - dx10 * dx10 - dy10 * dy10 - dz10 * dz10 - dw10 * dw10
			if(attn10 > 0):
				attn10 *= attn10
				value += attn10 * attn10 * extrapolate4d(xsb + 0, ysb + 0, zsb + 1, wsb + 1, dx10, dy10, dz10, dw10)
 
		#First extra vertex
		var attn_ext0 = 2 - dx_ext0 * dx_ext0 - dy_ext0 * dy_ext0 - dz_ext0 * dz_ext0 - dw_ext0 * dw_ext0
		if(attn_ext0 > 0):
			attn_ext0 *= attn_ext0
			value += attn_ext0 * attn_ext0 * extrapolate4d(xsv_ext0, ysv_ext0, zsv_ext0, wsv_ext0, dx_ext0, dy_ext0, dz_ext0, dw_ext0)

		#Second extra vertex
		var attn_ext1 = 2 - dx_ext1 * dx_ext1 - dy_ext1 * dy_ext1 - dz_ext1 * dz_ext1 - dw_ext1 * dw_ext1
		if(attn_ext1 > 0):
			attn_ext1 *= attn_ext1
			value += attn_ext1 * attn_ext1 * extrapolate4d(xsv_ext1, ysv_ext1, zsv_ext1, wsv_ext1, dx_ext1, dy_ext1, dz_ext1, dw_ext1)

		#Third extra vertex
		var attn_ext2 = 2 - dx_ext2 * dx_ext2 - dy_ext2 * dy_ext2 - dz_ext2 * dz_ext2 - dw_ext2 * dw_ext2
		if(attn_ext2 > 0):
			attn_ext2 *= attn_ext2
			value += attn_ext2 * attn_ext2 * extrapolate4d(xsv_ext2, ysv_ext2, zsv_ext2, wsv_ext2, dx_ext2, dy_ext2, dz_ext2, dw_ext2)

		return value / NORM_CONSTANT_4D
	
	func extrapolate2d(var xsb, var ysb, var dx, var dy):
		var index = perm[(perm[xsb & 0xFF] + ysb) & 0xFF] & 0x0E
		return gradients2D[index] * dx + gradients2D[index + 1] * dy
		
	func extrapolate3d(var xsb, var ysb, var zsb, var dx, var dy, var dz):
		var index = permGradIndex3D[(perm[(perm[xsb & 0xFF] + ysb) & 0xFF] + zsb) & 0xFF]
		return gradients3D[index] * dx + gradients3D[index + 1] * dy + gradients3D[index + 2] * dz
		
	func extrapolate4d(var xsb, var ysb, var zsb, var wsb, var dx, var dy, var dz, var dw):
		var index = perm[(perm[(perm[(perm[xsb & 0xFF] + ysb) & 0xFF] + zsb) & 0xFF] + wsb) & 0xFF] & 0xFC
		return gradients4D[index] * dx + gradients4D[index + 1] * dy + gradients4D[index + 2] * dz + gradients4D[index + 3] * dw
		
