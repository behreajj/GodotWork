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
    return Lab.difference(lk.fore_handle, lk.coord)


## Finds the Euclidean distance between a knot's rear handle and coordinate.
static func rear_dist(lk: LabKnot) -> float:
    return Lab.dist_euclidean(lk.coord, lk.rear_handle)


## Finds the signed difference between a knot's rear handle and coordinate.
static func rear_tangent(lk: LabKnot) -> Lab:
    return Lab.difference(lk.rear_handle, lk.coord)


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
