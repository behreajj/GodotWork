## A gradient for mixing colors in LAB color space.
class_name LabGradient


## Gradient evaluation presets.
enum Easing { LAB, LCH_CCW, LCH_CW, LCH_FAR, LCH_NEAR }


## An array of LAB keys.
var keys: Array


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


## Copies all components of the source gradient by value to a new gradient.
static func copy(source: LabGradient) -> LabGradient:
    var ks_source: Array = source.keys
    var ks_target: Array = []
    var len_ks: int = ks_source.size()

    var i: int = 0
    while i < len_ks:
        ks_target.append(LabKey.copy(ks_source[i]))
        i = i + 1

    return LabGradient.new(ks_target)


## Creates a gradient where the source's keys are distributed evenly through
## the range [0.0, 1.0]. The source gradient's colors are copied by value.
static func distributed(source: LabGradient) -> LabGradient:
    var ks_source: Array = source.keys
    var ks_target: Array = []
    var len_ks: int = ks_source.size()

    if len_ks == 0:
        return LabGradient.new([
            LabKey.new(0.0, Lab.black()),
            LabKey.new(1.0, Lab.white())
            ])
    if len_ks == 1:
        return LabGradient.new([
            LabKey.new(0.0, Lab.black()),
            LabKey.new(0.5, Lab.copy(ks_source[0].color)),
            LabKey.new(1.0, Lab.white())
            ])

    var i_to_step: float = 1.0 / (len_ks - 1.0)

    var i: int = 0
    while i < len_ks:
        var k_source: LabKey = ks_source[i]
        var color_source: Lab = k_source.color

        var step_target: float = i * i_to_step
        var color_target: Lab = Lab.copy(color_source)
        var k_target: LabKey = LabKey.new(step_target, color_target)

        ks_target.append(k_target)

        i = i + 1

    return LabGradient.new(ks_target)


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
    var t_mapped: float = (t_clamped - prev_step) * denom

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
    var samples: Array = []

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
## then places the color between black and white. Copies colors by value.
static func from_colors(cs: Array) -> LabGradient:
    var len_colors: int = cs.size()

    if len_colors == 0:
        return LabGradient.new([
            LabKey.new(0.0, Lab.black()),
            LabKey.new(1.0, Lab.white())
            ])
    if len_colors == 1:
        return LabGradient.new([
            LabKey.new(0.0, Lab.black()),
            LabKey.new(0.5, Lab.copy(cs[0])),
            LabKey.new(1.0, Lab.white())
            ])

    var ks: Array = []
    var i: int = 0
    var i_to_fac: float = 1.0 / (len_colors - 1.0)
    while i < len_colors:
        var step: float = i * i_to_fac
        var color: Lab = Lab.copy(cs[i])
        var k: LabKey = LabKey.new(step, color)
        ks.append(k)
        i = i + 1

    return LabGradient.new(ks)


## Creates a gradient from the standard RGB primaries and secondiares: red,
## yellow, green, cyan, blue and magenta. Red is included twice, at the first
## and last key.
static func palette_rgb() -> LabGradient:
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
static func palette_ryb() -> LabGradient:
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


## Creates a gradient where the keys are in reverse order. The source gradient's
## colors are copied by value.
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
        var color_target: Lab = Lab.copy(color_source)
        var k_target: LabKey = LabKey.new(step_target, color_target)

        ks_target.append(k_target)

    return LabGradient.new(ks_target)


## Renders a gradient as a string in JSON format.
static func to_json_string(cg: LabGradient) -> String:
    var ks: Array = cg.keys
    var len_ks: int = ks.size()
    var sb: PackedStringArray = PackedStringArray()
    sb.append("{\"keys\":[")

    var i: int = 0
    while i < len_ks:
        var k: LabKey = ks[i]
        var k_str: String = LabKey.to_json_string(k)
        sb.append(k_str)
        if i < len_ks - 1: sb.append(",")
        i = i + 1

    sb.append("]}")
    return "".join(sb)


## Renders a gradient as a string in SVG format. SVG gradients use gamma sRGB
## interpolation by default, so the LAB gradient is sampled by a count. With
## more samples, the SVG gradient will more closely approximate the original.
static func to_svg_string(cg: LabGradient, \
    count: int = 16, \
    preset: LabGradient.Easing = LabGradient.Easing.LAB, \
    id: String = "godotGradient",
    w: int = 768, \
    h: int = 64, \
    x1: float = 0.0, \
    y1: float = 0.5, \
    x2: float = 1.0, \
    y2: float = 0.5) -> String:

    # Step is for gradient interpolation, fac is for discrete swatches that
    # have a left and right edge.
    var count_verif: int = clamp(abs(count), 2, 256)
    var i_to_step: float = 1.0 / (count_verif - 1.0)
    var i_to_fac: float = 1.0 / count_verif

    var w_vrf: int = max(3, w)
    var h_vrf: int = max(3, h)
    @warning_ignore("integer_division")
    var h_vrf_half: int = h_vrf / 2

    var sw_left: float = 0.0
    var sw_right: float = w_vrf

    var w_str: String = "%.1f" % w_vrf
    var h_str: String = "%.1f" % h_vrf
    var h_mid_str: String = "%.1f" % h_vrf_half

    var svgp: PackedStringArray = PackedStringArray()
    svgp.append("<svg ")
    svgp.append("xmlns=\"http://www.w3.org/2000/svg\" ")
    svgp.append("xmlns:xlink=\"http://www.w3.org/1999/xlink\" ")
    svgp.append("width=\"%d\" height=\"%d\" " % [ w_vrf, h_vrf ])
    svgp.append("viewBox=\"0 0 %d %d\" " % [ w_vrf, h_vrf ])
    svgp.append("preserveAspectRatio=\"xMidYMid slice\" ")
    svgp.append("stroke=\"none\">\r\n")

    svgp.append("<defs>\r\n")
    svgp.append("<linearGradient id=\"%s\" " % id)
    svgp.append("x1=\"%.6f\" y1=\"%.6f\" x2=\"%.6f\" y2=\"%.6f\">\r\n"
        % [x1, y1, x2, y2])

    var sb_swatch: PackedStringArray = PackedStringArray()
    sb_swatch.append("<g id=\"swatches\">\r\n")

    var i: int = 0
    while i < count_verif:
        var step: float = i * i_to_step

        var lab: Lab = LabGradient.eval(cg, step, preset)
        var srgb_linear: Rgb = ClrUtils.sr_lab_2_to_linear_rgb(lab)
        var srgb_gamma: Rgb = Rgb.linear_to_gamma(srgb_linear)
        var hex_gamma: String = Rgb.to_hex_web(srgb_gamma)

        var t01: float = clamp(lab.alpha, 0.0, 1.0)
        var t01_str: String = "%.6f" % t01
        var include_opacity: bool = t01 < 0.999999

        svgp.append("<stop offset=\"")
        svgp.append("%.6f" % step)
        if include_opacity:
            svgp.append("\" stop-opacity=\"")
            svgp.append(t01_str)
        svgp.append("\" stop-color=\"#")
        svgp.append(hex_gamma)
        svgp.append("\" />")
        if i < count_verif - 1: svgp.append("\r\n")

        var fac0: float = i * i_to_fac
        var fac1: float = (i + 1) * i_to_fac
        var x_left: float = ( 1.0 - fac0 ) * sw_left + fac0 * sw_right
        var x_right: float = ( 1.0 - fac1 ) * sw_left + fac1 * sw_right

        var xl_str: String = "%.6f" % x_left
        var xr_str: String = "%.6f" % x_right

        sb_swatch.append("<path id=\"swatch%03d\" " % i)
        sb_swatch.append("d=\"M %s %s L %s %s L %s %s L %s %s Z" % [
            xl_str, h_mid_str,
            xr_str, h_mid_str,
            xr_str, h_str,
            xl_str, h_str
            ])

        if include_opacity:
            sb_swatch.append("\" fill-opacity=\"")
            sb_swatch.append(t01_str)
        sb_swatch.append("\" fill=\"#")
        sb_swatch.append(hex_gamma)
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
    svgp.append(" />\r\n")
    svgp.append("".join(sb_swatch))
    svgp.append("</svg>")

    return "".join(svgp)
