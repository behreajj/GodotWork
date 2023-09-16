const Rgb = preload("res://Rgb.gd")

class ClrUtils:
	static func gammaRgbToColor(c: Rgb.Rgb) -> Color:
		return Color(c.r, c.g, c.b, c.alpha)
		
	static func colorToGammaRgb(c: Color) -> Rgb.Rgb:
		return Rgb.Rgb.new(c.r, c.g, c.b, c.a)
