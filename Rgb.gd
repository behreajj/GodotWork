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
    self.r = rd
    self.g = gr
    self.b = bl
    self.alpha = opacity


## Renders the color as a string in JSON format.
func _to_string() -> String:
    return Rgb.to_json_string(self)


## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func adopt_alpha(o: Rgb, d: Rgb) -> Rgb:
    return Rgb.new(o.r, o.g, o.b, d.alpha)


## Finds the color's alpha expressed as a byte in [0, 255].
static func byte_alpha(c: Rgb) -> int:
    return int(clampf(c.alpha, 0.0, 1.0) * 255.0 + 0.5)


## Finds the color's blue channel expressed as a byte in [0, 255].
static func byte_blue(c: Rgb) -> int:
    return int(clampf(c.b, 0.0, 1.0) * 255.0 + 0.5)


## Finds the color's green channel expressed as a byte in [0, 255].
static func byte_green(c: Rgb) -> int:
    return int(clampf(c.g, 0.0, 1.0) * 255.0 + 0.5)


## Finds the color's red channel expressed as a byte in [0, 255].
static func byte_red(c: Rgb) -> int:
    return int(clampf(c.r, 0.0, 1.0) * 255.0 + 0.5)


## Clamps all color components to the range [0.0, 1.0].
static func clamp_01(c: Rgb) -> Rgb:
    return Rgb.new( \
        clampf(c.r, 0.0, 1.0), \
        clampf(c.g, 0.0, 1.0), \
        clampf(c.b, 0.0, 1.0), \
        clampf(c.alpha, 0.0, 1.0))


## Copies all components of the source color by value to a new color.
static func copy(source: Rgb) -> Rgb:
    return Rgb.new(source.r, source.g, source.b, source.alpha)


## Evaluates whether two colors are equal when represented as 32-bit integers
## in the format 0xAABBGGRR.
static func eq(o: Rgb, d: Rgb) -> bool:
    return Rgb.to_abgr_32(o) == Rgb.to_abgr_32(d)


## Creates a color from an integer with packed channels in 0xAABBGGRR order.
static func from_abgr_32(x: int) -> Rgb:
    return Rgb.from_bytes(
        x >> 0x00,
        x >> 0x08,
        x >> 0x10,
        x >> 0x18)


## Creates a color from an integer with packed channels in 0xAARRGGBB order.
static func from_argb_32(x: int) -> Rgb:
    return Rgb.from_bytes(
        x >> 0x10,
        x >> 0x08,
        x >> 0x00,
        x >> 0x18)


## Creates a color from integers in the range [0, 255].
static func from_bytes(r8: int = 255, \
    g8: int = 255, \
    b8: int = 255, \
    a8: int = 255) -> Rgb:
    return Rgb.new(
        (r8 & 0xff) / 255.0,
        (g8 & 0xff) / 255.0,
        (b8 & 0xff) / 255.0,
        (a8 & 0xff) / 255.0)


## Creates a color from integers in the range [0, 65535].
static func from_shorts(r16: int = 65535, \
    g16: int = 65535, \
    b16: int = 65535, \
    a16: int = 65535) -> Rgb:
    return Rgb.new(
        (r16 & 0xffff) / 65535.0,
        (g16 & 0xffff) / 65535.0,
        (b16 & 0xffff) / 65535.0,
        (a16 & 0xffff) / 65535.0)


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
    var v: float = rel_lum
    if v <= 0.04045:
        v = v / 12.92
    else:
        v = pow((v + 0.055) / 1.055, 2.4)
    return Rgb.new(v, v, v, c.alpha)


## Finds a grayscale version of the color, assuming the color is in linear
## sRGB. Uses the coefficients 0.213, 0.715 and 0.072.
static func gray_linear(c: Rgb) -> Rgb:
    var rel_lum: float = 0.21264935 * c.r \
        + 0.71516913 * c.g \
        + 0.07218152 * c.b
    return Rgb.new(rel_lum, rel_lum, rel_lum, c.alpha)


## Creates a 3D grid of colors in gamma sRGB, then returns them as a 1D array.
## Red is associated with columns, or the x axis. Green is associated with rows,
## or the y axis. Blue is associated with layers, or the z axis.
static func grid_cartesian(cols: int = 8, \
    rows: int = 8, \
    layers: int = 8, \
    opacity: float = 1.0) -> Array:
    var t_vrf: float = clampf(opacity, 0.0, 1.0)
    var l_vrf: int = maxi(1, layers)
    var r_vrf: int = maxi(1, rows)
    var c_vrf: int = maxi(1, cols)

    var one_layer: bool = l_vrf == 1
    var one_row: bool = r_vrf == 1
    var one_col: bool = c_vrf == 1

    var h_to_step: float = 0.0
    var i_to_step: float = 0.0
    var j_to_step: float = 0.0

    if not one_layer: h_to_step = 1.0 / (l_vrf - 1.0)
    if not one_row: i_to_step = 1.0 / (r_vrf - 1.0)
    if not one_col: j_to_step = 1.0 / (c_vrf - 1.0)

    var result: Array = []
    var rc_vrf: int = r_vrf * c_vrf
    var len3: int = l_vrf * rc_vrf
    var k: int = 0
    while k < len3:
        @warning_ignore("integer_division")
        var h: int = k / rc_vrf
        var m: int = k - h * rc_vrf
        @warning_ignore("integer_division")
        var i: int = m / c_vrf
        var j: int = m % c_vrf

        result.append(Rgb.new(
            j * j_to_step,
            i * i_to_step,
            h * h_to_step,
            t_vrf))
        k = k + 1

    return result


## Evaluates whether a color is greater than another when both are represented
## as 32-bit integers in the format 0xAABBGGRR.
static func gt(o: Rgb, d: Rgb) -> bool:
    return Rgb.to_abgr_32(o) > Rgb.to_abgr_32(d)


## Evaluates whether a color is greater than or equal to another when both are
## represented as 32-bit integers in the format 0xAABBGGRR.
static func gt_eq(o: Rgb, d: Rgb) -> bool:
    return Rgb.to_abgr_32(o) >= Rgb.to_abgr_32(d)


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


## Evaluates whether a color is less than another when both are represented
## as 32-bit integers in the format 0xAABBGGRR.
static func lt(o: Rgb, d: Rgb) -> bool:
    return Rgb.to_abgr_32(o) < Rgb.to_abgr_32(d)


## Evaluates whether a color is less or equal to than another when both are
## represented as 32-bit integers in the format 0xAABBGGRR.
static func lt_eq(o: Rgb, d: Rgb) -> bool:
    return Rgb.to_abgr_32(o) <= Rgb.to_abgr_32(d)


## Finds an opaque version of the color, where the alpha is 1.0.
static func opaque(c: Rgb) -> Rgb:
    return Rgb.new(c.r, c.g, c.b, 1.0)


## Creates a color with the source channels multiplied by its alpha channel.
## If the alpha is less than or equal to zero, returns clear black.
## If the alpha is greater than or equal to one, returns the opaque color.
## Used when blending colors.
static func premul(c: Rgb) -> Rgb:
    var t: float = c.alpha
    if t <= 0.0: return Rgb.clear_black()
    if t >= 1.0: return Rgb.opaque(c)
    return Rgb.new(c.r * t, c.g * t, c.b * t, t)


## Finds the color's alpha channel expressed as a short in [0, 65535].
static func short_alpha(c: Rgb) -> int:
    return int(clampf(c.alpha, 0.0, 1.0) * 65535.0 + 0.5)


## Finds the color's blue channel expressed as a short in [0, 65535].
static func short_blue(c: Rgb) -> int:
    return int(clampf(c.b, 0.0, 1.0) * 65535.0 + 0.5)


## Finds the color's green channel expressed as a short in [0, 65535].
static func short_green(c: Rgb) -> int:
    return int(clampf(c.g, 0.0, 1.0) * 65535.0 + 0.5)


## Finds the color's red channel expressed as a short in [0, 65535].
static func short_red(c: Rgb) -> int:
    return int(clampf(c.r, 0.0, 1.0) * 65535.0 + 0.5)


## For colors which exceed the range [0.0, 1.0] in gamma RGB, applies
## ACES tone mapping algorithm.
static func tone_map_aces_gamma(c: Rgb) -> Rgb:
    return Rgb.linear_to_gamma(Rgb.tone_map_aces_linear(
        Rgb.gamma_to_linear(c)))


## For colors which exceed the range [0.0, 1.0] in linear RGB, applies
## ACES tone mapping algorithm. See https://64.github.io/tonemapping/ .
static func tone_map_aces_linear(c: Rgb) -> Rgb:
    var r_frwrd: float = 0.59719 * c.r + 0.35458 * c.g + 0.04823 * c.b
    var g_frwrd: float = 0.076 * c.r + 0.90834 * c.g + 0.01566 * c.b
    var b_frwrd: float = 0.0284 * c.r + 0.13383 * c.g + 0.83777 * c.b

    var ar: float = r_frwrd * (r_frwrd + 0.0245786) - 0.000090537
    var ag: float = g_frwrd * (g_frwrd + 0.0245786) - 0.000090537
    var ab: float = b_frwrd * (b_frwrd + 0.0245786) - 0.000090537

    var br: float = r_frwrd * (0.983729 * r_frwrd + 0.432951) + 0.238081
    var bg: float = g_frwrd * (0.983729 * g_frwrd + 0.432951) + 0.238081
    var bb: float = b_frwrd * (0.983729 * b_frwrd + 0.432951) + 0.238081

    var cr: float = 0.0
    var cg: float = 0.0
    var cb: float = 0.0

    if br != 0.0: cr = ar / br
    if bg != 0.0: cg = ag / bg
    if bb != 0.0: cb = ab / bb

    var r_bckwd: float = 1.60475 * cr - 0.53108 * cg - 0.07367 * cb
    var g_bckwd: float = -0.10208 * cr + 1.10813 * cg - 0.00605 * cb
    var b_bckwd: float = -0.00327 * cr - 0.07276 * cg + 1.07602 * cb

    return Rgb.new(
        clampf(r_bckwd, 0.0, 1.0),
        clampf(g_bckwd, 0.0, 1.0),
        clampf(b_bckwd, 0.0, 1.0),
        clampf(c.alpha, 0.0, 1.0))


## Finds the color expressed as a 32 bit integer. Clamps the color's channels
## to [0, 255], i.e. uses saturation arithmetic. The channels are packed in
## the order alpha, blue, green, red.
static func to_abgr_32(o: Rgb) -> int:
    return Rgb.byte_alpha(o) << 0x18 \
        | Rgb.byte_blue(o) << 0x10 \
        | Rgb.byte_green(o) << 0x08 \
        | Rgb.byte_red(o)


## Finds the color expressed as a 32 bit integer. Clamps the color's channels
## to [0, 255], i.e. uses saturation arithmetic. The channels are packed in
## the order alpha, red, green, blue.
static func to_argb_32(o: Rgb) -> int:
    return Rgb.byte_alpha(o) << 0x18 \
        | Rgb.byte_red(o) << 0x10 \
        | Rgb.byte_green(o) << 0x08 \
        | Rgb.byte_blue(o)


## Renders the color as a 6 digit, 24 bit hexadecimal string suitable for web
## development. The channels are packed in the order red, green, blue. There is
## no hashtag or '0x' prefix for the string.
static func to_hex_web(o: Rgb) -> String:
    return "%06x" % (Rgb.byte_red(o) << 0x10 \
        | Rgb.byte_green(o) << 0x08 \
        | Rgb.byte_blue(o))


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
    if t <= 0.0: return Rgb.clear_black()
    if t >= 1.0: return Rgb.opaque(c)
    return Rgb.new(c.r / t, c.g / t, c.b / t, t)


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
