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
        samples.push_back(lab)
        i = i + 1

    return samples

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
        ks.push_back(k)
        i = i + 1

    return LabGradient.new(ks)

## Creates a gradient where the keys are in reverse order. The source gradient's
## colors are copied to the reversed by value.
static func reversed(source: LabGradient) -> LabGradient:
    var ks_source: Array = source.keys
    var ks_target: Array = []
    var len_ks: int = ks_source.size()

    var i: int = 0
    while i < len_ks:
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

        ks_target.push_back(k_target)
        i = i + 1

    ks_target.reverse()
    return LabGradient.new(ks_target)

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

## Renders a gradient as a string in JSON format.
static func to_json_string(cg: LabGradient) -> String:
    # TODO: Is there a better way to concatenate an array to strings?
    var ks: Array = cg.keys
    var len_ks: int = ks.size()
    var i: int = 0
    var cg_str: String = "{\"keys\":["
    while i < len_ks:
        var k: LabKey = ks[i]
        var k_str: String = LabKey.to_json_string(k)
        cg_str += k_str
        if i < len_ks - 1: cg_str += ","
        i = i + 1
    cg_str += "]}"
    return cg_str
