mphstartPath = 'D:\Program Files\COMSOL\COMSOL56\Multiphysics\mli';
% 
Port = 2111:2120;
Port_num=size(Port,2);
parpool(Port_num);

initial_population = round(rand(population_size,individual_size));
current_population = zeros(population_size,individual_size);
choosen_population = zeros(population_size,individual_size);
crossover_population = zeros(population_size,individual_size);
variation_population = zeros(population_size,individual_size);
sort_population = zeros(population_size*2,individual_size+3+variale_num);

for indivi_num = 1:population_size
    individual_pathal(indivi_num) = strcat(rootPath,data_path,num2str(indivi_num),'.txt');
end
for indivi_num = 1:population_size
    individual_pathal2(indivi_num) = strcat(rootPath,data_path,num2str(indivi_num),'_pha.txt');
end
addpath(pro_path);

for era_num = 1:iterations
    t0=tic;
    current_population = initial_population;
    [result_population] = Translation(current_population,gene_length,w_lim,h_lim,n_lim,0.00001);

    mat_para = [para_air,para_bar];%[f,f_del,c_air,rho_air,p0];[rho_bar,nu_bar,E_bar];
    geo_para = [w_beam,tot_sizex,cell_sizey,cav_h,air_sizey,solid_sizey,minsize];
    para_total = [mat_para,geo_para];
    for amo=1:(population_size/Port_num)
        parfor port_indi=1:Port_num
            if era_num+amo==2
                mphstart(Port(port_indi))
            end
            indi_num=(amo-1)*Port_num+port_indi;
            current_path = [individual_pathal(indi_num),individual_pathal2(indi_num)];
            Modelcalculate(mat_para,geo_para,result_population(indi_num,:),current_path);
        end

    end
%     for indi_num = 1:population_size
% %         indi_num=1;
%         current_path = [individual_pathal(indi_num),individual_pathal2(indi_num)];
%         Modelcalculate(mat_para,geo_para,result_population(indi_num,:),current_path);
%     end

    for individual_num=1:population_size
        % individual_path = strcat(path,data_path,num2str(individual_num),'.txt');
        para_path = individual_pathal(individual_num);
        fileOPID=fopen(para_path);
        fileData=textscan(fileOPID,'%f');
        fclose(fileOPID);
        fileResult=fileData{:};
        Apre_L=fileResult(2);
        Apre_M=fileResult(4);
        Apre_R=fileResult(6);

        para_path2 = individual_pathal2(individual_num);
        fileOPID=fopen(para_path2);
        fileData=textscan(fileOPID,'%f');
        fclose(fileOPID);
        fileResult=fileData{:};
        Apre_L2=fileResult(2);
        Apre_M2=fileResult(4);
        Apre_R2=fileResult(6);

        ampRe_L(individual_num)=abs(Apre_L);
        argRe_L2(individual_num)=angle(Apre_L2);
        ampRe_M(individual_num)=abs(Apre_M);
        argRe_M2(individual_num)=angle(Apre_M2);
        ampRe_R(individual_num)=abs(Apre_R);
        argRe_R2(individual_num)=angle(Apre_R2);
    end

     % delta_test_L = abs((ampRe_L).^2)*0.8+0.2*abs(argRe_L2-Target_pha)/pi;
     % delta_test_M = abs((ampRe_M).^2)*0.8+0.2*abs(argRe_M2-Target_pha)/pi;
     % delta_test_R = abs((ampRe_R).^2)*0.8+0.2*abs(argRe_R2-Target_pha)/pi;

     delta_test_L = abs((ampRe_L).^2);
     delta_test_M = abs((ampRe_M).^2);
     delta_test_R = abs((ampRe_R).^2);

     delta_test_ave = (delta_test_L+delta_test_R)./2;
     delta_test=delta_test_M*0.9+delta_test_ave*0.1;

     delta_T = [delta_test',delta_test_M',argRe_M2'];
 
     new_population_data = [delta_T,current_population,result_population];
    
    if era_num==1 
        sort_population(1:population_size,:) = sortrows(new_population_data,1);
    else
        sort_population(population_size+1:population_size*2,:) = new_population_data;
        sort_population = sortrows(sort_population,1);
    end
    
    choosen_population = sort_population(1:population_size,:);
     [delta_min,pos_min] = min(choosen_population(:,1));

     % Data save
    fileID = fopen (Target_path, 'wt'); % 打开文件并指定 'wt' 模式
    fprintf(fileID, '%d ', [sort_population(1,1:3),para_total]); % 写入行向量 x（元素之间用空格分隔）
    fprintf(fileID, '\n'); % 插入回车换行
    fprintf(fileID, '%d ', sort_population(1,individual_size+4:end)); % 写入行向量 x（元素之间用空格分隔）
    fclose(fileID); % 关闭文件

    Iteration_path = [mk_path,'/G',num2str(era_num),'.txt'];
    fileID = fopen (Iteration_path, 'wt'); % 打开文件并指定 'wt' 模式
    fprintf(fileID, '%d ', [sort_population(1,1),para_total]); % 写入行向量 x（元素之间用空格分隔）
    fprintf(fileID, '\n'); % 插入回车换行
    fprintf(fileID, '%d ', sort_population(1,2:end)); % 写入行向量 x（元素之间用空格分隔）
    fclose(fileID); % 关闭文件

    %% 交叉&变异

    variation_population = VariationMethod(choosen_population(:,4:individual_size+3),gene_length,crossover_probability,variation_probability);
    initial_population = variation_population;

    t1 = toc(t0);
    fprintf(['第',num2str(era_num),'代完成计算，偏差值为', ...
        num2str(min(choosen_population(:,1))),'-',num2str(choosen_population(pos_min,2)),'-' ...
        , num2str((min(choosen_population(:,1))-0.9*choosen_population(pos_min,2))*10),'相位是：',num2str(choosen_population(pos_min,3)), ...
        ',最小尺寸为',num2str(minsize),'，用时',num2str(t1),'s','\n']);
end