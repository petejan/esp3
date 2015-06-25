  function regInfo = getRegInfoFromRegNoteString(NoteStr) % get
            % region Info from Echoview region note string. The info
            % comes from the region definition page in esp2 and get's
            % written in Echoviews note string by mbs.convertBRfromMbs
            % Important variables are slicereftype, slicesize & vertslicesize
            i= 0;
            rem = NoteStr(strfind(NoteStr, 'Esp2RegionShape'):end);
            rem = regexprep(rem, ' Referenced', 'Referenced' );
            while 1
                i = i+1;
                [tok, rem] =  strtok(rem, '.');
                if isempty(tok) ;
                    %                     eval(['regInfo.' tok '= ''' value ''';']);
                    break;
                else
                    col =  strfind(rem, ':');
                    [tok, value] =  strtok(tok, ':');
                    value = regexprep(value, {':' ' ' '_' '"'}, '');
                    eval(['regInfo.' tok '= ''' value ''';']);
                end
            end
        end