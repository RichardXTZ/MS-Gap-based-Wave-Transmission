function PortConnect(Port, mphstartPath, projectDir)

Port_num = numel(Port);

pool = gcp('nocreate');
if isempty(pool) || pool.NumWorkers ~= Port_num
    if ~isempty(pool)
        delete(pool);
    end
    pool = parpool('Processes', Port_num);
end

addAttachedFiles(pool, {
    fullfile(projectDir, 'GA.m')
    fullfile(projectDir, 'PortConnect.m')
    fullfile(projectDir, 'Modelcalculate.m')
});

spmd
    cd(projectDir);
    addpath(genpath(projectDir));
    addpath(mphstartPath);

    which mphstart
    mphstart('localhost', Port(labindex));
end

end