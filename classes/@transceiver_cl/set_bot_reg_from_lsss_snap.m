function set_bot_reg_from_lsss_snap(trans_obj,snap_file,channelID)

p = inputParser;

addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addRequired(p,'filename',@(x) ischar(x));

parse(p,trans_obj,snap_file);

range=trans_obj.get_transceiver_range();
[school,layer,exclude,erased] = LSSSreader_readsnapfiles(snap_file);

trans_obj.rm_region_name('LSSS Erased');

if ~isempty(erased)
    idx_chan=find([erased.channel(:).channelID]==channelID);
    for i=1:length(erased.channel(idx_chan))
        reg=create_reg_lsss_erased(erased.channel(idx_chan),'Bad Data','LSSS Erased',range,trans_obj.Params.TransducerDepth);
        trans_obj.add_region(reg);
    end
end

trans_obj.rm_region_name('LSSS School');

for i=1:length(school)
    
    reg=create_reg_lsss(school(i),i,'Data','LSSS School',range,trans_obj.Params.TransducerDepth);
    trans_obj.add_region(reg);
end

trans_obj.rm_region_name('LSSS Layer');

for i=1:length(layer)
    
    reg=create_reg_lsss(layer(i),i,'Data','LSSS Layer',range,trans_obj.Params.TransducerDepth);
    trans_obj.add_region(reg);
end
bot=trans_obj.Bottom;
if ~isempty(exclude)
    
    for i=1:length(exclude)
        [~, startPing] = min(abs(exclude(i).startTime - trans_obj.Params.Time));
        endPing = startPing + exclude(i).numOfPings;
        
        tag=ones(size(bot.Tag));
        tag(startPing:endPing)=0;
        trans_obj.Bottom.Tag=tag;
    end
end


end


function reg=create_reg_lsss_erased(poly,type,name,range,td)
nb_pings=length(td);
nb_samples=length(range);
mask=zeros(numel(range),nb_pings);
dr=nanmean(diff(range));
for ip=1:length(poly.x)
    nb_sect=size(poly.y{ip},1);
    ping_start=poly.x(ip);
    for it=1:nb_sect
        r1=poly.y{ip}(it,1)-td(ip);
        r2=r1+poly.y{ip}(it,2);
        idx_r=round(r1/dr):round(r2/dr);
        idx_r(idx_r<=0|idx_r>=nb_samples)=[];
        mask(idx_r,ping_start)=1;
    end
end


[I,J]=find(mask);
Idx_r=nanmin(I):nanmax(I);
Idx_pings=nanmin(J):nanmax(J);
mask=mask(Idx_r,Idx_pings);
reg=region_cl(...
    'ID',1,...
    'Name',name,...
    'Tag','',...
    'Type',type,...
    'Idx_pings',Idx_pings,...
    'Idx_r',Idx_r,...
    'Shape','Polygon',...
    'MaskReg',mask,...
    'Reference','Surface',...
    'Cell_w',10,...
    'Cell_w_unit','meters',...
    'Cell_h',10,...
    'Cell_h_unit','meters');

end

function reg=create_reg_lsss(poly,id,type,name,range,td)

nb_pings=length(td);
X_cont=poly.x;

X_cont(X_cont>nb_pings)=nb_pings;
X_cont(X_cont<=0)=1;
y=poly.y-td(X_cont);
y(y>range(end))=range(end);
y(y<=range(1))=range(1);

Y_cont=resample_data_v2(1:length(range),range,y,'Opt','Nearest');
Idx_pings=nanmin(X_cont):nanmax(X_cont);
Idx_r=nanmin(Y_cont):nanmax(Y_cont);
X_cont=[X_cont X_cont(1)];
Y_cont=[Y_cont Y_cont(1)];
% X_cont=X_cont-Idx_pings(1)+1;
% Y_cont=Y_cont-Idx_r(1)+1;

reg=region_cl(...
    'ID',id,...
    'Name',name,...
    'Tag','',...
    'Type',type,...
    'Idx_pings',Idx_pings,...
    'Idx_r',Idx_r,...
    'Shape','Polygon',...
    'X_cont',{X_cont},...
    'Y_cont',{Y_cont},...
    'Reference','Surface',...
    'Cell_w',10,...
    'Cell_w_unit','meters',...
    'Cell_h',10,...
    'Cell_h_unit','meters');



end