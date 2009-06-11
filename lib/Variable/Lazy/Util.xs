#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static int call_get(pTHX_ SV* var, MAGIC* magic) {
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	call_sv(magic->mg_obj, G_SCALAR);
	SPAGAIN;
	sv_unmagic(var, PERL_MAGIC_ext);
	sv_setsv_mg(var, POPs);
	FREETMPS;
	LEAVE;
}

static const MGVTBL magic_table  = { call_get, 0, 0, 0, 0};

MODULE = Variable::Lazy::Util				PACKAGE = Variable::Lazy::Util

void
set_lazy(variable, subref)
	SV* variable;
	CV* subref;
	PROTOTYPE: \$$
	CODE:
	if (!SvROK(variable))
		Perl_croak(aTHX_ "Invalid argument!");
	sv_magicext(SvRV(variable), (SV*)subref, PERL_MAGIC_ext, &magic_table, NULL, 0);
