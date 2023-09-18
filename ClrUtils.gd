## A static class for methods that convert between color representations and to
## mix colors.
class_name ClrUtils

## Converts a color from gamma sRGB to SR LAB 2.
static func gamma_rgb_to_sr_lab_2(c: Rgb) -> Lab:
    return ClrUtils.linear_rgb_to_sr_lab_2(Rgb.gamma_to_linear(c))

## Converts a color from gamma sRGB to SR LCH.
static func gamma_rgb_to_sr_lch(c: Rgb) -> Lch:
    return ClrUtils.lab_to_lch(ClrUtils.linear_rgb_to_sr_lab_2(
        Rgb.gamma_to_linear(c)))

## Converts a color from LAB to LCH.
static func lab_to_lch(c: Lab) -> Lch:
    var c_sq: float = Lab.chroma_sq(c)
    if c_sq > 0.000001:
        return Lch.new(c.l, sqrt(c_sq), Lab.hue(c), c.alpha)
    return Lch.new(c.l, 0.0, 0.0, c.alpha)

## Converts a color from LCH to LAB.
static func lch_to_lab(c: Lch) -> Lab:
    var cr: float = max(0.0, abs(c.c))
    var hr: float = c.h * TAU
    return Lab.new(c.l, cr * cos(hr), cr * sin(hr), c.alpha)

## Converts a color from linear sRGB to SR LAB 2. See Jan Behrens,
## https://www.magnetkern.de/srlab2.html .
static func linear_rgb_to_sr_lab_2(c: Rgb) -> Lab:
    # There's drift when converting the same color back and forth between RGB
    # and LAB. Higher precision numbers don't seem to help.
    # The epsilon can be as big as 0.001.
    var rl: float = c.r
    var gl: float = c.g
    var bl: float = c.b

    # Convert from linear sRGB to XYZ.
    var x0: float = 0.32053 * rl + 0.63692 * gl + 0.04256 * bl
    var y0: float = 0.161987 * rl + 0.756636 * gl + 0.081376 * bl
    var z0: float = 0.017228 * rl + 0.10866 * gl + 0.874112 * bl

    var one_third: float = 1.0 / 3.0
    var comparisand: float = 216.0 / 24389.0
    var scalar: float = 24389.0 / 2700.0

    var x1: float = 0.0
    if x0 <= comparisand:
        x1 = x0 * scalar
    else:
        x1 = 1.16 * pow(x0, one_third) - 0.16

    var y1: float = 0.0
    if y0 <= comparisand:
        y1 = y0 * scalar
    else:
        y1 = 1.16 * pow(y0, one_third) - 0.16

    var z1: float = 0.0
    if z0 <= comparisand:
        z1 = z0 * scalar
    else:
        z1 = 1.16 * pow(z0, one_third) - 0.16

    # Convert from XYZ to LAB.
    var l: float = 37.095 * x1 + 62.9054 * y1 - 0.0008 * z1
    var a: float = 663.4684 * x1 - 750.5078 * y1 + 87.0328 * z1
    var b: float = 63.9569 * x1 + 108.4576 * y1 - 172.4152 * z1

    return Lab.new(l, a, b, c.alpha)

## Converts a color from linear sRGB to gamma SR LCH.
static func linear_rgb_to_sr_lch(c: Rgb) -> Lch:
    return ClrUtils.lab_to_lch(ClrUtils.linear_rgb_to_sr_lab_2(c))

## Mixes two colors in gamma sRGB by a factor in [0.0, 1.0].
static func mix_gamma_rgb(o: Rgb, d: Rgb, t: float = 0.5) -> Rgb:
    return Rgb.linear_to_gamma(ClrUtils.mix_linear_rgb(
        Rgb.gamma_to_linear(o), Rgb.gamma_to_linear(d), t))

## Mixes two colors in LAB by a factor in [0.0, 1.0].
static func mix_lab(o: Lab, d: Lab, t: float = 0.5) -> Lab:
    var u: float = 1.0 - t
    return Lab.new(
        u * o.l + t * d.l,
        u * o.a + t * d.a,
        u * o.b + t * d.b,
        u * o.alpha + t * d.alpha)

## Mixes two colors in LAB by a factor in [0.0, 1.0]. A convenience so as to
## avoid converting to and mixing in LCH.
static func mix_lab_polar(o: Lab, \
    d: Lab, \
    t: float = 0.5, \
    dir: MathUtils.PolarEasing = MathUtils.PolarEasing.NEAR) -> Lab:

    var ocsq: float = Lab.chroma_sq(o)
    var dcsq: float = Lab.chroma_sq(d)
    if ocsq < 0.000001 or dcsq < 0.000001:
        return ClrUtils.mix_lab(o, d, t)

    var u: float = 1.0 - t
    var cc: float = u * sqrt(ocsq) + t * sqrt(dcsq)
    var ch: float = MathUtils.mix_angle(
        atan2(o.b, o.a), atan2(d.b, d.a), t, TAU, dir)
    return Lab.new(
        u * o.l + t * d.l,
        cc * cos(ch),
        cc * sin(ch),
        u * o.alpha + t * d.alpha)

## Mixes two colors in LCH by a factor in [0.0, 1.0].
static func mix_lch(o: Lch, \
    d: Lch, \
    t: float = 0.5, \
    dir: MathUtils.PolarEasing = MathUtils.PolarEasing.NEAR) -> Lch:

    var u: float = 1.0 - t
    var cl: float = u * o.l + t * d.l
    var c_alpha: float = u * o.alpha + t * d.alpha

    var oc: float = max(0.0, abs(o.c))
    var dc: float = max(0.0, abs(d.c))
    var o_is_gray = oc < 0.000001
    var d_is_gray = dc < 0.000001

    if o_is_gray and d_is_gray:
        return Lch.new(cl, 0.0, 0.0, c_alpha)
    elif o_is_gray or d_is_gray:
        var oa: float = 0.0
        var ob: float = 0.0
        if not o_is_gray:
            var oh_radians: float = o.h * TAU
            oa = oc * cos(oh_radians)
            ob = oc * sin(oh_radians)

        var da: float = 0.0
        var db: float = 0.0
        if not d_is_gray:
            var dh_radians: float = d.h * TAU
            da = dc * cos(dh_radians)
            db = dc * sin(dh_radians)

        var ca: float = u * oa + t * da
        var cb: float = u * ob + t * db
        var cc: float = sqrt(ca * ca + cb * cb)
        var ch: float = fposmod(atan2(cb, ca), TAU) / TAU

        return Lch.new(cl, cc, ch, c_alpha)

    # Godot built-in lerp_angle may result in negative hues.
    # var ch: float = lerp_angle(o.h * TAU, d.h * TAU, t) / TAU
    var ch: float = MathUtils.mix_angle(o.h, d.h, t, 1.0, dir)
    var cc: float = u * oc + t * dc
    return Lch.new(cl, cc, ch, c_alpha)

## Mixes two colors in linear sRGB by a factor in [0.0, 1.0].
static func mix_linear_rgb(o: Rgb, d: Rgb, t: float = 0.5) -> Rgb:
    var u: float = 1.0 - t
    return Rgb.new(
        u * o.r + t * d.r,
        u * o.g + t * d.g,
        u * o.b + t * d.b,
        u * o.alpha + t * d.alpha)

## Converts a color from SR LAB 2 to gamma sRGB.
static func sr_lab_2_to_gamma_rgb(c: Lab) -> Rgb:
    return Rgb.linear_to_gamma(ClrUtils.sr_lab_2_to_linear_rgb(c))

## Converts a color from SR LAB 2 to linear sRGB. See Jan Behrens,
## https://www.magnetkern.de/srlab2.html .
static func sr_lab_2_to_linear_rgb(c: Lab) -> Rgb:
    # There's drift when converting the same color back and forth between RGB
    # and LAB. Higher precision numbers don't seem to help.
    # The epsilon can be as big as 0.001.
    var l: float = c.l
    var a: float = c.a
    var b: float = c.b

    # Convert from LAB to XYZ.
    var l01: float = l * 0.01
    var x0: float = l01 + 0.000904127 * a + 0.000456344 * b
    var y0: float = l01 - 0.000533159 * a - 0.000269178 * b
    var z0: float = l01 - 0.0058 * b

    var scalar: float = 2700.0 / 24389.0

    var x1: float = 0.0
    if x0 <= 0.08:
        x1 = x0 * scalar
    else:
        x1 = pow((x0 + 0.16) / 1.16, 3.0)

    var y1: float = 0.0
    if y0 <= 0.08:
        y1 = y0 * scalar
    else:
        y1 = pow((y0 + 0.16) / 1.16, 3.0)

    var z1: float = 0.0
    if z0 <= 0.08:
        z1 = z0 * scalar
    else:
        z1 = pow((z0 + 0.16) / 1.16, 3.0)

    # Convert from XYZ to linear sRGB.
    var rl: float = 5.435679 * x1 - 4.599131 * y1 + 0.163593 * z1
    var gl: float = -1.16809 * x1 + 2.327977 * y1 - 0.159798 * z1
    var bl: float = 0.03784 * x1 - 0.198564 * y1 + 1.160644 * z1

    return Rgb.new(rl, gl, bl, c.alpha)

## Converts a color from SR LCH to gamma sRGB.
static func sr_lch_to_gamma_rgb(c: Lch) -> Rgb:
    return Rgb.linear_to_gamma(ClrUtils.sr_lab_2_to_linear_rgb(
        ClrUtils.lch_to_lab(c)))

## Converts a color from SR LCH to linear sRGB.
static func sr_lch_to_linear_rgb(c: Lch) -> Rgb:
    return ClrUtils.sr_lab_2_to_linear_rgb(ClrUtils.lch_to_lab(c))
