extends Node

const Lab = preload("res://Lab.gd")
const Lch = preload("res://Lch.gd")
const Rgb = preload("res://Rgb.gd")
const ClrUtils = preload("res://ClrUtils.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
    var primaries: Array = [
        Rgb.red(), Rgb.green(), Rgb.blue(),
        Rgb.cyan(), Rgb.magenta(), Rgb.yellow()
    ]

    for primary in primaries:
        var lab: Lab = ClrUtils.gamma_rgb_to_sr_lab_2(primary)
        var lch: Lch = ClrUtils.lab_to_lch(lab)

        print("Lch.new(")
        print(lch.l)
        print(lch.c)
        print(lch.h)
        print(")")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass
