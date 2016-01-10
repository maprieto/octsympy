%% Copyright (C) 2014, 2015 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypefn  {Function File} {@var{f} =} symfun (@var{expr}, @var{vars})
%% Define a symbolic function (not usually called directly).
%%
%% A symfun can be abstract or concrete.  An abstract symfun
%% represents an unknown function (for example, in a differential
%% equation).  A concrete symfun represents a known function such as
%% @iftex
%% @math{f(x) = \sin(x)}.
%% @end iftex
%% @ifnottex
%% f(x) = sin(x).
%% @end ifnottex
%%
%% A concrete symfun:
%% @example
%% >> syms x
%% >> f(x) = sin(x)
%%    @result{} f(x) = (symfun) sin(x)
%% >> f
%%    @result{} f(x) = (symfun) sin(x)
%% >> f(1)
%%    @result{} ans = (sym) sin(1)
%% >> f(x)
%%    @result{} ans = (sym) sin(x)
%% @end example
%%
%% An abstract symfun:
%% @example
%% >> syms g(x)
%% >> g
%%    @result{} g(x) = (symfun) g(x)
%% @end example
%% and note this creates the sym @code{x} automatically.
%%
%% Alternatively:
%% @example
%% >> x = sym('x');
%% >> g(x) = sym('g(x)')
%%    @result{} g(x) = (symfun) g(x)
%% @end example
%% Note the following is @strong{not} the way to create an abstract
%% symfun:
%% @example
%% >> g = sym('g(x)')  % just the symbolic expression g(x)
%%    @result{} g = (sym) g(x)
%% @end example
%% Instead, use @code{g(x)} on the left-hand side as above.
%%
%% You can make multidimensional concrete or abstract symfuns:
%% @example
%% >> syms x y
%% >> g(x, y) = 2*x + sin(y)
%%    @result{} g(x, y) = (symfun) 2⋅x + sin(y)
%% >> syms g(x, y)
%% >> g
%%    @result{} g(x, y) = (symfun) g(x, y)
%% @end example
%% However, on old versions of Octave (before 4.0), one needs to
%% workaround a parsing bug:
%% @example
%% >> syms 'g(x, y)'
%% >> g
%%    @result{} g(x, y) = (symfun) g(x, y)
%% @end example
%%
%% As the above examples demonstrate, it is usually not necessary to
%% call symfun directly.  However, it can be done:
%% @example
%% >> syms x y
%% >> f = symfun(sin(x), x)
%%    @result{} f(x) = (symfun) sin(x)
%% >> F = symfun(x*y, [x y])
%%    @result{} F(x, y) = (symfun) x⋅y
%% >> g = symfun(sym('g(x)'), x)
%%    @result{} g(x) = (symfun) g(x)
%% >> G = symfun(sym('G(x, y)'), [x y])
%%    @result{} G(x, y) = (symfun) G(x, y)
%% @end example
%%
%% This allows, for example, creating an abstract function formally
%% of @code{x}, @code{y} but depending only on @code{x}:
%% @example
%% >> syms x y
%% >> h = symfun(sym('h(x)'), [x y])
%%    @result{} h(x, y) = (symfun) h(x)
%% @end example
%% which is the same as:
%% @example
%% >> h(x,y) = sym('h(x)')
%%    @result{} h(x, y) = (symfun) h(x)
%% @end example
%%
%% @seealso{sym, syms}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic, symbols, CAS

function f = symfun(expr, vars)

  if (nargin == 0)
    % octave docs say need a no-argument default for loading from files
    expr = sym(0);
    vars = sym('x');
  elseif (nargin == 1)
    print_usage ();
  end

  % if the vars are in a sym array, put them in a cell array
  if (isa( vars, 'sym'))
    varsarray = vars;
    vars = cell(1, numel(varsarray));
    for i = 1:numel(varsarray)
      vars{i} = varsarray(i);
    end
  end

  if (ischar (expr))
    % FIXME: drop this later
    warning('symfun: deprecated: symfun(''f'', x) format not supported')
    tok = mystrsplit(expr, {'(', ')', ','});
    fname = strtrim(tok{1});
    assert (isvarname (fname))
    cmd = {['_f = sp.Function("' fname '")(*_ins)'] ...
            'return (_f,)' };
    expr = python_cmd (cmd, vars{:});
  end

  if (isa(expr, 'symfun'))
    % allow symfun(<symfun>, x)
    expr = expr.sym;
  else
    % e.g., allow symfun(<double>, x)
    expr = sym(expr);
  end

  assert (isa (vars, 'cell'))
  for i=1:length(vars)
    assert (isa (vars{i}, 'sym'))
  end

  f.vars = vars;
  f = class(f, 'symfun', expr);
  superiorto ('sym');

end


%!test
%! syms x y
%! syms f(x)
%! assert(isa(f,'symfun'))
%! clear f
%! f(x,y) = sym('f(x,y)');
%! assert(isa(f,'symfun'))

%!test
%! % symfuns are syms as well
%! syms x
%! f(x) = 2*x;
%! assert (isa (f, 'symfun'))
%! assert (isa (f, 'sym'))
%! assert (isequal (f(3), 6))
%! assert (isequal (f(sin(x)), 2*sin(x)))

%!test
%! syms x y
%! f = symfun(sym('f(x)'), {x});
%! assert(isa(f, 'symfun'))
%! f = symfun(sym('f(x,y)'), [x y]);
%! assert(isa(f, 'symfun'))
%! f = symfun(sym('f(x,y)'), {x y});
%! assert(isa(f, 'symfun'))

%!test
%! % rhs is not sym
%! syms x
%! f = symfun(8, x);
%! assert (isa (f,'symfun'))
%! assert (isequal (f(10), sym(8)))

%!test
%! % vector symfun
%! syms x y
%! F(x,y) = [1; 2*x; y; y*sin(x)];
%! assert (isa (F, 'symfun'))
%! assert (isa (F, 'sym'))
%! assert (isequal (F(sym(pi)/2,4) , [sym(1); sym(pi); 4; 4] ))

%!test
%! x = sym('x');
%! y = sym('y');
%! f(x) = sym('f(x)');
%! g(x,y) = sym('g(x,y)');
%! % make sure these don't fail
%! f(1);
%! g(1,2);
%! g(x,y);
%! diff(g, x);
%! diff(g, y);

%!test
%! % defining 1D symfun in terms of a 2D symfun
%! syms x y t
%! syms 'g(x,y)'
%! f(t) = g(t,t);
%! f(5);
%! assert (length (argnames (f)) == 1)
%! assert (isequal (argnames (f), t))
%! assert (isequal( diff(f,x), sym(0)))

%!test
%! % replace g with shorter and specific fcn
%! syms x g(x)
%! g;
%! g(x) = 2*x;
%! assert( isequal (g(5), 10))

%!test
%! % octave <= 3.8 needs quotes on 2D symfuns, so make sure it works
%! syms x y
%! syms 'f(x)'
%! syms 'g(x,y)'
%! assert (isa (f, 'symfun'))
%! assert (isa (g, 'symfun'))

%!test
%! % Bug #41: Octave <= 3.8 parser fails without quotes around 2D fcn
%! % (put inside eval to hide from 3.6 parser)
%! if exist('octave_config_info', 'builtin')
%!   if (compare_versions (OCTAVE_VERSION (), '4.0.0', '>='))
%!     syms x y
%!     eval('syms g(x,y)')
%!     assert (isa (g, 'symfun'))
%!   end
%! else  % matlab
%!   syms x y
%!   eval('syms g(x,y)')
%!   assert (isa (g, 'symfun'))
%! end

%!test
%! % syms f(x) without defining x
%! clear
%! syms f(x)
%! assert(isa(f, 'symfun'))
%! assert(isa(x, 'sym'))

%!test
%! syms x y
%! f(x) = x^2;
%! g(x,y) = sym('g(x,y)');
%! f2 = 2*f;
%! assert( isequal (f2(4), 32))
%! assert( isa(f2, 'symfun'))
%! assert( isa(2*g, 'symfun'))
%! assert( isa(0*g, 'symfun'))  % in SMT, this is the zero symfun

%!test
%! % syms has its own parsing code, check it works
%! syms 'f(x,y)'
%! g = f;
%! syms 'f(x, y)'
%! assert (isequal (f, g))
%! syms 'f( x,  y  )'
%! assert (isequal (f, g))

%!test
%! % syms own parsing code should not reorder the vars
%! syms 'f(y, x)'
%! v = f.vars;
%! assert (isequal (v{1}, y) && isequal (v{2}, x))

%!test
%! % assignment of symfun to symfun, issue #189
%! syms t
%! x(t) = 2*t;
%! y(t) = x;
%! assert (isa (y, 'symfun'))
%! y = symfun(x, t);
%! assert (isa (y, 'symfun'))
%! % others
%! y = x;
%! assert (isa (y, 'symfun'))
%! y(t) = x(t);
%! assert (isa (y, 'symfun'))

%!test
%! % assignment of generic symfun to symfun
%! syms t x(t)
%! y(t) = x;
%! assert (isa (y, 'symfun'))
%! y = symfun(x, t);
%! assert (isa (y, 'symfun'))
