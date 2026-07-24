function Modelcalculate(mat_para,geo_para,var_para,current_path)
    %[f,f_del,c_air,rho_air,p0];[rho_bar,nu_bar,E_bar];
        import com.comsol.model.*
        import com.comsol.model.util.*
        model = ModelUtil.create('Model');
        %% Create Node
        myComp = model.component.create('comp1', true);
        myGeom = myComp.geom.create('geom1', 2);
        myMesh = myComp.mesh.create('mesh1');
        model.result.table.create('tbl1', 'Table');
        model.result.table.create('tbl2', 'Table');
    
        %% Parameters set
        model.param.set('minsize','0.0001[m]');
        model.param.set('f',[num2str(mat_para(1)),'[Hz]']);
        model.param.set('f_del',[num2str(mat_para(2)),'[Hz]']);
        model.param.set('lambda_air', 'c_air/f');
        model.param.set('c_air',[num2str(mat_para(3)),'[m/s]']);
        model.param.set('rho_air',[num2str(mat_para(4)),'[kg/(m^3)]']);
        model.param.set('p0','sqrt(c_air*rho_air)');
        model.param.set('rho_bar',[num2str(mat_para(6)),'[kg/(m^3)]']);
        model.param.set('nu_bar',num2str(mat_para(7)));
        model.param.set('E_bar_ori',[num2str(mat_para(8)),'[Pa]']);
        model.param.set('E_bar','E_bar_ori*(1+E0*i)');
        model.param.set('E0','0.0');
        model.param.set('c_bar', 'sqrt((E_bar_ori*(1-nu_bar))/(rho_bar*(1+nu_bar)*(1-2*nu_bar)))');
        model.param.set('lambda_bar','c_bar/f');
        model.param.set('rho_meta','rho_bar');
        model.param.set('nu_meta','nu_bar');
        model.param.set('E_meta_ori','E_bar_ori');
        model.param.set('E_meta','E_meta_ori*(1+E0*i)');
        model.param.set('c_meta', 'sqrt((E_meta_ori*(1-nu_meta))/(rho_meta*(1+nu_meta)*(1-2*nu_meta)))');
        model.param.set('lambda_meta','c_meta/f');
    
    
        model.param.set('w_beam',[num2str(geo_para(1)),'[m]']);
        model.param.set('tot_sizex',[num2str(geo_para(2)),'[m]']);
        model.param.set('cell_sizey',[num2str(geo_para(3)),'[m]']);
        model.param.set('cav_h',[num2str(geo_para(4)),'[m]']);
        model.param.set('air_sizey',[num2str(geo_para(5)),'[m]']);
        model.param.set('bar_sizey',[num2str(geo_para(6)),'[m]']);
        model.param.set('minsize',[num2str(geo_para(7)),'[m]']);
    
    
        model.param.set('wn1',[num2str(var_para(1)),'[m]']);  
        model.param.set('wn2',[num2str(var_para(2)),'[m]']);
        model.param.set('wn3',[num2str(var_para(3)),'[m]']);

        model.param.set('wc1',[num2str(var_para(4)),'[m]']);
        model.param.set('wc2',[num2str(var_para(5)),'[m]']);

        model.param.set('hc1',[num2str(var_para(6)),'[m]']);
        model.param.set('hc2',[num2str(var_para(7)),'[m]']);

    

        %% Create Goem
        myCavA = myGeom.create('CavA','Rectangle');
        myCavA.set('size',{'tot_sizex' 'cav_h'});
        myCavA.set('pos',{'0' '-cav_h'});
    
        myBar = myGeom.create('Bar','Rectangle');
        myBar.set('size',{'tot_sizex' 'bar_sizey'});
        myBar.set('pos',{'0' '-cav_h-bar_sizey'});
    
        myAir = myGeom.create('Air','Rectangle');
        myAir.set('size',{'tot_sizex' 'air_sizey'});
        myAir.set('pos',{'0' 'cell_sizey'});
    
        myBarPML = myGeom.create('BarPML','Rectangle');
        myBarPML.set('size',{'tot_sizex' 'lambda_bar'});
        myBarPML.set('pos',{'0' '-cav_h-bar_sizey-lambda_bar'});
    
        myAirPML = myGeom.create('AirPML','Rectangle');
        myAirPML.set('size',{'tot_sizex' 'lambda_air'});
        myAirPML.set('pos',{'0' 'cell_sizey+air_sizey'});
       
    
        myNec1 = myGeom.create('Nec1','Rectangle');
        myNec1.set('size',{'wn1' 'cell_sizey/4-hc1/2'});
        myNec1.set('pos',{'tot_sizex/2-wn1/2' '3*cell_sizey/4+hc1/2'});

        myNec2 = myGeom.create('Nec2','Rectangle');
        myNec2.set('size',{'wn2' 'cell_sizey/2-hc1/2-hc2/2'});
        myNec2.set('pos',{'tot_sizex/2-wn2/2' 'cell_sizey/4+hc2/2'});

        myNec3 = myGeom.create('Nec3','Rectangle');
        myNec3.set('size',{'wn3' 'cell_sizey/4-hc2/2'});
        myNec3.set('pos',{'tot_sizex/2-wn3/2' '0'});

        myCav = myGeom.create('Cav','Rectangle');
        myCav.set('size',{'wc1' 'hc1'});
        myCav.set('pos',{'tot_sizex/2-wc1/2' '3*cell_sizey/4-hc1/2'});

        myCav2 = myGeom.create('Cav2','Rectangle');
        myCav2.set('size',{'wc2' 'hc2'});
        myCav2.set('pos',{'tot_sizex/2-wc2/2' 'cell_sizey/4-hc2/2'});

       
        myMetauin = myGeom.create('uni1', 'Union');
        myMetauin.selection('input').set({'Nec1' 'Nec2' 'Nec3' 'Cav' 'Cav2'});
        myMetauin.set('intbnd', false);
        
    
        myMeta = myGeom.create('Meta','Rectangle');
        myMeta.set('size',{'tot_sizex' 'cell_sizey'});
        myMeta.set('pos',{'0' '0'});
    
        myDif = myGeom.create('dif2', 'Difference');
        myDif.selection('input').set({'Meta'});
        myDif.selection('input2').set({'uni1'});
        
        myBoxsel = myGeom.create('boxsel1', 'BoxSelection');
        myBoxsel.set('entitydim', 0);
        myBoxsel.set('xmin', 'minsize/200');
        myBoxsel.set('xmax', 'tot_sizex-minsize/200');
        myBoxsel.set('ymin', '-minsize/200');
        myBoxsel.set('ymax', 'cell_sizey+minsize/200');
    
        myFil = myGeom.create('fil1', 'Fillet');
        myFil.set('radius', 'minsize/6');
        myFil.selection('point').named('boxsel1');
    
        myMeta1 = myGeom.create('Meta1','Rectangle');
        myMeta1.set('size',{'tot_sizex' 'cell_sizey'});
        myMeta1.set('pos',{'0' '0'});
        
        myDif2 = myGeom.create('dif3', 'Difference');
        myDif2.selection('input').set({'Meta1'});
        myDif2.selection('input2').set({'fil1'});
        myDif2.set('keep', true);
    
        model.component('comp1').geom('geom1').run;
    
        strAirsel = 'Airsel';
        myAirsel = myComp.selection.create(strAirsel,'Box');
        myAirsel.label(strAirsel);
        myAirsel.set('ymin',{'cell_sizey'});
        myAirsel.set('ymax',{'cell_sizey+air_sizey'});
        myAirsel.set('condition', 'allvertices');
    
        strMetasel = 'Metasel';
        myMetasel = myComp.selection.create(strMetasel, 'Explicit');
        myMetasel.label(strMetasel);
        myMetasel.set(7);
    
        strCellsel = 'Cellsel';
        myMetasel = myComp.selection.create(strCellsel, 'Explicit');
        myMetasel.label(strCellsel);
        myMetasel.set([4 8]);
    
        strCavsel = 'Cavsel';
        myCavsel = myComp.selection.create(strCavsel,'Box');
        myCavsel.label(strCavsel);
        myCavsel.set('ymin',{'-cav_h'});
        myCavsel.set('ymax',{'0'});
        myCavsel.set('condition', 'allvertices');
    
        strBarsel = 'Barsel';
        myBarsel = myComp.selection.create(strBarsel,'Box');
        myBarsel.label(strBarsel);
        myBarsel.set('ymin',{'-bar_sizey-cav_h'});
        myBarsel.set('ymax',{'-cav_h'});
        myBarsel.set('condition', 'allvertices');
    
        strAirPMLsel = 'AirPMLsel';
        myAirPMLsel = myComp.selection.create(strAirPMLsel,'Box');
        myAirPMLsel.label(strAirPMLsel);
        myAirPMLsel.set('ymin',{'cell_sizey+air_sizey'});
    %     myAirPMLsel.set('ymax',{'cell_sizey+air_sizey+lambda_air'});
        myAirPMLsel.set('condition', 'allvertices');
    
        strBarPMLsel = 'BarPMLsel';
        myBarPMLsel = myComp.selection.create(strBarPMLsel,'Box');
        myBarPMLsel.label(strBarPMLsel);
    %     myBarPMLsel.set('ymin',{'-bar_sizey-cav_h-lambda_bar'});
        myBarPMLsel.set('ymax',{'-bar_sizey-cav_h'});
        myBarPMLsel.set('condition', 'allvertices');
        
        strAirTOsel = 'AirTOsel';
        myAirTOsel = myComp.selection.create(strAirTOsel,'Union');
        myAirTOsel.label(strAirTOsel);
        myAirTOsel.set('input',{strAirsel, strMetasel, strCavsel, strAirPMLsel});
    
        strSolidTOsel = 'SolidTOsel';
        mySolidTOsel = myComp.selection.create(strSolidTOsel,'Union');
        mySolidTOsel.label(strSolidTOsel);
        mySolidTOsel.set('input',{strBarsel, strBarPMLsel strCellsel});
    
        % Boundary condition
        strAirsideLsel = 'AirsideLsel';
        myAirsideLsel = myComp.selection.create(strAirsideLsel,'Box');
        myAirsideLsel.set('entitydim',1);
        myAirsideLsel.label(strAirsideLsel);
        myAirsideLsel.set('xmin','-minsize/200');
        myAirsideLsel.set('xmax','minsize/200');
        myAirsideLsel.set('condition', 'allvertices');
    
        strAirsideRsel = 'AirsideRsel';
        myAirsideRsel = myComp.selection.create(strAirsideRsel,'Box');
        myAirsideRsel.set('entitydim',1);
        myAirsideRsel.label(strAirsideRsel);
        myAirsideRsel.set('xmin','tot_sizex-minsize/200');
        myAirsideRsel.set('xmax','tot_sizex+minsize/200');
        myAirsideRsel.set('condition', 'allvertices');
    
        % Total Side sel
        strSidesel = 'Sidesel';
        mySidesel = myComp.selection.create(strSidesel,'Union');
        mySidesel.set('entitydim', 1);
        mySidesel.label(strSidesel);
        mySidesel.set('input',{strAirsideLsel,strAirsideRsel});
    
    
        myPML = myComp.coordSystem.create('pml1', 'PML');
        myPML.selection.named('AirPMLsel');
        myPML.set('wavelengthSourceType', 'userDefined');
        myPML.set('typicalWavelength', 'lambda_air');
    
        myPML2 = myComp.coordSystem.create('pml2', 'PML');
        myPML2.selection.named('BarPMLsel');
        myPML2.set('wavelengthSourceType', 'userDefined');
        myPML2.set('typicalWavelength', 'lambda_bar');
    
        % Create Acpr Physics
        myAcpr = myComp.physics.create('acpr', 'PressureAcoustics', 'geom1');
        myAcpr.selection.named({strAirTOsel});
        
        myFpam1 = myAcpr.feature('fpam1');
        myFpam1.set('rho_mat', 'userdef');
        myFpam1.set('rho', 'rho_air');
        myFpam1.set('c_mat', 'userdef');
        myFpam1.set('c', 'c_air');
    
        myBpf = myAcpr.create('bpf1', 'BackgroundPressureField', 2);
        myBpf.selection.named({strAirsel});
        myBpf.set('c', 'c_air');
        myBpf.set('pamp', 'p0');
        myBpf.set('dir', [0 -1 0]);
    
        myPCair = myAcpr.create('pc1', 'PeriodicCondition', 1);
        myPCair.selection.named({strSidesel});
        myPCair.set('PeriodicType', 'Floquet');
    
        mySolid = myComp.physics.create('solid', 'SolidMechanics', 'geom1');
        mySolid.selection.named({strSolidTOsel});
    
        myLemm1 = mySolid.feature('lemm1');
        myLemm1.set('E_mat', 'userdef');
        myLemm1.set('E', 'E_meta');
        myLemm1.set('nu_mat', 'userdef');
        myLemm1.set('nu', 'nu_meta');
        myLemm1.set('rho_mat', 'userdef');
        myLemm1.set('rho', 'rho_meta');
        myLemm1.label('Metasurface');
    
        myLemm2 = mySolid.create('lemm2', 'LinearElasticModel', 2);
        myLemm2.selection.named({strBarsel});
        myLemm2.set('E_mat', 'userdef');
        myLemm2.set('E', 'E_bar');
        myLemm2.set('nu_mat', 'userdef');
        myLemm2.set('nu', 'nu_bar');
        myLemm2.set('rho_mat', 'userdef');
        myLemm2.set('rho', 'rho_bar');
        myLemm2.label('Barrier');
    
        myPCsolid = mySolid.create('pc2', 'PeriodicCondition', 1);
        myPCsolid.selection.named({strSidesel});
        myPCsolid.set('PeriodicType', 'Floquet');
    
        % Create Multi Physics
        myMulti = myComp.multiphysics.create('asb1', 'AcousticStructureBoundary', 1);
        myMulti.selection.all;
    
        myMeshMeta = myMesh.create('ftri1', 'FreeTri');
        myMeshMeta.selection.set([4 7 8]);
        myMeshMetasize = myMeshMeta.create('size1', 'Size');
        myMeshMetasize.set('custom', 'on');
        myMeshMetasize.set('hmax', 'lambda_air/12');
        myMeshMetasize.set('hmaxactive', true);
        myMeshMetasize.set('hmin', 'minsize/200');
        myMeshMetasize.set('hminactive', true);
        myMeshMetasize.set('hcurveactive', true);
        myMeshMetasize.set('hcurve', 0.3);
    
        myMeshGap = myMesh.create('ftri2', 'FreeTri');
        myMeshGap.selection.set([3]);
        myMeshGapsize = myMeshGap.create('size1', 'Size');
        myMeshGapsize.set('custom', 'on');
        myMeshGapsize.set('hmax', 'lambda_air/12');
        myMeshGapsize.set('hmaxactive', true);
        myMeshGapsize.set('hmin', 'minsize/200');
        myMeshGapsize.set('hminactive', true);
    
        myMeshair = myMesh.create('ftri3', 'FreeTri');
        myMeshair.selection.geom('geom1', 2);
        myMeshair.selection.set([6 5]);
        myMeshairsize = myMeshair.create('size1', 'Size');
        myMeshairsize.set('custom', 'on');
        myMeshairsize.set('hmax', 'lambda_air/12');
        myMeshairsize.set('hmaxactive', true);
        myMeshairsize.set('hmin', 'minsize/200');
        myMeshairsize.set('hminactive', true);
    
        myMeshbar = myMesh.create('ftri4', 'FreeTri');
        myMeshbar.selection.geom('geom1', 2);
        myMeshbar.selection.set([1 2]);
        myMeshbarsize = myMeshbar.create('size1', 'Size');
        myMeshbarsize.set('custom', 'on');
        myMeshbarsize.set('hmax', 'lambda_bar/24');
        myMeshbarsize.set('hmaxactive', true);
        myMeshbarsize.set('hmin', 'minsize/200');
        myMeshbarsize.set('hminactive', true);
        
        model.component('comp1').mesh('mesh1').feature('size').set('custom', true);
        model.component('comp1').mesh('mesh1').feature('size').set('hgrad', 1.1);
        
        model.study.create('std1');
        model.study('std1').create('freq', 'Frequency');
        model.study('std1').feature('freq').activate('acpr', true);
        model.study('std1').feature('freq').activate('solid', true);
        model.study('std1').feature('freq').activate('asb1', true);
        model.study('std1').feature('freq').set('plist', 'range(f-f_del,f_del,f+f_del)');
        
        model.sol.create('sol1');
        model.sol('sol1').study('std1');
        
        model.study('std1').feature('freq').set('notlistsolnum', 1);
        model.study('std1').feature('freq').set('notsolnum', '1');
        model.study('std1').feature('freq').set('listsolnum', 1);
        model.study('std1').feature('freq').set('solnum', '1');
        
        model.sol('sol1').create('st1', 'StudyStep');
        model.sol('sol1').feature('st1').set('study', 'std1');
        model.sol('sol1').feature('st1').set('studystep', 'freq');
        model.sol('sol1').create('v1', 'Variables');
        model.sol('sol1').feature('v1').set('control', 'freq');
        model.sol('sol1').create('s1', 'Stationary');
        model.sol('sol1').feature('s1').set('stol', 0.001);
        model.sol('sol1').feature('s1').create('p1', 'Parametric');
        model.sol('sol1').feature('s1').feature.remove('pDef');
        model.sol('sol1').feature('s1').feature('p1').set('pname', {'freq'});
        model.sol('sol1').feature('s1').feature('p1').set('plistarr', {'range(f-f_del,f_del,f+f_del)'});
        model.sol('sol1').feature('s1').feature('p1').set('punit', {'Hz'});
        model.sol('sol1').feature('s1').feature('p1').set('pcontinuationmode', 'no');
        model.sol('sol1').feature('s1').feature('p1').set('preusesol', 'auto');
        model.sol('sol1').feature('s1').feature('p1').set('pdistrib', 'off');
        model.sol('sol1').feature('s1').feature('p1').set('plot', 'off');
        model.sol('sol1').feature('s1').feature('p1').set('plotgroup', 'Default');
        model.sol('sol1').feature('s1').feature('p1').set('probesel', 'all');
        model.sol('sol1').feature('s1').feature('p1').set('probes', {});
        model.sol('sol1').feature('s1').feature('p1').set('control', 'freq');
        model.sol('sol1').feature('s1').set('control', 'freq');
        model.sol('sol1').feature('s1').feature('aDef').set('complexfun', true);
        model.sol('sol1').feature('s1').feature('aDef').set('cachepattern', true);
        model.sol('sol1').feature('s1').feature('aDef').set('matherr', true);
        model.sol('sol1').feature('s1').feature('aDef').set('blocksizeactive', false);
        model.sol('sol1').feature('s1').create('seDef', 'Segregated');
        model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
        model.sol('sol1').feature('s1').feature('fc1').set('linsolver', 'dDef');
        model.sol('sol1').feature('s1').feature.remove('fcDef');
        model.sol('sol1').feature('s1').feature.remove('seDef');
        model.sol('sol1').attach('std1');
    
        model.sol('sol1').runAll;
    
        myResult = model.result;
        myExport = myResult.export.create('tbl1', 'Table');
        myExport2 = myResult.export.create('tbl2', 'Table');
        myCln = myResult.dataset.create('cln1', 'CutLine2D');
        myCln.set('genpoints', {'0' 'cell_sizey+lambda_air*1.2' ; 'tot_sizex' 'cell_sizey+lambda_air*1.2'});
    
        myCln2 = myResult.dataset.create('cln2', 'CutLine2D');
        myCln2.set('genpoints', {'0' '-cav_h-lambda_bar*1.2' ; 'tot_sizex' '-cav_h-lambda_bar*1.2'});
    
        myAve = myResult.numerical.create('av1', 'AvLine');
        myAve.set('probetag', 'none');
        myAve.set('data', 'cln1');
        myAve.set('table', 'tbl1');
        myAve.set('expr', {'(acpr.p_s)/p0'});
        myAve.set('unit', {'Pa'});
        myAve.set('descr', {''});
        myAve.setResult;
    
        myAve2 = myResult.numerical.create('av2', 'AvLine');
        myAve2.set('probetag', 'none');
        myAve2.set('data', 'cln2');
        myAve2.set('table', 'tbl2');
        myAve2.set('expr', {'(solid.sy)/sqrt(c_bar*rho_bar)'});
        myAve2.set('unit', {'Pa'});
        myAve2.set('descr', {''});
        myAve2.setResult;
    
        myExport.set('filename',current_path(1));
        myExport.set('header', false);
        myExport.run;
        myExport2.set('filename',current_path(2));
        myExport2.set('header', false);
        myExport2.set('table', 'tbl2');
        myExport2.run;
    
    
    
    
    
    end