#ifdef RCSIDS
static char rcsid[] = "$Id: wood2.sl,v 1.1.1.1 2002/02/10 02:35:52 tal Exp $";
#endif

/*
 * wood2.sl -- another surface shader for wood.
 *
 * DESCRIPTION:
 *   Makes wood solid texture.
 * 
 * PARAMETERS:
 *   Ka, Kd, Ks, specular, roughness - work just like the plastic shader
 *   txtscale - overall scaling factor for the texture
 *   ringscale - scaling for the ring spacing
 *   lightwood, darkwood - surface colors for the wood itself
 *   grainy - relative graininess (0 = no fine grain)
 *
 * AUTHOR: written by Larry Gritz
 *
 * $Revision: 1.1.1.1 $   $Date: 2002/02/10 02:35:52 $
 *
 * $Log: wood2.sl,v $
 * Revision 1.1.1.1  2002/02/10 02:35:52  tal
 * RenderMan Repository
 *
 * Revision 1.1.2.1  1998-02-06 14:02:32-08  lg
 * Converted to "modern" SL with appropriate use of vector & normal types
 *
 * Revision 1.1  1995-12-05 15:05:47-08  lg
 * Initial RCS revision
 *
 * 19 Jan 1994 -- recoded by lg in correct shading language.
 * March 1991 -- original by Larry Gritz
 */




surface
wood2 ( float Ka = 1, Kd = .75, Ks = .4;
        float roughness = .1;
        color specularcolor = 1;
        float ringscale = 15;
        float txtscale = 1;
        color lightwood = color (0.69, 0.44, 0.25);
        color darkwood  = color (0.35, 0.22, 0.08);
        float grainy = 1; )
{
  point PP, PQ;            /* shading space point to be computed */
  normal Nf;                /* forward facing normal */
  color Ct;                /* surface color of the wood */
  float r, r2;
  float my_t;

  /* Calculate in shader space */
  PP = txtscale * transform ("shader", P);

  my_t = zcomp(PP) / ringscale;
  PQ = point (xcomp(PP)*8, ycomp(PP)*8, zcomp(PP));
  my_t += noise (PQ) / 16;
  
  PQ = point (xcomp(PP), my_t, ycomp(PP)+12.93);
  r = ringscale * noise (PQ);
  r -= floor (r);
  r = 0.2 + 0.8 * smoothstep(0.2, 0.55, r) * (1 - smoothstep(0.75, 0.8, r));

  /* \/--  extra line added for fine grain */
  PQ = point (xcomp(PP)*128+5, zcomp(PP)*8-3, ycomp(PP)*128+1);
  r2 = grainy * (1.3 - noise (PQ)) + (1-grainy);

  Ct = mix (lightwood, darkwood, r*r2*r2);


  /*
   * Use the plastic illumination model
   */
  Nf = faceforward (normalize(N),I);
  Oi = Os;
  Ci = Os * ( Ct * (Ka*ambient() + Kd*diffuse(Nf)) +
	      specularcolor * Ks*specular(Nf,-normalize(I),roughness));
}
