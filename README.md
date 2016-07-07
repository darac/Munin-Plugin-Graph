Munin-Plugin-Graph
==================

[![Build Status](https://travis-ci.org/darac/Munin-Plugin-Graph.svg?branch=master)](https://travis-ci.org/darac/Munin-Plugin-Graph)
[![codecov](https://codecov.io/gh/darac/Munin-Plugin-Graph/branch/master/graph/badge.svg)](https://codecov.io/gh/darac/Munin-Plugin-Graph)

This module provides a Object-Oriented representation of a Munin Graph,
and associated data sources. The motivation behind this was, in processing
a complex JSON file, I wanted to be able to add graphs and datasources
as I processed the file and then, only at the end, press a single button
to spit out config and fetch output. As such, Munin::Plugin::Graph allows
incrementally craft your graphs, storing everything in a single object.
At the end of your script, call emit_config() or emit_fetch() and the
data will be printed to STDOUT.

INSTALLATION
------------

To install this module, run the following commands:

	perl Build.PL
	./Build
	./Build test
	./Build install

SUPPORT AND DOCUMENTATION
-------------------------

After installing, you can find documentation for this module with the
perldoc command.

	perldoc Munin::Plugin::Graph

LICENSE AND COPYRIGHT
---------------------

Copyright (C) 2016 Darac Marjal

This program is distributed under the [MIT (X11) License](http://www.opensource.org/licenses/mit-license.php)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

