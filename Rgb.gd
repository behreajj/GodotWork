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

	func _to_string() -> String:
		return "{\"r\":%.4f,\"g\":%.4f,\"b\":%.4f,\"alpha\":%.4f}" \
			% [ self.r, self.g, self.b, self.alpha ]

	static func clamp_01(c: Rgb) -> Rgb:
		return Rgb.new( \
			clamp(c.r, 0.0, 1.0), \
			clamp(c.g, 0.0, 1.0), \
			clamp(c.b, 0.0, 1.0), \
			clamp(c.alpha, 0.0, 1.0))

	static func copy_alpha(o: Rgb, d: Rgb) -> Rgb:
		return Rgb.new(o.r, o.g, o.b, d.alpha)

	static func gamma_to_linear(c: Rgb) -> Rgb:
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

	static func gray(c: Rgb) -> Rgb:
		return Rgb.gray_gamma(c)

	static func gray_gamma(c: Rgb) -> Rgb:
		var linear: Rgb = Rgb.gamma_to_linear(c)
		var rel_lum: float = 0.21264935 * linear.r \
			+ 0.71516913 * linear.g \
			+ 0.07218152 * linear.b
		var gr: float = rel_lum
		if gr <=  0.04045:
			gr = gr * 0.077399380804954
		else:
			gr = pow((gr + 0.055) * 0.9478672985782, 2.4)
		return Rgb.new(gr, gr, gr, c.alpha)

	static func gray_linear(c: Rgb) -> Rgb:
		var rel_lum: float = 0.21264935 * c.r \
			+ 0.71516913 * c.g \
			+ 0.07218152 * c.b
		return Rgb.new(rel_lum, rel_lum, rel_lum, c.alpha)

	static func is_in_gamut(c: Rgb) -> bool:
		return c.r >= 0.0 and c.r <= 1.0 \
			and c.g >= 0.0 and c.g <= 1.0 \
			and c.b >= 0.0 and c.b <= 1.0

	static func linear_to_gamma(c: Rgb) -> Rgb:
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
			return Rgb.clear_black()
		elif t >= 1.0:
			return Rgb.opaque(c)
		return Rgb.new(c.r * t, c.g * t, c.b * t, t)
		
	static func tone_map_aces_gamma(c: Rgb) -> Rgb:
		return Rgb.linear_to_gamma(Rgb.tone_map_aces_linear(
			Rgb.gamma_to_linear(c)))

	static func tone_map_aces_linear(c: Rgb) -> Rgb:
		#  https://64.github.io/tonemapping/
		var rFrwrd: float = 0.59719 * c.r + 0.35458 * c.g + 0.04823 * c.b
		var gFrwrd: float = 0.076 * c.r + 0.90834 * c.g + 0.01566 * c.b
		var bFrwrd: float = 0.0284 * c.r + 0.13383 * c.g + 0.83777 * c.b

		var ar: float = rFrwrd * (rFrwrd + 0.0245786) - 0.000090537
		var ag: float = gFrwrd * (gFrwrd + 0.0245786) - 0.000090537
		var ab: float = bFrwrd * (bFrwrd + 0.0245786) - 0.000090537

		var br: float = rFrwrd * (0.983729 * rFrwrd + 0.432951) + 0.238081
		var bg: float = gFrwrd * (0.983729 * gFrwrd + 0.432951) + 0.238081
		var bb: float = bFrwrd * (0.983729 * bFrwrd + 0.432951) + 0.238081

		var cr: float = 0.0
		var cg: float = 0.0
		var cb: float = 0.0

		if br != 0.0: cr = ar / br
		if bg != 0.0: cg = ag / bg
		if bb != 0.0: cb = ab / bb

		var rBckwd: float = 1.60475 * cr - 0.53108 * cg - 0.07367 * cb
		var gBckwd: float = -0.10208 * cr + 1.10813 * cg - 0.00605 * cb
		var bBckwd: float = -0.00327 * cr - 0.07276 * cg + 1.07602 * cb

		return Rgb.new(
			clamp(rBckwd, 0.0, 1.0),
			clamp(gBckwd, 0.0, 1.0),
			clamp(bBckwd, 0.0, 1.0),
			clamp(c.alpha, 0.0, 1.0))

	static func unpremul(c: Rgb) -> Rgb:
		var t: float = c.alpha
		if t <= 0.0:
			return Rgb.clear_black()
		elif t >= 1.0:
			return Rgb.opaque(c)
		var tInv: float = 1.0 / t
		return Rgb.new(c.r * tInv, c.g * tInv, c.b * tInv, t)

	static func black() -> Rgb:
		return Rgb.new(0.0, 0.0, 0.0, 1.0)

	static func blue() -> Rgb:
		return Rgb.new(0.0, 0.0, 1.0, 1.0)

	static func clear_black() -> Rgb:
		return Rgb.new(0.0, 0.0, 0.0, 0.0)
		
	static func clear_white() -> Rgb:
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
