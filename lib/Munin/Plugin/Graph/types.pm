package Munin::Plugin::Graph::types;

use base "Type::Library";
use Type::Utils -all;

BEGIN { extends "Types::Standard" };

declare "LowerStr", as Str,
	where	  { lc($_) eq $_ and not /\s/},
	inline_as { my $varname = $_[1]; "lc($varname) eq $varname and not $varname =~ /\\s/" };
coerce "LowerStr", from Str, q{lc $_};

declare "DS", as InstanceOf["Munin::Plugin::Graph::DS"];

declare "StrOrDS", as Str | InstanceOf["Munin::Plugin::Graph::DS"];

declare "Graph", as InstanceOf["Munin::Plugin::Graph::BaseGraph"];

declare "StrOrGraph", as Str | InstanceOf["Munin::Plugin::Graph::BaseGraph"];

declare "ValidFieldName",
	as 		  Str,
	where     { defined($_) and /^[a-zA-Z_][a-zA-Z0-9_]*$/ and $_ ne 'root' },
	inline_as { my $v = $_[1]; "defined($v) and $v =~ /^[a-zA-Z_][a-zA-Z0-9_]*\$/ and $v ne 'root'" };

#declare "HexStr", as StrMatch[qr{^[0-9a-fA-F]{6}$}];
declare "HexStr",
	as		Str,
	where   { /^[0-9a-fA-F]{6}$/ if defined($_)};

declare "DrawEnum", as StrMatch[qr{^(AREA(STACK)?|LINE\d*(STACK)?|STACK)$}];

declare "LineType", as StrMatch[qr{^-?\d+(\.\d+)?(:[0-9a-fA-F]{6}(:\S+)?)?$}];

declare "ValueType", as Num | StrMatch[qr{^U$}];

declare "SpoolType", as StrMatch[qr{^\d+:(-?\d+(\.\d+)?|U)$}];

declare "WordyBool", as Maybe[Enum[qw(no yes)]];

declare "StringList", as ArrayRef[Str] | Str | Undef;

declare "Positive",
	as Int,
	where { $_ > 0 };

declare "NonNegative",
	as Int,
	where { $_ >= 0 };

declare "WarnCritType",
	as StrMatch[qr{^\d*:\d*$}];

declare_coercion "WordyBoolFromStr",
	to_type WordyBool,
	from Str,
	via { return "no" if /^(0|false|off|disabled|no|)$/i;
		  return "yes" if /^(1|true|on|enabled|yes)$/i;
		  return $_; };

declare_coercion "StrFromList",
	to_type Str,
	from ArrayRef[Str],
	via { join " ", @${_} };

declare_coercion "FieldNameFromStr",
	to_type ValidFieldName,
	from Str,
	via { s/^[^A-Za-z_]/_/;
		  s/[^A-Za-z0-9_]/_/g;
          return $_ };

declare_coercion "HexStrFromStr",
 	to_type HexStr,
	from Str,
	via { $_ = $1 if defined($_) and /^#([0-9a-fA-F]{6})$/;
  		  return $_ };

declare_coercion "ValueFromUndef",
	to_type ValueType,
	from Undef,
	via { 'U' };

1;
