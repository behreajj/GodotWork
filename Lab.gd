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
static func adjust(o: Lab, d: Lab) -> Lab:
    return Lab.new(o.l + d.l, o.a + d.a, o.b + d.b, o.alpha + d.alpha)

## Finds a color's chroma. Finds the Euclidean distance of a and b from the
## origin.
static func chroma(c: Lab) -> float:
    return sqrt(Lab.chroma_sq(c))

## Finds a color's chroma squared, the sum of its a and b channels squared.
static func chroma_sq(c: Lab) -> float:
    return c.a * c.a + c.b * c.b

## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func copy_alpha(o: Lab, d: Lab) -> Lab:
    return Lab.new(o.l, o.a, o.b, d.alpha)

## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func copy_light(o: Lab, d: Lab) -> Lab:
    return Lab.new(d.l, o.a, o.b, o.alpha)

## Finds a grayscale version of the color, where a and b are zero.
static func gray(c: Lab) -> Lab:
    return Lab.new(c.l, 0.0, 0.0, c.alpha)

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
## the argument specified..
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

## Renders a color as a string in JSON format.
static func to_json_string(c: Lab) -> String:
    return "{\"l\":%.4f,\"a\":%.4f,\"b\":%.4f,\"alpha\":%.4f}" \
        % [ c.l, c.a, c.b, c.alpha ]

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
        -43.8020414387431,
        -15.0091246790041,
        1.0)

## Creates a preset color for green in SR LAB 2.
static func green() -> Lab:
    return Lab.new(
        87.5151869060629,
        -82.9559689892561,
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
        67.7006179200895,
        1.0)

## Creates a preset color for opaque white.
static func white() -> Lab:
    return Lab.new(100.0, 0.0, 0.0, 1.0)

## Creates a preset color for yellow in SR LAB 2.
static func yellow() -> Lab:
    return Lab.new(
        97.3452582060734,
        -37.1542649676957,
        95.1866226292217,
        1.0)
