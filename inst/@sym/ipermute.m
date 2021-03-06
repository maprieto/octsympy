%% Copyright (C) 2015 Colin B. Macdonald
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
%% @deftypefn {Function File} {@var{A} =} ipermute (@var{B}, @var{iperm})
%% Permute the indices of a symbolic array.
%%
%% @seealso{permute}
%% @end deftypefn

function A = ipermute(B, iperm)

  A = permute(B, iperm);

end


%!test
%! syms x
%! A = [1 x];
%! perm = [2 1];
%! B = permute(A, perm);
%! C = ipermute(B, perm);
%! assert (isequal(C, A))
