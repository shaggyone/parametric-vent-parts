eps = 0.01;
$fn = 20;

module round_angle(r, side) {
  $fn=50;
  if (side == "a") {
    intersection() {
      circle(r = r);
      translate([-r-eps, -r-eps])
        square(size = (r + eps));
    }
  } else if (side == "b") {
    intersection() {
      circle(r = r);
      translate([0, -r-eps])
        square(size = (r + eps));
    }
  } else if (side == "c") {
    intersection() {
      circle(r = r);
      translate([0, 0])
        square(size = (r + eps));
    }
  } else if (side == "d") {
    intersection() {
      circle(r = r);
      translate([-r-eps, 0])
        square(size = (r + eps));
    }
  }
}

function round_ducts_crossing_adapter_section_width(d, l, xing_r_a, xing_r_b, hz, z) =
  let(
      r = d * 0.5,
      area = PI*r*r,

      xing_h = d * 0.5,


      raz = r + z*(xing_r_a - r)/l,
      rbz = r + z*(xing_r_b - r)/l,

      // hz = r*2 + z*(xing_h - r*2)/l,

      yz = 0 + z * ((d-xing_h))/l,
      //yz = 0;

      // circle(r = gz);
      // circle(r = raz);

      cut_raz_area = 2*raz*raz*(1-PI*0.25),
      cut_rbz_area = 2*rbz*rbz*(1-PI*0.25),

      wz = (area + cut_raz_area + cut_rbz_area)/hz
  ) wz;

module round_ducts_crossing_adapter_section(
  d, l, xing_h, xing_r_a, xing_r_b, hz, z
) {

  r = d * 0.5;
  area = PI*r*r;

  // xing_h = d * 0.5-4;


  raz = r + z*(xing_r_a - r)/l;
  rbz = r + z*(xing_r_b - r)/l;

  // hz = r*2 + z*(xing_h - r*2)/l;
  yz = 0;
  // yz = 0 + z * ((d-xing_h))/l;
  //yz = 0;

  // circle(r = gz);
  // circle(r = raz);

  cut_raz_area = 2*raz*raz*(1-PI*0.25);
  cut_rbz_area = 2*rbz*rbz*(1-PI*0.25);

  wz = (area + cut_raz_area + cut_rbz_area)/hz;

  // square(size = [wz, hz], center=true);

  hull() {
    translate([-wz*0.5+raz, yz+raz])
      round_angle(raz, "a");
    translate([wz*0.5-raz, yz+raz])
      round_angle(raz, "b");

    translate([wz*0.5-rbz, yz+hz-rbz])
      round_angle(rbz, "c");
    translate([-wz*0.5+rbz, yz+hz-rbz])
      round_angle(rbz, "d");
  }

  perimeter = hz*2 + wz*2 - raz*4 - rbz*4 + raz*PI + rbz*PI;
  echo([z, "", raz, "x", rbz, ", ", hz, "x", wz, " perimeter=", perimeter]);
}

function bezier_1D(t, P0, P1, P2, P3) =
    P0 * pow(1 - t, 3) +
    3 * P1 * pow(1 - t, 2) * t
    + 3 * P2 * (1 - t) * pow(t, 2)
    + P3 * pow(t, 3);

module round_ducts_crossing_adapter(
    d=125,
    ls=20,
    xing_h=125 * 0.5 - 4,
    l=60.25,
    xing_r_a=35,
    xing_r_b=15/*(125*0.5-15)*/,
) {
  r = d*0.5;
  union() {
    translate([0, d/2, 0])
      cylinder(h = ls+eps, r = d/2, $fn=$fn*4);
    translate([0, 0, ls])  {
      step = l/20;
      union() {
        for (z=[0:step:l-step]) {
          hz  = bezier_1D(z/l, r*2, r*2, xing_h, xing_h);
          hz2  = bezier_1D((z+step)/l, r*2, r*2, xing_h, xing_h);

          hull() {
            translate([0, 0, z])
              linear_extrude(height = eps) {
                round_ducts_crossing_adapter_section(
                  d,
                  l,
                  xing_h,
                  xing_r_a,
                  xing_r_b,
                  hz,
                  z = z-eps
                );
              }

            translate([0, 0, z+step+eps])
              linear_extrude(height = eps) {
                round_ducts_crossing_adapter_section(
                  d,
                  l,
                  xing_h,
                  xing_r_a,
                  xing_r_b,
                  hz2,
                  z = z+step+eps
                );
              }
          }
        }

        translate([0, 0, l]) {
          linear_extrude(height = round_ducts_crossing_adapter_section_width(d, l, xing_r_a, xing_r_b, xing_h, l)*0.5) {
            round_ducts_crossing_adapter_section(
              d,
              l,
              xing_h,
              xing_r_a,
              xing_r_b,
              xing_h,
              z = l
            );
          }
        }
      }
    }
  }
}

round_ducts_crossing_adapter(
    d=125,
    ls=20,
    xing_h=125/2-4,
    l=60.25,
    xing_r_a=5,
    xing_r_b=5/*(125*0.5-15)*/
);
