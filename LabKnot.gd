## Organizes the colors that shape a cubic Bezier curve into a coordinate (or
## anchor point), fore handle (the following control point) and rear handle
## (the preceding control point).
class_name LabKnot


## The spatial coordinate of the knot.
var coord: Lab

## The handle that warps the curve segment heading away from the knot along the
## direction of the curve.
var fore_handle: Lab

## The handle that warps the curve segment heading towards the knot along the
## direction of the curve.
var rear_handle: Lab


## Creates a key from three coordinates. The cooardinates are passed by
## reference, not copied by value.
func _init(co: Lab, fh: Lab, rh: Lab):
    self.coord = co
    self.fore_handle = fh
    self.rear_handle = rh


## Sets the forward-facing handle to mirror the rear-facing handle: the
## fore will have the same magnitude and negated direction of the rear.
func mirror_handles_backward() -> LabKnot:
    self.fore_handle = Lab._sub(self.coord,
        Lab._sub(self.rear_handle, self.coord))
    return self


## Sets the rear-facing handle to mirror the forward-facing handle: the
## rear will have the same magnitude and negated direction of the fore.
func mirror_handles_forward() -> LabKnot:
    self.rear_handle = Lab._sub(self.coord,
        Lab._sub(self.fore_handle, self.coord))
    return self


## Renders the knot as a string in JSON format.
func _to_string() -> String:
    return LabKnot.to_json_string(self)


## Evaluates a point between two knots given an origin, destination and step.
static func bezier_point(o: LabKnot, d: LabKnot, t: float) -> Lab:
    return Lab.bezier_point(
        o.coord, o.fore_handle,
        d.rear_handle, d.coord, t)


## Evaluates a tangent between two knots given an origin, destination and step.
static func bezier_tangent(o: LabKnot, d: LabKnot, t: float) -> Lab:
    return Lab.bezier_tangent(
        o.coord, o.fore_handle,
        d.rear_handle, d.coord, t)


## Copies all components of the source knot by value to a new knot.
static func copy(source: LabKnot) -> LabKnot:
    return LabKnot.new(
        Lab.copy(source.coord),
        Lab.copy(source.fore_handle),
        Lab.copy(source.rear_handle))


## Finds the Euclidean distance between a knot's fore handle and coordinate.
static func fore_dist(lk: LabKnot) -> float:
    return Lab.dist_euclidean(lk.coord, lk.fore_handle)


## Finds the signed difference between a knot's fore handle and coordinate.
static func fore_tangent(lk: LabKnot) -> Lab:
    return Lab._sub(lk.fore_handle, lk.coord)


## Sets two knots from a segment of a Catmull-Rom curve. The default curve
## tightness is 0.0. Assumes that the previous knot's coordinate is set to a
## prior anchor point.
##
## The previous knot's fore handle, the next knot's rear handle and the next
## knot's coordinate are set by this function.
static func from_seg_catmull(prev_anchor: Lab, \
    curr_anchor: Lab, \
    next_anchor: Lab, \
    adv_anchor: Lab, \
    tightness: float, \
    prev_knot: LabKnot, \
    next_knot: LabKnot) -> LabKnot:

    if abs(tightness - 1.0) <= 0.000001:
        return LabKnot.from_seg_linear(next_anchor, prev_knot, next_knot)

    var fac: float = (tightness - 1.0) / 6.0

    prev_knot.fore_handle = Lab._sub(curr_anchor, Lab._scale(Lab._sub(
        next_anchor, prev_anchor), fac))
    next_knot.rear_handle = Lab._add(next_anchor, Lab._scale(Lab._sub(
        adv_anchor, curr_anchor), fac))
    next_knot.coord = Lab.copy(next_anchor)

    return next_knot


## Sets a knot from a line segment. Assumes that the previous knot's coordinate
## is set to the first anchor point.
##
## The previous knot's fore handle, the next knot's rear handle and the next
## knot's coordinate are set by this function.
static func from_seg_linear(next_anchor: Lab, \
    prev_knot: LabKnot, \
    next_knot: LabKnot) -> LabKnot:

    var one_third: float = 1.0 / 3.0
    var prev_coord: Lab = prev_knot.coord
    var next_coord: Lab = next_knot.coord

    prev_knot.fore_handle = ClrUtils.mix_lab(prev_coord, next_coord, one_third)
    next_knot.rear_handle = ClrUtils.mix_lab(next_coord, prev_coord, one_third)

    next_knot.coord = Lab.copy(next_anchor)
    return next_knot


## Finds the Euclidean distance between a knot's rear handle and coordinate.
static func rear_dist(lk: LabKnot) -> float:
    return Lab.dist_euclidean(lk.coord, lk.rear_handle)


## Finds the signed difference between a knot's rear handle and coordinate.
static func rear_tangent(lk: LabKnot) -> Lab:
    return Lab._sub(lk.rear_handle, lk.coord)


## Creates a copy of the source knot, swapping the rear and fore handle.
static func reversed(source: LabKnot) -> LabKnot:
    return LabKnot.new(
        Lab.copy(source.coord),
        Lab.copy(source.rear_handle),
        Lab.copy(source.fore_handle))


## Renders a knot as a string in JSON format.
static func to_json_string(lk: LabKnot) -> String:
    return "{\"coord\":%s,\"fore_handle\":%s,\"rear_handle\":%s}" \
        % [
            Lab.to_json_string(lk.coord),
            Lab.to_json_string(lk.fore_handle),
            Lab.to_json_string(lk.rear_handle)
        ]
