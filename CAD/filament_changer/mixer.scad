layer_height=0.2; extrusion_width=0.45;
epsilon=0.01;
$fs=0.125;

draft=true;

use <threads.scad>;
module pushfit_thread(h=10) {
 thr = 3/8 + .5/25.4;
 slit = 25.4*thr/2 + 0.2;
 if(draft) cylinder(d=thr*25.4,h=h);
 else english_thread(diameter=thr,threads_per_inch=28,length=h/25.4,internal=true);
 translate([-2,-slit,0]) cube([4,2*slit,h]);
}

module the_mixer(
 pushfit_d = 10, pushfit_h = 10,
 pushfit_id = 6.5,
 pushfit_type = "threaded", // threaded|embedded|embeddest
 pushfit_ring_h = 4.7, // height of embedded pushfit ring
 pushfit_insert_d = 8, // diameter of pushfit insert legs hole
 pushfit_legspace_h = 3.2, // the height of legspace for embeddest variant
 pushfit_inlet_ch = 1,
 liner_d = 4, liner_id = 2,
 filament_d = 1.75,
 join_angle = 30,

 interpushfit = 2*extrusion_width, // space between two pushfit holes
 pushfit_s = 2, // shell around pushfit holes
 output_l = 4, // length of output after before pushfit
 outer_r = 3, // outer radius

 liner_d_tolerance = .2,
) {
 fnd = PI*2*2; fnr = fnd*2;
 module liner(l,in) {
  inh=ld-liner_id;
  union() {
   translate([0,0,inh])
   cylinder(d=ld,h=l-inh,$fn=ld*fnd);
   translate([0,0,-epsilon])
   cylinder(d1=ld+epsilon,d2=liner_id-epsilon,h=inh+2*epsilon,$fn=ld*fnd);
  }
 }
 module pushfit() {
  if(pushfit_type=="threaded") {
   pushfit_thread(h=pushfit_h);
  }else if(pushfit_type=="embedded") {
   translate([0,0,pushfit_h-pushfit_ring_h])
   cylinder(d=pushfit_d,h=pushfit_ring_h,$fn=fnd);
   cylinder(d=pushfit_insert_d,h=pushfit_h,$fn=pushfit_insert_d*fnd);
  }else if(pushfit_type=="embeddest") {
   cylinder(d=pushfit_id,h=pushfit_h+1,$fn=pushfit_insert_d*fnd);
   cylinder(d=pushfit_d,h=pushfit_legspace_h,$fn=pushfit_d*fnd);
   dd = pushfit_d-pushfit_id;
   translate([0,0,pushfit_legspace_h-epsilon])
   cylinder(d1=pushfit_d,d2=pushfit_id-2*epsilon,h=dd+epsilon,$fn=pushfit_d*fnd);
   translate([0,0,pushfit_h-pushfit_inlet_ch-epsilon])
   cylinder(d1=pushfit_id-2*epsilon,d2=pushfit_id+2*pushfit_inlet_ch+2,h=pushfit_inlet_ch+epsilon+1,$fn=(pushfit_id+2*pushfit_inlet_ch+2)*fnd);
  }
 }
 
 ld = liner_d+liner_d_tolerance;
 linero = ld/2/tan(join_angle/2); // liner offset
 pfrx = interpushfit/2/cos(join_angle/2); // radial margin
 pfR = pushfit_d/2+pfrx;      // radius of pushfit with margin
 // offset of pushfit offset
 pfoo = (pushfit_type=="threaded") ? 0 :
        (pushfit_type=="embedded") ? (pushfit_h-pushfit_ring_h) :
        (pushfit_type=="embeddest") ? 0 : undef;
 pfo = pfR/tan(join_angle/2)-pfoo; // pushfit thread ofset

 h = pushfit_d+pushfit_s*2;
 difference() {
  hull() {
   for(s=[-1,1]) {
    rotate([0,0,s*join_angle/2])
    for(ss=[-1,1])
    translate([ss*pushfit_d/2,pfo+pushfit_h-outer_r-epsilon])
    cylinder(r=outer_r,h=h,center=true,$fn=outer_r*fnr);
    translate([s*pushfit_d/2,-output_l-pushfit_h+outer_r+epsilon,0])
    cylinder(r=outer_r,h=h,center=true,$fn=outer_r*fnr);
   }
  }
  for(s=[-1,1]) rotate([0,0,s*join_angle/2]) {
   translate([0,linero,0]) rotate([-90,0,0])
   liner(l=pfo-linero+epsilon,in="bottom");
   //cylinder(d=ld,h=pfo-linero+1,$fn=ld*fnd);
   translate([0,pfo,0]) rotate([-90,0,0])
   pushfit();
  }
  rotate([90,0,0]) {
   liner(l=output_l+epsilon,in="top");
   //cylinder(d=ld,h=output_l+1,$fn=ld*fnd);
   translate([0,0,output_l])
   pushfit();
  }
  hull() {
   for(s=[-1,1]) rotate([0,0,s*join_angle/2]) {
    rotate([-90,0,0])
    translate([0,0,linero])
    cylinder(d=ld,h=epsilon,$fn=ld*fnd);
   }
   rotate([90,0,0])
   cylinder(d=ld,h=epsilon,$fn=ld*fnd);
  }
 }
}

module this() {
 the_mixer(
  pushfit_type="embeddest",
  pushfit_d = 8,
  pushfit_h = 7,
  interpushfit = extrusion_width
 );
}

if(!false) {
 difference() {
  this();
  cylinder(d=100,h=100);
 }
}else
 this();
