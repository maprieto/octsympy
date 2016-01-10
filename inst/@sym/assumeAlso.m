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
%% @deftypefn  {Function File} {@var{x} =} assumeAlso (@var{x}, @var{cond}, @var{cond2}, ...)
%% @deftypefnx {Function File} {} assumeAlso (@var{x}, @var{cond})
%% Add additional assumptions on a symbolic variable.
%%
%% Behaviour is similar to @code{assume}; however @var{cond} is combined
%% with any existing assumptions of @var{x} instead of replacing them.
%%
%% Example:
%% @example
%% @group
%% >> syms x integer
%% >> x1 = x;
%% >> x = assumeAlso(x, 'positive');
%% >> assumptions(x)                     % doctest: +SKIP
%%    @result{} ans =
%%      @{
%%        [1,1] = x: integer, positive
%%      @}
%% @end group
%% @end example
%% @c FIXME: remove SKIP (and text below) once SymPy 0.7.7 is out.
%%
%% Note the previous output will be more verbose if you are using
%% a version of SymPy before SymPy 0.7.7.
%%
%% As with @code{assume}, note @code{x1} is unchanged:
%% @example
%% @group
%% >> assumptions(x1)
%%    @result{} ans =
%%      @{
%%        [1,1] = x: integer
%%      @}
%% @end group
%% @end example
%%
%% @strong{Warning}: with no output argument, this tries to find
%% and replace any @var{x} within expressions in the caller's
%% workspace.  See @ref{assume}.
%%
%% @seealso{assume, assumptions, sym, syms}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function varargout = assumeAlso(x, varargin)

  [tilde,ca] = assumptions(x, 'dict');

  if isempty(ca)
    ca = [];
  elseif (length(ca)==1)
    ca = ca{1};
  else
    ca
    error('expected at most one dict')
  end

  for n=2:nargin
    cond = varargin{n-1};
    ca.(cond) = true;
  end

  xstr = x.flat;
  newx = sym(xstr, ca);

  if (nargout > 0)
    varargout{1} = newx;
    return
  end

  % ---------------------------------------------
  % Muck around in the caller's namespace, replacing syms
  % that match 'xstr' (a string) with the 'newx' sym.
  %xstr =
  %newx =
  context = 'caller';
  % ---------------------------------------------
  S = evalin(context, 'whos');
  evalin(context, '[];');  % clear 'ans'
  for i = 1:numel(S)
    obj = evalin(context, S(i).name);
    [newobj, flag] = symreplace(obj, xstr, newx);
    if flag, assignin(context, S(i).name, newobj); end
  end
  % ---------------------------------------------

end


%!test
%! syms x
%! x = assumeAlso(x, 'positive');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: positive'))

%!test
%! syms x positive
%! x = assumeAlso(x, 'integer');
%! [tilde, a] = assumptions(x, 'dict');
%! assert(a{1}.integer)
%! assert(a{1}.positive)

%!test
%! % multiple assumptions
%! syms x positive
%! x = assumeAlso(x, 'integer', 'even');
%! [tilde, a] = assumptions(x, 'dict');
%! assert(a{1}.integer)
%! assert(a{1}.positive)
%! assert(a{1}.even)

%!xtest
%! % has output so avoids workspace
%! % FIXME: xtest for sympy 0.7.6.x where a is the full dict
%! syms x positive
%! x2 = x;
%! f = sin(x);
%! assumeAlso(x, 'integer');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))
%! a = assumptions(x2);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))
%! a = assumptions(f);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))

%!xtest
%! % has no output so does workspace
%! % FIXME: xtest for sympy 0.7.6 where a is the full dict
%! syms x positive
%! x2 = x;
%! f = sin(x);
%! assumeAlso(x, 'integer');
%! a = assumptions(x);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))
%! a = assumptions(x2);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))
%! a = assumptions(f);
%! assert(strcmp(a, 'x: positive, integer') || strcmp(a, 'x: integer, positive'))
