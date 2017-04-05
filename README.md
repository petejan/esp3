![EchoAnalysis.png](https://bitbucket.org/repo/g4Kg5e/images/2024943680-EchoAnalysis.png)

# What is ESP3?

ESP3 is an open-source software package for visualizing and processing fisheries acoustics data, developed by the deepwater fisheries acoustics team at NIWA (Wellington, New Zealand).

It is written in MATLAB (and contributions to the code from MATLAB users are welcome), but a **compiled version is available for non-MATLAB users**. See details below.

# What can ESP3 do?

ESP3 is designed for single-beam and split-beam data. Currently supported data formats are SIMRAD (.raw) and a small number of other formats. The software allows calibration and echo-integration and a number of algorithms are coded in, including bad pings identification, automated bottom detection, single targets identification and tracking, schools identification, etc.

ESP3 is currently under active development so keep an eye on it. More algorithms regularly show up. 

# How do I get ESP3 and run it?

You have two options:

1. If you have **MATLAB R2016a** (or more recent) and a small number of **required toolboxes**, you can simply get the source code and run it.

2. If you don't use MATLAB (or don't have the necessary version and toolboxes), you can download and run the stand-alone, compiled version.

More details below.

# I don't have/use/understand MATLAB and even if I did, I just want the software up-and-running on my PC, not the source code. How do I do that?

Simple. First, download and install the free [Matlab Compiler Runtime R2016a (9.0.1)](https://au.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/win64/MCR_R2016a_win64_installer.exe). Next, download and run [the installer for the ESP3 compiled version](https://sourceforge.net/projects/esp3/files/).

# I have MATLAB. How do I get the source code and how do I run it?

Follow the Downloads link in the menu bar on the left and it will get you the latest version of the project's source code. Once downloaded on your local machine, just run "EchoAnalysis.m" from the "ESP3" root folder.

# How do I stay up-to-date with the latest developments? Do I have to re-download a new version every time it comes out?

You can, but a better way would be for you to install Git and "fork" the project. Doing so will also download the source code and Git will allow you to keep it updated to the latest version if you so wish. [Learn about version controlling, Git and "forking" here](https://www.atlassian.com/git?utm_source=bitbucket&utm_medium=link&utm_campaign=help_dropdown&utm_content=learn_git).

# I can code some MATLAB. I'm keen to code my own algorithms and extensions for it. Can I do that?

Yes. Fork the project and do any updates and modifications you want. They'll stay on your copy without affecting the development of the main branch. And you can always integrate the latest changes made on the main branch back into your forked copy (see Git functions "sync" and "merge").

And if down the line you wish to suggest to integrate bits of your code to the main branch, you can do that too through "pull requests".

# I know MATLAB and I know Git. Can I join the development team?

Clone away, buddy.

# Copyright

Copyright 2017 NIWA

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Contact
Yoann Ladroit, NIWA.
Yoann.ladroit@niwa.co.nz