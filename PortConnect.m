function PortConnect(Port,mphstartPath)

addpath(mphstartPath);
Port_num = size(Port,2);
pool = gcp('nocreate');
if isempty(pool) || pool.NumWorkers ~= Port_num
    if ~isempty(pool)
        delete(pool);
    end
    pool = parpool('Processes', Port_num);
end

spmd
    cd(projectDir);
    addpath(genpath(projectDir));
    addpath(comsolMli);

    mphstart(Port(labindex));
end