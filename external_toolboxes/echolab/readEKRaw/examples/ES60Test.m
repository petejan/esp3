%readEKRaw_ES60Example.m
%
%  A copy of the readEKRaw_SimpleExample script using ES60 data.  In this
%  example we use alternative calibration parameters provided by calibration
%  parameter file.

%  THIS EXAMPLE REQURIES THE "XML Parser" LIBRARY AVAILABLE FROM MATLAB
%  CENTRAL.
%    http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=1757&objectType=file

%  define paths to example raw and bot files
rawFile = 'P:\2008\EBS 2008 Aldebaran\L0304-D20080711-T163725-ES60.raw';
outFile = 'P:\2008\EBS 2008 Aldebaran\L0304-D20080711-T163725-ES60.out';
parmFile = 'G:\AADP_project\parameter files\Aldebaran08_CalParms.xml';


%  read in raw ES60 data file
disp('Reading .raw file...');
[header, rawData] = readEKRaw(rawFile);


%  read calibration parameters from .xml file
%    readEKRaw provides functions for saving and reading a simple XML based 
%    calibration parameters file.  These files can be used to 
calParms = readEKRaw_ReadXMLParms(parmFile);


%  read in the .out file - return data as range
disp('Reading .out file...');
[header, botData] = readEKOut(outFile, calParms);


