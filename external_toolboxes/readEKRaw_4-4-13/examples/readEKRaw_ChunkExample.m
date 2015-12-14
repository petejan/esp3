%readEKRaw_ChunkExample.m
%
%  A script showing how to read data files in chunks using the 'Continue' and
%  'ReaderState' parameters.  This feature is useful if you have very large data
%  files and are unable to work with the entire file in memory at once.
%
%  While you can read data in chunks by specifying appropriate ping or time
%  ranges, using the Continue/ReaderState parameters allows the reading
%  function to pick up where it left off without scanning thru the entire file
%  to find the range of data specified.
%
%  Note that if you want to read discontinuous chunks of data, you can still
%  use the Continue/ReaderState parameters as long as you read the chunks
%  in a single pass thru the file.  For example you could read pings [50 100]
%  [200 300] and [500 550] using Continue.  But reading them out of order:
%  [500 550] [50 100] [200 300] would only return data for the first set
%  [500 550].  It is advised that if you are reading data in discontinuous
%  blocks to order the blocks accordingly.  If you cannot do this, you cannot
%  use the Continue/ReaderState parameters and must read your data starting from
%  the beginning of the file for every block (which can be very slow).



%  define paths to example raw and bot files
rawFile = 'data\DY0909-D20090610-T142514.raw';
botFile = 'data\DY0909-D20090610-T142514.bot';

disp('Reading .raw file...');
%  read in the first chunk of the file using PingRange to define chunk size.
%  Note that we specify the optional 3rd return argument "rstat" that will
%  contain the reader state when the function exits.
%
%  also note that we do not read in angle data

[header, firstRaw, rstat] = readEKRaw(rawFile, 'Frequencies', 38000, ...
    'PingRange', [1 50], 'Angles', false);

%  read in the second chunk of the file by setting the Continue and ReaderParms
%  parameters.  Here we pass rstat back into the function to continue where we
%  left off in the last call to readEKRaw.
[header, secondRaw] = readEKRaw(rawFile, 'Frequencies', 38000, ...
    'Continue', true, 'ReaderState', rstat, 'Angles', false);

%  extract calibration parameters from the first raw data structure
calParms = readEKRaw_GetCalParms(header, firstRaw);



disp('Reading .bot file...');

%  read in the .bot file - by passing the optional 3rd argument we force
%  readEKBot to only return data for pings contained in the firstRaw structure.
%  again, we set the rstat return argument.
[header, firstBot, rstat] = readEKBot(botFile, calParms, firstRaw, ...
    'ReturnRange', true);

%  read in the rest of the .bot data.  Set the Continue and ReaderState
%  parameters so the function doesn't have to scan thru the first half of the
%  file.
[header, secondBot] = readEKBot(botFile, calParms, secondRaw, ...
    'ReturnRange', true, 'Continue', true, 'ReaderState', rstat);

%  convert power to Sv
firstRaw = readEKRaw_Power2Sv(firstRaw, calParms);
secondRaw = readEKRaw_Power2Sv(secondRaw, calParms);



%  plot up the two blocks of data
disp('Plotting...');

%  plot the first chunk echogram
readEKRaw_SimpleEchogram(firstRaw.pings(1).Sv, firstRaw.pings(1).number, ...
    firstRaw.pings(1).range, 'Threshold', [-80,-34], 'Title', ...
    ['Sv  ' num2str(calParms(1).frequency)]);
hold on
%  plot the bottom
plot(firstRaw.pings(1).number, firstBot.pings.bottomdepth(1,:), 'c');
hold off

%  plot the second chunk echogram
readEKRaw_SimpleEchogram(secondRaw.pings(1).Sv, secondRaw.pings(1).number, ...
    secondRaw.pings(1).range, 'Threshold', [-80,-34], 'Title', ...
    ['Sv  ' num2str(calParms(1).frequency)]);
hold on
%  plot the bottom
plot(secondRaw.pings(1).number, secondBot.pings.bottomdepth(1,:), 'c');
hold off