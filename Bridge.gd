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

    # TODO: Test

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
        ks.append(lab_key)
        i = i + 1

    return LabGradient.new(ks)


## Converts a LAB color to a GDScript Vector3. The color's lightness is
## assigned to the z axis. The alpha is omitted.
static func lab_to_vector3(c: Lab) -> Vector3:
    return Vector3(c.a, c.b, c.l)


## Converts a LAB color to a GDScript Vector3. The color's lightness is
## assigned to the z axis. The w axis is assigned to alpha.
static func lab_to_vector4(c: Lab) -> Vector4:
    return Vector4(c.a, c.b, c.l, c.alpha)


## Converts a GDScript Vector3 to a LAB color. The z axis is assigned to the
## color's lightness.
static func vector3_to_lab(v: Vector3, opacity: float = 1.0) -> Lab:
    return Lab.new(v.z, v.x, v.y, opacity)


## Converts a GDScript Vector4 to a LAB color. The z axis is assigned to the
## color's lightness. The w axis is assigned to alpha.
static func vector4_to_lab(v: Vector4) -> Lab:
    return Lab.new(v.z, v.x, v.y, v.w)
