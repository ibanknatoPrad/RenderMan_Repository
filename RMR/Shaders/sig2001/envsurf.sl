surface envsurf (string envname = "", envspace = "world")
{
    if (envname != "")
	Ci = environment (envname, normalize(vtransform(envspace, I)));
    else Ci = Cs;
}
