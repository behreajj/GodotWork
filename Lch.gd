class Lch:
	
	var alpha: float
	var c: float
	var h: float
	var l: float

	func _init(lightness: float = 100.0, \
		chroma: float = 0.0, \
		hue: float = 0.0, \
		opacity: float = 1.0):
		self.l = lightness
		self.c = chroma
		self.h = hue
		self.alpha = opacity

	func _to_string() -> String:
		return "{\"l\":%.4f,\"c\":%.4f,\"h\":%.4f,\"alpha\":%.4f}" \
			% [ self.l, self.c, self.h, self.alpha ]

	static func adjust(o: Lch, d: Lch) -> Lch:
		return Lch.new(o.l + d.l, o.c + d.c, o.h + d.h, o.alpha + d.alpha)

	static func copy_alpha(o: Lch, d: Lch) -> Lch:
		return Lch.new(o.l, o.c, o.h, d.alpha)
		
	static func copy_light(o: Lch, d: Lch) -> Lch:
		return Lch.new(d.l, o.c, o.h, o.alpha)

	static func gray(lch: Lch) -> Lch:
		return Lch.new(lch.l, 0.0, lch.h, lch.alpha)

	static func harmony_analogous(lch: Lch) -> Array:
		var l_ana: float = (lch.l * 2.0 + 50.0) / 3.0

		var h30: float = lch.h + 0.083333333
		var h330: float = lch.h - 0.083333333

		return [
			Lch.new(l_ana, lch.c, h30 - floor(h30), lch.alpha),
			Lch.new(l_ana, lch.c, h330 - floor(h330), lch.alpha)
		]

	static func harmony_complement(lch: Lch) -> Array:
		var l_cmp: float = 100.0 - lch.l

		var h180: float = lch.h + 0.5

		return [
			new(l_cmp, lch.c, h180 - floor(h180), lch.alpha)
		]

	static func harmony_split(lch: Lch) -> Array:
		var l_spl: float = (250.0 - lch.l * 2.0) / 3.0

		var h150: float = lch.h + 0.41666667
		var h210: float = lch.h - 0.41666667

		return [
			Lch.new(l_spl, lch.c, h150 - floor(h150), lch.alpha),
			Lch.new(l_spl, lch.c, h210 - floor(h210), lch.alpha)
		]

	static func harmony_square(lch: Lch) -> Array:
		var l_cmp: float = 100.0 - lch.l

		var h90: float = lch.h + 0.25
		var h180: float = lch.h + 0.5
		var h270: float = lch.h - 0.25

		return [
			Lch.new(50.0, lch.c, h90 - floor(h90), lch.alpha),
			Lch.new(l_cmp, lch.c, h180 - floor(h180), lch.alpha),
			Lch.new(50.0, lch.c, h270 - floor(h270), lch.alpha)
		]

	static func harmony_tetradic(lch: Lch) -> Array:
		var l_tri: float = (200.0 - lch.l) / 3.0
		var l_cmp: float = 100.0 - lch.l
		var l_tet: float = (100.0 + lch.l) / 3.0

		var h120: float = lch.h + 0.333333333
		var h180: float = lch.h + 0.5
		var h300: float = lch.h - 0.16666667

		return [
			Lch.new(l_tri, lch.c, h120 - floor(h120), lch.alpha),
			Lch.new(l_cmp, lch.c, h180 - floor(h180), lch.alpha),
			Lch.new(l_tet, lch.c, h300 - floor(h300), lch.alpha)
		]

	static func harmony_triadic(lch: Lch) -> Array:
		var l_tri: float = (200.0 - lch.l) / 3.0

		var h120: float = lch.h + 0.333333333
		var h240: float = lch.h - 0.333333333

		return [
			Lch.new(l_tri, lch.c, h120 - floor(h120), lch.alpha),
			Lch.new(l_tri, lch.c, h240 - floor(h240), lch.alpha)
		]

	static func opaque(lch: Lch) -> Lch:
		return Lch.new(lch.l, lch.a, lch.b, 1.0)

	static func black() -> Lch:
		return Lch.new(0.0, 0.0, 0.0, 1.0)

	static func blue() -> Lch:
		return Lch.new(30.643950, 111.458463, 0.732794, 1.0)
	
	static func clear_black() -> Lch:
		return Lch.new(0.0, 0.0, 0.0, 0.0)
	
	static func clear_white() -> Lch:
		return Lch.new(100.0, 0.0, 0.0, 0.0)

	static func cyan() -> Lch:
		return Lch.new(90.624703, 46.302188, 0.552540, 1.0)

	static func green() -> Lch:
		return Lch.new(87.515187, 117.374612, 0.374923, 1.0)
	
	static func magenta() -> Lch:
		return Lch.new(60.255211, 119.431303, 0.914680, 1.0)
	
	static func red() -> Lch:
		return Lch.new(53.225974, 103.437344, 0.113562, 1.0)

	static func white() -> Lch:
		return Lch.new(100.0, 0.0, 0.0, 1.0)		

	static func yellow() -> Lch:
		return Lch.new(97.345258, 102.180881, 0.309228, 1.0)
