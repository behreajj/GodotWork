const Lab = preload("res://Lab.gd")
const Lch = preload("res://Lch.gd")
const Rgb = preload("res://Rgb.gd")

## A static class for methods that convert between color representations and to
## mix colors.
class ClrUtils:

    ## Converts a color from gamma sRGB to SR LAB 2.
    static func gamma_rgb_to_sr_lab_2(c: Rgb.Rgb) -> Lab.Lab:
        return ClrUtils.linear_rgb_to_sr_lab_2(Rgb.Rgb.gamma_to_linear(c))

    ## Converts a color from gamma sRGB to SR LCH.
    static func gamma_rgb_to_sr_lch(c: Rgb.Rgb) -> Lch.Lch:
        return ClrUtils.lab_to_lch(ClrUtils.linear_rgb_to_sr_lab_2(
            Rgb.Rgb.gamma_to_linear(c)))

    ## Converts a color from LAB to LCH.
    static func lab_to_lch(c: Lab.Lab) -> Lch.Lch:
        var cSq: float = Lab.Lab.chroma_sq(c)
        if cSq > 0.000001:
            return Lch.Lch.new(c.l, sqrt(cSq), Lab.Lab.hue(c), c.alpha)
        return Lch.Lch.new(c.l, 0.0, 0.0, c.alpha)

    ## Converts a color from LCH to LAB.
    static func lch_to_lab(c: Lch.Lch) -> Lab.Lab:
        var cr: float = max(0.0, c.c)
        var hr: float = c.h * TAU
        return Lab.Lab.new(c.l, cr * cos(hr), cr * sin(hr), c.alpha)

    ## Eases an origin angle to a destination angle along the shortest arc
    ## length -- clockwise or counter clockwise -- according to a factor in
    ## [0.0, 1.0]. The range can be customized, where typical arguments are
    ## TAU for radians, 360.0 for degrees and 1.0 for hues. If the factor is
    ## less than or equal to zero, returns the wrapped origin. If greater than
    ## or equal to one, returns the wrapped destination. Defaults to the origin
    ## if the wrapped origin and destination are the same.
    static func lerp_angle_near(o: float, \
        d: float, \
        t: float = 0.5, \
        r: float = 1.0)-> float:
        # range is a reserved keyword in GDScript.

        var o_wrapped: float = fposmod(o, r)
        if t <= 0.0: return o_wrapped

        var d_wrapped: float = fposmod(d, r)
        if t >= 1.0: return d_wrapped

        var diff: float = d_wrapped - o_wrapped
        if diff != 0.0:
            var u: float = 1.0 - t
            var r_half: float = r * 0.5
            if o_wrapped < d_wrapped and diff > r_half:
                return fposmod(u * (o_wrapped + r) + t * d_wrapped, r)
            elif o_wrapped > d_wrapped and diff < -r_half:
                return fposmod(u * o_wrapped + t * (d_wrapped + r), r)
            else:
                return u * o_wrapped + t * d_wrapped

        return o_wrapped

    ## Converts a color from linear sRGB to SR LAB 2. See Jan Behrens,
    ## https://www.magnetkern.de/srlab2.html .
    static func linear_rgb_to_sr_lab_2(c: Rgb.Rgb) -> Lab.Lab:
        var rl: float = c.r
        var gl: float = c.g
        var bl: float = c.b

        # Convert from linear sRGB to XYZ.
        var x0: float = 0.32053 * rl + 0.63692 * gl + 0.04256 * bl
        var y0: float = 0.161987 * rl + 0.756636 * gl + 0.081376 * bl
        var z0: float = 0.017228 * rl + 0.10866 * gl + 0.874112 * bl

        var x1: float = x0 * 9.032963
        var y1: float = y0 * 9.032963
        var z1: float = z0 * 9.032963

        if x0 > 0.008856452: x1 = 1.16 * pow(x0, 0.333333333) - 0.16
        if y0 > 0.008856452: y1 = 1.16 * pow(y0, 0.333333333) - 0.16
        if z0 > 0.008856452: z1 = 1.16 * pow(z0, 0.333333333) - 0.16

        # Convert from XYZ to LAB.
        var l: float = 37.095 * x1 + 62.9054 * y1 - 0.0008 * z1
        var a: float = 663.4684 * x1 - 750.5078 * y1 + 87.0328 * z1
        var b: float = 63.9569 * x1 + 108.4576 * y1 - 172.4152 * z1

        return Lab.Lab.new(l, a, b, c.alpha)

    ## Converts a color from linear sRGB to gamma SR LCH.
    static func linear_rgb_to_sr_lch(c: Rgb.Rgb) -> Lch.Lch:
        return ClrUtils.lab_to_lch(ClrUtils.linear_rgb_to_sr_lab_2(c))

    ## Mixes two colors in gamma sRGB by a factor in [0.0, 1.0]. If the factor
    ## is less than or equal to zero, returns the origin by value. If greater
    ## than or equal to one, returns the destination by value.
    static func mix_gamma_rgb(o: Rgb.Rgb, d: Rgb.Rgb, t: float = 0.5) -> Rgb.Rgb:
        if t <= 0.0: return Rgb.Rgb.new(o.r, o.g, o.b, o.alpha)
        if t >= 1.0: return Rgb.Rgb.new(d.r, d.g, d.b, d.alpha)

        var u: float = 1.0 - t
        var ol: Rgb.Rgb = Rgb.Rgb.gamma_to_linear(o)
        var dl: Rgb.Rgb = Rgb.Rgb.gamma_to_linear(d)
        return Rgb.Rgb.linear_to_gamma(Rgb.Rgb.new(
            u * ol.r + t * dl.r,
            u * ol.g + t * dl.g,
            u * ol.b + t * dl.b,
            u * ol.alpha + t * dl.alpha))

    ## Mixes two colors in LAB by a factor in [0.0, 1.0]. If the factor
    ## is less than or equal to zero, returns the origin by value. If greater
    ## than or equal to one, returns the destination by value.
    static func mix_lab(o: Lab.Lab, d: Lab.Lab, t: float = 0.5) -> Lab.Lab:
        if t <= 0.0: return Lab.Lab.new(o.l, o.a, o.b, o.alpha)
        if t >= 1.0: return Lab.Lab.new(d.l, d.a, d.b, d.alpha)

        var u: float = 1.0 - t
        return Lab.Lab.new(
            u * o.l + t * d.l,
            u * o.a + t * d.a,
            u * o.b + t * d.b,
            u * o.alpha + t * d.alpha)

    ## Mixes two colors in LCH by a factor in [0.0, 1.0]. If the factor
    ## is less than or equal to zero, returns the origin by value. If greater
    ## than or equal to one, returns the destination by value. Eases the hue
    ## according to its shortest arc length.
    static func mix_lch(o: Lch.Lch, d: Lch.Lch, t: float = 0.5) -> Lch.Lch:
        if t <= 0.0: return Lch.Lch.new(o.l, o.c, o.h, o.alpha)
        if t >= 1.0: return Lch.Lch.new(d.l, d.c, d.h, d.alpha)

        var u: float = 1.0 - t
        var cl: float = u * o.l + t * d.l
        var c_alpha: float = u * o.alpha + t * d.alpha

        var o_gray = o.c < 0.000001
        var d_gray = o.c < 0.000001
        if o_gray and d_gray:
            return Lch.Lch.new(cl, 0.0, 0.0, c_alpha)
        elif o_gray or d_gray:
            var oa: float = 0.0
            var ob: float = 0.0
            if not o_gray:
                oa = o.c * cos(o.h)
                ob = o.c * sin(o.h)

            var da: float = 0.0
            var db: float = 0.0
            if not d_gray:
                da = d.c * cos(d.h)
                db = d.c * sin(d.h)

            var ca: float = u * oa + t * da
            var cb: float = u * ob + t * db
            var cc: float = sqrt(ca * ca + cb * cb)
            var ch: float = fposmod(atan2(cb, ca), TAU) / TAU

            return Lch.Lch.new(cl, cc, ch, c_alpha)

        var cc: float = u * o.c + t * d.c

        # lerp_angle may result in negative hues.
        # var ch: float = lerp_angle(o.h * TAU, d.h * TAU, t) / TAU
        var ch: float = ClrUtils.lerp_angle_near(o.h, d.h, t, 1.0)
        return Lch.Lch.new(cl, cc, ch, c_alpha)

    ## Mixes two colors in linear sRGB by a factor in [0.0, 1.0]. If the factor
    ## is less than or equal to zero, returns the origin by value. If greater
    ## than or equal to one, returns the destination by value.
    static func mix_linear_rgb(o: Rgb.Rgb, \
        d: Rgb.Rgb, \
        t: float = 0.5) -> Rgb.Rgb:
        if t <= 0.0: return Rgb.Rgb.new(o.r, o.g, o.b, o.alpha)
        if t >= 1.0: return Rgb.Rgb.new(d.r, d.g, d.b, d.alpha)

        var u: float = 1.0 - t
        return Rgb.Rgb.new(
            u * o.r + t * d.r,
            u * o.g + t * d.g,
            u * o.b + t * d.b,
            u * o.alpha + t * d.alpha)

    ## Converts a color from SR LAB 2 to gamma sRGB.
    static func sr_lab_2_to_gamma_rgb(c: Lab.Lab) -> Rgb.Rgb:
        return Rgb.Rgb.linear_to_gamma(ClrUtils.sr_lab_2_to_linear_rgb(c))

    ## Converts a color from SR LAB 2 to linear sRGB. See Jan Behrens,
    ## https://www.magnetkern.de/srlab2.html .
    static func sr_lab_2_to_linear_rgb(c: Lab.Lab) -> Rgb.Rgb:
        var l: float = c.l
        var a: float = c.a
        var b: float = c.b

        # Convert from LAB to XYZ.
        var l01: float = l * 0.01
        var x0: float = l01 + 0.000904127 * a + 0.000456344 * b
        var y0: float = l01 - 0.000533159 * a - 0.000269178 * b
        var z0: float = l01 - 0.0058 * b

        var x1: float = x0 * 0.110705644
        var y1: float = y0 * 0.110705644
        var z1: float = z0 * 0.110705644

        if x0 > 0.08: x1 = pow((x0 + 0.16) / 1.16, 3.0)
        if y0 > 0.08: y1 = pow((y0 + 0.16) / 1.16, 3.0)
        if z0 > 0.08: z1 = pow((z0 + 0.16) / 1.16, 3.0)

        # Convert from XYZ to linear sRGB.
        var rl: float = 5.435679 * x1 - 4.599131 * y1 + 0.163593 * z1
        var gl: float = -1.16809 * x1 + 2.327977 * y1 - 0.159798 * z1
        var bl: float = 0.03784 * x1 - 0.198564 * y1 + 1.160644 * z1

        return Rgb.Rgb.new(rl, gl, bl, c.alpha)

    ## Converts a color from SR LCH to gamma sRGB.
    static func sr_lch_to_gamma_rgb(c: Lch.Lch) -> Rgb.Rgb:
        return Rgb.Rgb.linear_to_gamma(ClrUtils.sr_lab_2_to_linear_rgb(
            ClrUtils.lch_to_lab(c)))

    ## Converts a color from SR LCH to linear sRGB.
    static func sr_lch_to_linear_rgb(c: Lch.Lch) -> Rgb.Rgb:
        return ClrUtils.sr_lab_2_to_linear_rgb(ClrUtils.lch_to_lab(c))
