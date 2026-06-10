% Code for open the modulation 
Vb=0.025;                             % Vbias (As appears in the lockin box)
G0=7.748e-5;
modulation = 0;
%num_trace=[9053 21158];            % Number of the traces. First one and Last One
curva=[];
ind=0;
G_tot=[];
Z_tot=[];
Vth_tot =[];
RS = [];
remove=0;
remove_file=0;
remove_top=0;
remove_botom=0;
remove_modulation=0;
div_cut=100;
sgolay_filter = 51;
Rs_calculated = 1.087e6;
Gain_Resistor=1e8;                             % Gain resistance
factor_piezo= 3.02; % volts to nm
divisor_piezo = 0; % Divisor piezo
cse=20e-11;  % 4.3e-11
Temp_tip=-191.96;  % -194.7469 % -191.96
Temp_substrate=-198;
freq=3.123e3;
Pt_resistor_tip = 1090; % PT resistance Ohm
Pt_resistor_substrate = 1090; % PT resistance Ohm
number_traces = [];
%number_traces = length(({dir(fullfile(selpath,'AcX*.csv')).name}));
off_bool = 0; % 0 if automatic, 1 if manual
cal_trace =1;



modulation_path = 'C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Sample 2\77K\8V_4K\Modulations\session_20260220_094520_06_228Ohm\session_20260220_094520_06\stream_002';
offset_contact_path = 'C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Sample 2\77K\8V_4K\Modulations\session_20260220_094520_06_228Ohm\session_20260220_094520_06\stream_001';
offset_out_path = 'C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Sample 2\77K\8V_4K\Modulations\session_20260220_094520_06_228Ohm\session_20260220_094520_06\stream_000';

offsets_struct=calculate_offsets(offset_contact_path,offset_out_path);
files_measurement = ({dir(fullfile(modulation_path,'stream*.mat')).name});
t_ini=0;
times_cut = [1.15 1.35];
k3=2;
PIEZO=[];
ACX=[];
ACY=[];
DC=[];
TIME=[];

for k1=1:length(files_measurement)
    file_path_ind = [modulation_path,'\',files_measurement{k1}];
    A0=load(file_path_ind);
    ac_x_ind=A0.dev7613.demods(3).sample.x;
    ac_y_ind=A0.dev7613.demods(3).sample.y;
    dc_ind=A0.dev7613.demods(2).sample.y;
    piezo_ind=smooth(A0.dev7613.demods(4).sample.y)*factor_piezo;
    N=length(ac_x_ind);
    fs=A0.dev7613.demods(3).rate.value;
    t_ind = ((0:N-1) / fs)+t_ini;
    t_ini=t_ind(end)+(t_ind(end)-t_ind(end-1));

    PIEZO=[PIEZO; piezo_ind];
    TIME=[TIME; t_ind'];
    ACX=[ACX; ac_x_ind'];
    ACY=[ACY; ac_y_ind'];
    DC=[DC; dc_ind'];

end
% g_total=Conductance_AC(ACX,ACY,offsets_struct,freq,Rs_calculated,cse,sgolay_filter);
[value_top,index_top]  = findpeaks(smooth(PIEZO),'MinPeakProminence',2);
[value_bot,index_bot]  = findpeaks(smooth(-PIEZO),'MinPeakProminence',2);

if isempty(index_top)
    disp('No traces')
    return
end
if isempty(index_bot)
    disp('No traces')
    return
end
if index_top(end)>index_bot(end)
    number_peaks = length(index_top)-1;
else
    number_peaks = length(index_top);
end
f1=figure('units','normalized','position',[0.0818 0.1231 0.8600 0.7333]);
ax_g = axes('units','normalized','position',[0.1000 0.4451 0.8000 0.2829]);
ax_vth = axes('units','normalized','position',[0.1000 0.0791 0.8000 0.3395]);
ax_piezo = axes('units','normalized','position',[0.0976 0.7709 0.8000 0.2158]);


for k2=1:number_peaks
    cla(ax_g)
    cla(ax_piezo)
    cla(ax_vth)
    times_modulation_bottom =[];
    times_modulation_top = [];
    g_total=[];
    vth_total=[];
    time_corrected=[];



    if index_top(1)>index_bot(1)
        ac_x_cut = ACX(index_top(k2):index_bot(k2+1));
        ac_y_cut = ACY(index_top(k2):index_bot(k2+1));
        dc_cut = DC(index_top(k2):index_bot(k2+1));
        piezo_cut = PIEZO(index_top(k2):index_bot(k2+1));
        time_cut = TIME(index_top(k2):index_bot(k2+1));

    else
        ac_x_cut = ACX(index_top(k2):index_bot(k2));
        ac_y_cut = ACY(index_top(k2):index_bot(k2));
        dc_cut = DC(index_top(k2):index_bot(k2));
        piezo_cut = PIEZO(index_top(k2):index_bot(k2));
        time_cut = TIME(index_top(k2):index_bot(k2));

    end

    g_total=Conductance_AC(ac_x_cut,ac_y_cut,offsets_struct,freq,Rs_calculated,cse,sgolay_filter);
    g_log_g0 = log10(abs(g_total)/G0);
    DT = Temp_tip-Temp_substrate;
    vth_total = thermovoltage_calculator(g_total,dc_cut,offsets_struct,Rs_calculated,...
         Gain_Resistor,Temp_tip,Temp_substrate,sgolay_filter);
    
    time_move = mean(time_cut(g_log_g0>-0.3 & g_log_g0<0));
    time_corrected = time_cut-time_move;
    
    [value_top_mod,index_top_mod]  = findpeaks(smooth(piezo_cut),'MinPeakProminence',0.08);
    [value_bot_mod,index_bot_mod]  = findpeaks(smooth(-piezo_cut),'MinPeakProminence',0.08);

    modulation_amplitude=(mean(value_top_mod)-mean(-value_bot_mod));

    times_modulation_bottom = time_corrected(index_bot_mod);
    times_modulation_top = time_corrected(index_top_mod);
    if isempty(index_top_mod)
        continue
    end
    if isempty(index_bot_mod)
        continue
    end
    if any(isnan(time_corrected))
        continue
    end

    for i = 1:length(times_modulation_bottom)
        xline(ax_g,times_modulation_bottom(i), '--', 'LineWidth', 0.5,'color',[0 0 0]);
        xline(ax_vth,times_modulation_bottom(i), '--', 'LineWidth', 0.5,'color',[0 0 0]);
        xline(ax_piezo,times_modulation_bottom(i), '--', 'LineWidth', 0.5,'color',[0 0 0]);
        hold(ax_g,'on')
        hold(ax_piezo,'on')
        hold(ax_vth,'on')
    end
    for i = 1:length(times_modulation_bottom)
        xline(ax_g,times_modulation_top(i), '--', 'LineWidth', 0.5,'color',[0.5 0.5 0.5]);
        xline(ax_vth,times_modulation_top(i), '--', 'LineWidth', 0.5,'color',[0.5 0.5 0.5]);
    end
    zero_y=0*linspace(1,200,200);
    zero_x=linspace(time_corrected(index_bot_mod(1)),time_corrected(index_top_mod(end)),200);
    disp(['Trace = ' num2str(k2) '/' num2str(number_peaks)])

    move_piez = piezo_cut(time_corrected>time_corrected(index_bot_mod(1)) & time_corrected<time_corrected(index_top_mod(end)));

    piezo_corr = piezo_cut-(max(move_piez)+min(move_piez))/2;
    
    plot(ax_piezo,time_corrected,smooth(piezo_corr),'color',[0.49 0.18 0.56]);
    
    plot(ax_vth,zero_x,zero_y,'k')

    plot(ax_g,time_corrected,g_log_g0,'b');

    plot(ax_vth,time_corrected,-vth_total*1e6/DT,'r');

    linkaxes([ax_g,ax_vth,ax_piezo],'x')

    xlim(ax_g,[time_corrected(index_bot_mod(1)) time_corrected(index_top_mod(end))]);
    
    legend(ax_g,['Amp mod = ' num2str(modulation_amplitude) ' nm'])

    xlabel(ax_vth,'Time (s)')
    ylabel(ax_piezo,'Piezo (nm)')
    ylabel(ax_g,'log(G/G_0)')
    ylabel(ax_vth,'S (\muV/K)')

    
    disp('f')
end
 disp('f')
% file_path_ind = [modulation_path,'\',files_measurement{k3}];
% struct_indiv=[];
% disp(['Reading' files_measurement{k3} 'file'])
% A0=load(file_path_ind);
% ac_x=A0.dev7613.demods(3).sample.x;
% ac_y=A0.dev7613.demods(3).sample.y;
% dc=A0.dev7613.demods(2).sample.y;
% piezo=smooth(A0.dev7613.demods(4).sample.y);
% figure
% plot(piezo)
% figure
% plot(ac_x)
% 
% N=length(ac_x);
%      fs=A0.dev7613.demods(3).rate.value;
%      t_ind = ((0:N-1) / fs)+t_ini;
% 
% 
%      ac_x_cut = ac_x(t_ind>times_cut(1) & t_ind<times_cut(2));
%      ac_y_cut = ac_y(t_ind>times_cut(1) & t_ind<times_cut(2));
%      dc_cut = dc(t_ind>times_cut(1) & t_ind<times_cut(2));
%      piezo_cut = piezo(t_ind>times_cut(1) & t_ind<times_cut(2));
%      time_cut = t_ind(t_ind>times_cut(1) & t_ind<times_cut(2));
% 
%      g_total=Conductance_AC(ac_x_cut,ac_y_cut,offsets_struct,freq,Rs_calculated,cse,sgolay_filter);
%      g_log_g0 = log10(g_total/G0);
%      piezo_nm = piezo_cut*8.5;
%      DT = Temp_tip-Temp_substrate;
% 
% 
%      vth_total = thermovoltage_calculator(g_total,dc_cut,offsets_struct,Rs_calculated,...
%          Gain_Resistor,Temp_tip,Temp_substrate,sgolay_filter);
% 
%      figure
%      plot(time_cut,log10(g_total/G0))
%      xlim([1.15 1.35])
% 
%      figure
%      plot(time_cut,piezo_nm)
%      xlim([1.15 1.35])
% 
%      figure
%      plot(time_cut,vth_total*1e6/DT)
%      xlim([1.15 1.35])
% 
%       disp('f')




% Functions
function Offsets_struc = calculate_offsets(folder_contact,folder_outcontact)

    Offsets_struc=[];
    files_outcontact = ({dir(fullfile(folder_outcontact,'stream*.mat')).name});
    files_contact = ({dir(fullfile(folder_contact,'stream*.mat')).name});
    
    ACX_outcontact = [];
    ACY_outcontact = [];
    DC_outcontact = [];
    
    for k1=1:length(files_outcontact)
        A0=load([folder_outcontact,'\',files_outcontact{k1}]);
        ac_x=A0.dev7613.demods(3).sample.x;
        ac_y=A0.dev7613.demods(3).sample.y;
        dc_ind=A0.dev7613.demods(2).sample.y;
    
        ACX_outcontact=[ACX_outcontact; ac_x'];
        ACY_outcontact=[ACY_outcontact; ac_y'];
        DC_outcontact=[DC_outcontact; dc_ind'];
    
    
    end
    Offsets_struc.ACX_out = mean(ACX_outcontact);
    Offsets_struc.ACY_out = mean(ACY_outcontact);
    Offsets_struc.DC_out = mean(DC_outcontact);
    
    
    ACX_contact = [];
    ACY_contact = [];
    DC_contact = [];
    
    for k1=1:length(files_contact)
        A0=load([folder_contact,'\',files_contact{k1}]);
        ac_x=A0.dev7613.demods(3).sample.x;
        ac_y=A0.dev7613.demods(3).sample.y;
        dc_ind=A0.dev7613.demods(2).sample.y;
    
        ACX_contact=[ACX_contact; ac_x'];
        ACY_contact=[ACY_contact; ac_y'];
        DC_contact=[DC_contact; dc_ind'];
    
    
    end
    Offsets_struc.ACX_cont = mean(ACX_contact);
    Offsets_struc.ACY_cont = mean(ACY_contact);
    Offsets_struc.DC_cont = mean(DC_contact);
end

function g_ac = Conductance_AC(varargin)

        G0=7.748e-5;

        if length(varargin)==7
            acx = varargin{1};
            acy = varargin{2};
            offsets = varargin{3};
            freq = varargin{4};
            rserie_fun = varargin{5};
            cse_fun = varargin{6};
            sgolay_filter = varargin{7};

            acx_total = acx;
            acy_total = acy;

        else
            data = varargin{1};
            offsets = varargin{2};
            freq = varargin{3};
            rserie_fun = varargin{4};
            cse_fun = varargin{5};
            sgolay_filter = varargin{6};

            acx_total = data.acx;
            acy_total = data.acy;
        end
        smooth_acx = smoothdata(acx_total,'sgolay',sgolay_filter);
        smooth_acy = smoothdata(acy_total,'sgolay',sgolay_filter);
        va=complex(smooth_acx,smooth_acy);

        offset_complex = complex(offsets.ACX_out,offsets.ACY_out);

        vac_zer=(va-offset_complex);


        vac_sat = complex(offsets.ACX_cont,offsets.ACY_cont)-offset_complex;
        vac_norm=vac_zer./vac_sat;
       

        para= @(x,y) (x.*y)./(x+y);
        freq1=(-1j)/(2*pi*freq*cse_fun);
        zs1=para(rserie_fun,freq1);
        g_ac=real((vac_norm./zs1)./(1.001-vac_norm));

  end

  function Vth = thermovoltage_calculator(GAC_total,data_dc,offsets,rserie,Rg,T_tip,T_subs,sgolay_filter)

        G0=7.75e-5;
        DT = T_tip-T_subs;
        %lG_f = smoothdata(GAC_total,'sgolay',sgolay_filter*2);
        lG_f= medfilt1(GAC_total,sgolay_filter*2);
        %lG_f = GAC_total;
        G = lG_f;
        Rj = 1./(abs(G));
        Rj_f= medfilt1(Rj,sgolay_filter*10);
        dc = data_dc;             % IN THE LOCKIN WE ARE DIVIDING BY 5

        dc_lowpass = medfilt1(dc,sgolay_filter*30);
        vv_zer= offsets.DC_out;
        vv_1=dc_lowpass-vv_zer;   % Volts
        Ith=vv_1./Rg;            % Amplifier Resistor  Amps

        Isat = (offsets.DC_cont-vv_zer)./Rg;

        Vof=Isat*rserie;
        Vth = Ith.*(rserie+Rj_f)-Vof;  % Volts
    end

