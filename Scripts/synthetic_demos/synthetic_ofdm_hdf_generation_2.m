%=================================
% Key 
%=================================
% n    - Number of bits encoded in a single letter
% bits - The bit stream to be converted to phase codes 
%
% map  - The alphabet mapping
%
% L    - Number of symbols in a frame
% N    - Number of sub carriers in a symbol
% F    - number of frames in a signal (dependant of bitstream size)
%
% f0  - Center frequency 
% T      - Elementary period
%
% N   - Number of sub carriers in signal: excluding center
% N_0 - Number of sub carriers in signal inclding center
% L   - Symbols per frame
% Ts  - Elementary periods per symbol
% Tu  - Elementary periods per integration period
% Tg  - Elementary periods in the gaurd interval


%DAB_MODE DESCRIPTION
%     dab_mode.K         = 20;
%     dab_mode.L         = 3;
%     dab_mode.Tnull     = 0;
%     dab_mode.Tu        = 2048;
%     dab_mode.Tg        = 504;
%     dab_mode.Ts        = dab_mode.Tu + dab_mode.Tg;
%     dab_mode.Tp        = dab_mode.Tnull + (dab_mode.L)*dab_mode.Ts;
%     dab_mode.mask      = [ (dab_mode.Tu/2-dab_mode.K/2 +1):(dab_mode.Tu/2), ...
%                                     (dab_mode.Tu/2+2):(dab_mode.Tu/2+dab_mode.K/2 +1) ];
%     dab_mode.p_intra   = 1;
%     dab_mode.T_intra   = 0;
%     dab_mode.Tf        = (dab_mode.Tp + dab_mode.T_intra)*dab_mode.p_intra;
%================================================
%================================================


%% WAVEFORM PARAMETERS
n = 2;
%bits =  '10101010101010101011010101010101010101101010101010101010110101010101010101011010101010101010101';
%bits = '0000000000000000000000000000000000000000';
%bits =  '111111111111111111111111111111111111111';
%bits =  '111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
%bits = '101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010'
%bits =   '1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010'
%bits = '101010101010101010101010101010101010100010001010101011111110101010101011000110101010101010111111101010101010110001101010101010110010111010000101100101110100010101010';


%CHOOSE NEW CONSTANT
dab_mode = load_dab_rad_constants(7);

onez = (dab_mode.L*dab_mode.p_intra*dab_mode.K-dab_mode.K)*2/2;
zeroz = (dab_mode.L*dab_mode.p_intra*dab_mode.K-dab_mode.K)*2/2;
bits = [ones(1,onez), zeros(1,zeroz)];
bits = bits(randperm(numel(bits)));
bits = num2str(bits,'%i');

f0 = 2.048*10^6;
T = 1/f0;

%% EXTRACTING DAB_CONSTANTS

%symbols
L = dab_mode.L;
L_0 = L ;
%carriers no center
K = dab_mode.K ;    
%carriers incl. center
K_0 = dab_mode.K + 1;
%integration period
Tu = dab_mode.Tu;
%symbol period
Ts = dab_mode.Ts;
%gaurd inteval
Tg = dab_mode.Tg;
%intra frame time: spacing between pulses within a frame
T_intra = dab_mode.T_intra;

%% ENCODING BITS
% 
[F, A_pulses] = bits_to_phase_cube(bits,n,dab_mode);

%removing null o make basic pulse wave
A_pulses = A_pulses(:,2:end,:);

%Frequency weights ()
%time per symbol
W_cube = ones(L_0,K_0,F);
W_cube = rescale_cube_to_unity_weights(W_cube,F);

symbol_time = 1:1:Ts;

%% GENERATING WAVEFORM

%generating all envelopes of frames
S = gen_all_pulses(symbol_time, F, L_0, Tu, Ts, Tg, K,W_cube,A_pulses);

%interframe time
tif_time = linspace(T,T_intra,T_intra);

%adding in interframe time periods
S = insert_inter_frame_time(S, F, tif_time);


%% PLOTTING
    
%converting rows to columns
S = S';
%stacking all columns the transposing
S = S(:)';

% plot(1:1:length(S), S)

%% WRITTING TO FILES


% create_hdf5('emission',S);


fileID = fopen('emission.bin','w');
fwrite(fileID,S,'short')
fclose(fileID);

fid =fopen('bits.txt', 'w' );
fwrite(fid, bits);
fclose(fid);


%% debug code
scale = 0;
% symbol n
a = S( (scale)*dab_mode.Ts + dab_mode.Tg + 1:(scale)*dab_mode.Ts   + dab_mode.Tg + dab_mode.Tu );
% symbol n + 1
b = S((scale+1)*dab_mode.Ts+ dab_mode.Tg + 1:(scale+1)*dab_mode.Ts + dab_mode.Tg + dab_mode.Tu );

c = S((scale+2)*dab_mode.Ts+ dab_mode.Tg + 1:(scale+2)*dab_mode.Ts + dab_mode.Tg + dab_mode.Tu );

d = S((scale+3)*dab_mode.Ts+ dab_mode.Tg + 1:(scale+3)*dab_mode.Ts + dab_mode.Tg + dab_mode.Tu );



A = fftshift(fft(a))./length(a);
B = fftshift(fft(b))./length(b);
C = fftshift(fft(c))./length(c);
D = fftshift(fft(d))./length(d);

BB = B./A; %finding
CC = C./B;
DD = D./C;
% 
% figure
% plot(1:1:length(A),(abs(A)))

phase_codes = [round(wrapTo360(rad2deg(angle(BB(dab_mode.mask))))) round(wrapTo360(rad2deg(angle(CC(dab_mode.mask))))) round(wrapTo360(rad2deg(angle(DD(dab_mode.mask))))) ];

rx_bits = '';

mapper = define_inverse_alphabet_map(2);

for z = 1:numel(phase_codes)
    
   rx_bits = [rx_bits  mapper(phase_codes(z))];

end

%reference bits
fileID = fopen('bits.txt','r');
ref_bits = fscanf(fileID,'%s');
fclose(fileID);

ref=char(num2cell(ref_bits));
ref=reshape(str2num(ref),1,[]);

output=char(num2cell(rx_bits));
output=reshape(str2num(output),1,[]);

results = rx_bits - ref_bits;
results = (string(results));
results = horzcat(results{:})












