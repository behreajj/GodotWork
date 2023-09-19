## Represents colors in a perceptual color space, such as CIE LCH, SR LCH,
## OK LCH, etc., with polar coordinates. Lightness falls in  the range
## [0.0, 100.0]. Chroma is unbounded, but has a practical range of [0.0, 135.0],
## but dependent on the LAB variant. Hue is a periodic number in [0.0, 1.0].
## Alpha is expected to be in [0.0, 1.0].
class_name Lch

## The alpha, or opacity, component, in the range [0.0, 1.0].
var alpha: float

## The chroma component. Equivalent to the radius in polar coordinates.
var c: float

## The hue component, normalized to the period [0.0, 1.0), where 0.0 and
## 1.0 are the same hue. Equivalent to the angle in polar coordinates.
var h: float

## The light component, in the range [0.0, 100.0].
var l: float

## Creates an LCH color from real numbers.
func _init(lightness: float = 100.0, \
    chroma: float = 0.0, \
    hue: float = 0.0, \
    opacity: float = 1.0):

    self.l = lightness
    self.c = chroma
    self.h = hue
    self.alpha = opacity

## Renders the color as a string in JSON format.
func _to_string() -> String:
    return Lch.to_json_string(self)

## Adds the left and right operands, for the purpose of making adjustments.
static func adjust(o: Lch, d: Lch) -> Lch:
    return Lch.new(o.l + d.l, o.c + d.c, o.h + d.h, o.alpha + d.alpha)

## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func copy_alpha(o: Lch, d: Lch) -> Lch:
    return Lch.new(o.l, o.c, o.h, d.alpha)

## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func copy_light(o: Lch, d: Lch) -> Lch:
    return Lch.new(d.l, o.c, o.h, o.alpha)

## Finds a grayscale version of the color, where chroma is zero.
## Retains the source's hue, even though it'd be undefined in grayscale.
static func gray(lch: Lch) -> Lch:
    return Lch.new(lch.l, 0.0, lch.h, lch.alpha)

## Creates an array of 2 LAB colors at analogous hues from the source.
## The hues are positive and negative 30 degrees away.
static func harmony_analogous(lch: Lch) -> Array:
    var l_ana: float = (lch.l * 2.0 + 50.0) / 3.0

    var h30: float = lch.h + 0.08333333333333
    var h330: float = lch.h - 0.08333333333333

    return [
        Lch.new(l_ana, lch.c, h30 - floor(h30), lch.alpha),
        Lch.new(l_ana, lch.c, h330 - floor(h330), lch.alpha)
    ]

## Creates an array of 1 LAB color complementary to the source.
## The hue is 180 degrees away, or the negation of the source a and b.
static func harmony_complement(lch: Lch) -> Array:
    var l_cmp: float = 100.0 - lch.l

    var h180: float = lch.h + 0.5

    return [ new(l_cmp, lch.c, h180 - floor(h180), lch.alpha) ]

## Creates an array of 2 LAB colors at split hues from the source.
## The hues are 150 and 210 degrees away.
static func harmony_split(lch: Lch) -> Array:
    var l_spl: float = (250.0 - lch.l * 2.0) / 3.0

    var h150: float = lch.h + 0.04166666666667
    var h210: float = lch.h - 0.04166666666667

    return [
        Lch.new(l_spl, lch.c, h150 - floor(h150), lch.alpha),
        Lch.new(l_spl, lch.c, h210 - floor(h210), lch.alpha)
    ]

## Creates an array of 3 LAB colors at square hues from the source.
## The hues are 90, 180 and 270 degrees away.
static func harmony_square(lch: Lch) -> Array:
    var l_cmp: float = 100.0 - lch.l

    var h90: float = lch.h + 0.25
    var h180: float = lch.h + 0.5
    var h270: float = lch.h - 0.25

    return [
        Lch.new(50.0, lch.c, h90 - floor(h90), lch.alpha),
        Lch.new(l_cmp, lch.c, h180 - floor(h180), lch.alpha),
        Lch.new(50.0, lch.c, h270 - floor(h270), lch.alpha)
    ]

## Creates an array of 3 LAB colors at tetradic hues from the source.
## The hues are 120, 180 and 300 degrees away.
static func harmony_tetradic(lch: Lch) -> Array:
    var l_tri: float = (200.0 - lch.l) / 3.0
    var l_cmp: float = 100.0 - lch.l
    var l_tet: float = (100.0 + lch.l) / 3.0

    var h120: float = lch.h + 0.33333333333333
    var h180: float = lch.h + 0.5
    var h300: float = lch.h - 0.16666666666667

    return [
        Lch.new(l_tri, lch.c, h120 - floor(h120), lch.alpha),
        Lch.new(l_cmp, lch.c, h180 - floor(h180), lch.alpha),
        Lch.new(l_tet, lch.c, h300 - floor(h300), lch.alpha)
    ]

## Creates an array of 2 LAB colors at triadic hues from the source.
## The hues are positive and negative 120 degrees away.
static func harmony_triadic(lch: Lch) -> Array:
    var l_tri: float = (200.0 - lch.l) / 3.0

    var h120: float = lch.h + 0.33333333333333
    var h240: float = lch.h - 0.33333333333333

    return [
        Lch.new(l_tri, lch.c, h120 - floor(h120), lch.alpha),
        Lch.new(l_tri, lch.c, h240 - floor(h240), lch.alpha)
    ]

## Finds an opaque version of the color, where the alpha is 1.0.
static func opaque(lch: Lch) -> Lch:
    return Lch.new(lch.l, lch.c, lch.h, 1.0)

## Renders a color as a string in JSON format.
static func to_json_string(lch: Lch) -> String:
    return "{\"l\":%.4f,\"c\":%.4f,\"h\":%.4f,\"alpha\":%.4f}" \
        % [ lch.l, lch.c, lch.h, lch.alpha ]

## Creates a preset color for opaque black.
static func black() -> Lch:
    return Lch.new(0.0, 0.0, 0.0, 1.0)

## Creates a preset color for blue in SR LCH.
static func blue() -> Lch:
    return Lch.new(
        30.6439499148523,
        111.458462917368,
        0.73279449277552,
        1.0)

## Creates a preset color for invisible black.
static func clear_black() -> Lch:
    return Lch.new(0.0, 0.0, 0.0, 0.0)

## Creates a preset color for invisible white.
static func clear_white() -> Lch:
    return Lch.new(100.0, 0.0, 0.0, 0.0)

## Creates a preset color for cyan in SR LCH.
static func cyan() -> Lch:
    return Lch.new(
        90.624702543393,
        46.3021884777733,
        0.55254010973227,
        1.0)

## Creates a preset color for green in SR LCH.
static func green() -> Lch:
    return Lch.new(
        87.5151869060628,
        117.374612112472,
        0.37492251819407,
        1.0)

## Creates a preset color for magenta in SR LCH.
static func magenta() -> Lch:
    return Lch.new(
        60.2552107535831,
        119.431303173551,
        0.91467999408849,
        1.0)

## Creates a preset color for red in SR LCH.
static func red() -> Lch:
    return Lch.new(
        53.225973948503,
        103.437344089924,
        0.11356219478123,
        1.0)

## Creates a preset color for opaque white.
static func white() -> Lch:
    return Lch.new(100.0, 0.0, 0.0, 1.0)

## Creates a preset color for yellow in SR LCH.
static func yellow() -> Lch:
    return Lch.new(
        97.3452582060733,
        102.180881444855,
        0.30922841685654,
        1.0)
