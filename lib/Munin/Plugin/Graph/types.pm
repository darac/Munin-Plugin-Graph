package Munin::Plugin::Graph::types;

use base "Type::Library";
use Type::Utils -all;

BEGIN { extends "Types::Standard" };

declare "LowerStr", as Str,
	where	  { lc($_) eq $_},
	inline_as { my $varname = $_[1]; "lc($varname) eq $varname" };
coerce "LowerStr", from Str, q{lc $_};

declare "StrOrDS", as Str | InstanceOf["Munin::Plugin::Graph::DS"];

declare "ValidFieldName", as Str,
	where     { /^[a-zA-Z_][a-zA-Z0-9_]*$/ and $_ ne 'root' },
	inline_as { my $v = $_[1]; "$v =~ /^[a-zA-Z_][a-zA-Z0-9_]*\$/ and $v ne 'root'" };
coerce "ValidFieldName", from Str, via { my $v = $_ // ''; $v =~ s/^[^A-Za-z_]/_/; $v =~ s/[^A-Za-z0-9_]/_/g };

declare "HexStr", as StrMatch[qr{^[0-9a-fA-F]+$}];

declare "DrawEnum", as StrMatch[qr{^(AREA(STACK)?|LINE\d*(STACK)?|STACK)$}];

declare "LineType", as StrMatch[qr{^-?\d+(\.\d+)?(:[0-9a-f]+(:\S+)?)?}];

declare "ValueType", as Num | StrMatch[qr{^U$}];

declare "SpoolType", as StrMatch[qr{^\d+:(-?\d+(\.\d+)?|U)$}];

declare "WordyBool", as Str;
coerce "WordyBool", from Str, q{return 0 if /^(0|false|off|disabled|no|)$/; return 1 if /^(1|true|on|enabled|yes)/; return undef};
coerce "WordyBool", from Num, q{return 0 if $_ == 0; return 1};
coerce "WordyBool", from Bool, q{return $_};

1;
