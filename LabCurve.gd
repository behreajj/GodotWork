## Organizes a Bezier curve into a list of knots. Provides a function to
## retrieve a point and tangent on a curve from a step in the range [0.0, 1.0].
class_name LabCurve


## A flag for whether or not the curve is a closed loop.
var closed_loop: bool

## The list of knots contained by the curve.
var knots: Array


## Creates a new curve from an array of knots. The array is assigned by
## reference.
func _init(cl: bool, lab_knots: Array):
    self.closed_loop = cl
    self.knots = lab_knots


## Resizes the curve's array of knots to a given amount.
func resize(new_size: int) -> LabCurve:
    # There is an array resize method, but this needs to validate that expanded
    # arrays are filled with LabKnots, not left as nil, as though they were
    # structs, not classes.
    var ns_verif: int = max(2, new_size)
    var old_size: int = self.knots.size()
    var diff: int = ns_verif - old_size

    if diff < 0:
        var last: int = old_size - 1
        var i: int = 0
        while i < -diff:
            self.knots.remove_at(last - i)
            i = i + 1
    elif diff > 0:
        var i: int = 0
        while i < diff:
            self.knots.append(LabKnot.new(
                Lab.clear_black(),
                Lab.clear_black(),
                Lab.clear_black()))
            i = i + 1

    return self


## Straightens the fore handles and rear handles of a curve's knots so they are
## collinear with its coordinates. If the curve is not a closed loop, mirrors
## the first and last knots' end handles.
func straight_handles() -> LabCurve:
    var ks: Array = self.knots
    var len_ks: int = ks.size()
    if len_ks < 2: return self

    var one_third: float = 1.0 / 3.0

    var i: int = 1
    while i < len_ks:
        var prev: LabKnot = ks[i - 1]
        var next: LabKnot = ks[i]
        prev.fore_handle = ClrUtils.mix_lab(prev.coord, next.coord, one_third)
        next.rear_handle = ClrUtils.mix_lab(next.coord, prev.coord, one_third)
        i = i + 1

    var first: LabKnot = ks[0]
    var last: LabKnot = ks[len_ks - 1]
    if self.closed_loop:
        first.rear_handle = ClrUtils.mix_lab(first.coord, last.coord, one_third)
        last.rear_handle = ClrUtils.mix_lab(last.coord, first.coord, one_third)
    else:
        first.mirror_handles_forward()
        last.mirror_handles_backward()

    return self


## Renders the curve as a string in JSON format.
func _to_string() -> String:
    return LabCurve.to_json_string(self)


## Evaluates a point on the curve given a step in the range [0.0, 1.0] .
static func eval(lc: LabCurve, step: float) -> Lab:
    var ks: Array = lc.knots
    var len_ks: int = ks.size()

    var t_scaled: float = 0.0
    var i: int = 0
    var o: LabKnot = null
    var d: LabKnot = null

    if lc.closed_loop:
        t_scaled = fposmod(step, 1.0) * len_ks
        i = int(t_scaled)
        o = ks[posmod(i, len_ks)]
        d = ks[posmod(i + 1, len_ks)]
    else:
        if len_ks == 1 or step <= 0.0:
            return Lab.copy(ks[0].coord)

        if step >= 1.0:
            return Lab.copy(ks[len_ks - 1].coord)

        t_scaled = step * (len_ks - 1)
        i = int(t_scaled)
        o = ks[i]
        d = ks[i + 1]

    var t: float = t_scaled - i
    return LabKnot.bezier_point(o, d, t)


## Evaluates a range of points and tangents on a curve for a given origin and
## destination factor at a resolution, or count.
##
## For closed loops, an origin and destination of 0.0 and 1.0 would yield a
## duplicate point, and so should be calculated accordingly. I.e., 0.0 to
## 1.0 - 1.0 / count would avoid the duplicate.
static func eval_range(lc: LabCurve, \
    count: int, \
    orig: float = 0.0, \
    dest: float = 1.0) -> Array:

    var count_verif: int = max(3, abs(count))
    var to_percent = 1.0 / (count_verif - 1.0)

    var o_verif: float = orig
    var d_verif: float = dest
    var cl: bool = lc.closed_loop
    if cl:
        o_verif = clamp(o_verif, 0.0, 1.0)
        d_verif = clamp(d_verif, 0.0, 1.0)

    var result: Array = []
    var i: int = 0
    while i < count_verif:
        var percent: float = i * to_percent
        var step: float = (1.0 - percent) * o_verif + percent * d_verif
        var lab: Lab = LabCurve.eval(lc, step)
        result.append(lab)
        i = i + 1

    return result


## Sets a curve to a series of LAB colors.
static func from_catmull(cl: bool, \
    colors: Array, \
    tightness: float) -> LabCurve:

    var len_cs: int = colors.size()
    if len_cs < 2:
        return LabCurve.new(false, [])
    if len_cs < 3:
        return LabCurve.from_catmull(false, [
            colors[0], colors[0],
            colors[1], colors[1]
        ], tightness)
    if len_cs < 4:
        return LabCurve.from_catmull(false, [
            colors[0], colors[0],
            colors[1],
            colors[2], colors[2]
        ], tightness)

    var knot_count: int = 0
    if cl:
        knot_count = len_cs
    else:
        knot_count = len_cs - 2

    var kns: Array = []
    var h: int = 0
    while h < knot_count:
        kns.append(LabKnot.new(
                Lab.clear_black(),
                Lab.clear_black(),
                Lab.clear_black()))
        h = h + 1

    var last_c: int = len_cs - 1
    var first: LabKnot = kns[0]
    var prev: LabKnot = first
    var i: int = 0
    while i < knot_count - 1:
        var i1: int = i + 1
        var i2: int = i + 2
        var i3: int = i + 3

        if cl:
            i1 = i1 % len_cs
            i2 = i2 % len_cs
            i3 = i3 % len_cs
        elif i3 > last_c:
            i3 = last_c

        var curr: LabKnot = kns[i1]
        LabKnot.from_seg_catmull(
            colors[i],
            colors[i1],
            colors[i2],
            colors[i3],
            tightness,
            prev,
            curr)

        prev = curr
        i = i + 1

    if cl:
        LabKnot.from_seg_catmull(
            colors[last_c],
            colors[0],
            colors[1],
            colors[2],
            tightness,
            kns[knot_count - 1],
            first)
    else:
        first.coord = Lab.copy(colors[1])
        first.mirror_handles_forward()
        kns[knot_count - 1].mirror_handles_backward()

    return LabCurve.new(cl, kns)


## Renders a curve as a string in JSON format.
static func to_json_string(lc: LabCurve) -> String:
    var ks: Array = lc.knots
    var len_ks: int = ks.size()
    var sb: PackedStringArray = PackedStringArray()
    sb.append("{\"closed_loop\":")
    if lc.closed_loop:
        sb.append("true")
    else:
        sb.append("false")
    sb.append(",\"knots\":[")

    var i: int = 0
    while i < len_ks:
        var k: LabKnot = ks[i]
        var k_str: String = LabKnot.to_json_string(k)
        sb.append(k_str)
        if i < len_ks - 1: sb.append(",")
        i = i + 1

    sb.append("]}")
    return "".join(sb)
