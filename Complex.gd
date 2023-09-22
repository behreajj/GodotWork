## A two-dimensional complex number. The imaginary component is a
## coefficient of i, or the square root of negative one.
class_name Complex

## The real component.
var real: float

## The coefficient of the imaginary component i.
var imag: float

## Creates a complex number from two numbers, where the second argument is the
## imaginary component and the first is the real component.
func _init(r: float = 0.0, i: float = 0.0):
    self.real = r
    self.imag = i

## Renders the complex number as a string in JSON format.
func _to_string() -> String:
    return Complex.to_json_string(self)

## Finds the absolute of a complex number on an Argand diagram.
static func absolute(z: Complex) -> float:
    # Cannot be 'abs' due to GDScript variable shadowing.
    return sqrt(Complex.abs_sq(z))

## Finds the absolute, squared, of a complex number on an Argand diagram.
static func abs_sq(z: Complex) -> float:
    return z.real * z.real + z.imag * z.imag

## Sums the left and right operand.
static func add(a: Complex, b: Complex) -> Complex:
    return Complex.new(
        a.real + b.real,
        a.imag + b.imag)

## Finds the conjugate of a complex number.
static func conj(z: Complex) -> Complex:
    return Complex.new(z.real, -z.imag)

## Copies all components of the source complex number by value to another.
static func copy(source: Complex) -> Complex:
    return Complex.new(source.real, source.imag)

## Finds the cosine of a complex number.
static func cosine(z: Complex) -> Complex:
    # Cannot be 'cos' due to GDScript variable shadowing.
    return Complex.new(
        cos(z.real) * cosh(z.imag),
        -sin(z.real) * sinh(z.imag))

## Divides the left operand by the right. A convenience for multiplying the
## left operand by the inverse of the right.
static func div(a: Complex, b:Complex) -> Complex:
    return Complex.mul(a, Complex.inverse(b))

## Finds Euler's number, e, raised to a complex number.
static func exponent(z: Complex) -> Complex:
    # Cannot be 'exp' due to GDScript variable shadowing.
    return Complex.rect(exp(z.real), z.imag)

## Finds the inverse of a complex number. If the absolute is zero, returns
## a complex number with real and imaginary components set to zero.
static func inverse(z: Complex) -> Complex:
    var mag_sq: float = Complex.abs_sq(z)
    if mag_sq > 0.0:
        return new(z.real / mag_sq, -z.imag / mag_sq)
    return Complex.zero()

## Finds the complex logarithm.
static func logarithm(z: Complex) -> Complex:
    # Cannot be 'log' due to GDScript variable shadowing.
    return Complex.new(log(Complex.absolute(z)), Complex.phase(z))

## Performs the Mobius transformation on the variable z. Uses the formula
## (c z + d) / (a z + b) .
static func mobius(a: Complex, \
    b: Complex, \
    c: Complex, \
    d: Complex, \
    z: Complex) -> Complex:

    var czdr: float = c.real * z.real - c.imag * z.imag + d.real
    var czdi: float = c.real * z.imag + c.imag * z.real + d.imag

    var mag_sq: float = czdr * czdr + czdi * czdi
    if mag_sq < 0.00001: return Complex.zero()

    var azbr: float = a.real * z.real - a.imag * z.imag + b.real
    var azbi: float = a.real * z.imag + a.imag * z.real + b.imag

    var czdr_inv: float = czdr / mag_sq
    var czdi_inv: float = -czdi / mag_sq

    return Complex.new(
        azbr * czdr_inv - azbi * czdi_inv,
        azbr * czdi_inv + azbi * czdr_inv)

## Multiplies the left and right operand. Complex multiplication is not
## commutative.
static func mul(a: Complex, b: Complex) -> Complex:
    return Complex.new(
        a.real * b.real - a.imag * b.imag,
        a.real * b.imag + a.imag * b.real)

## Negates a complex number.
static func negate(z: Complex) -> Complex:
    return Complex.new(-z.real, -z.imag)

## Finds the angle of a complex number on an Argand diagram.
static func phase(z: Complex) -> float:
    return atan2(z.imag, z.real)

## Returns an array with the complex number's absolute and phase, i.e., its
## polar representation.
static func polar(z: Complex) -> Array:
    return [ Complex.absolute(z), Complex.phase(z) ]

## Creates a complex number from a polar representation.
static func rect(r: float = 0.0, phi: float = 0.0) -> Complex:
    return Complex.new(r * cos(phi), r * sin(phi))

## Scales a complex number by a real number.
static func scale(a: Complex, b: float) -> Complex:
    return Complex.new(a.real * b, a.imag * b)

## Raises a complex number to the power of another. Uses the formula
## pow ( a, b ) := exp ( b log ( a ) )
static func power(a: Complex, b: Complex) -> Complex:
    # Cannot be 'pow' due to GDScript variable shadowing.
    return Complex.exponent(Complex.mul(b, Complex.logarithm(a)))

## Finds the sine of a complex number.
static func sine(z: Complex) -> Complex:
    # Cannot be 'sin' due to GDScript variable shadowing.
    return Complex.new(
        sin(z.real) * cosh(z.imag),
        cos(z.real) * sinh(z.imag))

## Subtracts the right operand from the left.
static func sub(a: Complex, b: Complex) -> Complex:
    return Complex.new(
        a.real - b.real,
        a.imag - b.imag)

## Renders a complex number as a string in JSON format.
static func to_json_string(z: Complex) -> String:
    return "{\"real\":%.4f,\"imag\":%.4f}" \
        % [ z.real, z.imag ]

## Creates a complex number with all components set to zero.
static func zero() -> Complex:
    return Complex.new(0.0, 0.0)
