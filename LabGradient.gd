## A gradient for mixing colors in LAB color space.
class_name LabGradient

## An array of LAB keys.
var keys: Array

## Gradient evaluation presets.
enum Easing { LAB, LCH_CCW, LCH_CW, LCH_FAR, LCH_NEAR }

## Creates a new gradient from an array of keys.
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
