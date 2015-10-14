function layer=load_files_regions(mbs,varargin)

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
dfileDir=mbs.Input.dfileDir;
dPathToFile=mbs.Input.crestDir;
rawFilename=mbs.Input.rawFileName;
rawPathToFile=mbs.Input.rawDir;
reg=mbs.Input.reg;
botRev=mbs.Input.botRev;
regRev=mbs.Input.regRev;
calRev=mbs.Input.calRev;
calRaw=mbs.Input.calRaw;
absorbtion=mbs.Input.absorbtion;
surveyname=mbs.Header.title;
snapshot=mbs.Input.snapshot;
stratum=mbs.Input.stratum;
transect=mbs.Input.transect;


if length(idx_trans) > length(dFileNum)||isempty(idx_trans)
    warning('Requested index > num transects, using num transects');
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
                ifileInfo=parse_ifile(dPathToFile{i},dFileNum(i));
                layer(u)=open_EK60_file_stdalone(rawPathToFile{i},rawFilename{i},...
                    'PathToMemmap',datapath,'Frequencies',38000,'EsOffset',ifileInfo.es60error_offset);
            else
                continue;
            end
            
            [idx_freq,found]=layer(u).find_freq_idx(38000);
            if found==0
                continue;
            end
            
            origin=fullfile(dPathToFile{i},sprintf('d%07d',dFileNum(i)));
            layer(u).OriginCrest=origin;
            layer(u).Transceivers(idx_freq).apply_cw_cal(calRaw{i});
        case 'crest'
            layer(u)=read_crest(dPathToFile{i},sprintf('d%07d',dFileNum(i)),'PathToMemmap',datapath,'CVSCheck',0);
            idx_freq=find_freq_idx(layer(u),38000);
    end
    
    calRev_new = calRev{i};
    if ~strcmp(calRev_curr,calRev_new)
        calRev_curr=calRev_new;
        svCorr_def = CVS_CalRevs(cvsroot,'CalRev',calRev_curr);
    end
     svCorr(i)=svCorr_def;
    
    if isnan(mbs.Input.absorbtion(i))
        layer(u).Transceivers(idx_freq).apply_absorption(mbs.Header.default_absorption/1e3);
    else
        layer(u).Transceivers(idx_freq).apply_absorption(absorbtion(i)/1e3);
    end
    
    
    Transceiver =layer(u).Transceivers(idx_freq);
    
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
            layer(u).Transceivers(idx_freq).Algo=init_algos(layer(u).Transceivers(idx_freq).Data.Range);
            [idx_school_detect,~]=find_algo_idx(Transceiver,'SchoolDetection');
            linked_candidates=feval(layer(u).Transceivers(idx_freq).Algo(idx_school_detect).Function,layer(u).Transceivers(idx_freq),...
                'Type','sv',...
                'Sv_thr',-62,...
                'h_min_can',5,...
                'h_min_tot',10,...
                'l_min_can',15,...
                'l_min_tot',30,...
                'nb_min_sples',100,...
                'horz_link_max',5,...
                'vert_link_max',5);
            
            layer(u).Transceivers(idx_freq).create_regions_from_linked_candidates(linked_candidates,'w_unit','pings','h_unit','meters','cell_w',10,'cell_h',5,'bbox_only',0);
            
            rm_id=nan(1,length(layer(u).Transceivers(idx_freq).Regions));
            for uuk=1:length(layer(u).Transceivers(idx_freq).Regions)
                [mean_depth,~]=layer(u).Transceivers(idx_freq).get_mean_depth_from_region(layer(u).Transceivers(idx_freq).Regions(uuk).Unique_ID);
                if nanmin(mean_depth)<200
                    rm_id(uuk)=layer(u).Transceivers(idx_freq).Regions(uuk).Unique_ID;
                end
            end
            rm_id(isnan(rm_id))=[];
            for uik=1:length(rm_id)
                layer(u).Transceivers(idx_freq).rm_region_id(rm_id(uik));
            end
    end
    
    layer(u).SurveyData=survey_data_cl('SurveyName',surveyname,'Snapshot',snapshot(i),'Stratum',stratum{i},'Transect',transect(i));
    layer(u).save_regs();
    
end


end