#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static int call_get(pTHX_ SV* var, MAGIC* magic) {
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	AV* arguments = (AV*)SvRV((SV*)magic->mg_ptr);
	int i;
	for(i = 0; i < av_len(arguments); i++)
		XPUSHs(*av_fetch(arguments, i, FALSE));
	PUTBACK;
	call_sv(magic->mg_obj, G_SCALAR);
	SPAGAIN;
	sv_unmagic(var, PERL_MAGIC_ext);
	sv_setsv_mg(var, POPs);
	FREETMPS;
	LEAVE;
}

static const MGVTBL magic_table  = { call_get, 0, 0, 0, 0};

MODULE = Variable::Lazy::Util				PACKAGE = Variable::Lazy::Util

SV*
lazy(...)
	CODE:
		if (items < 2)
			Perl_croak(aTHX_ "Not enough arguments for lazy");
		if (items > 3)
			Perl_croak(aTHX_ "Too many arguments for lazy");
		SV* subref = POPs;
		SV* arguments = POPs;
		SV* variable  = (items == 3) ? POPs : newSV(0);
		SvREFCNT_inc(SvRV(arguments));
		sv_magicext(variable, (SV*)subref, PERL_MAGIC_ext, &magic_table, (char*)arguments, HEf_SVKEY);
		XPUSHs(variable);
		
