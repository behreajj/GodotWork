const Lab = preload("res://Lab.gd")
const Lch = preload("res://Lch.gd")
const Rgb = preload("res://Rgb.gd")

class ClrUtils:
	static func gammaRgbToSrLab2(c: Rgb.Rgb) -> Lab.Lab:
		return ClrUtils.linearRgbToSrLab2(Rgb.Rgb.gammaToLinear(c))

	static func gammaRgbToSrLch(c: Rgb.Rgb) -> Lch.Lch:
		return ClrUtils.labToLch(ClrUtils.linearRgbToSrLab2(
			Rgb.Rgb.gammaToLinear(c)))
		
	static func labToLch(c: Lab.Lab) -> Lch.Lch:
		var cSq: float = Lab.Lab.chromaSq(c)
		if cSq > 0.000001:
			return Lch.Lch.new(c.l, sqrt(cSq), Lab.Lab.hue(c), c.alpha)
		return Lch.Lch.new(c.l, 0.0, 0.0, c.alpha)

	static func lchToLab(c: Lch.Lch) -> Lab.Lab:
		var cr: float = max(0.0, c.c)
		var hr: float = c.h * TAU
		return Lab.Lab.new(c.l, cr * cos(hr), cr * sin(hr), c.alpha)

	static func lerpAngleNear(o: float, \
		d: float, \
		t: float = 0.5, \
		r: float = 1.0)-> float:
		# range is a reserved keyword in GDScript.

		var oWrapped: float = fposmod(o, r)
		var dWrapped: float = fposmod(d, r)

		if t <= 0.0: return oWrapped
		if t >= 1.0: return dWrapped

		var diff: float = dWrapped - oWrapped
		if diff != 0.0:
			var u: float = 1.0 - t
			var rHalf: float = r * 0.5
			if oWrapped < dWrapped and diff > rHalf:
				return fposmod(u * (oWrapped + r) + t * dWrapped, r)
			elif oWrapped > dWrapped and diff < -rHalf:
				return fposmod(u * oWrapped + t * (dWrapped + r), r)
			else:
				return u * oWrapped + t * dWrapped
		return oWrapped

	static func linearRgbToSrLab2(c: Rgb.Rgb) -> Lab.Lab:
		# https://www.magnetkern.de/srlab2.html
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
		
	static func linearRgbToSrLch(c: Rgb.Rgb) -> Lch.Lch:
		return ClrUtils.labToLch(ClrUtils.linearRgbToSrLab2(c))

	static func mixGammaRgb(o: Rgb.Rgb, d: Rgb.Rgb, t: float = 0.5) -> Rgb.Rgb:
		if t <= 0.0: return Rgb.Rgb.new(o.r, o.g, o.b, o.alpha)
		if t >= 1.0: return Rgb.Rgb.new(d.r, d.g, d.b, d.alpha)

		var u: float = 1.0 - t
		var ol: Rgb.Rgb = Rgb.Rgb.gammaToLinear(o)
		var dl: Rgb.Rgb = Rgb.Rgb.gammaToLinear(d)
		return Rgb.Rgb.linearToGamma(Rgb.Rgb.new(
			u * ol.r + t * dl.r,
			u * ol.g + t * dl.g,
			u * ol.b + t * dl.b,
			u * ol.alpha + t * dl.alpha))

	static func mixLab(o: Lab.Lab, d: Lab.Lab, t: float = 0.5) -> Lab.Lab:
		if t <= 0.0: return Lab.Lab.new(o.l, o.a, o.b, o.alpha)
		if t >= 1.0: return Lab.Lab.new(d.l, d.a, d.b, d.alpha)

		var u: float = 1.0 - t
		return Lab.Lab.new(
			u * o.l + t * d.l,
			u * o.a + t * d.a,
			u * o.b + t * d.b,
			u * o.alpha + t * d.alpha)

	static func mixLch(o: Lch.Lch, d: Lch.Lch, t: float = 0.5) -> Lch.Lch:
		if t <= 0.0: return Lch.Lch.new(o.l, o.c, o.h, o.alpha)
		if t >= 1.0: return Lch.Lch.new(d.l, d.c, d.h, d.alpha)

		var u: float = 1.0 - t
		var cl: float = u * o.l + t * d.l
		var calpha: float = u * o.alpha + t * d.alpha

		var ogray = o.c < 0.000001
		var dgray = o.c < 0.000001
		if ogray and dgray:
			return Lch.Lch.new(cl, 0.0, 0.0, calpha)
		elif ogray or dgray:
			var oa: float = 0.0
			var ob: float = 0.0
			if not ogray:
				oa = o.c * cos(o.h)
				ob = o.c * sin(o.h)

			var da: float = 0.0
			var db: float = 0.0	
			if not dgray:
				da = d.c * cos(d.h)
				db = d.c * sin(d.h)
			
			var ca: float = u * oa + t * da
			var cb: float = u * ob + t * db
			var cc: float = sqrt(ca * ca + cb * cb)
			var ch: float = fposmod(atan2(cb, ca), TAU) / TAU

			return Lch.Lch.new(cl, cc, ch, calpha)

		var cc: float = u * o.c + t * d.c
	
		# lerp_angle may reslult in negative hues.
		# var ch: float = lerp_angle(o.h * TAU, d.h * TAU, t) / TAU
		var ch: float = ClrUtils.lerpAngleNear(o.h, d.h, t, 1.0)
		return Lch.Lch.new(cl, cc, ch, calpha)

	static func mixLinearRgb(o: Rgb.Rgb, d: Rgb.Rgb, t: float = 0.5) -> Rgb.Rgb:
		if t <= 0.0: return Rgb.Rgb.new(o.r, o.g, o.b, o.alpha)
		if t >= 1.0: return Rgb.Rgb.new(d.r, d.g, d.b, d.alpha)

		var u: float = 1.0 - t
		return Rgb.Rgb.new(
			u * o.r + t * d.r,
			u * o.g + t * d.g,
			u * o.b + t * d.b,
			u * o.alpha + t * d.alpha)

	static func srLab2ToGammaRgb(c: Lab.Lab) -> Rgb.Rgb:
		return Rgb.Rgb.linearToGamma(ClrUtils.srLab2ToLinearRgb(c))

	static func srLab2ToLinearRgb(c: Lab.Lab) -> Rgb.Rgb:
		# https://www.magnetkern.de/srlab2.html
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

	static func srLchToGammaRgb(c: Lch.Lch) -> Rgb.Rgb:
		return Rgb.Rgb.linearToGamma(ClrUtils.srLab2ToLinearRgb(
			ClrUtils.lchToLab(c)))

	static func srLchToLinearRgb(c: Lch.Lch) -> Rgb.Rgb:
		return ClrUtils.srLab2ToLinearRgb(ClrUtils.lchToLab(c))
