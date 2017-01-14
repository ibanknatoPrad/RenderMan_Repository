/* I took wave's lead and renamed starfield to KMCyclone.sl -- tal AT renderman DOT org */

/*
 * cyclone.sl - surface for a semi-opaque cloud layer to be put on an
 *              earth-like planetary model to model clouds and a cyclone.
 *
 * DESCRIPTION:
 *      When put on a sphere, sets the color & opacity of the sphere to
 *   make it look like the clouds surrounding an Earth-like planet, with
 *   a big cyclone.
 *      The shader works by creating a fractal turbulence function over
 *   the surface, then modulating the opacity based on this function in
 *   a way that looks like clouds on a planetary scale.
 *
 *
 * PARAMETERS:
 *    Ka, Kd - the usual meaning
 *    cloudcolor - the color of the clouds, usually white
 *    max_radius
 *    twist - controls the twisting of the clouds due to the cyclone.
 *    offset, scale - control the linear scaling of the cloud value.
 *    omega, octaves - controls the fractal characteristics of the clouds
 *
 *
 * HINTS:
 *    See the "planetclouds" shader for hints which apply equally well
 *    to this shader.
 *
 *
 * AUTHOR: Ken Musgrave
 *    Conversion to Shading Language and other minor changes by Larry Gritz.
 *
 * REFERENCES:
 *    _Texturing and Modeling: A Procedural Approach_, by David S. Ebert, ed.,
 *    F. Kenton Musgrave, Darwyn Peachey, Ken Perlin, and Steven Worley.
 *    Academic Press, 1994.  ISBN 0-12-228760-6.
 *
 * HISTORY:
 *    ???? - original texture developed by Ken Musgrave.
 *    Feb 1994 - Conversion to Shading Language by L. Gritz
 *
 * last modified 1 March 1994 by lg
 */



#define TWOPI (2*PI)

/* Use signed Perlin noise */
#define snoise(x) ((2*noise(x))-1)
#define DNoise(p) (2*(point noise(p)) - point(1,1,1))
#define VLNoise(Pt,scale) (snoise(DNoise(Pt)+(scale*Pt)))
#define VERY_SMALL 0.001




surface
KMCyclone (float Ka = 0.5, Kd = 0.75;
	 float max_radius = 1;
	 float twist = 0.5;
	 float scale = .7, offset = .5;
	 float omega = 0.675;
	 float octaves = 4;)
{
  float radius, dist, angle, sine, cosine, eye_weight, value;
  point Pt;                 /* Point in texture space */
  point PN;                 /* Normalized vector in texture space */
  point PP;                 /* Point after distortion */
  float l, o, a, i;         /* Loop control for fractal sum */

  /* Transform to texture coordinates */
  Pt = transform ("shader", P);

  /* Rotate hit point to "cyclone space" */
  PN = normalize (Pt);
  radius = sqrt (xcomp(PN)*xcomp(PN) + ycomp(PN)*ycomp(PN));

  if (radius < max_radius) {   /* inside of cyclone */
      /* invert distance from center */
      dist = pow (max_radius - radius, 3);
      angle = PI + twist * TWOPI * (max_radius-dist) / max_radius;
      sine = sin (angle);
      cosine = cos (angle);
      PP = point (xcomp(Pt)*cosine - ycomp(Pt)*sine,
		  xcomp(Pt)*sine + ycomp(Pt)*cosine,
		  zcomp(Pt));
      /* Subtract out "eye" of storm */
      if (radius < 0.05*max_radius) {  /* if in "eye" */
	  eye_weight = (.1*max_radius - radius) * 10;   /* normalize */
	  /* invert and make nonlinear */
	  eye_weight = pow (1 - eye_weight, 4);
	}
      else eye_weight = 1;
    }
  else PP = Pt;

  if (eye_weight > 0) {   /* if in "storm" area */
      /* Compute VLfBm */
      l = 1;  o = 1;  a = 0;
      for (i = 0;  i < octaves  &&  o >= VERY_SMALL;  i += 1) {
	  a += o * VLNoise (PP * l, 1);
	  l *= 2;
	  o *= omega;
	}
      value = abs (eye_weight * (offset + scale * a));
    }
  else value = 0;

  /* Thin the density of the clouds */
  Oi = value * Os;

  /* Shade like matte, but with color scaled by cloud opacity */
  Ci = Oi * (Ka * ambient() + Kd * diffuse(faceforward(normalize(N),I)));
}
