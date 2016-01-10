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
%% @deftypefn  {Function File} {@var{A} =} assumptions ()
%% @deftypefnx {Function File} {@var{A} =} assumptions (@var{x})
%% @deftypefnx {Function File} {[@var{v}, @var{d}] =} assumptions (@var{x}, 'dict')
%% @deftypefnx {Function File} {@var{L} =} assumptions ('possible')
%% List assumptions on symbolic variables.
%%
%% The assumptions are returned as a cell-array of strings:
%% @example
%% @group
%% >> syms x y positive
%% >> syms n integer
%% >> assumptions
%%    @result{} ans =
%%      @{
%%        [1,1] = n: integer
%%        [1,2] = x: positive
%%        [1,3] = y: positive
%%      @}
%% >> f = sin(n*x);
%% >> assumptions(f)
%%    @result{} ans =
%%      @{
%%        [1,1] = n: integer
%%        [1,2] = x: positive
%%      @}
%% >> assumptions(n)
%%    @result{} ans =
%%      @{
%%        [1,1] = n: integer
%%      @}
%% @end group
%% @end example
%%
%% With the optional second argument set to the string @code{'dict'},
%% return the assumption dictionaries in @var{d} corresponding
%% to the variables in @var{v}.
%%
%% You can also get a list of possible assumptions:
%% @example
%% @group
%% >> A = assumptions('possible');
%% >> sprintf('%s ', A@{:@})
%%    @result{} ans = real positive negative integer even odd rational finite
%% @end group
%% @end example
%%
%% @seealso{sym, syms, assume, assumeAlso}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [A, B] = assumptions(F, outp)

  if ((nargin == 1) && ischar(F) && strcmp(F, 'possible'))
    A = valid_sym_assumptions();
    return
  end

  if ((nargin == 0) || isempty(F))
    find_all_free_symbols = true;
  else
    find_all_free_symbols = false;
  end
  if (nargin <= 1)
    outp = 'no';
  end

  if (find_all_free_symbols)
    %% no input arguments
    % find all syms, check each for free symbols
    workspace = {};
    context = 'caller';
    S = evalin(context, 'whos');
    evalin(context, '[];');  % clear 'ans'
    for i = 1:numel(S)
      workspace{i} = evalin(context, S(i).name);
    end
    F = findsymbols(workspace);
  end

  % Nice and easy on SymPy >= 0.7.7
  % FIXME: See also, sym.m and syms.m, updates there?
  cmd = {
      'x = _ins[0]'
      'outputdict = _ins[1]'
      'd = x._assumptions.generator'
      'if d == {}:'
      '    astr = ""'
      'elif all(d.values()):'  % all True so list them
      '    astr = ", ".join([str(i) for i in d.keys()])'
      'else:'  % more complicated case, just the raw dict
      '    astr = str(d)'
      'if outputdict:'
      '    return (astr, d)'
      'else:'
      '    return astr,' };

  % FIXME: Deprecate 0.7.6.x.  But on older SymPy we do some foolishness.
  % Abbreviate certain assumption dicts to shorter equivalent forms.
  % I look forward to deleting all this.
  oldsympy = python_cmd('return sympy.__version__ == "0.7.5" or sympy.__version__.startswith("0.7.6"),');
  if (oldsympy)
    cmd = {
    'x = _ins[0]'
    'outputdict = _ins[1]'
    '# saved cases to abbreviate later'
    'adict_default = {"commutative":True}'
    'adict_real = {"commutative":True, "complex":True, "hermitian":True, "imaginary":False, "real":True}'
    'adict_pos = {"commutative":True, "complex":True, "hermitian":True, "imaginary":False, "negative":False, "nonnegative":True, "nonpositive":False, "nonzero":True, "positive":True, "real":True, "zero":False}'
    'adict_neg = {"commutative":True, "complex":True, "hermitian":True, "imaginary":False, "negative":True, "nonnegative":False, "nonpositive":True, "nonzero":True, "positive":False, "prime":False, "composite":False, "real":True, "zero":False}'
    'adict_odd = {"even":False, "nonzero":True, "commutative":True, "noninteger":False, "hermitian":True, "zero":False, "complex":True, "rational":True, "real":True, "integer":True, "imaginary":False, "odd":True, "irrational":False}'
    'adict_even = {"real":True, "even":True, "commutative":True, "noninteger":False, "hermitian":True, "complex":True, "rational":True, "integer":True, "imaginary":False, "odd":False, "irrational":False}'
    'adict_even_076 = {"real":True, "even":True, "commutative":True, "noninteger":False, "hermitian":True, "complex":True, "rational":True, "integer":True, "imaginary":False, "odd":False, "irrational":False}'
    'adict_integer = {"real":True, "commutative":True, "noninteger":False, "hermitian":True, "complex":True, "rational":True, "integer":True, "imaginary":False, "irrational":False}'
    'adict_rational = {"real":True, "commutative":True, "hermitian":True, "complex":True, "rational":True, "imaginary":False, "irrational":False}'
    'if sympy.__version__.startswith("0.7.6"):'
    '    new076 = {"algebraic":True,  "transcendental":False}'
    '    adict_integer.update(new076)'
    '    adict_even.update(new076)'
    '    adict_odd.update(new076)'
    '    adict_rational.update(new076)'
    'adict = x.assumptions0'
    'if adict == adict_default:'
    '    astr = ""'
    '    #adict={}'
    'elif adict == adict_real:'
    '    astr = "real"'
    '    #adict = {"real":True}'
    'elif adict == adict_pos:'
    '    astr = "positive"'
    '    #adict = {"positive":True}'
    'elif adict == adict_neg:'
    '    astr = "negative"'
    '    #adict = {"negative":False}'
    'elif adict == adict_integer:'
    '    astr = "integer"'
    '    #adict = {"integer":True}'
    'elif adict == adict_even:'
    '    astr = "even"'
    '    #adict = {"even":True}'
    'elif adict == adict_odd:'
    '    astr = "odd"'
    '    #adict = {"odd":True}'
    'elif adict == adict_rational:'
    '    astr = "rational"'
    '    #adict = {"rational":True}'
    'else:'
    '    astr = str(adict)'
    '    astr = astr.replace("True","1").replace("False","0").replace(": ",":")'
    '#astr = str(x) + ": " + astr'
    'if outputdict:'
    '    return (astr,adict)'
    'else:'
    '    return (astr,)'
  };
  end

  c = 0; A = {};
  if strcmp(outp, 'dict')
    B = {};
  end
  if (isempty(F))
    return
  end
  s = findsymbols(F);
  for i=1:length(s)
    x = s{i};
    if strcmp(outp, 'dict')
      [astr, adict] = python_cmd(cmd, x, true);
      if ~isempty(astr)
        c = c + 1;
        A{c} = x;
        B{c} = adict;
      end
    else
      astr = python_cmd(cmd, x, false);
      if ~isempty(astr)
        c = c + 1;
        str = [x.flat ': ' astr];
        A{c} = str;
        %if c == 1
        %  A = str;
        %elseif c == 2
        %  A = {A str};
        %else
        %  A{c} = str;
        %end
      end
    end
  end

end


%!test
%! syms x
%! assert(isempty(assumptions(x)))

%!test
%! x = sym('x', 'positive');
%! a = assumptions(x);
%! assert(~isempty(strfind(a{1}, 'positive')))

%!test
%! syms x
%! assert(isempty(assumptions(x)))

%!test
%! clear  % for matlab test script
%! syms x positive
%! assert(~isempty(assumptions()))
%! clear
%! assert(isempty(assumptions()))

%!test
%! A = {'real' 'positive' 'negative' 'integer' 'even' 'odd' 'rational'};
%! % FIXME: remove once SymPy 0.7.6 support deprecated
%! for i = 1:length(A)
%!   x = sym('x', A{i});
%!   a = assumptions(x);
%!   assert(strcmp(a{1}, ['x: ' A{i}] ))
%! end

%!test
%! if (str2num(strrep(python_cmd ('return sp.__version__,'),'.',''))<=761)
%!   disp('skipping: char(x) of assumptions suboptimal in <= 0.7.6.x')
%! else
%!   A = assumptions('possible');
%!   for i = 1:length(A)
%!     x = sym('x', A{i});
%!     a = assumptions(x);
%!     assert(strcmp(a{1}, ['x: ' A{i}] ))
%!     s1 = char(x);
%!     s2 = ['Symbol(''x'', ' A{i} '=True)'];
%!     assert (strcmp (s1, s2))
%!   end
%! end

%!test
%! syms x positive
%! syms y real
%! syms z
%! f = x*y*z;
%! a = assumptions(f);
%! assert(length(a) == 2)
%! assert(~isempty(strfind(a{1}, 'positive')))
%! assert(~isempty(strfind(a{2}, 'real')))

%!test
%! % dict output
%! syms x positive
%! syms y real
%! syms z
%! f = x*y*z;
%! [v, d] = assumptions(f, 'dict');
%! assert(length(v) == 2)
%! assert(iscell(v))
%! assert(isa(v{1}, 'sym'))
%! assert(isa(v{2}, 'sym'))
%! assert(length(d) == 2)
%! assert(iscell(d))
%! assert(isstruct(d{1}))
%! assert(isstruct(d{2}))

%!test
%! %% assumptions on just the vars in an expression
%! clear  % for matlab test script
%! syms x y positive
%! f = 2*x;
%! assert(length(assumptions(f))==1)
%! assert(length(assumptions())==2)

%!test
%! %% assumptions in cell/struct
%! clear  % for matlab test script
%! syms x y z w positive
%! f = {2*x [1 2 y] {1, {z}}};
%! assert(length(assumptions())==4)
%! assert(length(assumptions(f))==3)
%! clear x y z w
%! assert(length(assumptions())==3)
%! assert(length(assumptions(f))==3)
