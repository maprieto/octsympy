%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{l} =} findsymbols (@var{x})
%% Return a list (cell array) of the symbols in an expression.
%%
%% The list is sorted alphabetically.  @xref{symvar}, for details.
%%
%% If two variables have the same symbol but different assumptions,
%% they will both appear in the output.  It is not well-defined
%% in what order they appear.
%%
%% @var{x} could be a sym, sym array, cell array, or struct.
%%
%% @example
%% @group
%% >> syms x y z
%% >> C = @{x, 2*x*y, [1 x; sin(z) pi]@};
%% >> findsymbols (C)
%%    @result{} ans =
%%      @{
%%        (sym) x
%%        (sym) y
%%        (sym) z
%%      @}
%% @end group
%% @end example
%%
%% Note ℯ, ⅈ, π, etc are not counted as symbols.
%%
%% Note only returns symbols actually appearing in the RHS of a
%% @code{symfun}.
%%
%% @seealso{symvar, findsym}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function L = findsymbols(obj, dosort)

  if nargin == 1
    dosort = true;
  end

  if isa(obj, 'sym')
    cmd = { 'x = _ins[0]'
            'if sympy.__version__ == "0.7.5":'   % deprecate with Issue #164
            '    if not x.is_Matrix:'
            '        s = x.free_symbols'
            '    else:'
            '        s = set()'
            '        for i in x.values():'
            '            s = s.union(i.free_symbols)'
            'else:'
            '    s = x.free_symbols'
            'l = list(s)'
            'l = sorted(l, key=str)'
            'return l,' };
    L = python_cmd (cmd, obj);


  elseif iscell(obj)
    %fprintf('Recursing into a cell array of numel=%d\n', numel(obj))
    L = {};
    for i=1:numel(obj)
      temp = findsymbols(obj{i}, false);
      if ~isempty(temp)
        L = {L{:} temp{:}};
      end
    end


  elseif isstruct(obj)
    %fprintf('Recursing into a struct array of numel=%d\n', numel(obj))
    L = {};
    fields = fieldnames(obj);
    for i=1:numel(obj)
      for j=1:length(fields)
        thisobj = getfield(obj, {i}, fields{j});
        temp = findsymbols(thisobj, false);
        if ~isempty(temp)
          L = {L{:} temp{:}};
        end
      end
    end

  else
    L = {};
  end


  % sort and make unique using internal representation
  if dosort
    Ls = {};
    for i=1:length(L)
      Ls{i} = char(L{i});
    end
    [tilde, I] = unique(Ls);
    L = L(I);
  end
end


%!test
%! syms x b y n a arlo
%! z = a*x + b*pi*sin (n) + exp (y) + exp (sym (1)) + arlo;
%! s = findsymbols (z);
%! assert (isequal ([s{:}], [a,arlo,b,n,x,y]))
%!test
%! syms x
%! s = findsymbols (x);
%! assert (isequal (s{1}, x))
%!test
%! syms z x y a
%! s = findsymbols ([x y; 1 a]);
%! assert (isequal ([s{:}], [a x y]))
%!assert (isempty (findsymbols (sym (1))))
%!assert (isempty (findsymbols (sym ([1 2]))))
%!assert (isempty (findsymbols (sym (nan))))
%!assert (isempty (findsymbols (sym (inf))))
%!assert (isempty (findsymbols (exp (sym (2)))))

%!test
%! % empty sym for findsymbols, findsym, and symvar
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=761)
%!   disp('skipping: findsymbols of empty sym broken before SymPy 0.7.7')
%! else
%!   assert (isempty (findsymbols (sym([]))))
%!   assert (isempty (findsym (sym([]))))
%!   assert (isempty (symvar (sym([]))))
%! end

%!test
%! % diff. assumptions make diff. symbols
%! x1 = sym('x');
%! x2 = sym('x', 'positive');
%! f = x1*x2;
%! assert (length (findsymbols (f)) == 2)

%!test
%! % symfun or sym
%! syms x f(y)
%! a = f*x;
%! b = f(y)*x;
%! assert (isequal (findsymbols(a), {x y}))
%! assert (isequal (findsymbols(b), {x y}))

%!test
%! % findsymbols on symfun does not find the argnames (unless they
%! % are on the RHS of course, this matches SMT 2014a).
%! syms a x y
%! f(x, y) = a;  % const symfun
%! assert (isequal (findsymbols(f), {a}))
%! syms a x y
%! f(x, y) = a*y;
%! assert (isequal (findsymbols(f), {a y}))

%!test
%! % sorts lexigraphically, same as symvar *with single input*
%! % (note symvar does something different with 2 inputs).
%! syms A B a b x y X Y
%! f = A*a*B*b*y*X*Y*x;
%! assert (isequal (findsymbols(f), {A B X Y a b x y}))
%! assert (isequal (symvar(f), [A B X Y a b x y]))

%!test
%! % symbols in matpow
%! syms x y
%! syms n
%! if (str2num(strrep(python_cmd ('return sp.__version__,'), '.', ''))<=75)
%!   disp('skipping known failure b/c SymPy <= 0.7.5')
%! else
%!   A = [sin(x) 2; y 1];
%!   B = A^n;
%!   L = findsymbols(B);
%!   assert (isequal (L, {n x y}))
%! end
