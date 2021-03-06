%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{L} =} rhs (@var{f})
%% Right-hand side of symbolic expression.
%%
%% Gives an error if any of the symbolic objects have no right-hand side.
%%
%% @seealso{lhs, children}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function R = rhs(f)

  cmd = {
    'f, = _ins'
    'flag = 0'
    'r = 0'
    'if f.is_Matrix:'
    '    try:'
    '        r = f.applyfunc(lambda a: a.rhs)'
    '    except:'
    '        flag = 1'
    'else:'
    '    try:'
    '        r = f.rhs'
    '    except:'
    '        flag = 1'
    'return (flag, r)' };

  [flag, R] = python_cmd (cmd, f);

  if (flag)
    error('rhs: one or more entries have no ''rhs'' attribute')
  end

end


%% most tests are in lhs
%!test
%! syms x
%! f = x + 1 == 2*x;
%! assert (isequal (rhs(f), 2*x))

