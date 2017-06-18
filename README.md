![EchoAnalysis.png](https://bitbucket.org/repo/g4Kg5e/images/2024943680-EchoAnalysis.png)

# What is ESP3?

ESP3 is an **open-source** software package for visualizing and processing **fisheries acoustics data**, developed by the deepwater fisheries acoustics team at NIWA (Wellington, New Zealand).

ESP3 is designed for single-beam and split-beam echosounder data. The software is mainly focused on the processing of fisheries acoustic surveys, with attention to reproducibility and consistency. It was primarily built around SIMRAD EK60 and EK80 data (.raw) but also supports a small number of other formats to a certain extend (CREST, Furuno FCV30, and ASL data). The software allows standard data processing procedures such as calibration and echo-integration and a number of our in-house algorithms are coded in, including bad pings identification, automated bottom detection, single targets identification and tracking, schools detection, etc. 

ESP3 is currently under active development (particularly in terms of broadband processing) so keep an eye on this project page. More features and algorithms regularly show up.

**[See the wiki for more information on what ESP3 does.](https://bitbucket.org/echoanalysis/esp3/wiki/Home)**

# How do I download it and get it to run on my data?

ESP3 is written in **MATLAB** so the source code can be run from a standard MATLAB environment provided you have the appropriate version (R2016a or later) and toolboxes.

**For non-MATLAB users** on a Windows 64bits platform, a compiled version of the latest stable release is also available.

**[See the wiki for detailed information on how to download and install ESP3 either in its MATLAB or compiled version.](https://bitbucket.org/echoanalysis/esp3/wiki/Home)**

# How can I learn to use it?

**[See the wiki for manuals (user, technical, tutorials) currently in development.](https://bitbucket.org/echoanalysis/esp3/wiki/Home)**

# Can I contribute to the development of ESP3?

Coding contributions are gladly welcome and to be coordinated through the ESP3 BitBucket project page. Please contact the team to notify your interest.

# Copyright

Copyright 2017 NIWA

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Contact
Yoann Ladroit, NIWA
Yoann.ladroit@niwa.co.nz

Alexandre C.G. Schimel, NIWA
Alexandre.Schimel@niwa.co.nz

Pablo Escobar-Flores,NIWA
Pablo.Escobar@niwa.co.nz