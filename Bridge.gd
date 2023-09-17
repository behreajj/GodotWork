const Rgb = preload("res://Rgb.gd")

class ClrUtils:
	static func gamma_rgb_to_color(c: Rgb.Rgb) -> Color:
		return Color(c.r, c.g, c.b, c.alpha)
		
	static func color_to_gamma_rgb(c: Color) -> Rgb.Rgb:
		return Rgb.Rgb.new(c.r, c.g, c.b, c.a)
