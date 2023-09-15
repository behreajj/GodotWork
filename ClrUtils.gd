const Lab = preload("res://Lab.gd")
const Lch = preload("res://Lch.gd")
const Rgb = preload("res://Rgb.gd")

class ClrUtils:
	static func labToLch(c: Lab.Lab) -> Lch.Lch:
		var cSq: float = Lab.chromaSq(c)
		if cSq > 0.000001:
			return Lch.Lch.new(c.l, sqrt(cSq), Lab.hue(c), c.alpha)
		return Lch.Lch.new(c.l, 0.0, 0.0, c.alpha)

	static func lchToLab(c: Lch.Lch) -> Lab.Lab:
		var cr: float = max(0.0, c.c)
		var hr: float = c.h * TAU
		return Lab.Lab.new(c.l, cr * cos(hr), cr * sin(hr), c.alpha)

	static func linearToSrLab2(c: Rgb.Rgb) -> Lab.Lab:
		var rLin: float = c.r
		var gLin: float = c.g
		var bLin: float = c.b

		# Convert from linear sRGB to XYZ.
		var x0: float = 0.32053 * rLin + 0.63692 * gLin + 0.04256 * bLin
		var y0: float = 0.161987 * rLin + 0.756636 * gLin + 0.081376 * bLin
		var z0: float = 0.017228 * rLin + 0.10866 * gLin + 0.874112 * bLin
	
		var x1: float = x0 * 9.032963
		var y1: float = y0 * 9.032963
		var z1: float = z0 * 9.032963
	
		if x0 > 0.008856452: x1 = 1.16 * pow(x0, 0.333333333) - 0.16
		if y0 > 0.008856452: y1 = 1.16 * pow(y0, 0.333333333) - 0.16
		if z0 > 0.008856452: z1 = 1.16 * pow(z0, 0.333333333) - 0.16
	
		# Convert from XYZ to LAB.
		var l: float = 37.095 * x1 + 62.9054 * y1 - 0.0008 * z1
		var a: float = 663.4684 * x1 - 750.5078 * y1 + 87.0328 * z1
		var b: float = 63.9569 * x1 + 108.4576 * y1 - 172.4152 * z1
	
		return Lab.Lab.new(l, a, b, c.alpha)

	static func srLab2ToLinear(c: Lab.Lab) -> Rgb.Rgb:
		var l: float = c.l
		var a: float = c.a
		var b: float = c.b
	
		# Convert from LAB to XYZ.
		var l01: float = l * 0.01
		var x0: float = l01 + 0.000904127 * a + 0.000456344 * b
		var y0: float = l01 - 0.000533159 * a - 0.000269178 * b
		var z0: float = l01 - 0.0058 * b
	
		var x1: float = x0 * 0.110705644
		var y1: float = y0 * 0.110705644
		var z1: float = z0 * 0.110705644
	
		if x0 > 0.08: x1 = pow((x0 + 0.16) / 1.16, 3.0)
		if y0 > 0.08: y1 = pow((y0 + 0.16) / 1.16, 3.0)
		if z0 > 0.08: z1 = pow((z0 + 0.16) / 1.16, 3.0)
	
		# Convert from XYZ to linear sRGB.
		var rl: float = 5.435679 * x1 - 4.599131 * y1 + 0.163593 * z1
		var gl: float = -1.16809 * x1 + 2.327977 * y1 - 0.159798 * z1
		var bl: float = 0.03784 * x1 - 0.198564 * y1 + 1.160644 * z1

		return Rgb.Rgb.new(rl, gl, bl, c.alpha)
