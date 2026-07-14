function [result_population] = Translation(current_population,gene_length,wi_lim,hi_lim,ne_lim,wn_lim,ln_lim,resolution)

    result_population=zeros(size(current_population,1),size(current_population,2)/gene_length);
    
    lim = [repmat(wi_lim,2,1); repmat(hi_lim,2,1); repmat(ne_lim,1,1); repmat(wn_lim,2,1); repmat(ln_lim,2,1)];
    for i = 1:size(current_population,1)
        gene_matrix = reshape(current_population(i,:), gene_length, size(current_population,2)/gene_length).';
        normalized_value = gene_matrix * (2.^(gene_length-1:-1:0)).' / (2^gene_length - 1);
    
        real_value = lim(:,1) + normalized_value .* (lim(:,2) - lim(:,1));
    
        real_value = round(real_value / resolution) * resolution;
    
        result_population(i,:)=real_value';
    end