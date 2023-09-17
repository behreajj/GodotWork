class_name ClrKey

## The color key's place in a gradient, within the range [0.0, 1.0].
var step: float

## The color held by the color key.
var color: Lab

## Creates a color key from a real number and a LAB color. The LAB color is
## passed by reference. The step is clamped to the range [0.0, 1.0].
func _init(s: float, c: Lab):
    self.step = clamp(s, 0.0, 1.0)
    self.color = c

## Renders the color key as a string in JSON format.
func _to_string() -> String:
    return ClrKey.to_json_string(self)

## Renders a color key as a string in JSON format.
static func to_json_string(ck: ClrKey) -> String:
    return "{\"step\":%.4f,\"color\":%s}" \
        % [ ck.step, Lab.to_json_string(ck.color) ]
