function varargout = FlareFlowModule(varargin)
% FLAREFLOWMODULE M-file for FlareFlowModule.fig
%      FLAREFLOWMODULE, by itself, creates a new FLAREFLOWMODULE or raises the existing
%      singleton*.
%
%      H = FLAREFLOWMODULE returns the handle to a new FLAREFLOWMODULE or the handle to
%      the existing singleton*.
%
%      FLAREFLOWMODULE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLAREFLOWMODULE.M with the given input arguments.
%
%      FLAREFLOWMODULE('Property','Value',...) creates a new FLAREFLOWMODULE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FlareFlowModule_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FlareFlowModule_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FlareFlowModule

% Last Modified by GUIDE v2.5 06-Mar-2015 17:43:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FlareFlowModule_OpeningFcn, ...
                   'gui_OutputFcn',  @FlareFlowModule_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FlareFlowModule is made visible.
function FlareFlowModule_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FlareFlowModule (see VARARGIN)
handles.c_or_d_item=0;
data = ['Woolf93          ';'Woolf & Thorpe91 ';'Memery & Merlivat';...
    'Leifer           ';'Mendelson        ';'Leifer&Patro     ';'Off              '];
handles.names_BRS=cellstr(data);
clear data
handles.sel_BRS=handles.names_BRS{1};
handles.temp=0;
handles.Sal=35;
handles.c_speed=1500;
handles.depth_value=0;
handles.shear_visc=0.0014;
handles.dens=1000;
handles.surf_ten=0.074;
handles.Depth_mean=0;
handles.PSI=-1;
handles.select=0;
handles.Cp=2191;
handles.gamma=1.4;
handles.Th_conductivity_value=0.03057; 
handles.rho_G=0;
handles.BeamW=7;
handles.P0st=101325;
handles.g_value=9.8;
handles.freq_value=38000;
handles.Poly_order_value=6;
handles.nbins=20;
handles.S_rad=0;
handles.C_S_num=0;
handles.Poly_order_BRS=6;
handles.sel_BRS='Woolf93';
handles.BRS_poly_fit=0;
handles.low_lim=0;
handles.main_path=pwd;
% Choose default command line output for FlareFlowModule
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FlareFlowModule wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FlareFlowModule_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BSD_file.
function BSD_file_Callback(hObject, eventdata, handles)
% hObject    handle to BSD_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%cd Fl'areFlowModule Functions'\
handles.BSD=BSD_selection();
if handles.BSD==-1
    handles.sentence='...no selected BSD file';
    set(handles.message,'String',handles.sentence);
else
    handles.sentence='';
    set(handles.message,'String',handles.sentence);
end
%cd ..
guidata(hObject,handles)
handles.output = hObject;

% --- Executes on button press in open_flare_file.
function open_flare_file_Callback(hObject, eventdata, handles)
% hObject    handle to open_flare_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%cd Fl'areFlowModule Functions'\
[handles.filename,handles.flare,handles.flarenames,...
    handles.structSize,handles.path_data_analized]=flares_file_selection();
if handles.filename==-1
    handles.sentence='...no selected flare file';
    set(handles.message,'String',handles.sentence);
end

guidata(hObject,handles)
handles.output = hObject;


% --- Executes on selection change in flare_list.
function flare_list_Callback(hObject, eventdata, handles)
% hObject    handle to flare_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns flare_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from flare_list
set(handles.flare_list,'String',handles.flarenames);
handles.flare_item=get(handles.flare_list,'value');
handles.flare_in_proc=getfield(handles.flare,handles.flarenames{handles.flare_item});
handles.UTMzone=handles.flare_in_proc{1,3}(1,:);
handles.c_speed=handles.flare_in_proc{1,13};
handles.freq_value=handles.flare_in_proc{1,14};
handles.SampleInterval=handles.flare_in_proc{1,15};

handles.flare_in_proc=[double(handles.flare_in_proc{1,1}) double(handles.flare_in_proc{1,2})...
    double(handles.flare_in_proc{1,4}) double(handles.flare_in_proc{1,5}) double(handles.flare_in_proc{1,6})...
    double(handles.flare_in_proc{1,7}) double(handles.flare_in_proc{1,8}) double(handles.flare_in_proc{1,9})...
    double(handles.flare_in_proc{1,10}) double(handles.flare_in_proc{1,11}) double(handles.flare_in_proc{1,12})];

set(handles.c_value,'String',handles.c_speed);
set(handles.freq,'String',handles.freq_value);
handles.Min_depth_flare=max(handles.flare_in_proc(:,5));
handles.Max_depth_flare=min(handles.flare_in_proc(:,5));

% if handles.low_lim==0
    handles.low_lim=min(handles.flare_in_proc(:,5));
    set(handles.lower_limit_layer,'String',num2str(handles.low_lim));
% elseif min(handles.flare_in_proc(:,5))> handles.low_lim 
%     handles.low_lim=min(handles.flare_in_proc(:,5));
%     set(handles.lower_limit_layer,'String',num2str(handles.low_lim));
% end
handles.Min_depth_flare=max(handles.flare_in_proc(:,5));
handles.height=handles.Min_depth_flare-handles.Max_depth_flare;

handles.depth_value=handles.height;
set(handles.av_depth_value,'String',num2str(handles.depth_value));

handles.select=handles.flare_in_proc((find(handles.flare_in_proc(:,5)>handles.low_lim...
    & handles.flare_in_proc(:,5)<(handles.low_lim+handles.depth_value))),:);
handles.Depth_mean=abs(mean(handles.select(:,5)));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function flare_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flare_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calculate_flow.
function calculate_flow_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_flow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'TSgeomean')==0
    handles.sentence='... you must press statistic button';
    set(handles.message,'String',handles.sentence);
else

handles.q=flow_estimation(handles.PSI,handles.TSgeomean);
set(handles.flow_result,'String',num2str(handles.q));

end
guidata(hObject,handles)
handles.output = hObject;


% --- Executes on button press in K_value.
function K_value_Callback(hObject, eventdata, handles)
% hObject    handle to K_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.PSI=calculates_PSI(handles.Depth_mean,handles.c_speed,handles.shear_visc,handles.dens,...
    handles.Cp,handles.gamma,handles.Th_conductivity_value,handles.rho_G,...
    handles.P0st,handles.g_value,handles.freq_value,handles.fun,handles.r,...
    handles.ris_speed,handles.SampleInterval,handles.surf_ten);

set(handles.K_num,'String',num2str(handles.PSI));
guidata(hObject,handles)
handles.output = hObject;


function flow_result_Callback(hObject, eventdata, handles)
% hObject    handle to flow_result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flow_result as text
%        str2double(get(hObject,'String')) returns contents of flow_result as a double
guidata(hObject,handles)
handles.output = hObject;


% --- Executes during object creation, after setting all properties.
function flow_result_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flow_result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in BRS_models.
function BRS_models_Callback(hObject, eventdata, handles)
% hObject    handle to BRS_models (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns BRS_models contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BRS_models

handles.sel_BRS=handles.names_BRS{get(handles.BRS_models,'value')};
if isfield(handles,'r')==0
    handles.sentence='...please load a BSD file!!!';
    set(handles.message,'String',handles.sentence);
else
    handles.BRS_val_models=(buoyvel(handles.r*100,handles.temp,handles.c_or_d_item,...
    handles.sel_BRS,handles.Sal ))/100;
    cd ..
    handles.sentence=handles.sel_BRS;
    set(handles.message,'String',handles.sentence);
end

if (get(handles.checkboxBRS,'Value') == get(handles.checkboxBRS,'Min'))
	handles.ris_speed=handles.BRS_val_models;
end

guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function BRS_models_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BRS_models (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function clean_or_dirty_Callback(hObject, eventdata, handles)
% hObject    handle to clean_or_dirty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clean_or_dirty as text
%        str2double(get(hObject,'String')) returns contents of clean_or_dirty as a double
handles.c_or_d_item=str2double(get(handles.clean_or_dirty,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function clean_or_dirty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clean_or_dirty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_value_Callback(hObject, eventdata, handles)
% hObject    handle to temp_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_value as text
%        str2double(get(hObject,'String')) returns contents of temp_value as a double
handles.temp=str2double(get(handles.temp_value,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function temp_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function salinity_value_Callback(hObject, eventdata, handles)
% hObject    handle to salinity_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of salinity_value as text
%        str2double(get(hObject,'String')) returns contents of salinity_value as a double
handles.Sal=str2double(get(handles.salinity_value,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function salinity_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to salinity_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c_value_Callback(hObject, eventdata, handles)
% hObject    handle to c_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c_value as text
%        str2double(get(hObject,'String')) returns contents of c_value as a double
handles.c_speed=str2double(get(handles.c_value,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function c_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function av_depth_value_Callback(hObject, eventdata, handles)
% hObject    handle to av_depth_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of av_depth_value as text
%        str2double(get(hObject,'String')) returns contents of av_depth_value as a double
handles.depth_value=str2double(get(handles.av_depth_value,'String'));
handles.select=handles.flare_in_proc((find(handles.flare_in_proc(:,5)>handles.low_lim...
    & handles.flare_in_proc(:,5)<(handles.low_lim+handles.depth_value))),:);
handles.Depth_mean=abs(mean(handles.select(:,5)));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function av_depth_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to av_depth_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shear_visc_value_Callback(hObject, eventdata, handles)
% hObject    handle to shear_visc_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shear_visc_value as text
%        str2double(get(hObject,'String')) returns contents of shear_visc_value as a double
handles.shear_visc=str2double(get(handles.shear_visc_value,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function shear_visc_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shear_visc_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density_value_Callback(hObject, eventdata, handles)
% hObject    handle to density_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dens=str2double(get(handles.density_value,'String'));
guidata(hObject,handles)
handles.output = hObject;

% Hints: get(hObject,'String') returns contents of density_value as text
%        str2double(get(hObject,'String')) returns contents of density_value as a double


% --- Executes during object creation, after setting all properties.
function density_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function surf_ten_value_Callback(hObject, eventdata, handles)
% hObject    handle to surf_ten_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of surf_ten_value as text
%        str2double(get(hObject,'String')) returns contents of surf_ten_value as a double
handles.surf_ten=str2double(get(handles.surf_ten_value,'String'));
guidata(hObject,handles)
handles.output = hObject;


% --- Executes during object creation, after setting all properties.
function surf_ten_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to surf_ten_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cp_value_Callback(hObject, eventdata, handles)
% hObject    handle to Cp_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cp_value as text
%        str2double(get(hObject,'String')) returns contents of Cp_value as a double
handles.Cp=str2double(get(handles.Cp_value,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function Cp_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cp_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gamma_ratio_Callback(hObject, eventdata, handles)
% hObject    handle to gamma_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gamma_ratio as text
%        str2double(get(hObject,'String')) returns contents of gamma_ratio as a double
handles.gamma=str2double(get(handles.gamma_ratio,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function gamma_ratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Th_conductivity_Callback(hObject, eventdata, handles)
% hObject    handle to Th_conductivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Th_conductivity as text
%        str2double(get(hObject,'String')) returns contents of Th_conductivity as a double
handles.Th_conductivity_value=str2double(get(handles.Th_conductivity,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function Th_conductivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Th_conductivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density_G_Callback(hObject, eventdata, handles)
% hObject    handle to density_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density_G as text
%        str2double(get(hObject,'String')) returns contents of density_G as a double
handles.rho_G=str2double(get(handles.density_G,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function density_G_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BW_value_Callback(hObject, eventdata, handles)
% hObject    handle to BW_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BW_value as text
%        str2double(get(hObject,'String')) returns contents of BW_value as a double
handles.BeamW=str2double(get(handles.BW_value,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function BW_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BW_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P0_Callback(hObject, eventdata, handles)
% hObject    handle to P0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P0 as text
%        str2double(get(hObject,'String')) returns contents of P0 as a double
handles.P0st=str2double(get(handles.P0,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function P0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function g_Callback(hObject, eventdata, handles)
% hObject    handle to g (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of g as text
%        str2double(get(hObject,'String')) returns contents of g as a double
handles.g_value=str2double(get(handles.g,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function g_CreateFcn(hObject, eventdata, handles)
% hObject    handle to g (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freq_Callback(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq as text
%        str2double(get(hObject,'String')) returns contents of freq as a double
handles.freq_value=str2double(get(handles.freq,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_flare.
function plot_flare_Callback(hObject, eventdata, handles)
% hObject    handle to plot_flare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'flare_in_proc')==0
    handles.sentence='...please load and choose a flare';
    set(handles.message,'String',handles.sentence);
else
    figure; 
    handles.uno=10*ones(1,max(size(handles.flare_in_proc(:,1))));
    h=scatter3(handles.flare_in_proc(:,1),handles.flare_in_proc(:,2),handles.flare_in_proc(:,5),handles.uno, handles.flare_in_proc(:,6),'filled');
    colorbar
    xlabel('X(meters)')
    ylabel('Y(meters)')
    zlabel('Depth(m)')
    title('Spatial distribution of scattering (TS values)','Color','Black')
    clear uno
end
guidata(hObject,handles)
handles.output = hObject;


% --- Executes on button press in BSD_poly_fit.
function BSD_poly_fit_Callback(hObject, eventdata, handles)
% hObject    handle to BSD_poly_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'BSD')==0 | handles.BSD==-1 
    handles.sentence='...please load a BSD file!!!';
    set(handles.message,'String',handles.sentence);
elseif handles.Poly_order_value==0
    handles.sentence='...please choose a polynomial order different to 0!!!';
    set(handles.message,'String',handles.sentence);
else
   %cd Fl'areFlowModule Functions'\
    [handles.fun,handles.r]=polynom_fit_BSD(handles.BSD,handles.Poly_order_value);
    handles.BRS_val_models=(buoyvel(handles.r*100,handles.temp,handles.c_or_d_item,...
    handles.sel_BRS,handles.Sal ))/100;
    cd ..
    if (get(handles.checkboxBRS,'Value') == get(handles.checkboxBRS,'Min'))
        handles.ris_speed=handles.BRS_val_models;
    end
end

guidata(hObject,handles)
handles.output = hObject;

function order_value_Callback(hObject, eventdata, handles)
% hObject    handle to order_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of order_value as text
%        str2double(get(hObject,'String')) returns contents of order_value as a double
handles.Poly_order_value=str2double(get(handles.order_value,'String'));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function order_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to order_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cellSnum_Callback(hObject, eventdata, handles)
% hObject    handle to cellSnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cellSnum as text
%        str2double(get(hObject,'String')) returns contents of cellSnum as a double
handles.C_S_num=get(handles.cellSnum,'String');
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function cellSnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellSnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GridLayer.
function GridLayer_Callback(hObject, eventdata, handles)
% hObject    handle to GridLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
if handles.C_S_num==0
    handles.sentence='...please insert cell size!!!';
    set(handles.message,'String',handles.sentence);
elseif handles.S_rad==0
    handles.sentence='...please insert nearneighbor radius!!!';
    set(handles.message,'String',handles.sentence);
elseif handles.C_S_num>=handles.S_rad
    handles.sentence='...please choose a search radius (nearneighbor)greater than the cell size!!!';
    set(handles.message,'String',handles.sentence);
else
    cd Fl'areFlowModule Functions'\
    [handles.J,handles.SigmaV_geoM]=data_gridding(handles.select,handles.C_S_num,handles.S_rad,handles.UTMzone);
    cd ..
handles.sentence='';
set(handles.message,'String',handles.sentence);
end


guidata(hObject,handles)
handles.output = hObject;

function search_rad_Num_Callback(hObject, eventdata, handles)
% hObject    handle to search_rad_Num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of search_rad_Num as text
%        str2double(get(hObject,'String')) returns contents of search_rad_Num as a double
handles.S_rad=get(handles.search_rad_Num,'String');
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function search_rad_Num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to search_rad_Num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function K_num_Callback(hObject, eventdata, handles)
% hObject    handle to K_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_num as text
%        str2double(get(hObject,'String')) returns contents of K_num as a double

guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function K_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxBRS.
function checkboxBRS_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBRS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxBRS
%handles.check_Value=get(handles.checkboxBRS,'Value');
if (get(handles.checkboxBRS,'Value') == get(handles.checkboxBRS,'Max'))
	handles.ris_speed=handles.BRS_poly_fit;
else
	handles.ris_speed=handles.BRS_val_models;
end
guidata(hObject,handles)
handles.output = hObject;

% --- Executes on button press in Add_BRS.
function Add_BRS_Callback(hObject, eventdata, handles)
% hObject    handle to Add_BRS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BRS2=BRS_selection();
if handles.BRS2==-1
    handles.sentence='...no selected BRS file';
    set(handles.message,'String',handles.sentence);
end

guidata(hObject,handles)
handles.output = hObject;

% --- Executes on button press in BRS_poly_fit.
function BRS_poly_fit_Callback(hObject, eventdata, handles)
% hObject    handle to BRS_poly_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'BRS2')==0 | handles.BRS2==-1
    handles.sentence='...please select BRS file!!!';
    set(handles.message,'String',handles.sentence);
elseif handles.Poly_order_BRS==0
    handles.sentence='...please choose a polynomial order different to 0!!!';
    set(handles.message,'String',handles.sentence);
elseif isfield(handles,'r')==0
    handles.sentence='...please make the polynomial fit of the BSD first!!!';
    set(handles.message,'String',handles.sentence);
else
    handles.BRS_poly_fit=polynom_fit_BRS(handles.BRS2,handles.Poly_order_BRS,handles.r);
    handles.sentence='';
    set(handles.message,'String',handles.sentence);
end

if (get(handles.checkboxBRS,'Value') == get(handles.checkboxBRS,'Max'))
	handles.ris_speed=handles.BRS_poly_fit;
end
guidata(hObject,handles)
handles.output = hObject;


function order_BRS_Callback(hObject, eventdata, handles)
% hObject    handle to order_BRS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of order_BRS as text
%        str2double(get(hObject,'String')) returns contents of order_BRS as a double
handles.Poly_order_BRS=str2double(get(handles.order_BRS,'String'));
guidata(hObject,handles)
handles.output = hObject;


% --- Executes during object creation, after setting all properties.
function order_BRS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to order_BRS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function message_Callback(hObject, eventdata, handles)
% hObject    handle to message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of message as text
%        str2double(get(hObject,'String')) returns contents of message as a double


% --- Executes during object creation, after setting all properties.
function message_CreateFcn(hObject, eventdata, handles)
% hObject    handle to message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in max_depth.
function max_depth_Callback(hObject, eventdata, handles)
% hObject    handle to max_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.sentence_max_depth=sprintf('The maximum depth of the selected flare is: %f meters',handles.Max_depth_flare);
set(handles.message,'String',handles.sentence_max_depth);
guidata(hObject,handles)
handles.output = hObject;

function lower_limit_layer_Callback(hObject, eventdata, handles)
% hObject    handle to lower_limit_layer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lower_limit_layer as text
%        str2double(get(hObject,'String')) returns contents of lower_limit_layer as a double
handles.low_lim=str2double(get(handles.lower_limit_layer,'String'));
handles.select=handles.flare_in_proc((find(handles.flare_in_proc(:,5)>handles.low_lim...
    & handles.flare_in_proc(:,5)<(handles.low_lim+handles.depth_value))),:);
handles.Depth_mean=abs(mean(handles.select(:,5)));
guidata(hObject,handles)
handles.output = hObject;

% --- Executes during object creation, after setting all properties.
function lower_limit_layer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lower_limit_layer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in statistic.
function statistic_Callback(hObject, eventdata, handles)
% hObject    handle to statistic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.TSn_points=length(handles.select(:,6));
handles.TSgeomean=10*log10(geomean(10.^(handles.select(:,6)/10)));
handles.TSmean=10*log10(mean(10.^(handles.select(:,6)/10)));
handles.sentence_max_depth=sprintf('Number of points: %d\nGeomean TS: %0.2f dB\nMean TS: %0.2f dB',...
    handles.TSn_points,handles.TSgeomean,handles.TSmean);
set(handles.message,'String',handles.sentence_max_depth);
guidata(hObject,handles)
handles.output = hObject;

% --- Executes on button press in TS_layer_histo.
function TS_layer_histo_Callback(hObject, eventdata, handles)
% hObject    handle to TS_layer_histo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 figure;hist((handles.select(:,6)))
 xlabel('TS (dB)')
 ylabel('Frequency')
 title('Histogram TS values (selected layer)','Color','Black')
% figure;plot(handles.select(:,8),handles.select(:,6),'*')
uno=10*ones(1,size(handles.select,1));
figure;scatter(handles.select(:,8),handles.select(:,6),3*uno,handles.select(:,5),'filled');
xlabel('Ping number')
ylabel('TS (dB)')
hcb=colorbar;
set(get(hcb,'Title'),'String','Depth (m)')
guidata(hObject,handles)
handles.output = hObject;


% --- Executes on button press in min_depth.
function min_depth_Callback(hObject, eventdata, handles)
% hObject    handle to min_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.sentence_min_depth=sprintf('The minimum depth of the selected flare is: %f meters',handles.Min_depth_flare);
set(handles.message,'String',handles.sentence_min_depth);

guidata(hObject,handles)
handles.output = hObject;
