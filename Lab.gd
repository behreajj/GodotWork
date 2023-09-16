class Lab:
	
	var alpha: float
	var a: float
	var b: float
	var l: float
	
	func _init(lightness: float = 100.0, \
		greenRed: float = 0.0, \
		blueYellow: float = 0.0, \
		opacity: float = 1.0):
		# TODO: Add documentation comments.
		# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html
		self.l = lightness
		self.a = greenRed
		self.b = blueYellow
		self.alpha = opacity
		
	func _to_string() -> String:
		return "{\"l\":%.4f,\"a\":%.4f,\"b\":%.4f,\"alpha\":%.4f}" \
			% [ self.l, self.a, self.b, self.alpha ]

	static func adjust(o: Lab, d: Lab) -> Lab:
		return Lab.new(o.l + d.l, o.a + d.a, o.b + d.b, o.alpha + d.alpha)

	static func copyAlpha(o: Lab, d: Lab) -> Lab:
		return Lab.new(o.l, o.a, o.b, d.alpha)
		
	static func copyLight(o: Lab, d: Lab) -> Lab:
		return Lab.new(d.l, o.a, o.b, o.alpha)

	static func chroma(c: Lab) -> float:
		return sqrt(Lab.chromaSq(c))

	static func chromaSq(c: Lab) -> float:
		return c.a * c.a + c.b * c.b

	static func gray(c: Lab) -> Lab:
		return Lab.new(c.l, 0.0, 0.0, c.alpha)
	
	static func harmonyAnalogous(c: Lab) -> Array:
		var lAna: float = (c.l * 2.0 + 50.0) / 3.0
		
		var cos30: float = 0.8660254
		var sin30: float = 0.5
		var a30: float = cos30 * c.a - sin30 * c.b
		var b30: float = cos30 * c.b + sin30 * c.a
		
		var cos330: float = 0.8660254
		var sin330: float = -0.5
		var a330: float = cos330 * c.a - sin330 * c.b
		var b330: float = cos330 * c.b + sin330 * c.a
		
		return [
			Lab.new(lAna, a30, b30, c.alpha),
			Lab.new(lAna, a330, b330, c.alpha)
		]
	
	static func harmonyComplement(c: Lab) -> Array:
		return [ Lab.new(100.0 - c.l, -c.a, -c.b, c.alpha) ]
		
	static func harmonySplit(c: Lab) -> Array:
		var lSpl: float = (250.0 - c.l * 2.0) / 3.0
		
		var cos150: float = -0.8660254
		var sin150: float = 0.5
		var a150: float = cos150 * c.a - sin150 * c.b
		var b150: float = cos150 * c.b + sin150 * c.a
		
		var cos210: float = -0.8660254
		var sin210: float = -0.5
		var a210: float = cos210 * c.a - sin210 * c.b
		var b210: float = cos210 * c.b + sin210 * c.a

		return [
			Lab.new(lSpl, a150, b150, c.alpha),
			Lab.new(lSpl, a210, b210, c.alpha)
		]
		
	static func harmonySquare(c: Lab) -> Array:
		return [
			Lab.new(50.0, -c.b, c.a, c.alpha),
			Lab.new(100.0 - c.l, -c.a, -c.b, c.alpha),
			Lab.new(50.0, c.b, -c.a, c.alpha)
		]
		
	static func harmonyTetradic(c: Lab) -> Array:
		var lTri: float = (200.0 - c.l) / 3.0
		var lCmp: float = 100.0 - c.l
		var lTet: float = (100.0 + c.l) / 3.0
		
		var cos120: float = -0.5
		var sin120: float = 0.8660254
		var a120: float = cos120 * c.a - sin120 * c.b
		var b120: float = cos120 * c.b + sin120 * c.a
		
		var cos300: float = 0.5
		var sin300: float = -0.8660254
		var a300: float = cos300 * c.a - sin300 * c.b
		var b300: float = cos300 * c.b + sin300 * c.a
		
		return [
			Lab.new(lTri, a120, b120, c.alpha),
			Lab.new(lCmp, -c.a, -c.b, c.alpha),
			Lab.new(lTet, a300, b300, c.alpha)
		]
		
	static func harmonyTriadic(c: Lab) -> Array:
		var lTri: float = (200.0 - c.l) / 3.0
		
		var cos120: float = -0.5
		var sin120: float = 0.8660254
		var a120: float = cos120 * c.a - sin120 * c.b
		var b120: float = cos120 * c.b + sin120 * c.a
		
		var cos240: float = -0.5
		var sin240: float = -0.8660254
		var a240: float = cos240 * c.a - sin240 * c.b
		var b240: float = cos240 * c.b + sin240 * c.a
		
		return [
			Lab.new(lTri, a120, b120, c.alpha),
			Lab.new(lTri, a240, b240, c.alpha)
		]
		
	static func hue(c: Lab) -> float:
		# For reference, fposmod is GDScript floorMod for floats.
		var hueSigned: float = atan2(c.b, c.a)
		var hueUnsigned: float = hueSigned
		if hueSigned < -0.0:
			hueUnsigned = hueSigned + TAU
		return hueUnsigned / TAU

	static func opaque(c: Lab) -> Lab:
		return Lab.new(c.l, c.a, c.b, 1.0)

	static func rescaleChroma(c: Lab, scalar: float) -> Lab:
		var cSq: float = Lab.chromaSq(c)
		if cSq > 0.000001:
			var scInv: float = scalar / sqrt(cSq)
			return Lab.new(
				c.l,
				c.a * scInv,
				c.b * scInv,
				c.alpha)
		return Lab.gray(c)

	static func rotateHue(c: Lab, hueShift: float) -> Lab:
		var radians: float = hueShift * TAU
		return Lab.rotateHueInternal(c, cos(radians), sin(radians))

	static func rotateHueInternal(c: Lab, cosa: float, sina: float) -> Lab:
		return Lab.new(
			c.l,
			cosa * c.a - sina * c.b,
			cosa * c.b + sina * c.a,
			c.alpha)

	static func black() -> Lab:
		return Lab.new(0.0, 0.0, 0.0, 1.0)

	static func blue() -> Lab:
		return Lab.new(30.643950, -12.025805, -110.807802, 1.0)

	static func clearBlack() -> Lab:
		return Lab.new(0.0, 0.0, 0.0, 0.0)
	
	static func clearWhite() -> Lab:
		return Lab.new(100.0, 0.0, 0.0, 0.0)

	static func cyan() -> Lab:
		return Lab.new(90.624703, -43.802041, -15.009125, 1.0)

	static func green() -> Lab:
		return Lab.new(87.515187, -82.955969, 83.036780, 1.0)

	static func magenta() -> Lab:
		return Lab.new(60.255211, 102.677095, -61.002051, 1.0)

	static func red() -> Lab:
		return Lab.new(53.225974, 78.204287, 67.700618, 1.0)

	static func yellow() -> Lab:
		return Lab.new(97.345258, -37.154265, 95.186623, 1.0)

	static func white() -> Lab:
		return Lab.new(100.0, 0.0, 0.0, 1.0)
