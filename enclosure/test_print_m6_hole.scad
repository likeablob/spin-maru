include <BOSL2/screws.scad>
include <BOSL2/std.scad>

$fn = 100;

difference() {
  linear_extrude(height = 8, center = false, convexity = 10, twist = 0,
                 slices = 20, scale = 1.0) circle(d = 12);

  screw_hole("M6,15", anchor = BOT, thread = true, bevel1 = "reverse",
             $slop = 0.2);  // Adjust $slop for your printer.
  cylinder(d1 = 8, d2 = 6, h = 0.8, anchor = BOT);
};