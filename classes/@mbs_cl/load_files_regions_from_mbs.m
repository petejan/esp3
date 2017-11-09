function layer=load_files_regions_from_mbs(mbs,varargin)

p = inputParser;

addRequired(p,'mbs',@(obj) isa(obj,'mbs_cl'));
addParameter(p,'CVSroot','',@ischar);
addParameter(p,'PathToMemmap','',@ischar)
addParameter(p,'type','crest');
addParameter(p,'mode','normal');
addParameter(p,'idx_trans',[],@isnumeric);

parse(p,mbs,varargin{:});

cvsroot=p.Results.CVSroot;
datapath=p.Results.PathToMemmap;
type=p.Results.type;
mode=p.Results.mode;
idx_trans=p.Results.idx_trans;

dFileNum=mbs.Input.dfileNum;
%dfileDir=mbs.Input.dfileDir;
dPathToFile=mbs.Input.crestDir;
rawFilename=mbs.Input.rawFileName;
rawPathToFile=mbs.Input.rawDir;
reg=mbs.Input.reg;
botRev=mbs.Input.botRev;
regRev=mbs.Input.regRev;
calRev=mbs.Input.calRev;
calRaw=mbs.Input.calRaw;
absorption=mbs.Input.absorption;
surveyname=mbs.Header.title;
voyage=mbs.Header.voyage;
%vertslice=mbs.Header.vertical_slice_size;
snapshot=mbs.Input.snapshot;
stratum=mbs.Input.stratum;
transect=mbs.Input.transect;


if length(idx_trans) > length(dFileNum)
    warning('Requested index > num transects, using num transects');
    idx_trans=1:length(dFileNum);
elseif isempty(idx_trans)
    idx_trans=1:length(dFileNum);
end


svCorr=nan(1,length(transect));
calRev_curr='';
svCorr_def=1;

u=0;
for i=idx_trans
    u=u+1;
    fprintf(1,'Opening file d%07d, (%s)\n',dFileNum(i),rawFilename{i});
    
    switch type
        case 'raw'
            if exist(fullfile(rawPathToFile{i},rawFilename{i}),'file')==2
                ifileInfo=parse_ifile(fullfile(dPathToFile{i},sprintf('i%07d', dFileNum(i))));
                layer(u)=open_EK_file_stdalone(fullfile(rawPathToFile{i},rawFilename{i}),...
                    'PathToMemmap',datapath,'Frequencies',38000,'EsOffset',ifileInfo.es60error_offset);
            else
                continue;
            end
            
            trans_obj=layer(u).get_trans(38000);
            if isempty(trans_obj)
                continue;
            end
            
            origin=fullfile(dPathToFile{i},sprintf('d%07d',dFileNum(i)));
            layer(u).OriginCrest=origin;
            trans_obj.apply_cw_cal(calRaw{i});
        case 'crest'
            layer(u)=read_crest(fullfile(dPathToFile{i},sprintf('d%07d',dFileNum(i))),'PathToMemmap',datapath,'CVSCheck',0);
            idx_freq=find_freq_idx(layer(u),38000);
    end
    
    calRev_new = calRev{i};
    if ~strcmp(calRev_curr,calRev_new)
        calRev_curr=calRev_new;
        svCorr_def = CVS_CalRevs(cvsroot,'CalRev',calRev_curr);
    end
     svCorr(i)=svCorr_def;
    
    if isnan(mbs.Input.absorption(i))
        trans_obj.apply_absorption(mbs.Header.default_absorption/1e3);
    else
        trans_obj.apply_absorption(absorption(i)/1e3);
    end
    
   
    switch mode
        case 'normal'
            
            reg_curr=reg{i};
            
            if ~isempty(reg_curr)>0
                layer(u).CVS_BottomRegions(cvsroot,'BotRev',botRev{i},'RegRev',regRev{i},'Reg',reg_curr);
            else
                layer(u).CVS_BottomRegions(cvsroot,'BotRev',botRev{i},'RegCVS',0);
            end
            
            
        case 'sch'
            layer(u).CVS_BottomRegions(cvsroot,'BotRev',botRev{i},'RegCVS',0);            

            trans_obj.add_algo(algo_cl('Name','SchoolDetection','Varargin',struct(...
                'Type','sv',...
                'Sv_thr',-62,...
                'l_min_can',15,...
                'h_min_tot',10,...
                'h_min_can',5,...
                'l_min_tot',30,...
                'nb_min_sples',100,...
                'horz_link_max',5,...
                'vert_link_max',5)));  
       
            trans_obj.apply_algo('SchoolDetection');
                       
            rm_id=nan(1,length(trans_obj.Regions));
            for uuk=1:length(trans_obj.Regions)
                [mean_depth,~]=trans_obj.get_mean_depth_from_region(trans_obj.Regions(uuk).Unique_ID);
                if nanmin(mean_depth)<200
                    rm_id(uuk)=trans_obj.Regions(uuk).Unique_ID;
                end
            end
            rm_id(isnan(rm_id))=[];
            for uik=1:length(rm_id)
                trans_obj.rm_region_id(rm_id(uik));
            end
    end
    surv=survey_data_cl('Voyage',voyage,'SurveyName',surveyname,'Snapshot',snapshot(i),'Stratum',stratum{i},'Transect',transect(i));
    layer(u).set_survey_data(surv);
    
    
end


end