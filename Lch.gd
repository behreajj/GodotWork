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
static func _add(o: Lch, d: Lch) -> Lch:
    # To make this consistent with any Lab polar addition method, the hue
    # for gray colors must be treated as zero.
    var oh: float = o.h
    if o.c < 0.000001:
        oh = 0.0

    var dh: float = d.h
    if d.c < 0.000001:
        dh = 0.0

    var ch: float = oh + dh

    return Lch.new(
        clampf(o.l - d.l, 0.0, 100.0),
        maxf(o.c + d.c, 0.0),
        ch - floorf(ch),
        clampf(o.alpha + d.alpha, 0.0, 1.0))


## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func adopt_alpha(o: Lch, d: Lch) -> Lch:
    return Lch.new(o.l, o.c, o.h, d.alpha)


## Creates a color with the chroma of the right operand. The other channels
## adopt the values of the left operand.
static func adopt_chroma(o: Lch, d: Lch) -> Lch:
    return Lch.new(o.l, d.c, o.h, o.alpha)


## Creates a color with the hue of the right operand. The other channels
## adopt the values of the left operand.
static func adopt_hue(o: Lch, d: Lch) -> Lch:
    return Lch.new(o.l, o.c, d.h, o.alpha)


## Creates a color with the alpha channel of the right operand. The other
## channels adopt the values of the left operand.
static func adopt_light(o: Lch, d: Lch) -> Lch:
    return Lch.new(d.l, o.c, o.h, o.alpha)


## Finds the color's alpha expressed as a byte in [0, 255].
static func byte_alpha(o: Lch) -> int:
    return int(clamp(o.alpha, 0.0, 1.0) * 255.0 + 0.5)


## Finds the color's chroma expressed as a byte in [0, 255].
## Clamps the chroma to [0.0, 127.5], then multiplies by 2.
static func byte_chroma(o: Lch) -> int:
    return int(clamp(o.c, 0.0, 127.5) * 2.0 + 0.5)


## Finds the color's hue expressed as a byte in [0, 255].
static func byte_hue(o: Lch) -> int:
    return int((o.h - floorf(o.h)) * 255.0 + 0.5)


## Finds the color's lightness expressed as a byte in [0, 255].
static func byte_light(o: Lch) -> int:
    return int(clamp(o.l, 0.0, 100.0) * 2.55 + 0.5)


## Copies all components of the source color by value to a new color.
static func copy(source: Lch) -> Lch:
    return Lch.new(source.l, source.c, source.h, source.alpha)


## Evaluates whether two colors are equal when represented as 64 bit integers.
static func eq(o: Lch, d: Lch) -> bool:
    return Lch._to_tlch_64(o) == Lch._to_tlch_64(d)


## Creates a color from integers in the range [0, 255].
static func from_bytes(lightness: int = 255, \
    chroma: int = 0, \
    hue: int = 0, \
    opacity: int = 255) -> Lch:
    return Lch.new(
        (lightness & 0xff) / 2.55,
        (chroma & 0xff) / 2.0,
        (hue & 0xff) / 255.0,
        (opacity & 0xff) / 255.0)


## Creates a color from integers in the range [0, 65535].
static func from_shorts(lightness: int = 65535, \
    chroma: int = 0, \
    hue: int = 0, \
    opacity: int = 65535) -> Lch:
    return Lch.new(
        (lightness & 0xffff) / 655.35, \
        (chroma & 0xffff) / 514.0,
        (hue & 0xffff) / 65535.0,
        (opacity & 0xffff) / 65535.0)


## Creates a color from a 32 bit integer.
static func _from_tlch_32(x: int) -> Lch:
    return Lch.from_bytes(
        x >> 0x10,
        x >> 0x08,
        x >> 0x00,
        x >> 0x18)


## Creates a color from a 64 bit integer.
static func _from_tlch_64(x: int) -> Lch:
    return Lch.from_shorts(
        x >> 0x20,
        x >> 0x10,
        x >> 0x00,
        x >> 0x30)


## Finds a grayscale version of the color, where chroma is zero.
## Retains the source's hue, even though it'd be undefined in grayscale.
static func gray(lch: Lch) -> Lch:
    return Lch.new(lch.l, 0.0, lch.h, lch.alpha)


## Creates a cylindrical grid of colors in LCH, then returns them as a 1D array.
## Hue is associated with the cylinder's sectors, or circumference.
## Chroma is associated with the cylinder's rings, or radius.
## Lightness is associated with layers, or the z axis.
static func grid_cylinder(
    sectors: int = 12, \
    rings: int = 6, \
    layers: int = 8, \
    opacity: float = 1.0, \
    min_chroma: float = 15.0, \
    max_chroma: float = 120.0, \
    min_light: float = 0.0, \
    max_light: float = 100.0) -> Array:

    var mxl_vrf: float = maxf(min_light, max_light)
    var mnl_vrf: float = minf(min_light, max_light)

    var mxc_vrf: float = maxf(min_chroma, max_chroma)
    var mnc_vrf: float = minf(min_chroma, max_chroma)

    var t_vrf: float = clampf(opacity, 0.0, 1.0)
    var l_vrf: int = maxi(1, layers)
    var r_vrf: int = maxi(1, rings)
    var s_vrf: int = maxi(2, sectors)

    var one_layer: bool = l_vrf == 1
    var x_to_step: float = 0.0
    var x_off: float = 0.5
    if not one_layer:
        x_off = 0.0
        x_to_step = 1.0 / (l_vrf - 1.0)

    var one_row: bool = r_vrf == 1
    var i_to_step: float = 0.0
    var i_off: float = 0.5
    if not one_row:
        i_off = 0.0
        i_to_step = 1.0 / (r_vrf - 1.0)

    var j_to_hue: float = 1.0 / s_vrf

    var result: Array = []
    var rs_vrf: int = s_vrf * s_vrf
    var len3: int = l_vrf * rs_vrf
    var k: int = 0
    while k < len3:
        @warning_ignore("integer_division")
        var x: int = k / rs_vrf
        var m: int = k - x * rs_vrf
        @warning_ignore("integer_division")
        var i: int = m / s_vrf
        var j: int = m % s_vrf

        var j_hue: float = j * j_to_hue
        var i_fac: float = i * i_to_step + i_off
        var x_fac: float = x * x_to_step + x_off

        result.append(Lch.new(
            (1.0 - x_fac) * mnl_vrf + x_fac * mxl_vrf,
            (1.0 - i_fac) * mnc_vrf + i_fac * mxc_vrf,
            j_hue,
            t_vrf))
        k = k + 1

    return result


## Evaluates whether a color is greater than another when both are represented
## as 64 bit integers.
static func gt(o: Lch, d: Lch) -> bool:
    return Lch._to_tlch_64(o) > Lch._to_tlch_64(d)


## Evaluates whether a color is greater than or equal to another when both are
## represented as 64 bit integers.
static func gt_eq(o: Lch, d: Lch) -> bool:
    return Lch._to_tlch_64(o) >= Lch._to_tlch_64(d)


## Creates an array of 2 LCH colors at analogous hues from the source.
## The hues are positive and negative 30 degrees away.
static func harmony_analogous(lch: Lch) -> Array:
    var l_ana: float = (lch.l * 2.0 + 50.0) / 3.0

    var h30: float = lch.h + 0.08333333333333
    var h330: float = lch.h - 0.08333333333333

    return [
        Lch.new(l_ana, lch.c, h30 - floorf(h30), lch.alpha),
        Lch.new(l_ana, lch.c, h330 - floorf(h330), lch.alpha)
    ]


## Creates an array of 1 LCH color complementary to the source.
## The hue is 180 degrees away.
static func harmony_complement(lch: Lch) -> Array:
    var l_cmp: float = 100.0 - lch.l

    var h180: float = lch.h + 0.5

    return [ new(l_cmp, lch.c, h180 - floorf(h180), lch.alpha) ]


## Creates an array of 2 LCH colors at split hues from the source.
## The hues are 150 and 210 degrees away.
static func harmony_split(lch: Lch) -> Array:
    var l_spl: float = (250.0 - lch.l * 2.0) / 3.0

    var h150: float = lch.h + 0.04166666666667
    var h210: float = lch.h - 0.04166666666667

    return [
        Lch.new(l_spl, lch.c, h150 - floorf(h150), lch.alpha),
        Lch.new(l_spl, lch.c, h210 - floorf(h210), lch.alpha)
    ]


## Creates an array of 3 LCH colors at square hues from the source.
## The hues are 90, 180 and 270 degrees away.
static func harmony_square(lch: Lch) -> Array:
    var l_cmp: float = 100.0 - lch.l

    var h90: float = lch.h + 0.25
    var h180: float = lch.h + 0.5
    var h270: float = lch.h - 0.25

    return [
        Lch.new(50.0, lch.c, h90 - floorf(h90), lch.alpha),
        Lch.new(l_cmp, lch.c, h180 - floorf(h180), lch.alpha),
        Lch.new(50.0, lch.c, h270 - floorf(h270), lch.alpha)
    ]


## Creates an array of 3 LCH colors at tetradic hues from the source.
## The hues are 120, 180 and 300 degrees away.
static func harmony_tetradic(lch: Lch) -> Array:
    var l_tri: float = (200.0 - lch.l) / 3.0
    var l_cmp: float = 100.0 - lch.l
    var l_tet: float = (100.0 + lch.l) / 3.0

    var h120: float = lch.h + 0.33333333333333
    var h180: float = lch.h + 0.5
    var h300: float = lch.h - 0.16666666666667

    return [
        Lch.new(l_tri, lch.c, h120 - floorf(h120), lch.alpha),
        Lch.new(l_cmp, lch.c, h180 - floorf(h180), lch.alpha),
        Lch.new(l_tet, lch.c, h300 - floorf(h300), lch.alpha)
    ]


## Creates an array of 2 LCH colors at triadic hues from the source.
## The hues are positive and negative 120 degrees away.
static func harmony_triadic(lch: Lch) -> Array:
    var l_tri: float = (200.0 - lch.l) / 3.0

    var h120: float = lch.h + 0.33333333333333
    var h240: float = lch.h - 0.33333333333333

    return [
        Lch.new(l_tri, lch.c, h120 - floorf(h120), lch.alpha),
        Lch.new(l_tri, lch.c, h240 - floorf(h240), lch.alpha)
    ]


## Finds the color's hue in degrees, [0, 360).
static func hue_degrees(lch: Lch) -> float:
    return (lch.h - floorf(lch.h)) * 360.0


## Finds the color's hue in degrees, [0, TAU).
static func hue_radians(lch: Lch) -> float:
    return (lch.h - floorf(lch.h)) * TAU


## Evaluates whether a color is less than another when both are represented
## as 64 bit integers.
static func lt(o: Lch, d: Lch) -> bool:
    return Lch._to_tlch_64(o) < Lch._to_tlch_64(d)


## Evaluates whether a color is less than or equal to another when both are
## represented as 64 bit integers.
static func lt_eq(o: Lch, d: Lch) -> bool:
    return Lch._to_tlch_64(o) <= Lch._to_tlch_64(d)


## Finds an opaque version of the color, where the alpha is 1.0.
static func opaque(o: Lch) -> Lch:
    return Lch.new(o.l, o.c, o.h, 1.0)


## Finds the color's alpha channel expressed as a short in [0, 65535].
static func short_alpha(o: Lch) -> int:
    return int(clamp(o.alpha, 0.0, 1.0) * 65535.0 + 0.5)


## Finds the color's chroma expressed as a short in [0, 65535].
## Multiplies the chroma by 257, clamps it to [0.0, 32767.5],
## then multiplies by 2.
static func short_chroma(o: Lch) -> int:
    return int(clamp(o.c * 257.0, 0.0, 32767.5) * 2.0 + 0.5)


## Finds the color's hue expressed as a short in [0, 65535].
static func short_hue(o: Lch) -> int:
    return int((o.h - floorf(o.h)) * 65535.0 + 0.5)


## Finds the color's lightness expressed as a short in [0, 65535].
static func short_light(o: Lch) -> int:
    return int(clamp(o.l, 0.0, 100.0) * 655.35 + 0.5)


## Finds the signed difference between two colors.
static func _sub(o: Lch, d: Lch) -> Lch:
    # To make this consistent with any Lab polar subtraction method, the hue
    # for gray colors must be treated as zero.
    var oh: float = o.h
    if o.c < 0.000001:
        oh = 0.0

    var dh: float = d.h
    if d.c < 0.000001:
        dh = 0.0

    var ch: float = oh - dh

    return Lch.new(
        clampf(o.l - d.l, 0.0, 100.0),
        maxf(o.c - d.c, 0.0),
        ch - floorf(ch),
        clampf(o.alpha - d.alpha, 0.0, 1.0))


## Renders a color as a string in JSON format.
static func to_json_string(lch: Lch) -> String:
    return "{\"l\":%.4f,\"c\":%.4f,\"h\":%.4f,\"alpha\":%.4f}" \
        % [ lch.l, lch.c, lch.h, lch.alpha ]


## Finds the color expressed as a 32 bit integer.
static func _to_tlch_32(o: Lch) -> int:
    return Lch.byte_alpha(o) << 0x18 \
        | Lch.byte_light(o) << 0x10 \
        | Lch.byte_chroma(o) << 0x08 \
        | Lch.byte_hue(o)


## Finds the color expressed as a 64 bit integer.
static func _to_tlch_64(o: Lch) -> int:
    return Lch.short_alpha(o) << 0x30 \
        | Lch.short_light(o) << 0x20 \
        | Lch.short_chroma(o) << 0x10 \
        | Lch.short_hue(o)


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
