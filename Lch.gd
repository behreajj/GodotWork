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
		return "{\"l\":%.3f,\"c\":%.3f,\"h\":%.3f,\"alpha\":%.3f}" \
			% [self.l, self.c, self.h, self.alpha]

	static func adjust(o: Lch, d: Lch) -> Lch:
		return Lch.new(o.l + d.l, o.c + d.c, o.h + d.h, o.alpha + d.alpha)

	static func copyAlpha(o: Lch, d: Lch) -> Lch:
		return Lch.new(o.l, o.c, o.h, d.alpha)
		
	static func copyLight(o: Lch, d: Lch) -> Lch:
		return Lch.new(d.l, o.c, o.h, o.alpha)

	static func gray(lch: Lch) -> Lch:
		return Lch.new(lch.l, 0.0, lch.h, lch.alpha)

	static func harmonyAnalogous(lch: Lch) -> Array:
		var lAna: float = (lch.l * 2.0 + 50.0) / 3.0

		var h30: float = lch.h + 0.083333333
		var h330: float = lch.h - 0.083333333

		return [
			Lch.new(lAna, lch.c, h30 - floor(h30), lch.alpha),
			Lch.new(lAna, lch.c, h330 - floor(h330), lch.alpha)
		]

	static func harmonyComplement(lch: Lch) -> Array:
		var lCmp: float = 100.0 - lch.l

		var h180: float = lch.h + 0.5

		return [
			new(lCmp, lch.c, h180 - floor(h180), lch.alpha)
		]

	static func harmonySplit(lch: Lch) -> Array:
		var lSpl: float = (250.0 - lch.l * 2.0) / 3.0

		var h150: float = lch.h + 0.41666667
		var h210: float = lch.h - 0.41666667

		return [
			Lch.new(lSpl, lch.c, h150 - floor(h150), lch.alpha),
			Lch.new(lSpl, lch.c, h210 - floor(h210), lch.alpha)
		]

	static func harmonySquare(lch: Lch) -> Array:
		var lCmp: float = 100.0 - lch.l

		var h90: float = lch.h + 0.25
		var h180: float = lch.h + 0.5
		var h270: float = lch.h - 0.25

		return [
			Lch.new(50.0, lch.c, h90 - floor(h90), lch.alpha),
			Lch.new(lCmp, lch.c, h180 - floor(h180), lch.alpha),
			Lch.new(50.0, lch.c, h270 - floor(h270), lch.alpha)
		]

	static func harmonyTetradic(lch: Lch) -> Array:
		var lTri: float = (200.0 - lch.l) / 3.0
		var lCmp: float = 100.0 - lch.l
		var lTet: float = (100.0 + lch.l) / 3.0

		var h120: float = lch.h + 0.333333333
		var h180: float = lch.h + 0.5
		var h300: float = lch.h - 0.16666667

		return [
			Lch.new(lTri, lch.c, h120 - floor(h120), lch.alpha),
			Lch.new(lCmp, lch.c, h180 - floor(h180), lch.alpha),
			Lch.new(lTet, lch.c, h300 - floor(h300), lch.alpha)
		]

	static func harmonyTriadic(lch: Lch) -> Array:
		var lTri: float = (200.0 - lch.l) / 3.0

		var h120: float = lch.h + 0.333333333
		var h240: float = lch.h - 0.333333333

		return [
			Lch.new(lTri, lch.c, h120 - floor(h120), lch.alpha),
			Lch.new(lTri, lch.c, h240 - floor(h240), lch.alpha)
		]

	static func opaque(lch: Lch) -> Lch:
		return Lch.new(lch.l, lch.a, lch.b, 1.0)

	static func black() -> Lch:
		return Lch.new(0.0, 0.0, 0.0, 1.0)
		
	static func clearBlack() -> Lch:
		return Lch.new(0.0, 0.0, 0.0, 0.0)
	
	static func clearWhite() -> Lch:
		return Lch.new(100.0, 0.0, 0.0, 0.0)
	
	static func white() -> Lch:
		return Lch.new(100.0, 0.0, 0.0, 1.0)
