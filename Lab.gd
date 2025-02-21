## Represents colors in a perceptual color space, such as CIE LAB, SR LAB 2,
## OK LAB, etc. The a and b axes are signed, unbounded values. Negative a
## indicates a green hue; positive, magenta. Negative b indicates a blue hue;
## positive, yellow. Lightness falls in the range [0.0, 100.0]. For a and b,
## the practical range varies, but is roughly in [-111.0, 111.0] for CIE LAB.
## Alpha is expected to be in [0.0, 1.0].
class_name Lab


## The alpha, or opacity, component, in the range [0.0, 1.0].
var alpha: float

## The green-magenta component. Positive values proceed toward magenta.
## Negative values proceed toward green.
var a: float

## The blue-yellow component. Positive values proceed toward yellow.
## Negative values proceed toward blue.
var b: float

## The light component, in the range [0.0, 100.0].
var l: float


## Creates a LAB color from real numbers.
func _init(lightness: float = 100.0, \
    green_magenta: float = 0.0, \
    blue_yellow: float = 0.0, \
    opacity: float = 1.0):
    self.l = lightness
    self.a = green_magenta
    self.b = blue_yellow
    self.alpha = opacity


## Renders the color as a string in JSON format.
func _to_string() -> String:
    return Lab.to_json_string(self)


## Adds the left and right operands, for the purpose of making adjustments.
static func _add(o: Lab, d: Lab) -> Lab:
    return Lab.new(o.l + d.l, o.a + d.a, o.b + d.b, o.alpha + d.alpha)


## Evaluates whether two colors are approximately equal according to a
## tolerance.
static func approx(o: Lab, \
    d: Lab, \
    eps: float = 0.000001, \
    alpha_scalar: float = 1.0) -> bool:
    return abs(d.l - o.l) <= eps \
        and abs(d.a - o.a) <= eps \
        and abs(d.b - o.b) <= eps \
        and abs((d.alpha - o.alpha) * alpha_scalar) <= eps


## Evaluates a Bezier curve in color space according to a factor [0.0, 1.0],
## returning a point on the curve.
static func bezier_point(ap0: Lab, \
    cp0: Lab, \
    cp1: Lab, \
    ap1: Lab, \
    t: float) -> Lab:
    return Lab.new(
        bezier_interpolate(ap0.l, cp0.l, cp1.l, ap1.l, t),
        bezier_interpolate(ap0.a, cp0.a, cp1.a, ap1.a, t),
        bezier_interpolate(ap0.b, cp0.b, cp1.b, ap1.b, t),
        bezier_interpolate(ap0.alpha, cp0.alpha, cp1.alpha, ap1.alpha, t))


## Evaluates a Bezier curve in color space according to a factor [0.0, 1.0],
## returning a tangent, or derivative, from the curve.
static func bezier_tangent(ap0: Lab, \
    cp0: Lab, \
    cp1: Lab, \
    ap1: Lab, \
    t: float) -> Lab:
    return Lab.new(
        bezier_derivative(ap0.l, cp0.l, cp1.l, ap1.l, t),
        bezier_derivative(ap0.a, cp0.a, cp1.a, ap1.a, t),
        bezier_derivative(ap0.b, cp0.b, cp1.b, ap1.b, t),
        bezier_derivative(ap0.alpha, cp0.alpha, cp1.alpha, ap1.alpha, t))


## Finds the color's a component expressed as a byte in [0, 255].
## Clamps to the range [-127.5, 127.5], floors to an int, then adds 128.
static func byte_a(c: Lab) -> int:
    return 128 + floori(clamp(c.a, -127.5, 127.5))


## Finds the color's alpha expressed as a byte in [0, 255].
static func byte_alpha(c: Lab) -> int:
    return int(clamp(c.alpha, 0.0, 1.0) * 255.0 + 0.5)


## Finds the color's b component expressed as a byte in [0, 255].
## Clamps to the range [-127.5, 127.5], floors to an int, then adds 128.
static func byte_b(c: Lab) -> int:
    return 128 + floori(clamp(c.b, -127.5, 127.5))


## Finds the color's lightness expressed as a byte in [0, 255].
static func byte_light(c: Lab) -> int:
    return int(clamp(c.l, 0.0, 100.0) * 2.55 + 0.5)


## Finds a color's chroma. Finds the Euclidean distance of a and b from the
## origin.
static func chroma(c: Lab) -> float:
    return sqrt(Lab.chroma_sq(c))


## Finds a color's chroma squared, the sum of its a and b channels squared.
static func chroma_sq(c: Lab) -> float:
    return c.a * c.a + c.b * c.b


## Copies all components of the source color by value to a new color.
static func copy(source: Lab) -> Lab:
    return Lab.new(source.l, source.a, source.b, source.alpha)


## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func copy_alpha(o: Lab, d: Lab) -> Lab:
    return Lab.new(o.l, o.a, o.b, d.alpha)


## Creates a color with the chroma of the right operand. The other channels
## adopt the values of the left operand.
static func copy_chroma(o: Lab, d: Lab) -> Lab:
    var ocsq: float = Lab.chroma_sq(o)
    if ocsq > 0.000001:
        var s: float = Lab.chroma(d) / sqrt(ocsq)
        return Lab.new(o.l, s * o.a, s * o.b, o.alpha)
    return Lab.gray(o)


## Creates a color with the hue of the right operand. The other channels
## adopt the values of the left operand.
static func copy_hue(o: Lab, d: Lab) -> Lab:
    var dcsq: float = Lab.chroma_sq(d)
    if dcsq > 0.000001:
        var s: float = Lab.chroma(o) / sqrt(dcsq)
        return Lab.new(o.l, s * d.a, s * d.b, o.alpha)
    return Lab.gray(o)


## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func copy_light(o: Lab, d: Lab) -> Lab:
    return Lab.new(d.l, o.a, o.b, o.alpha)


## Finds the Euclidean distance between two colors.
static func dist_euclidean(o: Lab, d: Lab, alpha_scalar: float = 1.0) -> float:
    var vl: float = d.l - o.l
    var va: float = d.a - o.a
    var vb: float = d.b - o.b
    var vt: float = (d.alpha - o.alpha) * alpha_scalar
    return sqrt(vl * vl + va * va + vb * vb + vt * vt)


## Evaluates whether two colors are equal when represented as 32-bit integers.
static func eq(o: Lab, d: Lab) -> bool:
    return Lab._to_tlab_32(o) == Lab._to_tlab_32(d)


## Creates a color from integers in the range [0, 255].
static func from_bytes(lightness: int = 255, \
    green_magenta: int = 128, \
    blue_yellow: int = 128, \
    opacity: int = 255) -> Lab:
    return Lab.new(lightness / 2.55, \
        (green_magenta & 0xff) - 128.0, \
        (blue_yellow & 0xff) - 128.0, \
        opacity / 255.0)


## Creates a color from integers in the range [0, 65535].
static func from_shorts(lightness: int = 65535, \
    green_magenta: int = 32768, \
    blue_yellow: int = 32768, \
    opacity: int = 65535) -> Lab:
    return Lab.new(lightness / 655.35, \
        ((green_magenta & 0xffff) - 32768) / 257.0, \
        ((blue_yellow & 0xffff) - 32768) / 257.0, \
        opacity / 65535.0)


## Creates a color from a 32 bit integer.
static func _from_tlab_32(c: int) -> Lab:
    return Lab.new(
        ((c >> 0x10) & 0xff) / 2.55,
        ((c >> 0x08) & 0xff) - 128.0,
        (c & 0xff) - 128.0,
        ((c >> 0x18) & 0xff) / 255.0)


## Finds a grayscale version of the color, where a and b are zero.
static func gray(c: Lab) -> Lab:
    return Lab.new(c.l, 0.0, 0.0, c.alpha)


## Creates a 3D grid of colors in LAB, then returns them as a 1D array.
## Green to magenta is associated with columns, or the x axis.
## Blue to yellow is associated with rows, or the y axis.
## Lightness is associated with layers, or the z axis.
static func grid_cartesian(cols: int = 8, \
    rows: int = 8, \
    layers: int = 8, \
    opacity: float = 1.0, \
    ab_bounds: float = 111.0, \
    min_light: float = 0.0, \
    max_light: float = 100.0) -> Array:

    var mxl_vrf: float = max(min_light, max_light)
    var mnl_vrf: float = min(min_light, max_light)

    var ab_bds_vrf: float = abs(ab_bounds)

    var t_vrf: float = clamp(opacity, 0.0, 1.0)
    var l_vrf: int = max(1, layers)
    var r_vrf: int = max(1, rows)
    var c_vrf: int = max(1, cols)

    var one_layer: bool = l_vrf == 1
    var one_row: bool = r_vrf == 1
    var one_col: bool = c_vrf == 1

    var h_to_step: float = 0.0
    var i_to_step: float = 0.0
    var j_to_step: float = 0.0

    var h_off: float = 0.5
    var i_off: float = 0.5
    var j_off: float = 0.5

    if not one_layer:
        h_off = 0.0
        h_to_step = 1.0 / (l_vrf - 1.0)

    if not one_row:
        i_off = 0.0
        i_to_step = 1.0 / (r_vrf - 1.0)

    if not one_col:
        j_off = 0.0
        j_to_step = 1.0 / (c_vrf - 1.0)

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

        var j_fac: float = j * j_to_step + j_off
        var i_fac: float = i * i_to_step + i_off
        var h_fac: float = h * h_to_step + h_off

        result.append(Lab.new(
            (1.0 - h_fac) * mnl_vrf + h_fac * mxl_vrf,
            (1.0 - j_fac) * -ab_bds_vrf + j_fac * ab_bds_vrf,
            (1.0 - i_fac) * -ab_bds_vrf + i_fac * ab_bds_vrf,
            t_vrf))
        k = k + 1

    return result


## Evaluates whether a color is greater than another when both are represented
## as 32-bit integers.
static func gt(o: Lab, d: Lab) -> bool:
    return Lab._to_tlab_32(o) > Lab._to_tlab_32(d)


## Evaluates whether a color is greater than or equal to another when both are
## represented as 32-bit integers.
static func gt_eq(o: Lab, d: Lab) -> bool:
    return Lab._to_tlab_32(o) >= Lab._to_tlab_32(d)


## Creates an array of 2 LAB colors at analogous hues from the source.
## The hues are positive and negative 30 degrees away.
static func harmony_analogous(c: Lab) -> Array:
    var l_ana: float = (c.l * 2.0 + 50.0) / 3.0

    var cos30: float = 0.86602540378444
    var sin30: float = 0.5
    var a30: float = cos30 * c.a - sin30 * c.b
    var b30: float = cos30 * c.b + sin30 * c.a

    var cos330: float = 0.86602540378444
    var sin330: float = -0.5
    var a330: float = cos330 * c.a - sin330 * c.b
    var b330: float = cos330 * c.b + sin330 * c.a

    return [
        Lab.new(l_ana, a30, b30, c.alpha),
        Lab.new(l_ana, a330, b330, c.alpha)
    ]


## Creates an array of 1 LAB color complementary to the source.
## The hue is 180 degrees away, or the negation of the source a and b.
static func harmony_complement(c: Lab) -> Array:
    return [ Lab.new(100.0 - c.l, -c.a, -c.b, c.alpha) ]


## Creates an array of 2 LAB colors at split hues from the source.
## The hues are 150 and 210 degrees away.
static func harmony_split(c: Lab) -> Array:
    var l_spl: float = (250.0 - c.l * 2.0) / 3.0

    var cos150: float = -0.86602540378444
    var sin150: float = 0.5
    var a150: float = cos150 * c.a - sin150 * c.b
    var b150: float = cos150 * c.b + sin150 * c.a

    var cos210: float = -0.86602540378444
    var sin210: float = -0.5
    var a210: float = cos210 * c.a - sin210 * c.b
    var b210: float = cos210 * c.b + sin210 * c.a

    return [
        Lab.new(l_spl, a150, b150, c.alpha),
        Lab.new(l_spl, a210, b210, c.alpha)
    ]


## Creates an array of 3 LAB colors at square hues from the source.
## The hues are 90, 180 and 270 degrees away.
static func harmony_square(c: Lab) -> Array:
    return [
        Lab.new(50.0, -c.b, c.a, c.alpha),
        Lab.new(100.0 - c.l, -c.a, -c.b, c.alpha),
        Lab.new(50.0, c.b, -c.a, c.alpha)
    ]


## Creates an array of 3 LAB colors at tetradic hues from the source.
## The hues are 120, 180 and 300 degrees away.
static func harmony_tetradic(c: Lab) -> Array:
    var l_tri: float = (200.0 - c.l) / 3.0
    var l_cmp: float = 100.0 - c.l
    var l_tet: float = (100.0 + c.l) / 3.0

    var cos120: float = -0.5
    var sin120: float = 0.86602540378444
    var a120: float = cos120 * c.a - sin120 * c.b
    var b120: float = cos120 * c.b + sin120 * c.a

    var cos300: float = 0.5
    var sin300: float = -0.86602540378444
    var a300: float = cos300 * c.a - sin300 * c.b
    var b300: float = cos300 * c.b + sin300 * c.a

    return [
        Lab.new(l_tri, a120, b120, c.alpha),
        Lab.new(l_cmp, -c.a, -c.b, c.alpha),
        Lab.new(l_tet, a300, b300, c.alpha)
    ]


## Creates an array of 2 LAB colors at triadic hues from the source.
## The hues are positive and negative 120 degrees away.
static func harmony_triadic(c: Lab) -> Array:
    var l_tri: float = (200.0 - c.l) / 3.0

    var cos120: float = -0.5
    var sin120: float = 0.86602540378444
    var a120: float = cos120 * c.a - sin120 * c.b
    var b120: float = cos120 * c.b + sin120 * c.a

    var cos240: float = -0.5
    var sin240: float = -0.86602540378444
    var a240: float = cos240 * c.a - sin240 * c.b
    var b240: float = cos240 * c.b + sin240 * c.a

    return [
        Lab.new(l_tri, a120, b120, c.alpha),
        Lab.new(l_tri, a240, b240, c.alpha)
    ]


## Finds the source color's hue, the wrapped and normalized arctangent of a
## and b.
static func hue(c: Lab) -> float:
    var hue_signed: float = atan2(c.b, c.a)
    var hue_unsigned: float = hue_signed
    if hue_signed < -0.0:
        hue_unsigned = hue_signed + TAU
    return hue_unsigned / TAU


## Finds the hue distance between two colors. When either color is gray,
## returns zero. Otherwise, returns a number in the range [0.0, 0.5].
static func hue_dist(o: Lab, d: Lab) -> float:
    var ocsq: float = Lab.chroma_sq(o)
    var dcsq: float = Lab.chroma_sq(d)

    # Arguably, the distance from a saturated color to
    # gray could be 0.5, different from the distance
    # between two gray colors.
    if ocsq < 0.000001 or dcsq < 0.000001:
        return 0.0

    # The numerator of the angle between formula is
    # the dot product.
    var numer: float = o.a * d.a + o.b * d.b
    var denom: float = sqrt(ocsq) * sqrt(dcsq)
    return acos(numer / denom) / TAU


## Evaluates whether a color is less than another when both are represented
## as 32-bit integers.
static func lt(o: Lab, d: Lab) -> bool:
    return Lab._to_tlab_32(o) < Lab._to_tlab_32(d)


## Evaluates whether a color is less than or equal to another when both are
## represented as 32-bit integers.
static func lt_eq(o: Lab, d: Lab) -> bool:
    return Lab._to_tlab_32(o) <= Lab._to_tlab_32(d)


## Finds an opaque version of the color, where the alpha is 1.0.
static func opaque(c: Lab) -> Lab:
    return Lab.new(c.l, c.a, c.b, 1.0)


## Returns a color with the source's components, but a and b scaled to the
## arguments provided.
static func rescale_chroma(c: Lab, scalar: float) -> Lab:
    var c_sq: float = Lab.chroma_sq(c)
    if c_sq > 0.000001:
        var sc_inv: float = scalar / sqrt(c_sq)
        return Lab.new(c.l, c.a * sc_inv, c.b * sc_inv, c.alpha)
    return Lab.gray(c)


## Returns a color with the source's components, but a and b rotated by
## the argument specified.
static func rotate_hue(c: Lab, hue_shift: float) -> Lab:
    var radians: float = hue_shift * TAU
    return Lab._rotate_hue_internal(c, cos(radians), sin(radians))


## Returns a color with the source's components, but a and b rotated by
## the argument specified. Internal function that accepts precalculated
## cosine and sine of an angle.
static func _rotate_hue_internal(c: Lab, cosa: float, sina: float) -> Lab:
    return Lab.new(
        c.l,
        cosa * c.a - sina * c.b,
        cosa * c.b + sina * c.a,
        c.alpha)


## Multiplies all color components by a scalar.
static func _scale(o: Lab, d: float) -> Lab:
    return Lab.new(o.l  * d, o.a  * d, o.b  * d, o.alpha * d)


## Multiplies the color's a and b components by a scalar.
static func scale_chroma(c: Lab, scalar: float) -> Lab:
    return Lab.new(c.l, c.a * scalar, c.b * scalar, c.alpha)


## Finds the color's a component expressed as a short in [0, 65535].
static func short_a(c: Lab) -> int:
    return 32768 + floori(257.0 * clamp(c.a, -127.5, 127.5))


## Finds the color's alpha channel expressed as a short in [0, 65535].
static func short_alpha(c: Lab) -> int:
    return int(clamp(c.alpha, 0.0, 1.0) * 65535.0 + 0.5)


## Finds the color's b component expressed as a short in [0, 65535].
static func short_b(c: Lab) -> int:
    return 32768 + floori(257.0 * clamp(c.b, -127.5, 127.5))


## Finds the color's lightness expressed as a short in [0, 65535].
static func short_light(c: Lab) -> int:
    return int(clamp(c.l, 0.0, 100.0) * 655.35 + 0.5)


## Finds the signed difference between two colors.
static func _sub(o: Lab, d: Lab) -> Lab:
    return Lab.new(o.l - d.l, o.a - d.a, o.b - d.b, o.alpha - d.alpha)


## Renders a color as a string in JSON format.
static func to_json_string(c: Lab) -> String:
    return "{\"l\":%.4f,\"a\":%.4f,\"b\":%.4f,\"alpha\":%.4f}" \
        % [ c.l, c.a, c.b, c.alpha ]


## Finds the color expressed as a 32 bit integer.
static func _to_tlab_32(c: Lab) -> int:
    return int(clamp(c.alpha, 0.0, 1.0) * 255.0 + 0.5) << 0x18 \
        | int(clamp(c.l, 0.0, 100.0) * 2.55 + 0.5) << 0x10 \
        | (128 + floori(clamp(c.a, -127.5, 127.5))) << 0x08 \
        | (128 + floori(clamp(c.b, -127.5, 127.5)))


## Creates a preset color for opaque black.
static func black() -> Lab:
    return Lab.new(0.0, 0.0, 0.0, 1.0)


## Creates a preset color for blue in SR LAB 2.
static func blue() -> Lab:
    return Lab.new(
        30.6439499148523,
        -12.0258048341643,
        -110.807801954524,
        1.0)


## Creates a preset color for invisible black.
static func clear_black() -> Lab:
    return Lab.new(0.0, 0.0, 0.0, 0.0)


## Creates a preset color for invisible white.
static func clear_white() -> Lab:
    return Lab.new(100.0, 0.0, 0.0, 0.0)


## Creates a preset color for cyan in SR LAB 2.
static func cyan() -> Lab:
    return Lab.new(
        90.624702543393,
        -43.802041438743,
        -15.0091246790041,
        1.0)


## Creates a preset color for green in SR LAB 2.
static func green() -> Lab:
    return Lab.new(
        87.5151869060628,
        -82.9559689892563,
        83.0367796678485,
        1.0)


## Creates a preset color for magenta in SR LAB 2.
static func magenta() -> Lab:
    return Lab.new(
        60.2552107535831,
        102.67709544511,
        -61.0020511842712,
        1.0)


## Creates a preset color for red in SR LAB 2.
static func red() -> Lab:
    return Lab.new(
        53.225973948503,
        78.2042868749242,
        67.7006179200894,
        1.0)


## Creates a preset color for opaque white.
static func white() -> Lab:
    return Lab.new(100.0, 0.0, 0.0, 1.0)


## Creates a preset color for yellow in SR LAB 2.
static func yellow() -> Lab:
    return Lab.new(
        97.3452582060733,
        -37.1542649676957,
        95.1866226292217,
        1.0)
