#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static int call_remove(pTHX_ SV* var, MAGIC* magic) {
	sv_unmagic(var, PERL_MAGIC_ext);
}

static int call_get(pTHX_ SV* var, MAGIC* magic) {
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	AV* arguments = (AV*)magic->mg_ptr;
	int i;
	for(i = 0; i < av_len(arguments); i++)
		XPUSHs(*av_fetch(arguments, i, FALSE));
	PUTBACK;
	call_sv(magic->mg_obj, G_SCALAR);
	SPAGAIN;
	call_remove(aTHX_ var, magic);
	sv_setsv_mg(var, POPs);
	FREETMPS;
	LEAVE;
}

static const MGVTBL magic_table  = { call_get, call_remove, 0, call_remove, 0};

MODULE = Variable::Lazy::Guts				PACKAGE = Variable::Lazy::Guts

SV*
lazy(...)
	CODE:
		if (items < 2)
			Perl_croak(aTHX_ "Not enough arguments for lazy");
		if (items > 3)
			Perl_croak(aTHX_ "Too many arguments for lazy");
		SV* subref = POPs;
		SV* arguments = SvRV(POPs);
		SV* variable  = (items == 3) ? POPs : newSV(0);
		SvREFCNT_inc(arguments);
		sv_magicext(variable, (SV*)subref, PERL_MAGIC_ext, &magic_table, (char*)arguments, HEf_SVKEY);
		XPUSHs(variable);
		
