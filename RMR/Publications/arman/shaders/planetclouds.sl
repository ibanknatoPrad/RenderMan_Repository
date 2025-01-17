/*
 * planetclouds.sl - surface for a semi-opaque cloud layer to be put on
 *                   an earth-like planetary model.
 *
 * DESCRIPTION:
 *      When put on a sphere, sets the color & opacity of the sphere to
 *   make it look like the clouds surrounding an Earth-like planet.
 *      The shader works by creating a fractal turbulence function over
 *   the surface, then modulating the opacity based on this function in
 *   a way that looks like clouds on a planetary scale.
 *
 *
 * PARAMETERS:
 *    Ka, Kd - the usual meaning
 *    distortionscale - controls the amount of texture distortion
 *    omega,lambda,octaves - the fractal characteristics of the clouds
 *    offset - controls the zero crossings (where the clouds disappear)
 *
 *
 * HINTS:
 *   1. The way this shader is typically used is to have two concentric
 *      spheres represent a planet.  The inner one is colored like the
 *      surface of a planet (perhaps using the "terran" shader), and the
 *      outer one uses the "planetclouds" shader.
 *   2. The best effects are achieved when the clouds not only occlude
 *      the view of the planet, but also shadow it.  The way to do this
 *      with the Blue Moon Renderer is to let the light cast shadows,
 *      then declare the cloud sphere as follows:
 *           AttributeBegin
 *             Attribute "render" "casts_shadows" "shade"
 *             Surface "planetclouds"
 *             Sphere 1 -1 1 360
 *           AttributeEnd
 *   3. The default values for the shader assume that the planet is
 *      represented by a unit sphere.  The texture space and/or parameters
 *      to this shader will need to be altered if the size of your planet
 *      is radically different.
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
 *    Apr 1998 - modern SL and antialiasing by lg
 *
 * last modified 4 Apr 1998 by lg
 */



#include "noises.h"




surface
planetclouds (float Ka = 0.5, Kd = 0.75;
	      float distortionscale = 1;
	      float omega = 0.7;
	      float lambda = 2;
	      float octaves = 9;
	      float offset = 0;)
{
    vector Pdistortion;       /* "distortion" vector */
    point PP;                 /* Point after distortion */
    float result;             /* Fractal sum is stored here */
    float filtwidth;

    /* Transform to texture coordinates */
    PP = transform ("shader", P);
    filtwidth = filterwidthp (PP);

    /* Add in "distortion" vector */
    Pdistortion = distortionscale * filteredvsnoise (PP, filtwidth);
    /* Second cirrus: replace fsnoise with vector fBm */
    PP = PP + Pdistortion;
    filtwidth = filterwidthp (PP);

    /* Compute fBm */
    result = fBm (PP, filtwidth, octaves, lambda, omega);
    /* Adjust zero crossing (where the clouds disappear) */
    result = clamp (result+offset, 0, 1);
    /* Scale density */
    result /= (1 + offset);

    /* Modulate surface opacity by the cloud value */
    Oi = result * Os;
    /* Shade like matte, but with color scaled by cloud opacity */
    Ci = Oi * (Ka * ambient() + Kd * diffuse(faceforward(normalize(N),I)));
}
