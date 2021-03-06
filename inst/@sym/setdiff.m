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
%% @deftypefn {Function File}  {@var{r} =} setdiff (@var{A}, @var{B})
%% Set subtraction.
%%
%% @seealso{union, intersect, setxor, unique, ismember}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = setdiff(A, B)

  % FIXME: is it worth splitting out a "private/set_helper"?

  cmd = { 'A, B = _ins'
          'try:'
          '    A = iter(A)'
          'except TypeError:'
          '    A = set([A])'
          'else:'
          '    A = set(A)'
          'try:'
          '    B = iter(B)'
          'except TypeError:'
          '    B = set([B])'
          'else:'
          '    B = set(B)'
          'C = A.difference(B)'
          'C = sympy.Matrix([list(C)])'
          'return C,' };

  A = sym(A);
  B = sym(B);
  r = python_cmd (cmd, A, B);

  % reshape to column if both inputs are
  if (iscolumn(A) && iscolumn(B))
    r = reshape(r, length(r), 1);
  end

end


%!test
%! A = sym([1 2 3]);
%! B = sym([1 2 4]);
%! C = setdiff(A, B);
%! D = sym([3]);
%! assert (isequal (C, D))

%!test
%! % one nonsym
%! A = sym([1 2 3]);
%! B = [1 2 4];
%! C = setdiff(A, B);
%! D = sym([3]);
%! assert (isequal (C, D))

%!test
%! % empty
%! A = sym([1 2 3]);
%! C = setdiff(A, A);
%! assert (isempty (C))

%!test
%! % empty input
%! A = sym([1 2]);
%! C = setdiff(A, []);
%! assert (isequal (C, A) || isequal (C, sym([2 1])))

%!test
%! % scalar
%! syms x
%! assert (isequal (setdiff([x 1], x), sym(1)))
%! assert (isempty (setdiff(x, x)))
