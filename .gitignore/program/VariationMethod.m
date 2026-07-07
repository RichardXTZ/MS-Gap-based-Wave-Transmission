function output_population = VariationMethod(input_population,gene_length,crossover_probability,variation_probability)

output_population = input_population;

[n_pop,total_gene_length] = size(input_population);

variable_num = total_gene_length / gene_length;

% =========================
% 1. 交叉
% =========================
for i = 1:2:n_pop-1
    
    if rand < crossover_probability
        
        % 在变量之间交叉，不切断单个变量的基因
        cross_point = randi([1,variable_num-1]) * gene_length;
        
        parent1 = output_population(i,:);
        parent2 = output_population(i+1,:);
        
        output_population(i,:)   = [parent1(1:cross_point), parent2(cross_point+1:end)];
        output_population(i+1,:) = [parent2(1:cross_point), parent1(cross_point+1:end)];
        
    end
end

% =========================
% 2. 变异
% =========================
mutation_position = rand(size(output_population)) < variation_probability;

output_population(mutation_position) = 1 - output_population(mutation_position);

end