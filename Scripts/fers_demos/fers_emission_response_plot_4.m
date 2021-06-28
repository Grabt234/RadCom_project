% ---------------------------------------------------------------------    
% demo_fers_emission_response_compare: plots the first emission followed by
% all the recieved pulses. 
%
% note: the difference between start of first transmission and first
% response in the propogation delay and therefore the range of the target
% ---------------------------------------------------------------------  

%file name of emmitted and recieved pulse
hdf5_file_name_emission = "emission.h5"
hdf5_file_name_response = "response.h5"

%sampling frequency
fs = 2.048e6;
%window skip (time steos)
win_skip = ceil(1246e-6*fs);
%pulse repetition frequency
prf = 10;
%the dab mode used
dab_mode = load_dab_constants(1);


%reading data from hdf5
cmplx_data_emission = loadfersHDF5_iq(hdf5_file_name_emission); 
cmplx_data_response = loadfersHDF5_cmplx(hdf5_file_name_response);

cmplx_data_emission = [cmplx_data_emission zeros(1,(1/prf)*fs-win_skip )];
%three is hard coded
cmplx_data_emission = repmat(cmplx_data_emission,1,3);

%time axis
time_emission = (1:1:length(cmplx_data_emission))*(1/fs);
time_response = (1:1:length(cmplx_data_response))*(1/fs);


%plotting time domain envelope of frame
%0.01 is an arbitrary rescaling to make plot clearer
plot(time_emission,real(cmplx_data_emission));
hold on
plot(time_response,real(cmplx_data_response));

%plot labels
xlabel("Time (seconds)");
ylabel("Amplitude");
title("Plot showing first emiited pulse v.s all recieved pulses");

