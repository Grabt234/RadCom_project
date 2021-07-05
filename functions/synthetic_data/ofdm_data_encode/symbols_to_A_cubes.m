function A_cubes = symbols_to_A_cubes(L_encode,dab_mode)
    % ---------------------------------------------------------------------    
    % add_prs_A_cube: Adding in prs then reshaping into cube without
    %                       null symbol
    %                           
    % ---------------------------------------------------------------------
    % Usage:
    %  Inputs
    %  > L_encode - n vectors of length L phase codes
    %  > dab_mode - describtion of DAB modulation parameters
    %
    %  Outputs
    %  > 
    %
    % ---------------------------------------------------------------------
    
    %not including null symbol
    number_cubes = size(L_encode,1)/(dab_mode.L-1)
    
    required_symbols = (number_cubes-floor(number_cubes))*(dab_mode.L-1)
    
    additional = ones(required_symbols, dab_mode.K);
    
    L_encode = [L_encode ; additional];
    
    A_cubes = reshape(L_encode,[],dab_mode.L-1,dab_mode.K);
    
end

















