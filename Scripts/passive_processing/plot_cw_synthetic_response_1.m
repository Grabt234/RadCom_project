% ---------------------------------------------------------------------    
% FERS SIM
% TARGET RANGE: 
% VELOCITY:     0   M/S
% ---------------------------------------------------------------------  

close all

%file name
hdf5_file_name_emission = "base_emission.h5"
%hdf5_file_name_response = "cw_emission.h5"
hdf5_file_name_response = "cw_response.h5"


%reading data from hdf5
cmplx_data_emission = loadfersHDF5_iq(hdf5_file_name_emission);
cmplx_data_response = loadfersHDF5_cmplx(hdf5_file_name_response);
%cmplx_data_response = loadfersHDF5_iq(hdf5_file_name_response);

cmplx_data_response =resample(cmplx_data_response,10,1);
% up_samp = 10;
% down_samp = 1;
%cmplx_data_response = resample(cmplx_data_response,up_samp,down_samp);


plot((1:1:length(cmplx_data_emission)),cmplx_data_emission)
figure
% matched_filter = conj(fliplr(cmplx_data_emission));
% a = conv(matched_filter,cmplx_data_response);
% %a = cmplx_data_response;
% plot((1:1:length(a))*(1/2.048e9),(a))
% %%
dab_mode = load_dab_rad_constants(3);
%runtime of simulation (seconds)
run_time = 0.0125;
%sampling frequency
fs = 2.048e9;
%window skip (time steos)
win_skip = 0;
%pulse repetition frequency
%for a continous version 1/frametime
prf = 1/(255200*(1/fs));
%the dab mode used
%     
% 
% %% PLOTTING  READ DATA
% 
figure
subplot(2,3,1)  
plot((1:1:length(cmplx_data_emission)),(cmplx_data_emission))
title("PLOT SHOWING RECEIVED PULSE TRAIN")

subplot(2,3,2)  
plot((1:1:length(cmplx_data_response)),(cmplx_data_response))
title("PLOT SHOWING RECEIVED PULSE TRAIN")

%% CUTTING INTO SLOW TIME SAMPLES

%preallocating memory

slow_time = zeros(ceil(run_time*prf), floor((1/prf)*fs));

i=0;

while length(cmplx_data_response) >= (1/prf)*fs
    
    i = i + 1
    %stroing slow time sample
    slow_time(i,:) = cmplx_data_response(1:(1/prf)*fs);
    %removing slow time sample
    cmplx_data_response = cmplx_data_response((1/prf)*fs:end);
    
end

%showing single pulse, assumes more than 4 pulses
subplot(2,3,3)
plot((1:1:length(slow_time(4,:))),slow_time(4,:))
title("SINGLE RECEIVED PULSE")

%% MATCHING
 
%creating matched filter (there is a size mismatch)
%matching poertion of signal will be fist symbol
matched_filter = conj(fliplr(cmplx_data_emission(1:dab_mode.Tp)));

%plottng matched response with prs from range bin
prs_bin_response = abs(conv(matched_filter,slow_time(2,:)));
subplot(2,3,4)
plot(1:1:length( matched_filter), matched_filter)
title("MATCHED FILTER")

subplot(2,3,5)
plot(1:1:length(prs_bin_response), abs(prs_bin_response))
title("EXAMPLE RESPONSE")

%preallocating memory
range_response = zeros(ceil(run_time*prf),length(conv(matched_filter,slow_time(1,:))));

for j = 1:i
    
    range_response(j,:) = conv(matched_filter,slow_time(j,:));
    
end

figure
plot(1:1:length(range_response(2,:)),range_response(2,:))
%% PLOTTING FIGURE
figure
range_response = fftshift(fft(range_response,[],1),1);

range_response = range_response/max(range_response,[], 'all');


fast_time = size(range_response,2);
slow_time = size(range_response,1);

%range axis
r_axis = (1:1:fast_time)*(1/fs)*(3e8/(2*1000));

%velocity axis
%SIMPLIFY THIS AXIS

v_axis = (-slow_time/2:1:slow_time/2)*(prf/slow_time)*(1/fs)*(3e8/2);

%plotting

%%

imagesc(r_axis , v_axis  ,10*log10(abs(range_response_2)))
xlabel("Range (Km)")
ylabel("Velocity (m/s)")











