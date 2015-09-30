function [xOut, fsOut] = VocodeSound(filename, vocoder_type)
%function [xOut, fsOut] = VocodeSound(filename, vocoder_type)
%
%Function that vocodes .wav file given by 'filename' according to the 
%'vocoder_type'. 
%
%INPUTS:
%------
%   filename     --> .wav filename including path, if it is not in the same
%                    folder as this script.
%   vocoder_type --> 0 to indicate noise-band vocoder, or 1 to indicate
%                    sine-wave vocoder.
%
%OUTPUTS:
%-------
%   xOut         --> Vocoded signal.
%   fsOut        --> Corresponding sampling frequency.
%
%Usage Examples:
%---------------
%
%   1. If the sound wave file is not in the same folder as this script:
%   [xOut, fsOut] = VocodeSound('C:/My Documents/Folder/Example1.wav', 0);
%
%   This vocodes the file Example1.wav, which is stored in 
%   'C:/My Documents/Folder' using a noise-band vocoder.
%
%   2. If the sound wave file is in the same folder as this script:
%   [xOut, fsOut] = VocodeSound('Example1.wav', 0);
%
%   In this case, there is no need to include the full path.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% BEGIN CODE:

    %Load the sound wave file
    [y,fs] = audioread(filename);

    if vocoder_type == 0
        load('params_noise.mat');
    elseif vocoder_type == 1
        load('params_sine.mat');
    end

    %Apply vocoder:
    [xOut, fsOut, p] = vocode(y, fs, params);
    xOut = xOut(:);

    %This prevents the wavwrite from clipping the data
    m = max(abs(min(xOut)),max(xOut)) + 0.001;
    xOut = xOut./m;
    
    
    %Play the vocoded signal:
    x = audioplayer(xOut,fsOut,16);
    playblocking(x);


end