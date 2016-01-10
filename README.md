OctSymPy
========

An implementation of a symbolic toolbox using SymPy.

[https://github.com/cbm755/octsympy]


Goals
-----

Feature parity with the other symbolic toolboxes.

![Screenshot 1](/screenshot.png)

![Screenshot 2](/screenshot-install.png)



Status
------

"Beta" quality at best!  Contributions welcome.



How to Install
--------------

1. The only dependencies are Python and SymPy.  Consult the SymPy
   website (e.g., `yum install sympy` on Fedora).

2. Download the latest release, e.g., `octsympy-0.1.2.tar.gz`.

3. Run Octave and change to the folder containing the downloaded file.

4. At Octave prompt, type `pkg install octsympy-0.1.2.tar.gz`.

5. At Octave prompt, type `pkg load octsympy`.

6. At Octave prompt, type `syms x`, then `f = (sin(x/2))^3`,
   `diff(f,x)`, etc.



How to Install on Windows
-------------------------

1.  Get [Octave](http://www.octave.org) for Windows.

2.  Try the octsympy-windows-0.1.2.zip package.  Follow the last three
    steps above using this file instead.

The `octsympy-windows` package should have no dependencies other than
Octave itself (it includes SymPy and a Python interpreter.)

Alternatively, you can install Python and SymPy yourself and use the
standard `octsympy-0.1.2.zip` package.

If you encounter any difficulties (even minor ones) please read and
if possible help us improve the
[wiki page on Windows Installation](https://github.com/cbm755/octsympy/wiki/Notes-on-Windows-installation).




How to Install on Matlab
------------------------

Although OctSymPy is designed for GNU Octave, it will work with
Matlab.  Currently only the slower system()-based communication is
available.

1.  Download the latest release, e.g., `octsympy-matlab-0.1.2.tar.gz`.

2.  Unzip is somewhere and add it to your Matlab Path.

The .m files for Matlab have been reformatted for Matlab comment
conventions, but are otherwise the same as the Octave source.


How to Help
-----------

We have a list of things to work on tagged [help
wanted](https://github.com/cbm755/octsympy/issues?q=is:open+is:issue+label:"help+wanted").
Some of these should be quite easy to fix and would be a great way to
get involved.  Come join us!

How to hack on the code:

1.  Clone the repo with git (preferred, but you can use the "Download
    ZIP" instead of you want).

2.  Go to octsympy/src/ and type "make".  (You only need to do this
    again if you change the inst/private/python_header.py or various
    autogeneration scripts in src/.)

3.  Run Octave (or Matlab) in octsympy/inst/.



Implementation
--------------

Python code is generated to do the actual work.  Each sym objects keep
a text field for display purposes and a string (a SymPy `srepr`).  The
objects are communicated between Python and Octave by passing the
srepr's back-and-forth.  Currently pure m-file (and Python)
implementation, no code to be compiled.



Communication
-------------

We have two IPC mechanisms between Octave and Python.  One option is
calling "system()".  The other uses "popen2()".  Others could be
implemented.



Related Projects
----------------

  * There was a previous "symbolic" package in Octave Forge based on
    GiNaC.  Its history has now been merged into octsympy.

  * ["SymPy CAS" by Jonathan Lister](http://www.mathworks.com/matlabcentral/fileexchange/42787-sympy-cas-in-matlab).
    Calls SymPy commands using system().

