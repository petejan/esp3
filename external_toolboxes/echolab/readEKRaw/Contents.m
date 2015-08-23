%  readEKRaw toolbox - Functions for reading and writing EK/ES60 raw data
%  
%  Read data
%    readEKRaw.m                 - Reads EK/ES60 raw data files (partial ME70 support)
%    readEKBot.m                 - Reads EK60 .bot files
%    readEKOut.m                 - Reads EK60 MKI and ES60 .out files
%
%  Write data
%    writeEKRaw.m                - Writes EK60 raw data files.
%
%  Transform data
%    readEKRaw_Power2Sv.m        - Convert power to Sv (or sv)
%    readEKRaw_Sv2Power.m        - Convert Sv (or sv) to power
%    readEKRaw_Power2Sp.m        - Convert power to Sp (or sp)
%    readEKRaw_Sp2Power.m        - Convert Sp (or sp) to power
%    readEKRaw_ConvertAngles.m   - Convert electrical angles to physical
%                                  angles and physical angles to electrical
%
%  Parameter management
%    readEKRaw_GetCalParms.m     - Extracts calibration parameters from readEKRaw structrue
%    readEKRaw_SetCalParms.m     - Sets calibration parameters in the readEKRaw structrue
%    readEKRaw_SaveXMLParms.m    - Saves calibration parameters to an XML file
%    readEKRaw_ReadXMLParms.m    - Reads calibration parameters from an XML file
%
%  Interpolation
%    readEKRaw_InterpGPS.m       - Interpolates GPS data on a ping by ping basis
%    readEKRaw_InterpVLog.m      - Interpolates vessel log data on a ping by ping basis
%    readEKRaw_InterpVSpeed.m    - Interpolates vessel speed data on a ping by ping basis
%
%  Display
%    readEKRaw_SimpleEchogram.m  - Creates a simple echogram figure
%    readEKRaw_SimpleAnglogram.m - Creates a simple anglogram figure
%
%  12/09/2009 - RHT

