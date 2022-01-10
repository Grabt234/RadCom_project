%================================================
% Note that this file is dabMode independant
% Tests conversion of bits to phases
%================================================

%% Setting carrier and frame parameter

%Number of frames
F = 2;
%symbols
L = 2;
L_0 = L;
%carriers no center
K = 5;    
%carriers incl. center
K_0 = K + 1;
%bits per phase
Ns = [1 2 3];


for i = 1:length(Ns)
    
    %% Setting bits per phase
    n = Ns(i);
    
    %% Generating bit stream of equal number of ones and zeros
    onez = L*K*n;
    zeroz = L*K*n;
    bits = [ones(1,onez), zeros(1,zeroz)];
    bits = bits(randperm(numel(bits)));
    bits = num2str(bits,'%i');
    
    %DataTable = [DataTable bits];
    %% Defining alphabet mapping

    map = define_alphabet_map(n);

    %% Breaking bitstream into n sized strings
    
    cleaved_bit_stream = cleave_bitstream(bits,n);
    
    disp(cleaved_bit_stream)
    
    %% Converting to phase
    
    A = bitstream_to_phase(map,cleaved_bit_stream);
    
    A = convert_phase_to_complex(A);
    
    disp(A)
    
    %% Reshaping into symbol
    
    L_encode = convert_vector_symbols(A,K);
    
    disp(L_encode)

end
    