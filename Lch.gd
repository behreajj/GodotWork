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

	static func adjust(o: Lch, d: Lch) -> Lch:
		return Lch.new(o.l + d.l, o.c + d.c, o.h + d.h, o.alpha + d.alpha)

	static func copyAlpha(o: Lch, d: Lch) -> Lch:
		return Lch.new(o.l, o.c, o.h, d.alpha)
		
	static func copyLight(o: Lch, d: Lch) -> Lch:
		return Lch.new(d.l, o.c, o.h, o.alpha)

	static func gray(c: Lch) -> Lch:
		return Lch.new(c.l, 0.0, c.h, c.alpha)

	static func harmonyAnalogous(c: Lch) -> Array:
		var lAna: float = (c.l * 2.0 + 50.0) / 3.0

		var h30: float = c.h + 0.083333333
		var h330: float = c.h - 0.083333333

		return [
			Lch.new(lAna, c.c, h30 - floor(h30), c.alpha),
			Lch.new(lAna, c.c, h330 - floor(h330), c.alpha)
		]

	static func harmonyComplement(c: Lch) -> Array:
		var lCmp: float = 100.0 - c.l

		var h180: float = c.h + 0.5

		return [
			new(lCmp, c.c, h180 - floor(h180), c.alpha)
		]

	static func harmonySplit(c: Lch) -> Array:
		var lSpl: float = (250.0 - c.l * 2.0) / 3.0

		var h150: float = c.h + 0.41666667
		var h210: float = c.h - 0.41666667

		return [
			Lch.new(lSpl, c.c, h150 - floor(h150), c.alpha),
			Lch.new(lSpl, c.c, h210 - floor(h210), c.alpha)
		]

	static func harmonySquare(c: Lch) -> Array:
		var lCmp: float = 100.0 - c.l

		var h90: float = c.h + 0.25
		var h180: float = c.h + 0.5
		var h270: float = c.h - 0.25

		return [
			Lch.new(50.0, c.c, h90 - floor(h90), c.alpha),
			Lch.new(lCmp, c.c, h180 - floor(h180), c.alpha),
			Lch.new(50.0, c.c, h270 - floor(h270), c.alpha)
		]

	static func harmonyTetradic(c: Lch) -> Array:
		var lTri: float = (200.0 - c.l) / 3.0
		var lCmp: float = 100.0 - c.l
		var lTet: float = (100.0 + c.l) / 3.0

		var h120: float = c.h + 0.333333333
		var h180: float = c.h + 0.5
		var h300: float = c.h - 0.16666667

		return [
			Lch.new(lTri, c.c, h120 - floor(h120), c.alpha),
			Lch.new(lCmp, c.c, h180 - floor(h180), c.alpha),
			Lch.new(lTet, c.c, h300 - floor(h300), c.alpha)
		]

	static func harmonyTriadic(c: Lch) -> Array:
		var lTri: float = (200.0 - c.l) / 3.0

		var h120: float = c.h + 0.333333333
		var h240: float = c.h - 0.333333333

		return [
			Lch.new(lTri, c.c, h120 - floor(h120), c.alpha),
			Lch.new(lTri, c.c, h240 - floor(h240), c.alpha)
		]

	static func opaque(c: Lch) -> Lch:
		return Lch.new(c.l, c.a, c.b, 1.0)

	static func black() -> Lch:
		return Lch.new(0.0, 0.0, 0.0, 1.0)
		
	static func clearBlack() -> Lch:
		return Lch.new(0.0, 0.0, 0.0, 0.0)
	
	static func clearWhite() -> Lch:
		return Lch.new(100.0, 0.0, 0.0, 0.0)
	
	static func white() -> Lch:
		return Lch.new(100.0, 0.0, 0.0, 1.0)
