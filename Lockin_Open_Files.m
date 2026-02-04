% Measuring with the Lockin

measurement_folder=  'C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Sample 2\Room T\30V\No GRND\session_20260130_114535_21\session_20260130_114535_21\stream_002';
contact_folder=      'C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Sample 2\Room T\30V\No GRND\session_20260130_114535_21\session_20260130_114535_21\stream_001';
outcontact_folder=   'C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Sample 2\Room T\30V\No GRND\session_20260130_114535_21\session_20260130_114535_21\stream_000';
save_folder ='C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Sample 2\Room T\30V\Measure';


calibration_folder = 'C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Room Temperature\AC\Lockin\session_20260122_175547_09\Calibration 15mV Hot\stream_021\stream_021';
out_calibration_folder = 'C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Room Temperature\AC\Lockin\session_20260122_175547_09\Calibration 15mV Hot\stream_022\stream_022';
cont_calibration_folder = 'C:\Users\hurtadogalle\OneDrive - UCL\Post Doc UCL 2023-2024\Cryo ps-para\Room Temperature\AC\Lockin\session_20260122_175547_09\Calibration 15mV Hot\stream_023\stream_023';

calibration = 0;
retraction=1;
   

frequency=3.123e3;
rserie = 1.087e6;
%rserie = 1e6;
capacitor= 20e-11;
Rg=1e8;
T_tip=61;
T_subs=21;
G0=7.748e-5;
piezo_fact = 35;   % V to nm
DT=T_tip-T_subs;
sgolay_filter = 1;







if calibration==1

    offsets=calculate_offsets(cont_calibration_folder,out_calibration_folder);
    data_total=join_files(calibration_folder);
    g_total=Conductance_AC(data_total,offsets,frequency,rserie,capacitor,sgolay_filter);
    g_dc = cunductancedc(data_total.DC_total,rserie,offsets,sgolay_filter);
    figure
    plot(log10(abs(g_dc)/G0))
    hold on
    plot(log10(abs(g_total)/G0))
    xlim([6.22e5 6.27e5])

else
    offsets=calculate_offsets(contact_folder,outcontact_folder);
    data_total=join_files(measurement_folder);
    g_total=Conductance_AC(data_total,offsets,frequency,rserie,capacitor,sgolay_filter);
    vth_total = thermovoltage_calculator(g_total,data_total,offsets,rserie,Rg,T_tip,T_subs,sgolay_filter);
    [curva_ind,curva_ret] =cut_traces(g_total,vth_total,data_total,piezo_fact,DT);

 if retraction==1
        curva=curva_ret;
        save_filename = ['pspara_RT_Retract_',measurement_folder(end-2:end),'_30V'];

    else
        curva=curva_ind;
        save_filename = 'pspara_RT_Indent';

    end

    save([save_folder '\' save_filename],'curva', '-v7.3')
end

AC_Clustering_UCL_Conductance_V3;
disp('Done')

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

function  Data_struct = join_files(folder_files)
Data_struct=[];
files_measurement = ({dir(fullfile(folder_files,'stream*.mat')).name});

ACX = [];
ACY= [];
DC= [];
Piezo = [];
Time = [];
t_ini=0;

for k1=1:length(files_measurement)
    A0=load([folder_files,'\',files_measurement{k1}]);
    ac_x=A0.dev7613.demods(3).sample.x;
    ac_y=A0.dev7613.demods(3).sample.y;
    dc_ind=A0.dev7613.demods(2).sample.y;
    piezo_ind=A0.dev7613.demods(4).sample.y;
    N=length(ac_x);
    fs=A0.dev7613.demods(3).rate.value;
    t_ind = ((0:N-1) / fs)+t_ini;
    t_ini=t_ind(end)+(t_ind(end)-t_ind(end-1));

    ACX=[ACX; ac_x'];
    ACY=[ACY; ac_y'];
    DC=[DC; dc_ind'];
    Piezo=[Piezo; piezo_ind'];
    Time=[Time; t_ind'];

end
Data_struct.Time_total = Time;
Data_struct.Piezo_total = Piezo;
Data_struct.DC_total = DC;
Data_struct.ACX_total = ACX;
Data_struct.ACY_total = ACY;

end

function g_ac = Conductance_AC(data,offsets,freq,rserie_fun,cse_fun,sgolay_filter)

        G0=7.748e-5;
        acx_total = data.ACX_total;
        acy_total = data.ACY_total;
        smooth_acx = smoothdata(acx_total,'sgolay',sgolay_filter);
        smooth_acy = smoothdata(acy_total,'sgolay',sgolay_filter);
        %smooth_acx = acx_total;
        %smooth_acy = acy_total;
        va=complex(smooth_acx,smooth_acy);
       % zer_real = mean(smooth_acx(smooth_acx<0.59));
       % zer_img = mean(smooth_acy(smooth_acx<0.59));
       % offset_complex = complex(zer_real,zer_img);


        offset_complex = complex(offsets.ACX_out,offsets.ACY_out);

        vac_zer=(va-offset_complex);

        %vac_sat =  mean(vac_zer(smooth_acx>0.9));
        

        vac_sat = complex(offsets.ACX_cont,offsets.ACY_cont)-offset_complex;
        vac_norm=vac_zer./vac_sat;
       

        para= @(x,y) (x.*y)./(x+y);
        freq1=(-1j)/(2*pi*freq*cse_fun);
        zs1=para(rserie_fun,freq1);
        g_ac=real((vac_norm./zs1)./(1.001-vac_norm));

end

  function Vth = thermovoltage_calculator(GAC_total,data_total,offsets,rserie,Rg,T_tip,T_subs,sgolay_filter)
       
        G0=7.75e-5;
        DT = T_tip-T_subs;
        lG_f = smoothdata(GAC_total,'sgolay',sgolay_filter*2);
        %lG_f = GAC_total;
        G = 10.^lG_f;
        Rj = 1./(abs(G*G0));
        dc = data_total.DC_total;             % IN THE LOCKIN WE ARE DIVIDING BY 5

        dc_lowpass = smoothdata(dc,'sgolay',sgolay_filter*4);
        
        %dc_lowpass = dc;
        vv_zer= offsets.DC_out;
        vv_1=dc_lowpass-vv_zer;  % Volts
         Ith=vv_1./Rg;            % Amplifier Resistor  Amps
            
         Isat = (offsets.DC_cont)./Rg;

           %Isat=mean(Ith(c_dc:2*c_dc));  %
            Vof=Isat*rserie;
            Vth = Ith.*(rserie+Rj)-Vof;  % Volts
  end
  function [g_dc] = cunductancedc(traces_dc,rserie_fun,offsets,sgolay_filter)
        G0=7.75e-5;
        dc_filtered = smoothdata(traces_dc,'sgolay',sgolay_filter);
        vdc_zer1=offsets.DC_out;
        vdc_zer=(dc_filtered-vdc_zer1);
        vdc_sat=mean(vdc_zer(vdc_zer>1.4));
        vdc_norm=vdc_zer./vdc_sat;
        g_dc=(vdc_norm./rserie_fun)./(1.001-vdc_norm);
    end



  function [curva_ind,curva_ret] =cut_traces(g_total,vth_total,data_total,fact_piezo,DT)
  G0=7.75e-5;
  piezo = data_total.Piezo_total;
  time = data_total.Time_total;

  [value_top,index_top]  = findpeaks(smooth(piezo),'MinPeakProminence',0.1);
  [value_bot,index_bot]  = findpeaks(smooth(-piezo),'MinPeakProminence',0.1);
curva_ind=[];
curva_ret=[];

for k2=1:length(index_bot)-1

    extra_points = 1e4;
    points_trace=index_top(k2+1)-index_bot(k2);
    if index_bot(k2)>index_top(k2)
        time_trace_ind=time(index_bot(k2):index_top(k2+1));
        piezo_trace_ind=piezo(index_bot(k2):index_top(k2+1));
        g_trace_ind=g_total(index_bot(k2):index_top(k2+1));
        vth_trace_ind=vth_total(index_bot(k2):index_top(k2+1));

        time_trace_ret=time(index_top(k2):index_bot(k2));
        piezo_trace_ret=piezo(index_top(k2):index_bot(k2));
        g_trace_ret=g_total(index_top(k2):index_bot(k2));
        vth_trace_ret=vth_total(index_top(k2):index_bot(k2));
       


    else
        time_trace_ind=time(index_bot(k2):index_top(k2));
        piezo_trace_ind=piezo(index_bot(k2):index_top(k2));
        g_trace_ind=g_total(index_bot(k2):index_top(k2));
        vth_trace_ind=vth_total(index_bot(k2):index_top(k2));

         points_trace_ret=index_bot(k2)-index_top(k2);
        time_trace_ret=time(index_top(k2):index_bot(k2+1));
        piezo_trace_ret=piezo(index_top(k2):index_bot(k2+1));
        g_trace_ret=g_total(index_top(k2):index_bot(k2+1));
        vth_trace_ret=vth_total(index_top(k2):index_bot(k2+1));

      
    end

    log_g_ind=log10(abs(real(g_trace_ind))./G0);

    move_array=piezo_trace_ind(log_g_ind>-0.7 & log_g_ind<-0.1);
    if isempty(move_array)
        move_ind=0;
    else
    move_ind=move_array(1);
    end
    piezo_trace_ind=piezo_trace_ind-move_ind;

%     if index_bot(k2)>index_top(k2)
% k3=k2;
% else
% k3=k2+1;
% end
%     points_trace_ret=index_bot(k2)-index_top(k2);
%     time_trace_ret=time(index_top(k2):index_bot(k3));
%     piezo_trace_ret=piezo(index_top(k2):index_bot(k3);
%     g_trace_ret=g_total(index_top(k2):index_bot(k3));
%     vth_trace_ret=vth_total(index_top(k2):index_bot(k3));

    log_g_ret=log10(abs(real(g_trace_ret))./G0);

    move_array=piezo_trace_ret(log_g_ret>-0.7 & log_g_ret<-0.1);
    if isempty(move_array)
        move_ret=0;
    else
        move_ret=move_array(end);
    end
    piezo_trace_ret=piezo_trace_ret-move_ret;

    curva_ind(k2).g=abs(real(g_trace_ind))./G0;   % Conductance G/G0
    curva_ind(k2).z=piezo_trace_ind*fact_piezo;                     % Distance nm
    curva_ind(k2).piezoV=piezo_trace_ind;         % Distance Volts
    curva_ind(k2).vth=vth_trace_ind;                 % Thermovoltage mV
    curva_ind(k2).Temp=DT;                 % Temperature K

    curva_ret(k2).g=abs(real(g_trace_ret))./G0;   % Conductance G/G0
    curva_ret(k2).z=-piezo_trace_ret*fact_piezo;                     % Distance nm
    curva_ret(k2).piezoV=-piezo_trace_ret;         % Distance Volts
    curva_ret(k2).vth=vth_trace_ret;                 % Thermovoltage mV
    curva_ret(k2).Temp=DT;                 % Temperature K


                   

 %   plot(piezo_trace_ind,log10(abs(g_trace_ind)./G0))
 %  hold on
 %   plot(piezo_trace_ret,log10(abs(g_trace_ret)./G0))

  %  disp('f')

end



  end

