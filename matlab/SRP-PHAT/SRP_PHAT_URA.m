%% SRP Estimate of Direction of Arrival at Microphone Array
% Estimate the direction of arrival of a signal using the SRP-PHAT
% algorithm. 
%%
%close all
fs=16000;        % sampling frequency (arbitrary)
D=2;            % duration in seconds

L = ceil(fs*D)+1; % signal duration (samples)
n = 0:L-1;        % discrete-time axis (samples)
t = n/fs;         % discrete-time axis (sec)
x = chirp(t,0,D,fs/2)';   % sine sweep from 0 Hz to fs/2 Hz

%% load recorded office noise audio
noisepath = '../../noise/';
[noise2,fs] = audioread([noisepath,'����-2.wav']);
noise0 = audioread([noisepath,'����.wav']);
noise5 = audioread([noisepath,'����-5.wav']);
noise = [noise2,noise0,noise5];

%use a clean speech audio as desired signal
pathname = '../';
[speech ,fs] = audioread([pathname,'speech.wav']);
%scale source signal to obtain 0 dB input SNR    
speech = speech(1:length(noise0))/2;   


% x = filter(Num,1,x0);
c = 340.0;
%%
% Create the 5-by-5 microphone URA.
d = 0.042;
N = 3;
mic = phased.OmnidirectionalMicrophoneElement;
array = phased.ULA(N,d,'Element',mic);
% array = phased.URA([N,N],[d,d],'Element',mic);

%%
% Simulate the incoming signal using the |WidebandCollector| System
% object(TM).
arrivalAng = [15;0];
collector = phased.WidebandCollector('Sensor',array,'PropagationSpeed',c,...
    'SampleRate',fs,'ModulatedInput',false);
s = collector(speech,arrivalAng);
% signal = signal(1:4800,:);
signal = s+noise;

%%
path = '../../TestAudio/num3_MIC5/';
[s1,fs] = audioread([path,'����-2.wav']);
s5 = audioread([path,'����-6.wav']);
s4 = audioread([path,'����-5.wav']);
s2 = audioread([path,'����-3.wav']);
signal = [s1,s5,s4,s2];
%%
t = 0;

step = 1;
P = zeros(1,length(0:step:360-step));
tic
h = waitbar(0,'Please wait...');
for i = 0:step:360-step
    [ DS, x1] = DelaySumURA(signal,fs,256,256,128,d,i/180*pi);
    t = t+1;
    P(t) = DS'*DS;
    waitbar(i / length(step:360-step))
end
toc
close(h) 
[m,index] = max(P);
figure,plot(0:step:360-step,P/max(P))
(index)*step






