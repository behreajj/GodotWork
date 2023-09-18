## A static class for methods that convert custom classes to and from GDScript
## native objects.
class_name Bridge

## Converts an RGB color to a GDScript Color.
static func gamma_rgb_to_color(c: Rgb) -> Color:
    return Color(c.r, c.g, c.b, c.alpha)

## Converts a GDScript Color to an RGB color.
static func color_to_gamma_rgb(c: Color) -> Rgb:
    return Rgb.new(c.r, c.g, c.b, c.a)

## Converts a GDScript Gradient to a LAB Gradient. Does so indirectly by
## sampling the gradient a given number of times.
static func gradient_to_lab_gradient(g: Gradient, \
    samples: int = 16) -> LabGradient:
    var verif_samples: int = clamp(abs(samples), 2, 96)
    var i_to_fac: float = 1.0 / (verif_samples - 1)
    var ks: Array = []

    var i: int = 0
    while i < verif_samples:
        var fac: float = i * i_to_fac
        var color: Color = g.sample(fac)
        var gamma_rgb: Rgb = Bridge.color_to_gamma_rgb(color)
        var lab: Lab = ClrUtils.gamma_rgb_to_sr_lab_2(gamma_rgb)
        var lab_key: LabKey = LabKey.new(fac, lab)
        ks.push_back(lab_key)
        i = i + 1

    return LabGradient.new(ks)
