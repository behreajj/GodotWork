const Rgb = preload("res://Rgb.gd")

## A static class for methods that convert custom classes to and from GDScript
## native objects.
class Bridge:

    ## Converts an RGB color to a GDScript Color.
    static func gamma_rgb_to_color(c: Rgb.Rgb) -> Color:
        return Color(c.r, c.g, c.b, c.alpha)

    ## Converts a GDScript Color to an RGB color.
    static func color_to_gamma_rgb(c: Color) -> Rgb.Rgb:
        return Rgb.Rgb.new(c.r, c.g, c.b, c.a)
