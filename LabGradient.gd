## A gradient for mixing colors in LAB color space.
class_name LabGradient

## An array of LAB keys.
var keys: Array

## Gradient evaluation presets.
enum Easing { LAB, LCH_CCW, LCH_CW, LCH_FAR, LCH_NEAR }

## Creates a new gradient from an array of keys. The array is assigned by
## reference.
func _init(lab_keys: Array):
    self.keys = lab_keys

## Renders the gradient as a string in JSON format.
func _to_string() -> String:
    return LabGradient.to_json_string(self)

## Internal helper function to find the index of the appropriate gradient key
## based on a step given to the evaluate method.
static func _bisect_right(cg: LabGradient, t: float) -> int:
    var ks: Array = cg.keys
    var low: int = 0
    var high: int = ks.size()
    while low < high:
        @warning_ignore("integer_division")
        var middle: int = (low + high) / 2
        if t < ks[middle].step:
            high = middle
        else:
            low = middle + 1
    return low

## Evaluates a sample from the gradient according to a step in [0.0, 1.0]. The
## manner which the gradient is sampled is determined by an enum.
static func eval(cg: LabGradient, \
    t: float = 0.5, \
    preset: LabGradient.Easing = LabGradient.Easing.LAB) -> Lab:

    var ks: Array = cg.keys
    var len_ks: int = ks.size()

    var first_key: LabKey = ks[0]
    var first_step: float = first_key.step

    var last_key: LabKey = ks[len_ks - 1]
    var last_step: float = last_key.step

    var t_clamped: float = clamp(t, first_step, last_step)
    var next_idx: int = LabGradient._bisect_right(cg, t_clamped)
    var prev_idx: int = next_idx - 1

    var prev_key: LabKey = first_key
    if prev_idx >= 0 and prev_idx < len_ks:
        prev_key = ks[prev_idx]
    var prev_step: float = prev_key.step

    var next_key: LabKey = last_key
    if next_idx >= 0 and next_idx < len_ks:
        next_key = ks[next_idx]
    var next_step: float = next_key.step

    var diff: float = next_step - prev_step
    var denom: float = 0.0
    if diff != 0.0: denom = 1.0 / diff
    var t_mapped = (t_clamped - prev_step) * denom

    var prev_color: Lab = prev_key.color
    var next_color: Lab = next_key.color
    if preset == LabGradient.Easing.LCH_CCW:
        return ClrUtils.mix_lab_polar(prev_color, next_color, t_mapped,
            MathUtils.PolarEasing.CCW)
    elif preset == LabGradient.Easing.LCH_CW:
        return ClrUtils.mix_lab_polar(prev_color, next_color, t_mapped,
            MathUtils.PolarEasing.CW)
    elif preset == LabGradient.Easing.LCH_FAR:
        return ClrUtils.mix_lab_polar(prev_color, next_color, t_mapped,
            MathUtils.PolarEasing.FAR)
    elif preset == LabGradient.Easing.LCH_NEAR:
        return ClrUtils.mix_lab_polar(prev_color, next_color, t_mapped,
            MathUtils.PolarEasing.NEAR)
    else:
        return ClrUtils.mix_lab(prev_color, next_color, t_mapped)

## Evaluates a range of samples given a start and stop point. Returns an array
## of LAB colors.
static func eval_range(cg: LabGradient, \
    count: int, \
    preset: LabGradient.Easing = LabGradient.Easing.LAB, \
    start: float = 0.0, \
    stop: float = 1.0) -> Array:

    var count_verif: int = max(2, abs(count))
    var start_verif: float = max(0.0, start)
    var stop_verif: float = min(1.0, stop)
    var i_to_fac: float = 1.0 / (count_verif - 1.0)
    var samples = []

    var i: int = 0
    while i < count_verif:
        var fac: float = i * i_to_fac
        var step: float = (1.0 - fac) * start_verif + fac * stop_verif
        var lab: Lab = LabGradient.eval(cg, step, preset)
        samples.append(lab)
        i = i + 1

    return samples

## Finds the absolute difference between a gradient's minimum and maximum step.
static func extent(cg: LabGradient) -> float:
    # Don't assume that the keys array has been sorted by step.
    var ks: Array = cg.keys
    var len_ks: int = ks.size()
    var min_step: float = 999999
    var max_step: float = -999999

    var i: int = 0
    while i < len_ks:
        var k: LabKey = ks[i]
        var k_step: float = k.step
        if k_step < min_step: min_step = k_step
        if k_step > max_step: max_step = k_step
        i = i + 1

    return max_step - min_step

## Creates a gradient from an array of LAB colors. If the array's length is
## 0, then returns a black and white gradient. If the array's length is 1,
## then places the color between black and white.
static func from_colors_lab(cs: Array) -> LabGradient:
    var len_colors: int = cs.size()
    if len_colors <= 0:
        return LabGradient.new([
            LabKey.new(0.0, Lab.black()),
            LabKey.new(1.0, Lab.white())])
    if len_colors <= 1:
        return LabGradient.new([
            LabKey.new(0.0, Lab.black()),
            LabKey.new(0.5, cs[0]),
            LabKey.new(1.0, Lab.white())])

    var ks: Array = []
    var i: int = 0
    var i_to_fac = 1.0 / (len_colors - 1)
    while i < len_colors:
        var step: float = i * i_to_fac
        var color: Lab = cs[i]
        var k: LabKey = LabKey.new(step, color)
        ks.append(k)
        i = i + 1

    return LabGradient.new(ks)

## Creates a gradient where the keys are in reverse order. The source gradient's
## colors are copied to the reversed by value.
static func reversed(source: LabGradient) -> LabGradient:
    var ks_source: Array = source.keys
    var ks_target: Array = []
    var len_ks: int = ks_source.size()

    var i: int = len_ks
    while i > 0:
        i = i - 1

        var k_source: LabKey = ks_source[i]
        var step_source: float = k_source.step
        var color_source: Lab = k_source.color

        var step_target: float = 1.0 - step_source
        var color_target: Lab = Lab.new(
            color_source.l,
            color_source.a,
            color_source.b,
            color_source.alpha)
        var k_target: LabKey = LabKey.new(step_target, color_target)

        ks_target.append(k_target)

    return LabGradient.new(ks_target)

## Renders a gradient as a string in JSON format.
static func to_json_string(cg: LabGradient) -> String:
    # TODO: Is there a better way to concatenate an array to strings?
    # Use PackedStringArray plus String.join instead?
    var ks: Array = cg.keys
    var len_ks: int = ks.size()
    var cg_str: String = "{\"keys\":["

    var i: int = 0
    while i < len_ks:
        var k: LabKey = ks[i]
        var k_str: String = LabKey.to_json_string(k)
        cg_str = cg_str + k_str
        if i < len_ks - 1: cg_str = cg_str + ","
        i = i + 1
    cg_str = cg_str + "]}"
    return cg_str

## Renders a gradient as a string in SVG format. The gradient is not sampled.
## Rather its keys are reproduced, and the swatches per key are uniformly
## distributed. SVG gradients use gamma sRGB interpolation default. A filter
## can alter the gamma to create a linear sRGB interpolation. Either way, the
## appearance will differ from the LAB gradient.
static func to_svg_string(cg: LabGradient, \
    id: String = "godotGradient",
    w: int = 768, \
    h: int = 64, \
    x1: float = 0.0, \
    y1: float = 0.5, \
    x2: float = 1.0, \
    y2: float = 0.5,
    use_linear_rgb: bool = false) -> String:

    # TODO: The problem with the filter approach as it stands is that it
    # doesn't just mix between steps in linear, it applies linear to the whole
    # image, including the stops. Maybe if linear rgb is used, convert srlab2
    # to linear, then apply component transfer to go into gamma?

    var w_vrf: int = max(3, w)
    var h_vrf: int = max(3, h)
    @warning_ignore("integer_division")
    var h_vrf_half: int = h_vrf / 2

    var sw_left: float = 0.0
    var sw_right: float = w_vrf

    var w_str: String = "%.6f" % w_vrf
    var h_str: String = "%.6f" % h_vrf
    var h_mid_str: String = "%.6f" % h_vrf_half

    var svgp: PackedStringArray = PackedStringArray()
    svgp.append("<svg ")
    svgp.append("xmlns=\"http://www.w3.org/2000/svg\" ")
    svgp.append("xmlns:xlink=\"http://www.w3.org/1999/xlink\" ")
    svgp.append("shape-rendering=\"geometricPrecision\" ")
    svgp.append("viewBox=\"0 0 ")
    svgp.append(str(w_vrf))
    svgp.append(' ')
    svgp.append(str(h_vrf))
    svgp.append("\">\r\n")

    svgp.append("<defs>\r\n")
    if use_linear_rgb:
        svgp.append("<filter id=\"gammaFilter\">\r\n")
        svgp.append("<feComponentTransfer color-interpolation-filters=\"sRGB\">\r\n")
        svgp.append("<feFuncR type=\"gamma\" exponent=\"0.454545\" />\r\n")
        svgp.append("<feFuncG type=\"gamma\" exponent=\"0.454545\" />\r\n")
        svgp.append("<feFuncB type=\"gamma\" exponent=\"0.454545\" />\r\n")
        svgp.append("</feComponentTransfer>\r\n")
        svgp.append("</filter>\r\n")
    svgp.append("<linearGradient id=\"")
    svgp.append(id)
    svgp.append("\" x1=\"")
    svgp.append("%.6f" % x1)
    svgp.append("\" y1=\"")
    svgp.append("%.6f" % y1)
    svgp.append("\" x2=\"")
    svgp.append("%.6f" % x2)
    svgp.append("\" y2=\"")
    svgp.append("%.6f" % y2)
    svgp.append("\">\r\n")

    var sb_swatch: PackedStringArray = PackedStringArray()
    sb_swatch.append("<g id=\"swatches\">\r\n")

    var ks: Array = cg.keys
    var len_ks: int = ks.size()
    var to_fac: float = 1.0
    if len_ks > 1: to_fac = 1.0 / len_ks

    var i: int = 0
    while i < len_ks:
        var k: LabKey = ks[i]
        var step: float = k.step
        var lab: Lab = k.color
        var srgb: Rgb = ClrUtils.sr_lab_2_to_gamma_rgb(lab)
        var hex: String = Rgb.to_hex_web(srgb)
        var t01 = clamp(lab.alpha, 0.0, 1.0)
        var t01_str = "%.6f" % t01

        svgp.append("<stop offset=\"")
        svgp.append("%.6f" % step)
        if t01 < 1.0:
            svgp.append("\" stop-opacity=\"")
            svgp.append(t01_str)
        svgp.append("\" stop-color=\"#")
        svgp.append(hex)
        svgp.append("\" />")
        if i < len_ks - 1: svgp.append("\r\n")

        var fac0: float = i * to_fac
        var fac1: float = (i + 1) * to_fac
        var xl: float = ( 1.0 - fac0 ) * sw_left + fac0 * sw_right
        var xr: float = ( 1.0 - fac1 ) * sw_left + fac1 * sw_right

        var xl_str: String = "%.6f" % xl
        var xr_str: String = "%.6f" % xr

        sb_swatch.append("<path id=\"")
        sb_swatch.append("swatch.")
        sb_swatch.append(str(i))

        sb_swatch.append("\" d=\"M ")
        sb_swatch.append(xl_str)
        sb_swatch.append(' ')
        sb_swatch.append(h_mid_str)

        sb_swatch.append(" L ")
        sb_swatch.append(xr_str)
        sb_swatch.append(' ')
        sb_swatch.append(h_mid_str)

        sb_swatch.append(" L ");
        sb_swatch.append(xr_str)
        sb_swatch.append(' ')
        sb_swatch.append(h_str)

        sb_swatch.append(" L ")
        sb_swatch.append(xl_str)
        sb_swatch.append(' ')
        sb_swatch.append(h_str)

        sb_swatch.append(" Z\" stroke=\"none")
        if t01 < 1.0:
            sb_swatch.append("\" fill-opacity=\"")
            sb_swatch.append(t01_str)
        sb_swatch.append("\" fill=\"#")
        sb_swatch.append(hex)
        sb_swatch.append("\" />\r\n")

        i = i + 1

    sb_swatch.append("</g>\r\n")

    svgp.append("\r\n</linearGradient>\r\n")
    svgp.append("</defs>\r\n")
    svgp.append("<path id=\"ramp\" d=\"M 0.0 0.0 L ")
    svgp.append(w_str)
    svgp.append(" 0.0 L ")
    svgp.append(w_str)
    svgp.append(' ')
    svgp.append(h_mid_str)
    svgp.append(" L 0.0 ")
    svgp.append(h_mid_str)
    svgp.append(" Z\" fill=\"url('#")
    svgp.append(id)
    svgp.append("')\"")
    if use_linear_rgb:
        svgp.append(" filter=\"url('#gammaFilter')\"")
    svgp.append(" />\r\n")
    svgp.append("".join(sb_swatch))
    svgp.append("</svg>")

    return "".join(svgp)

## Creates a gradient from the standard RGB primaries and secondiares: red,
## yellow, green, cyan, blue and magenta. Red is included twice, at the first
## and last key.
static func rgb() -> LabGradient:
    return LabGradient.new([
        LabKey.new(0.0, Lab.red()),
        LabKey.new(0.16666666666667, Lab.yellow()),
        LabKey.new(0.33333333333333, Lab.green()),
        LabKey.new(0.5, Lab.cyan()),
        LabKey.new(0.66666666666667, Lab.blue()),
        LabKey.new(0.83333333333333, Lab.magenta()),
        LabKey.new(1.0, Lab.red())
    ])

## Creates a gradient that simulates a red-yellow-blue wheel where yellow is the
## brightest color and purple is the darkest. Red is included twice, at the
## first and last key.
static func ryb() -> LabGradient:
    return LabGradient.new([
        LabKey.new(0.0, Lab.new(
            39.0502325875047,
            62.1913263950166,
            53.8350374095145, 1.0)),
        LabKey.new(0.16666666666667, Lab.new(
            66.1750712486991,
            13.8165954011947,
            72.5026791646071, 1.0)),
        LabKey.new(0.33333333333333, Lab.new(
            97.0986480894659,
            -33.8687299475305,
            87.8639689718856, 1.0)),
        LabKey.new(0.5, Lab.new(
            66.0894625726177,
            -45.3366282555715,
            54.4551582873687, 1.0)),
        LabKey.new(0.66666666666667, Lab.new(
            37.0555560083937,
            -7.58274627896071,
            -92.7766323892714, 1.0)),
        LabKey.new(0.83333333333333, Lab.new(
            17.9616504201505,
            38.3366437364077,
            -42.0277981982295,
            1.0)),
        LabKey.new(1.0, Lab.new(
            39.0502325875047,
            62.1913263950166,
            53.8350374095145, 1.0))
    ])
