clear

currentFile = mfilename('fullpath');
rootPath = fileparts(currentFile);

filename = [rootPath,'\Result.txt'];
fid = fopen(filename, 'r');
i = 1;
while ~feof(fid)
    if i==1
        line = fgetl(fid);  % 获取一行文本
        basic = str2num(line);
    else
        line = fgetl(fid);  % 获取一行文本
        code = str2num(line);
    end
    i=i+1;
end
fclose(fid);
mat_para = basic(4:11);
% para_stru_basic = para_stru_basic*3/5;
geo_para = basic(12:18);
result_population = code;


individual_path = {[rootPath,'\1.txt'],[rootPath,'\2.txt']};
mesh_n = 12;

Modelcalculate(mat_para,geo_para,result_population,individual_path);
mphlaunch