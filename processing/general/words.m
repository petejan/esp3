function all_words = words(sentence, delimiter)

% This function will parse a sentence into words using the given 
% delimiter character

% Copied from the Matlab manual
% $Id: words.m 5007 2001-10-31 03:12:56Z gjm $

remainder = sentence;
all_words = '';
while (any(remainder))
  [chopped,remainder] = strtok(remainder, delimiter);
  all_words = strvcat(all_words,chopped);
end
