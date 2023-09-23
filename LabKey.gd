## A key in a LAB gradient, which associates a color to a step in [0.0, 1.0].
class_name LabKey


## The key's step in the gradient, in the range [0.0, 1.0].
var step: float

## The color held in the key, represented in LAB.
var color: Lab


## Creates a gradient LAB key using a real number, clamped to [0.0, 1.0], and a
## color in LAB. The color is passed by reference, not copied by value.
func _init(t: float, c: Lab):
    self.step = clamp(t, 0.0, 1.0)
    self.color = c


## Renders the LAB Key as a string in JSON format.
func _to_string() -> String:
    return LabKey.to_json_string(self)


## Copies all components of the source key by value to a new key.
static func copy(source: LabKey) -> LabKey:
    return LabKey.new(
        source.step,
        Lab.copy(source.color))


## Renders a LAB Key as a string in JSON format.
static func to_json_string(lk: LabKey) -> String:
    return "{\"step\":%.4f,\"color\":%s}" \
        % [ lk.step, Lab.to_json_string(lk.color) ]
