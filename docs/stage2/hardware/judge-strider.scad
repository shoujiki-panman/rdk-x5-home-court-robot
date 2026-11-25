// Removable judge robe and display gavel for StackChan Strider (K151).
// Dimensions in mm. "robe" and "gavel" are oriented on the print bed.
part = "robe";
mount_tape_mm = 0.55;
peg_clearance_mm = 0.25;
$fn = 48;

robe_thickness = 2.2;
stock_collar_radius = 44.7;
robe_front_y = 51.3;
robe_height = 3; // Relative to the bottom of the stock Strider yoke.
gavel_x = 20;
gavel_y = 12.1;
gavel_angle = -24;
gavel_back = 5.4;
peg_width = 3.6;
peg_length = 6;
peg_depth = 3.05;

module stroke(points, width) {
    for (i = [0 : len(points) - 2])
        hull() {
            translate(points[i]) circle(d = width, $fn = 20);
            translate(points[i + 1]) circle(d = width, $fn = 20);
        }
}

module robe_profile() {
    offset(r = 1.4)
        offset(delta = -1.4)
            polygon([
                [-33, -3], [-32, 7], [-28, 15], [-23, 19], [-12, 17],
                [0, 10], [12, 17], [23, 19], [28, 15], [32, 7], [33, -3],
                [21, -2.6], [0, -3], [-21, -2.6]
            ]);
}

module lapels() {
    for (side = [-1, 1])
        scale([side, 1])
            union() {
                stroke([[0, 5], [10.5, 11], [17, 15.2]], 1.25);
                stroke([[4.1, 3.1], [12.9, 7.8]], 0.9);
                stroke([[13, -0.6], [15, 4.2]], 0.7);
            }
}

function mount_depth(x) =
    robe_front_y - sqrt(pow(stock_collar_radius + mount_tape_mm, 2) - x*x);

module tape_pad() {
    // This surface follows the front of the fixed ring, with room for tape.
    pad_profile = concat(
        [[4, robe_thickness - 0.1], [17, robe_thickness - 0.1]],
        [for (x = [17 : -0.5 : 4]) [x, mount_depth(x)]]
    );
    translate([0, 7, 0])
        rotate([90, 0, 0])
            linear_extrude(height = 7.4)
                polygon(pad_profile);
}

module gavel_position() {
    translate([gavel_x, gavel_y, 0])
        rotate([0, 0, gavel_angle])
            children();
}

module robe() {
    difference() {
        union() {
            linear_extrude(height = robe_thickness)
                robe_profile();
            tape_pad();
            mirror([1, 0, 0]) tape_pad();
        }
        translate([0, 0, -0.05])
            linear_extrude(height = 0.65)
                lapels();
        gavel_position()
            translate([0, 0, -0.1])
                linear_extrude(height = robe_thickness + 0.2)
                    square([peg_width + 2*peg_clearance_mm, peg_length + 2*peg_clearance_mm], center = true);
    }
}

module along_x(x0, x1, y, z, radius) {
    translate([x0, y, z])
        rotate([0, 90, 0])
            cylinder(h = x1-x0, r = radius);
}

module gavel() {
    union() {
        intersection() {
            union() {
                along_x(-9.5, 9.5, 12, 2.6, 4.4);
                along_x(-10.5, -7.4, 12, 2.6, 5.05);
                along_x(7.4, 10.5, 12, 2.6, 5.05);
                along_x(-6.5, -5.4, 12, 2.6, 4.65);
                along_x(5.4, 6.5, 12, 2.6, 4.65);
                linear_extrude(height = gavel_back)
                    hull() {
                        translate([0, -8.7]) circle(r = 2.7);
                        translate([0, 1]) circle(r = 2.55);
                        translate([0, 9.5]) circle(r = 2.1);
                    }
                linear_extrude(height = gavel_back)
                    translate([0, -9.8]) circle(r = 3.25);
            }
            translate([-12, -15, 0]) cube([24, 36, gavel_back]);
        }
        translate([0, 0, gavel_back - 0.08])
            linear_extrude(height = peg_depth + 0.08, scale = 0.85)
                square([peg_width, peg_length], center = true);
    }
}

module installed() {
    translate([0, robe_front_y, robe_height])
        rotate([90, 0, 0]) {
            robe();
            gavel_position()
                translate([0, 0, -gavel_back])
                    gavel();
        }
}

if (part == "robe") robe();
if (part == "gavel") gavel();
if (part == "installed") installed();
