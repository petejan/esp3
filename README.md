%% EchoAnalysis.m
%
% ESP3 Main function
%
%          |
%         /|\
%        / | \
%       /  |  \
%      /   |___\   
%    _/____|______   
%     \___________\   written by Yoann Ladroit
%        / \          in 2016
%       /   \
%      / <>< \    Fisheries Acoustics
%     /<>< <><\   NIWA - National Institute of Water & Atmospheric Research
%
%% Help
%
% *USE*
%
% Run this function without input variables to launch empty ESP3, or with
% input file names to open. Use the SaveEcho optional parameter to print
% out contents of any input file.
%
% *INPUT VARIABLES*
%
% * 'Filenames': Filenames to load (Optional. char or cell).
% * 'SaveEcho': Flag to print window (Optional. If |1|, print content of
% input file and closes ESP3).
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% NA
%
% *NEW FEATURES*
%
% * 2017-03-22: reformatting header according to new template (Alex Schimel)
% * 2017-03-17: reformatting comment and header for compatibility with publish (Alex Schimel)
% * 2017-03-02: commented and header added (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
%   EchoAnalysis; % launches ESP3
%   EchoAnalysis('Filenames','my_file.raw'); % launches ESP3 and opens 'my_file.raw'.
%   EchoAnalysis('Filenames','my_file.raw','SaveEcho',1); % launches ESP3, opens 'my_file.raw', print file data to .png, and close ESP3.
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA.
%
% Copyright 2017 NIWA
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions: The above copyright notice and this permission
% notice shall be included in all copies or substantial portions of the
% Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
%
This README would normally document whatever steps are necessary to get your application up and running.

### What is this repository for? ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact