class Rgb:
	
	var alpha: float
	var b: float
	var g: float
	var r: float
	
	func _init(rd: float = 1.0, \
		gr: float = 1.0, \
		bl: float = 1.0, \
		opacity: float = 1.0):
		self.alpha = opacity
		self.b = bl
		self.g = gr
		self.r = rd

	static func clamp01(c: Rgb) -> Rgb:
		return Rgb.new( \
			clamp(c.r, 0.0, 1.0), \
			clamp(c.g, 0.0, 1.0), \
			clamp(c.b, 0.0, 1.0), \
			clamp(c.alpha, 0.0, 1.0))

	static func copyAlpha(o: Rgb, d: Rgb) -> Rgb:
		return Rgb.new(o.r, o.g, o.b, d.alpha)

	static func gammaToLinear(c: Rgb) -> Rgb:
		var lr: float = c.r
		if lr <= 0.04045:
			lr = lr * 0.077399380804954
		else:
			lr = pow((lr + 0.055) * 0.9478672985782, 2.4)

		var lg: float = c.g
		if lg <= 0.04045:
			lg = lg * 0.077399380804954
		else:
			lg = pow((lg + 0.055) * 0.9478672985782, 2.4)

		var lb: float = c.b
		if lb <= 0.04045:
			lb = lb * 0.077399380804954
		else:
			lb = pow((lb + 0.055) * 0.9478672985782, 2.4)

		return Rgb.new(lr, lg, lb, c.alpha)

	static func isInGamut(c: Rgb) -> bool:
		return c.r >= 0.0 and c.r <= 1.0 \
			and c.g >= 0.0 and c.g <= 1.0 \
			and c.b >= 0.0 and c.b <= 1.0

	static func linearToGamma(c: Rgb) -> Rgb:
		var sr: float = c.r
		if sr <= 0.0031308:
			sr = sr * 12.92
		else:
			sr = pow(sr, 0.41666666666667) * 1.055 - 0.055

		var sg: float = c.g
		if sg <= 0.0031308:
			sg = sg * 12.92
		else:
			sg = pow(sg, 0.41666666666667) * 1.055 - 0.055

		var sb: float = c.b
		if sb <= 0.0031308:
			sb = sb * 12.92
		else:
			sb = pow(sb, 0.41666666666667) * 1.055 - 0.055

		return Rgb.new(sr, sg, sb, c.alpha)

	static func opaque(c: Rgb) -> Rgb:
		return Rgb.new(c.r, c.g, c.b, 1.0)
		
	static func premul(c: Rgb) -> Rgb:
		var t: float = c.alpha
		if t <= 0.0:
			return Rgb.clearBlack()
		elif t >= 1.0:
			return Rgb.opaque(c)
		return Rgb.new(c.r * t, c.g * t, c.b * t, t)

	static func unpremul(c: Rgb) -> Rgb:
		var t: float = c.alpha
		if t <= 0.0:
			return Rgb.clearBlack()
		elif t >= 1.0:
			return Rgb.opaque(c)
		var tInv: float = 1.0 / t
		return Rgb.new(c.r * tInv, c.g * tInv, c.b * tInv, t)

	static func black() -> Rgb:
		return Rgb.new(0.0, 0.0, 0.0, 1.0)

	static func blue() -> Rgb:
		return Rgb.new(0.0, 0.0, 1.0, 1.0)

	static func clearBlack() -> Rgb:
		return Rgb.new(0.0, 0.0, 0.0, 0.0)
		
	static func clearWhite() -> Rgb:
		return Rgb.new(1.0, 1.0, 1.0, 0.0)

	static func cyan() -> Rgb:
		return Rgb.new(0.0, 1.0, 1.0, 1.0)

	static func green() -> Rgb:
		return Rgb.new(0.0, 1.0, 0.0, 1.0)

	static func magenta() -> Rgb:
		return Rgb.new(1.0, 0.0, 1.0, 1.0)

	static func red() -> Rgb:
		return Rgb.new(1.0, 0.0, 0.0, 1.0)

	static func white() -> Rgb:
		return Rgb.new(1.0, 1.0, 1.0, 1.0)

	static func yellow() -> Rgb:
		return Rgb.new(1.0, 1.0, 0.0, 1.0)
