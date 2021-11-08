%%Notes

%TX file should be generated at the ideal system sampling rate, not what is
%   use in the physiocal hardware
%%
close all
dab_mode = load_dab_rad_constants(7);

%% RF Parameters

fc = 2.4e9;
integrationTime = 1;
prf = 100;
maxPulses = 100;
%system sampling rate
fs = 2.048e6;
%delay before data starts being taken by hardware
sampDelay = 0.27;

%% TX Params Config

%transmitted file parameters
txFilename = "tmp.bin";

%file reading configurations
txFileParams.fileType = 'Bin';
txFileParams.fs = 2.048e6;
txFileParams.dataType = "double";

%% RX Params Config

%transmitted file parameters
rxFilename = "rx.dat";

%file reading configurations
rxFileParams.fileType = 'Bin';
rxFileParams.fs = 2.5e6;
rxFileParams.dataType = "double";

%% TX Read In/Resample

txFileParams.r_fid = fopen(txFilename,'rb');

%reading in doubles from bin file
tx_file = fread(txFileParams.r_fid, txFileParams.dataType);

%changing into complex numbers
tx = tx_file(1:2:end) + 1j*tx_file(2:2:end);

%changing column into row
tx = tx.';

figure
%Plotting time domain of tx signal
subplot(2,2,1)
ax = (1:1:length(tx))*1/txFileParams.fs;
plot(ax, real(tx))
xlabel("time - s")
ylabel("amplitude")
title("TIME DOMAIN OF TX SIGNAL")

%Plotting Tx Frequency Domain
subplot(2,2,2)
ax = (1:1:length(tx))*txFileParams.fs/length(tx) - txFileParams.fs/2;
plot(ax/1e6, 20*log10(abs(fftshift(fft(tx)))))
xlabel("frequency - Mhz")
ylabel("amplitude")
title("FREQUENCY DOMAIN OF TX SIGNAL")

%resampling to system frequency
tx = resample(tx, fs, txFileParams.fs);

%% RX read in/Resample

rxFileParams.r_fid = fopen(rxFilename,'rb');

%reading in doubles from bin file
rx_file = fread(rxFileParams.r_fid,'double');

%changing into complex numbers
rx = rx_file(1:2:end) + 1j*rx_file(2:2:end);

%changing column into row
rx = rx.';

%Plotting time domain of tx signal
subplot(2,2,3)
ax = (1:1:length(rx))*1/rxFileParams.fs;
plot(ax, real(rx))
xlabel("time - s")
ylabel("amplitude")
title("TIME DOMAIN OF RX SIGNAL")

%Plotting Tx Frequency Domain
subplot(2,2,4)
ax = (1:1:length(rx))*rxFileParams.fs/length(rx) - rxFileParams.fs/2;
plot(ax/1e6, 20*log10(abs(fftshift(fft(rx)))))
xlabel("frequency - Mhz")
ylabel("amplitude")
title("FREQUENCY DOMAIN OF RX SIGNAL")

%resampling to system frequency
rx = resample(rx, fs, rxFileParams.fs);

%% Conditioning for RD

%prepending zeroes to round to closest prf after sampling delay
prfFill = sampDelay*prf  - floor(sampDelay*prf);
rx = [zeros(1, fs*prfFill) rx];

%removing first pulse in order to remove added zeros
rx = rx(1,fs/prf :end);

%preallocating memory 
RD = zeros(maxPulses, fs/prf);

nPulses = 0;

while nPulses < maxPulses
    
    %taking slow time cut
    RD(nPulses+1,:) = rx(1,1:fs/prf);
    %removing cut from data
    rx = rx(1, fs/prf:end);
   
    nPulses = nPulses +1 ;
end

%cutting excess if leftover rows of zeros
RD = RD(1:nPulses,:);

%% Creating Matched Filter

mf = tx;
fill = fs/prf - length(tx);
mf = [mf zeros(1,fill)];
mf = conj(flip(mf));
MF = fft(mf);

%% ARD

for i = 1:nPulses 
    
    RD(i,:) = ifft(fft(RD(i,:)).*MF);
    
end


RD = fftshift(fft(RD,[],1),1);

%%

figure
s = surf(10*log10(abs(RD)));
set(s, "linestyle", "none")







    






