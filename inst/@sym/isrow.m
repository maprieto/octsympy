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
%% @deftypefn  {Function File} {@var{r} =} isrow (@var{x})
%% Return true if symbolic expression is a row vector.
%%
%% @seealso{iscolumn, isvector, isscalar}
%% @end deftypefn

function r = isrow(x)

  % from Rik Wehbring's Octave function
  sz = size (x);
  r = (ndims (x) == 2 && (sz(1) == 1));

end


%!assert (isrow (sym ([1])))
%!assert (isrow (sym ([1 2 3])))
%!assert (~isrow (sym ([])))
%!assert (~isrow (sym ([1 2 3]')))
%!assert (~isrow (sym ([1 2; 3 4])))
