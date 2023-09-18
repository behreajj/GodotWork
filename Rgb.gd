## Represents colors in gamma or linear RGB, assumed to be standard RGB (sRGB).
## Typically, the red, green and blue channels are real numbers in [0.0, 1.0],
## but these channels are not clamped so as to preserve out-of-gamut colors.
class_name Rgb

## The alpha, or opacity, component, in the range [0.0, 1.0].
var alpha: float

## The blue channel, typically in the range [0.0, 1.0].
var b: float

## The green channel, typically in the range [0.0, 1.0].
var g: float

## The red channel, typically in the range [0.0, 1.0].
var r: float

## Creates an RGB color from real numbers.
func _init(rd: float = 1.0, \
    gr: float = 1.0, \
    bl: float = 1.0, \
    opacity: float = 1.0):
    self.alpha = opacity
    self.b = bl
    self.g = gr
    self.r = rd

## Renders the color as a string in JSON format.
func _to_string() -> String:
    return Rgb.to_json_string(self)

## Finds the color's alpha expressed as a byte in [0, 255].
static func byte_alpha(c: Rgb) -> int:
    return int(clamp(c.alpha, 0.0, 1.0) * 255 + 0.5)

## Finds the color's blue channel expressed as a byte in [0, 255].
static func byte_blue(c: Rgb) -> int:
    return int(clamp(c.b, 0.0, 1.0) * 255 + 0.5)

## Finds the color's green channel expressed as a byte in [0, 255].
static func byte_green(c: Rgb) -> int:
    return int(clamp(c.g, 0.0, 1.0) * 255 + 0.5)

## Finds the color's red channel expressed as a byte in [0, 255].
static func byte_red(c: Rgb) -> int:
    return int(clamp(c.r, 0.0, 1.0) * 255 + 0.5)

## Clamps all color components to the range [0.0, 1.0].
static func clamp_01(c: Rgb) -> Rgb:
    return Rgb.new( \
        clamp(c.r, 0.0, 1.0), \
        clamp(c.g, 0.0, 1.0), \
        clamp(c.b, 0.0, 1.0), \
        clamp(c.alpha, 0.0, 1.0))

## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func copy_alpha(o: Rgb, d: Rgb) -> Rgb:
    return Rgb.new(o.r, o.g, o.b, d.alpha)

## Converts a color from gamma sRGB to linear sRGB.
static func gamma_to_linear(c: Rgb) -> Rgb:
    var lr: float = c.r
    if lr <= 0.04045:
        lr = lr / 12.92
    else:
        lr = pow((lr + 0.055) / 1.055, 2.4)

    var lg: float = c.g
    if lg <= 0.04045:
        lg = lg / 12.92
    else:
        lg = pow((lg + 0.055) / 1.055, 2.4)

    var lb: float = c.b
    if lb <= 0.04045:
        lb = lb / 12.92
    else:
        lb = pow((lb + 0.055) / 1.055, 2.4)

    return Rgb.new(lr, lg, lb, c.alpha)

## Finds a grayscale version of the color, assuming the color is in gamma
## sRGB. Uses the coefficients 0.213, 0.715 and 0.072. Converts the color
## from gamma to linear, finds the relative luminance, then converts that
## to gamma.
static func gray_gamma(c: Rgb) -> Rgb:
    var linear: Rgb = Rgb.gamma_to_linear(c)
    var rel_lum: float = 0.21264935 * linear.r \
        + 0.71516913 * linear.g \
        + 0.07218152 * linear.b
    var gr: float = rel_lum
    if gr <=  0.04045:
        gr = gr * 0.077399380804954
    else:
        gr = pow((gr + 0.055) * 0.9478672985782, 2.4)
    return Rgb.new(gr, gr, gr, c.alpha)

## Finds a grayscale version of the color, assuming the color is in linear
## sRGB. Uses the coefficients 0.213, 0.715 and 0.072.
static func gray_linear(c: Rgb) -> Rgb:
    var rel_lum: float = 0.21264935 * c.r \
        + 0.71516913 * c.g \
        + 0.07218152 * c.b
    return Rgb.new(rel_lum, rel_lum, rel_lum, c.alpha)

## Evaluates whether a color is in gamut, i.e., whether the red, green and
## blue channels are all within [0.0, 1.0] plus or minus an epsilon. The
## epsilon requires adjustment based on, e.g., the LAB variant used.
static func is_in_gamut(c: Rgb, eps: float = 0.001) -> bool:
    var one_eps: float = 1.0 + eps
    return c.r >= -eps and c.r <= one_eps \
        and c.g >= -eps and c.g <= one_eps \
        and c.b >= -eps and c.b <= one_eps

## Converts a color from linear sRGB to gamma sRGB.
static func linear_to_gamma(c: Rgb) -> Rgb:
    var inverse_gamma: float = 1.0 / 2.4

    var sr: float = c.r
    if sr <= 0.0031308:
        sr = sr * 12.92
    else:
        sr = pow(sr, inverse_gamma) * 1.055 - 0.055

    var sg: float = c.g
    if sg <= 0.0031308:
        sg = sg * 12.92
    else:
        sg = pow(sg, inverse_gamma) * 1.055 - 0.055

    var sb: float = c.b
    if sb <= 0.0031308:
        sb = sb * 12.92
    else:
        sb = pow(sb, inverse_gamma) * 1.055 - 0.055

    return Rgb.new(sr, sg, sb, c.alpha)

## Finds an opaque version of the color, where the alpha is 1.0.
static func opaque(c: Rgb) -> Rgb:
    return Rgb.new(c.r, c.g, c.b, 1.0)

## Creates a color with the source channels multiplied by its alpha channel.
## If the alpha is less than or equal to zero, returns clear black.
## If the alpha is greater than or equal to one, returns the opaque color.
## Used when blending colors.
static func premul(c: Rgb) -> Rgb:
    var t: float = c.alpha
    if t <= 0.0:
        return Rgb.clear_black()
    elif t >= 1.0:
        return Rgb.opaque(c)
    return Rgb.new(c.r * t, c.g * t, c.b * t, t)

## For colors which exceed the range [0.0, 1.0] in gamma RGB, applies
## ACES tone mapping algorithm.
static func tone_map_aces_gamma(c: Rgb) -> Rgb:
    return Rgb.linear_to_gamma(Rgb.tone_map_aces_linear(
        Rgb.gamma_to_linear(c)))

## For colors which exceed the range [0.0, 1.0] in linear RGB, applies
## ACES tone mapping algorithm. See https://64.github.io/tonemapping/ .
static func tone_map_aces_linear(c: Rgb) -> Rgb:
    var rFrwrd: float = 0.59719 * c.r + 0.35458 * c.g + 0.04823 * c.b
    var gFrwrd: float = 0.076 * c.r + 0.90834 * c.g + 0.01566 * c.b
    var bFrwrd: float = 0.0284 * c.r + 0.13383 * c.g + 0.83777 * c.b

    var ar: float = rFrwrd * (rFrwrd + 0.0245786) - 0.000090537
    var ag: float = gFrwrd * (gFrwrd + 0.0245786) - 0.000090537
    var ab: float = bFrwrd * (bFrwrd + 0.0245786) - 0.000090537

    var br: float = rFrwrd * (0.983729 * rFrwrd + 0.432951) + 0.238081
    var bg: float = gFrwrd * (0.983729 * gFrwrd + 0.432951) + 0.238081
    var bb: float = bFrwrd * (0.983729 * bFrwrd + 0.432951) + 0.238081

    var cr: float = 0.0
    var cg: float = 0.0
    var cb: float = 0.0

    if br != 0.0: cr = ar / br
    if bg != 0.0: cg = ag / bg
    if bb != 0.0: cb = ab / bb

    var rBckwd: float = 1.60475 * cr - 0.53108 * cg - 0.07367 * cb
    var gBckwd: float = -0.10208 * cr + 1.10813 * cg - 0.00605 * cb
    var bBckwd: float = -0.00327 * cr - 0.07276 * cg + 1.07602 * cb

    return Rgb.new(
        clamp(rBckwd, 0.0, 1.0),
        clamp(gBckwd, 0.0, 1.0),
        clamp(bBckwd, 0.0, 1.0),
        clamp(c.alpha, 0.0, 1.0))

## Finds the color expressed as a 32 bit integer. Clamps the color's channels
## to [0, 255], i.e. uses saturation arithmetic. The channels are packed in
## the order alpha, blue, green, red.
static func to_abgr_32(c: Rgb) -> int:
    return int(clamp(c.alpha, 0.0, 1.0) * 255 + 0.5) << 0x18 \
        | int(clamp(c.b, 0.0, 1.0) * 255 + 0.5) << 0x10 \
        | int(clamp(c.g, 0.0, 1.0) * 255 + 0.5) << 0x08 \
        | int(clamp(c.r, 0.0, 1.0) * 255 + 0.5)

## Finds the color expressed as a 32 bit integer. Clamps the color's channels
## to [0, 255], i.e. uses saturation arithmetic. The channels are packed in
## the order alpha, red, green, blue.
static func to_argb_32(c: Rgb) -> int:
    return int(clamp(c.alpha, 0.0, 1.0) * 255 + 0.5) << 0x18 \
        | int(clamp(c.r, 0.0, 1.0) * 255 + 0.5) << 0x10 \
        | int(clamp(c.g, 0.0, 1.0) * 255 + 0.5) << 0x08 \
        | int(clamp(c.b, 0.0, 1.0) * 255 + 0.5)

## Renders the color as a 6 digit, 24 bit hexadecimal string suitable for web
## development. The channels are packed in the order red, green, blue. There is
## no hashtag or '0x' prefix for the string.
static func to_hex_web(c: Rgb) -> String:
    return "%06x" % (int(clamp(c.r, 0.0, 1.0) * 255 + 0.5) << 0x10 \
        | int(clamp(c.g, 0.0, 1.0) * 255 + 0.5) << 0x08 \
        | int(clamp(c.b, 0.0, 1.0) * 255 + 0.5))

## Renders a color as a string in JSON format.
static func to_json_string(c: Rgb) -> String:
    return "{\"r\":%.4f,\"g\":%.4f,\"b\":%.4f,\"alpha\":%.4f}" \
        % [ c.r, c.g, c.b, c.alpha ]

## Creates a color with the source channels divided by its alpha channel.
## If the alpha is less than or equal to zero, returns clear black.
## If the alpha is greater than or equal to one, returns the opaque color.
## Used when blending colors.
static func unpremul(c: Rgb) -> Rgb:
    var t: float = c.alpha
    if t <= 0.0:
        return Rgb.clear_black()
    elif t >= 1.0:
        return Rgb.opaque(c)
    var tInv: float = 1.0 / t
    return Rgb.new(c.r * tInv, c.g * tInv, c.b * tInv, t)

## Creates a preset color for opaque black.
static func black() -> Rgb:
    return Rgb.new(0.0, 0.0, 0.0, 1.0)

## Creates a preset color for blue.
static func blue() -> Rgb:
    return Rgb.new(0.0, 0.0, 1.0, 1.0)

## Creates a preset color for invisible black.
static func clear_black() -> Rgb:
    return Rgb.new(0.0, 0.0, 0.0, 0.0)

## Creates a preset color for invisible white.
static func clear_white() -> Rgb:
    return Rgb.new(1.0, 1.0, 1.0, 0.0)

## Creates a preset color for cyan.
static func cyan() -> Rgb:
    return Rgb.new(0.0, 1.0, 1.0, 1.0)

## Creates a preset color for green.
static func green() -> Rgb:
    return Rgb.new(0.0, 1.0, 0.0, 1.0)

## Creates a preset color for magenta.
static func magenta() -> Rgb:
    return Rgb.new(1.0, 0.0, 1.0, 1.0)

## Creates a preset color for red.
static func red() -> Rgb:
    return Rgb.new(1.0, 0.0, 0.0, 1.0)

## Creates a preset color for opaque white.
static func white() -> Rgb:
    return Rgb.new(1.0, 1.0, 1.0, 1.0)

## Creates a preset color for yellow.
static func yellow() -> Rgb:
    return Rgb.new(1.0, 1.0, 0.0, 1.0)
