include <BOSL2/std.scad>

include <BOSL2/screws.scad>

$fn = 50;

BODY_D = 50;
BODY_Z = 28;

BODY_TOP_Z = 7;

BODY_PILAR_SIZE = [ BODY_D / 1.5, 32 ];

WHEEL_D = BODY_D;
WHEEL_Z = 10;
WHEEL_GAP = 1;

BODY_BOTTOM_Z = BODY_Z - BODY_TOP_Z - WHEEL_Z - WHEEL_GAP * 2;

echo(BODY_BOTTOM_Z);

CIRCLE_TOUCHPAD_D_T = 43.8;
CIRCLE_TOUCHPAD_D_B = 46.1;

BEARING_D = 15;
BEARING_Z = 5;

module bearing() {
  cylinder(d = BEARING_D, h = BEARING_Z);
};

XIAO_RP2040_SIZE = [ 17.6, 21.3, 1.1 ];

MAGNET_S_SIZE_D = 6;
MAGNET_S_SIZE_Z = 3;

AS5600_SIZE = [ 23.5, 22.5, 1.5 ];

module xiao_rp2040(type_c_offset_length = 0,
                   type_c_offset_size = 0,
                   include_typec = true,
                   include_board = true,
                   slop_xy = 0) {
  translate([ 0, -20, 3.2 ]) {
    if (include_board) {
      cube(size =
               [
                 XIAO_RP2040_SIZE.x + slop_xy, XIAO_RP2040_SIZE.y + slop_xy,
                 XIAO_RP2040_SIZE.z
               ],
           anchor = CENTER + BOT);
    };

    if (include_typec) {
      // type-c receptacle
      rotate([ 0, 0, 90 ]) translate([ -XIAO_RP2040_SIZE.x / 2, 0, 0 ]) diff() {
        cube(
            [
              7.2 + type_c_offset_length,
              8.9 + type_c_offset_size,
              3.2 + type_c_offset_size,
            ],
            anchor = CENTER + TOP) {
          tag("remove") edge_mask([ BACK, FRONT ], except = [ RIGHT, LEFT ])
              rounding_edge_mask(l = 10 + type_c_offset_length, r = 1.5);
        };
      };
    };
  };
};

module pos_top() {
  translate([ 0, 0, BODY_Z ]) children();
};

module pos_wheel() {
  translate([ 0, 0, BODY_Z - BODY_TOP_Z - WHEEL_GAP - WHEEL_Z ]) children();
};

module space_for_xiao_rp2040() {
  // space for xiao_rp2040
  xiao_rp2040(slop_xy = 0.2);
  linear_extrude(height = 2) projection(cut = false) xiao_rp2040(slop_xy = 0.2);
  linear_extrude(height = 4) projection(cut = false)
      xiao_rp2040(include_typec = false, slop_xy = 0.2);
}

module spin_maru_top() {
  difference() {
    up(BODY_Z - BODY_TOP_Z)
        linear_extrude(height = BODY_TOP_Z, center = false, convexity = 10,
                       twist = 0, slices = 20, scale = 1.0) difference() {
      round2d(r = 5) union() {
        // back pilar
        rect(size = BODY_PILAR_SIZE, anchor = CENTER + BACK);
        circle(d = BODY_D);
      };
    };

    // space for circle touch pad (top)
    pos_top() up(3)
        cylinder(h = BODY_TOP_Z, d = CIRCLE_TOUCHPAD_D_B, anchor = TOP);

    // space for circle touch pad (bottom)
    pos_top() down(BODY_TOP_Z) cylinder(h = 3, d2 = CIRCLE_TOUCHPAD_D_T + 1,
                                        d1 = CIRCLE_TOUCHPAD_D_T, anchor = BOT);

    // screw holes
    pos_top() xflip_copy()
        translate([ BODY_PILAR_SIZE.x / 2 - 5, -BODY_PILAR_SIZE.y + 5, 0 ]) {
      up(1) cylinder(h = BODY_TOP_Z, d = 4, anchor = TOP);
      cylinder(h = BODY_TOP_Z, d = 2, anchor = TOP);
    }

    // space for cables
    hull() {
      translate([ 0, -BODY_D / 2 + 5, BODY_BOTTOM_Z ])
          cube([ 10, 10, BODY_Z - BODY_BOTTOM_Z - BODY_TOP_Z + 1 ],
               anchor = BOT + BACK);

      // incline to print overhang
      translate([ 0, -BODY_D / 2 + 10 / 2, BODY_Z - 3.5 ])
          cube([ 10, 0.1, 0.1 ], anchor = BOT);
    };
  };

  // bottom panel
  pos_top() down(BODY_TOP_Z) {
    difference() {
      cylinder(h = 1, d = BODY_D, anchor = BOT);

      // window for the sensor
      linear_extrude(height = 1 + 0.01, center = false, convexity = 10,
                     twist = 0, slices = 20, scale = 1.0)
          rect([ AS5600_SIZE.x - 2, AS5600_SIZE.y - 2 ], rounding = 2,
               anchor = CENTER);

      // holder
      up(0.5) linear_extrude(height = 1 + 0.01, center = false, convexity = 10,
                             twist = 0, slices = 20, scale = 1.0)
          rect([ AS5600_SIZE.x + 0.3, AS5600_SIZE.y + 0.3 ], rounding = 2,
               anchor = CENTER);

      // slit for cable
      right(10 / 2) cube([ 1, BODY_D / 2 + 1, 2 ], anchor = BACK + RIGHT);
    };
  };
};

module spin_maru_wheel() {
  difference() {
    tex = texture("diamonds");
    linear_sweep(region = circle(d = WHEEL_D), texture = tex, h = WHEEL_Z,
                 center = false, tex_inset = true, tex_depth = 0.7,
                 tex_size = [ 3, 3 ], style = "alt");

    // screw hole
    screw_hole("M6,10", anchor = BOT, thread = true, bevel1 = true,
               $slop = 0.2);

    cylinder(d1 = 8, d2 = 6, h = 0.8, anchor = BOT);

    // holes for weights
    translate([ 0, 0, 3 ]) {
      for (i = [1:8]) {
        rotate([ 0, 0, i * 360 / 8 ]) translate([ 20, 0, 0 ])
            cylinder(d = 5.5, h = WHEEL_Z, anchor = BOT);
      };
    };
  };
}

module spin_maru_bottom() {
  difference() {
    linear_extrude(height = BODY_Z - BODY_TOP_Z, center = false, convexity = 10,
                   twist = 0, slices = 20, scale = 1.0) round2d(r = 5) union() {
      // back pilar
      rect(size = BODY_PILAR_SIZE, anchor = CENTER + BACK);
      circle(d = BODY_D);
    };

    // space for wheel
    up(BODY_BOTTOM_Z)
        cylinder(h = WHEEL_Z + WHEEL_GAP * 2, d = WHEEL_D + 2, center = false);

    // screw holes
    pos_top() down(BODY_TOP_Z) xflip_copy()
        translate([ BODY_PILAR_SIZE.x / 2 - 5, -BODY_PILAR_SIZE.y + 5, 0 ]) {
      cylinder(h = 15, d = 2, anchor = TOP);
    }

    // space for cables
    // TODO: align to the pilar
    translate([ 0, -BODY_D / 2 + 4.65, BODY_BOTTOM_Z ])
        cube([ XIAO_RP2040_SIZE.x + 0.4, 10, BODY_Z - 4 ], anchor = BOT + BACK);

    // space for xiao_rp2040
    z_offset_for_board_space = 2;
    up(BODY_BOTTOM_Z - z_offset_for_board_space) back(0.5)
        rotate([ 0, 180, 0 ]) {
      // inclined type-c to mitigate overhanging
      hull() {
        translate([ 0, -20 - 5, 3.2 - 5 ]) sphere(r = 0.3);
        xiao_rp2040(type_c_offset_length = 0, type_c_offset_size = 0.2,
                    include_board = false);
      }

      xiao_rp2040(type_c_offset_length = 1, type_c_offset_size = 0.2,
                  slop_xy = 0.4);
      down(z_offset_for_board_space) {
        linear_extrude(height = 4 + z_offset_for_board_space)
            projection(cut = false)
                xiao_rp2040(include_typec = false, slop_xy = 0.4);

        // back edge of the board
        translate([ 0, -XIAO_RP2040_SIZE.y / 2, -1 ])
            cube([ XIAO_RP2040_SIZE.x + 0.4, 3, 4 + z_offset_for_board_space ],
                 anchor = BOT + FRONT);
      };
    };

    // space for reset switch & cable
    left(17) {
      up(2)
          cube([ 6.1 + 0.3, 6.1 + 0.3, BODY_BOTTOM_Z ], anchor = CENTER + BOT);
      cylinder(h = 2, d = 5, anchor = BOT);
    };

    up(BODY_BOTTOM_Z - 3) hull() {
      left(17) cylinder(h = BODY_BOTTOM_Z + 1, d = 3, anchor = BOT);

      fwd(17) cylinder(h = BODY_BOTTOM_Z + 1, d = 3, anchor = BOT);
    };

    // hole for bearing
    up(BODY_BOTTOM_Z)
        cylinder(h = BEARING_Z + 0.2, d = BEARING_D + 0.1, anchor = TOP);
    up(BODY_BOTTOM_Z - BEARING_Z) cylinder(h = 1, d = 10, anchor = TOP);

    // holes for bottom magnets
    translate([ 0, 0, 0 ]) {
      for (i = [1:3]) {
        rotate([ 0, 0, i * 360 / 3 + 90 ]) translate([ 20, 0, 0 ]) cylinder(
            d = MAGNET_S_SIZE_D + 0.4, h = BODY_BOTTOM_Z, anchor = BOT);
      };
    };
  };
};