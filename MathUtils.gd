## A static class for methods that handle real numbers.
class_name MathUtils

## Determines arc direction when mixing angles.
enum PolarEasing { CCW, CW, FAR, NEAR }

## Eases an origin angle to a destination angle according to a factor in
## [0.0, 1.0]. The range can be customized, where typical arguments are
## TAU for radians, 360.0 for degrees and 1.0 for hues. The enum determines
## whether to ease clockwise, counter-clockwise, nearest or furthest.
static func mix_angle(o: float, \
    d: float, \
    t: float = 0.5, \
    r: float = 1.0, \
    dir: MathUtils.PolarEasing = MathUtils.PolarEasing.NEAR) -> float:
        if dir == MathUtils.PolarEasing.CCW:
            return MathUtils.mix_angle_ccw(o, d, t, r)
        elif dir == MathUtils.PolarEasing.CW:
            return MathUtils.mix_angle_cw(o, d, t, r)
        elif dir == MathUtils.PolarEasing.FAR:
            return MathUtils.mix_angle_far(o, d, t, r)
        return MathUtils.mix_angle_near(o, d, t, r)

## Eases an origin angle to a destination angle in the counter-clockwise
## direction according to a factor in [0.0, 1.0]. The range can be customized,
## where typical arguments are TAU for radians, 360.0 for degrees and 1.0 for
## hues.
static func mix_angle_ccw(o: float, \
    d: float, \
    t: float = 0.5, \
    r: float = 1.0) -> float:

    var o_wrapped: float = fposmod(o, r)
    var d_wrapped: float = fposmod(d, r)

    var diff: float = d_wrapped - o_wrapped
    if diff == 0.0: return o_wrapped

    var u: float = 1.0 - t
    if o_wrapped > d_wrapped:
        return fposmod(u * o_wrapped + t * (d_wrapped + r), r)
    else:
        return u * o_wrapped + t * d_wrapped

## Eases an origin angle to a destination angle in the clockwise direction
## according to a factor in [0.0, 1.0]. The range can be customized, where
## typical arguments are TAU for radians, 360.0 for degrees and 1.0 for hues.
static func mix_angle_cw(o: float, \
    d: float, \
    t: float = 0.5, \
    r: float = 1.0) -> float:

    var o_wrapped: float = fposmod(o, r)
    var d_wrapped: float = fposmod(d, r)

    var diff: float = d_wrapped - o_wrapped
    if diff == 0.0: return d_wrapped

    var u: float = 1.0 - t
    if o_wrapped < d_wrapped:
        return fposmod(u * (o_wrapped + r) + t * d_wrapped, r)
    else:
        return u * o_wrapped + t * d_wrapped

## Eases an origin angle to a destination angle across the longest arc
## length -- clockwise or counter clockwise -- according to a factor in
## [0.0, 1.0]. The range can be customized, where typical arguments are
## TAU for radians, 360.0 for degrees and 1.0 for hues.
static func mix_angle_far(o: float, \
    d: float, \
    t: float = 0.5, \
    r: float = 1.0) -> float:

    var o_wrapped: float = fposmod(o, r)
    var d_wrapped: float = fposmod(d, r)
    var diff: float = d_wrapped - o_wrapped
    var r_half: float = r * 0.5
    var u: float = 1.0 - t

    if diff == 0.0 or (o_wrapped < d_wrapped and diff < r_half):
        return fposmod(u * (o_wrapped + r) + t * d_wrapped, r)
    elif o_wrapped > d_wrapped and diff > -r_half:
        return fposmod(u * o_wrapped + t * (d_wrapped + r), r)
    else:
        return u * o_wrapped + t * d_wrapped

## Eases an origin angle to a destination angle across the shortest arc
## length -- clockwise or counter clockwise -- according to a factor in
## [0.0, 1.0]. The range can be customized, where typical arguments are
## TAU for radians, 360.0 for degrees and 1.0 for hues. Defaults to the origin
## if the wrapped origin and destination are the same.
static func mix_angle_near(o: float, \
    d: float, \
    t: float = 0.5, \
    r: float = 1.0) -> float:
    # range is a reserved keyword in GDScript.

    var o_wrapped: float = fposmod(o, r)
    var d_wrapped: float = fposmod(d, r)

    var diff: float = d_wrapped - o_wrapped
    if diff == 0.0: return o_wrapped

    var u: float = 1.0 - t
    var r_half: float = r * 0.5
    if o_wrapped < d_wrapped and diff > r_half:
        return fposmod(u * (o_wrapped + r) + t * d_wrapped, r)
    elif o_wrapped > d_wrapped and diff < -r_half:
        return fposmod(u * o_wrapped + t * (d_wrapped + r), r)
    else:
        return u * o_wrapped + t * d_wrapped
