CiteProc::JS Engine
===================

CiteProc::JS Engine is a CSL 1.0 compatible engine for
[citeproc](http://rubygems.org/gems/citeproc); it is implemented as a
thin Ruby wrapper around Frank G. Benett's awesome
[citeproc-js](https://bitbucket.org/fbennett/citeproc-js/overview).


Requirements
------------

In addition to the dependencies defined by the gem, please make sure to
your environment meets the following requirements depending on your platform;

* For Ruby 1.9, please install this [experimental branch of johnson](https://github.com/inukshuk/johnson):
  download/clone the repository and run `rake compile` followed by `rake gem`;
  find and install the pre-release gem in the `pkg` directory.
* For Ruby 1.8.7, please install stable [johnson](https://github.com/jbarnette/johnson).
* For JRuby, please install [therubyrhino](https://github.com/cowboyd/therubyrhino).

Support for other platforms is still in development.


License
-------

Copyright (c) 2011  Sylvester Keil. All Rights Reserved.

citeproc-js

Copyright (c) 2009, 2010 and 2011 Frank G. Bennett, Jr. All Rights Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
