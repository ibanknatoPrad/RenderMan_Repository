/****************************************************************************
 * glass.sl -- Shiny reflective & refractive glass, using ray tracing.
 *
 * Description:
 *   Makes semi-transparent glass, using ray tracing to calculate
 *   reflections and refractions of the environment.
 * 
 * Parameters:
 *    Ka, Kd, Ks, roughness, specularcolor - The usual meaning
 *    Kr - coefficient for mirror-like reflections of environment
 *    blur - how blurry are the reflections? (0 = perfectly sharp)
 *    envname, envspace, envrad - controls for using environment maps
 *    rayjitter, raysamples - ray tracing controls for reflection
 *    Kt - coefficient for refracted transmission
 *    transmitcolor - color of the glass
 *    refrblur - how blurry are the refractions? (0 = perfectly sharp)
 *    eta - the coefficient of refraction of the glass
 *    reflrayjitter, refrraysamples - ray tracing controls for refraction
 *
 ***************************************************************************
 *
 * Author: Larry Gritz, 1999  (lg AT larrygritz DOT com)
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 * $Revision: 1.2 $    $Date: 2003/12/24 06:18:06 $
 *
 ****************************************************************************/


/* Comment out the following line if you do *not* wish to use BMRT and
 * PRMan together.
 */
#ifdef WANT_RAYSERVER
#include "rayserver.h"
#endif


#include "material.h"



surface
glass ( float Ka = 0.2, Kd = 0, Ks = 0.5, roughness = 0.05;
	color specularcolor = 1;
	float Kr = 1, reflblur = 0;
	DECLARE_DEFAULTED_ENVPARAMS;
	float Kt = 1, refrblur = 0, eta = 1.5;
	color transmitcolor = 1;
	float refrrayjitter = 0, refrraysamples = 1; )
{
    normal Nf = faceforward (normalize(N), I);
    Ci = MaterialGlass (Nf, Cs, Ka, Kd, Ks, roughness, Kr, reflblur,
			Kt, refrblur, eta, transmitcolor,
			refrrayjitter, refrraysamples, ENVPARAMS);
}
