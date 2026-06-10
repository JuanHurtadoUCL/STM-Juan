% Preliminary code for Kmeans UCLouvain
function AC_clustering_UCL_Conductance_V4(varargin)

len_input=length(varargin);
%[file,path] = uigetfile;
if len_input==0

[file path] = uigetfile({'*.*'},'chose blq or mat', 'MultiSelect','on' );
if isequal(file,0)
    disp('User selected Cancel');
else
    disp(['User selected ', fullfile(path,file)]);
    caminonu=path;
end

factor_dist = 1;
%factor_dist = 12.2067;
%factor_dist = 1.7920;

t=length(file);
curva=[];
if iscell(file)==0
    cura =load([path '\' file]);

    if isfield(cura, 'curva_ini')
        curva_ini=cura.curva_ini;
    else
        curva_ini=cura.curva;
    end

    title_ini=file(1:end-4);
else
    for m=1:t
        curva{m}=[];
        cura =load([path '\' file{m}]);
        if isfield(cura, 'curva_ini')
            curva{m}=cura.curva_ini;
        else
            curva{m}=cura.curva;
        end
      
        length_curva(m)=length(curva{m});
    end
    curva_ini = struct();
    num_curva=0;
    for i = 1:t
        estructuraActual = curva{i};

        
        fields = fieldnames(estructuraActual);
        for k3 = 1:length(estructuraActual)
            num_curva=num_curva+1;
            curva_ini(num_curva).g=estructuraActual(k3).g;
            curva_ini(num_curva).vth=estructuraActual(k3).vth;
            curva_ini(num_curva).z=estructuraActual(k3).z*factor_dist;
            curva_ini(num_curva).Temp = estructuraActual(k3).Temp;
        end
    end
    curva = [];
    title_ini=file{1}(1:end-4);
end

else
    disp('f')
    curva_ini=varargin{1};
    title_ini='No Title';
    path = varargin{2};
end

limits_general1 = [-0.25 2;    % Xlimits
                   1e-5 3;     % Ylimits
                   -1 1;       % Vthlimits
                   -15 15];    % Slimits
checks = [0;  % Check Seebeck
          0;  % Check Mean Trace
          0;  % Check Hist Fit
          0]; % Check GS

sat_ini = 0.003;
pinta_traces(curva_ini,title_ini, path,limits_general1,sat_ini,checks);



function pinta_traces(curva, title1,file_path,limits_general,saturation_value,checks)

fig_general=figure('units','normalized','Position',[0.1167 0.0815 0.7578 0.8000]);
%fig_general = uifigure('units','normalized','Position',[0.1167 0.0815 0.7578 0.8000]);
%grid = uigridlayout(fig_general, [3, 2]); % 3 rows, 2 columns
%grid.RowHeight = {'1x', '1x', '1x'}; % Auto-adjusted
%grid.ColumnWidth = {'1x', '2x'};

%fig_general = uifigure('units','normalized','Position',[0.1167 0.0815 0.7578 0.8000]);
ax_ind=axes(fig_general,'position',[0.2927 0.5146 0.2589 0.4753]);
ax_2d=axes(fig_general,'Position',[0.6277 0.5146 0.2000 0.4753]);
ax_1d=axes(fig_general,'Position',[0.8265 0.5146 0.1500 0.4753]);

ax_ind_vth=axes(fig_general,'position',[0.2927 0.1026 0.2589 0.3644]);
ax_2d_vth=axes(fig_general,'Position',[0.6277 0.1026 0.2000 0.3644]);
ax_1d_vth=axes(fig_general,'Position',[0.8265 0.1026 0.1500 0.3644]);

set(fig_general,'name',title1)


num_traces=length(curva);

xlimit = limits_general(1,:);
ylimit = limits_general(2,:);
vthlimit = limits_general(3,:);
slimit = limits_general(4,:);
ind_trace=[1,2];
num_clust=3;
fontsize=11;
thick=1;
line_width=1;
filter_ord = 1;
filter_type = 'sgolay';
sumt = 0;
sig=0.8;
xx_1d=[];
yy_1d=[];
fit_wf = 0;
ed_negative = 3;

Seebeck_check = checks(1);
Mean_check = checks(2);
Hist_check = checks(3);
GS_bool = checks(4);

sat_2d = saturation_value;
G0_lengt_str = 'G0 = Press G0 button'
wf_lengt_str = 'WF = Press WF checkbox'


individual_plot(ind_trace);
Histogram_plot(curva);

individual_plot_vth(ind_trace);
Histogram_plot_vth(curva);


hp_information = uipanel(fig_general,'position',[0.0102 0.8779 0.1824 0.1143],'BackgroundColor',[0.7 1 0.6]);
tx_g0 = uicontrol('style','Text','parent',hp_information,...
    'units','normalized','position',[0.0500 0.5796 0.9000 0.3978],'String',[G0_lengt_str],'BackgroundColor',[0.7 1 0.6],'TooltipString','Information display');
tx_wf = uicontrol('style','Text','parent',hp_information,...
    'units','normalized','position',[0.0500 0.2361 0.9000 0.4673],'String',[wf_lengt_str],'BackgroundColor',[0.7 1 0.6],'TooltipString','Information display');



hp_movetrace = uipanel(fig_general,'position',[0.0102 0.0258 0.1824 0.1438],'Title','Traces');


edit_numtrace = uicontrol('style','edit','parent',hp_movetrace,...
    'units','normalized','position',[0.0500 0.4624 0.9000 0.2747],...
    'string',num2str(ind_trace),...
    'callback',@e2);
    function e2(~,~)
        ind_trace = str2num(get(edit_numtrace,'string'));
        individual_plot(ind_trace);
        individual_plot_vth(ind_trace);
    end

  uicontrol('style','pushbutton','parent',hp_movetrace,...
        'units','normalized','position',[0.05,0.01,.45,.24],...
        'string','-',...
        'callback',@minus);
    function minus(~,~)
        if ind_trace(1) < 2
            ind_trace = [1 2];
        else
            ind_trace = ind_trace-2;
        end
        set(edit_numtrace,'string',num2str(ind_trace));
        individual_plot(ind_trace)
        individual_plot_vth(ind_trace);
    end

 uicontrol('style','pushbutton','parent',hp_movetrace,...
        'units','normalized','position',[0.5,0.01,.45,.24],...
        'string','+',...
        'callback',@mas);
    function mas(~,~)
        if ind_trace(end) > (length(curva)-1)
            ind_trace = [length(curva)-1   length(curva)];
        else
            ind_trace = ind_trace+2;
        end
        set(edit_numtrace,'string',num2str(ind_trace));
        individual_plot(ind_trace)
        individual_plot_vth(ind_trace);
    end

uicontrol('style','pushbutton','parent',hp_movetrace,...
    'units','normalized','position',[0.05,0.25,.45,.2],...
    'string','Reset',...
    'callback',@res);
    function res(~,~)
        ind_trace = [1, 2];
        set(edit_numtrace,'string',num2str(ind_trace));
        individual_plot(ind_trace)
        individual_plot_vth(ind_trace);
    end

cbx = uicontrol('style','checkbox','parent',hp_movetrace,...
    'units','normalized','position',[0.5060 0.25 0.4455 0.2],'String','Sum Dis','TooltipString','Display the traces with 1nm extra between them',...
    'callback',@checksum);
    function checksum(~,~)
        sumt=cbx.Value;
        individual_plot(ind_trace)
        individual_plot_vth(ind_trace);
    end

text_trace =uicontrol(fig_general,'style','text',...
        'Parent',hp_movetrace,'units','normalized','position',[0.0466 0.7583 0.9000 0.2000],...
        'string',['Number of Traces = ' num2str(length(curva))]);

hp_limits = uipanel(fig_general,'position',[0.0102 0.1721 0.1824 0.1404],'Title','Limits');
text_xlims=uicontrol('parent',hp_limits,'style','text',...
    'units','normalized','position',[0.0206 0.0750 0.4000 0.1900],...
    'string','Zlmits (nm)');
text_ylims=uicontrol('parent',hp_limits,'style','text',...
    'units','normalized','position',[0.0206 0.2894 0.4000 0.1900],...
    'string','Glmits G/G0');
text_vlims=uicontrol('parent',hp_limits,'style','text',...
    'units','normalized','position',[0.0206 0.4994 0.4000 0.1900],...
    'string','Vlmits (mV)');
text_slims=uicontrol('parent',hp_limits,'style','text',...
    'units','normalized','position',[0.0206 0.7117 0.4000 0.1900],...
    'string','Slmits (uV/K)');
edit_slimit = uicontrol('style','edit','parent',hp_limits,...
    'units','normalized','position',[0.4500 0.7117 0.5239 0.1900],...
    'string',num2str(slimit),...
    'callback',@eslim);
    function eslim(~,~)
        slimit = str2num(get(edit_slimit,'string'));
        individual_plot(ind_trace);
        individual_plot_vth(ind_trace);
        Histogram_plot(curva);
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end

edit_vlimit = uicontrol('style','edit','parent',hp_limits,...
    'units','normalized','position',[0.4500 0.4884 0.5239 0.1900],...
    'string',num2str(vthlimit),...
    'callback',@evlim);
    function evlim(~,~)
        vthlimit = str2num(get(edit_vlimit,'string'));
        individual_plot(ind_trace);
        individual_plot_vth(ind_trace);
        Histogram_plot(curva);
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end
edit_xlimit = uicontrol('style','edit','parent',hp_limits,...
    'units','normalized','position',[0.4500 0.0422 0.5239 0.1900],...
    'string',num2str(xlimit),...
    'callback',@exlim);
    function exlim(~,~)
        xlimit = str2num(get(edit_xlimit,'string'));
        individual_plot(ind_trace);
        individual_plot_vth(ind_trace);
        Histogram_plot(curva);
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end
edit_ylimit = uicontrol('style','edit','parent',hp_limits,...
    'units','normalized','position',[0.4500 0.2651 0.5239 0.1900],...
    'string',num2str(ylimit),...
    'callback',@eylim);
    function eylim(~,~)
        ylimit = str2num(get(edit_ylimit,'string'));
        individual_plot(ind_trace);
        individual_plot_vth(ind_trace);
        Histogram_plot(curva);
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end


hp_cluster = uipanel(fig_general,'position',[0.0102 0.3119 0.1824 0.0890],'Title','Clusters');
edit_numClust = uicontrol('style','edit','parent',hp_cluster,...
    'units','normalized','position',[0.4679 0.0278 0.5000 0.4000],'TooltipString','Number of clusters',...
    'string',num2str(num_clust),...
    'callback',@enumclust);
    function enumclust(~,~)
        num_clust = str2num(get(edit_numClust,'string'));
    end
text_method = uicontrol('style','text','parent',hp_cluster,...
    'units','normalized','position',[0.0846 0.4634 0.3197 0.4000],...
    'string','Method');
pop_clust = uicontrol('style','popup','parent',hp_cluster,...
    'units','normalized','position',[0.4679 0.6157 0.5000 0.4000],...
    'string',{'1D Histogram';'1D-2D Histogram'; '2D Histogram';'Lorentzian';'Z-S';'S-G';'Plateau Fit';'Centre Trace'},'Value',2)
buton_clust=uicontrol('style','pushbutton','parent',hp_cluster,...
    'units','normalized','position',[0.0345 0.0833 0.4161 0.3858],...
    'string','Do Clusters',...
    'callback',@cluster);
    function cluster(~,~)
        disp('Starting Clustering. Wait a few seconds');
        figna = get(gcf,'name');
        clust_type = pop_clust.Value;
        mart=[];
        switch clust_type
            case 1  % 1D Histogram
                ma = histoM(curva);
                mart=[ma'];
            case 2  % 1D-2D Histogram
                ma2 = histo2M(curva);
                ma = histoM(curva);
                sz = size(ma2);
                M = reshape(ma2,sz(1)*sz(2),sz(3));
                mart=[ma';M];
            case 3  % 2D Histogram
                ma2 = histo2M(curva);
                sz = size(ma2);
                M = reshape(ma2,sz(1)*sz(2),sz(3));
                mart=[M];
            case 4  % Lorentzian
                mL=histoL(curva);
                mart=[mL'];
                disp('Finished')
            case 5  % Z-S
                ma2 = histo2S(curva);
                ma = histoS(curva);
                sz = size(ma2);
                M = reshape(ma2,sz(1)*sz(2),sz(3));
                mart=[ma';M];
            case 6  % S-G
                ma2 = histo2SG(curva);
                ma = histoS(curva);
                sz = size(ma2);
                M = reshape(ma2,sz(1)*sz(2),sz(3));
                mart=[ma';M];
            case 7  % Plateau Fit
                ma2 = histoDer(curva);
                sz = size(ma2);
                M = reshape(ma2,sz(1)*sz(2),sz(3));
                mart=[M];
            case 8 % Trace centre
                if length(ind_trace)==1

                    ma2 = histo2M(curva);
                    ma = histoM(curva);
                    sz = size(ma2);
                    M = reshape(ma2,sz(1)*sz(2),sz(3));
                    mart=[ma';M];
                    mart = mart-mart(:,ind_trace);


                else
                    disp('Put just one trace on the plotter')
                    return
                end


        end

        [icx,C,sumd,D]= doclusters(mart',num_clust);
        limits_general_clus = [xlimit(1) xlimit(2);
                              ylimit(1) ylimit(2)
                              vthlimit(1) vthlimit(2)
                              slimit(1) slimit(2)];
        
        checks_clust = [Seebeck_check;
                        Mean_check;
                        Hist_check;
                        GS_bool];

        for k=1:num_clust
            curk = curva(icx==k);
            nuk = length(curk);
            pinta_traces(curk,[figna ' Clust' num2str(k)],file_path,limits_general_clus,sat_2d,checks_clust)
           
        end
    end
hp_save = uipanel(fig_general,'position',[0.0102 0.4016 0.1824 0.0639]);

buton_save=uicontrol('style','pushbutton','parent',hp_save,...
    'units','normalized','position',[0.0209 0.0739 0.2161 0.8300],...
    'string','Save','TooltipString','Save .mat file in the same directory',...
    'callback',@save_mat);
    function save_mat(~,~)
        buton_save.BackgroundColor = [1 0 0];
        buton_save.String = 'Wait...';
        save([file_path '\' title1 '_Cluster'],'curva', '-v7.3');
         buton_save.BackgroundColor = [0.9400    0.9400    0.9400];
         buton_save.String = 'Save';
        disp('File saved');
    end

edit_sigma = uicontrol('style','edit','parent',hp_save,...
    'units','normalized','position',[0.2505 0.0639 0.2337 0.4400],'TooltipString','Width of the gaussian distribution for the 2D Histogram',...
    'string',num2str(sig),...
    'callback',@sigma_edit);
    function sigma_edit(~,~)
        sig = str2num(get(edit_sigma,'string'));
        Histogram_plot(curva)
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end
text_sigma = uicontrol('style','text','parent',hp_save,...
    'units','normalized','position',[0.2325 0.5896 0.2663 0.3279],...
    'string','Sigma');

buton_fitpeak = uicontrol('style','pushbutton','parent',hp_save,...
    'units','normalized','position',[0.5006 0.0739 0.2068 0.8300],'TooltipString','Fit gaussian to the main conductance peak',...
    'string','Fit',...
    'callback',@fitpeak);
    function fitpeak(~,~)
        cuts = [-5, -1.5];
        xx_cut = xx_1d(xx_1d> cuts(1) & xx_1d<cuts(2));
        yy_cut = yy_1d(xx_1d> cuts(1) & xx_1d<cuts(2));

        f24 = fit(xx_cut.',yy_cut.','gauss1');
        xxlen=linspace(-6,-2,100);
        yff =  f24.a1*exp(-((xxlen-f24.b1)/f24.c1).^2);
        hold(ax_1d,'on')
        plot(ax_1d,yff,xxlen,'--r');

        g_min = f24.b1-f24.c1;
        g_max = f24.b1+f24.c1;
        N_plat = 100;
        G_P_Mean=[];
        Z_P_Mean=[];
        V_P_Mean=[];
        S_P_Mean=[];
        plateau_length=zeros(1,length(curva));
        indf=0;
        for k3 = 1:length(curva)
            zz=curva(k3).z;
            gg=curva(k3).g;
            vv = smoothdata(curva(k3).vth*1e3,filter_type,filter_ord);
            Temp = curva(k3).Temp;
            % VV_cut =  -VV_cut.*1e3./curva(1).Temp
            lg=log10(abs(gg));
            %g_max=0;
            zz_cut = zz(lg>g_min & lg<g_max);
            gg_cut = lg(lg>g_min  & lg<g_max);
            vv_cut = vv(lg>g_min  & lg<g_max);

            z_plat_mean1 = linspace(min(zz_cut),max(zz_cut),N_plat);
            if min(zz_cut)>0.2
                continue
            end

            for j1 =1:N_plat-1
                z_low =z_plat_mean1(j1);
                z_high =z_plat_mean1(j1+1);
                g_plat_mean(j1) = mean(gg_cut(zz_cut>z_low & zz_cut<z_high));
                vv_plat_mean(j1) = mean(vv_cut(zz_cut>z_low & zz_cut<z_high));
                ss_plat_mean(j1) = (-mean(vv_cut(zz_cut>z_low & zz_cut<z_high)).*1e3)./Temp;
                %ss_plat_std(j1) = (-std(vv_cut(zz_cut>z_low & zz_cut<z_high)).*1e3)./Temp;
                z_plat_mean = (z_plat_mean1(2:end)+z_plat_mean1(1:end-1))./2;

            end
            if isnan(mean(g_plat_mean))

            else
                G_P_Mean  = [G_P_Mean; g_plat_mean];
                Z_P_Mean  = [Z_P_Mean; z_plat_mean];
                V_P_Mean=[V_P_Mean; vv_plat_mean];
                S_P_Mean=[S_P_Mean; ss_plat_mean];
                indf=indf+1;
                plateau_length(indf)= max(zz_cut);
            end

        end
        fin_g_mean = mean(G_P_Mean);
        fin_z_mean = mean(Z_P_Mean);
        fin_v_mean = mean(V_P_Mean);
        fin_s_mean = mean(S_P_Mean);
        fin_s_std = std(S_P_Mean);
        fin_g_std = std(G_P_Mean);
        p1 = polyfit(fin_z_mean,fin_g_mean,1);
        f2 = polyval(p1,fin_z_mean);
        
        

        hold(ax_2d,'on')

        plot(ax_2d,fin_z_mean,fin_g_mean,'k','linewidth',1.5);
        plot(ax_2d,fin_z_mean,f2,'.r','linewidth',2);
        plateau_length(isnan(plateau_length)) = [];
        mean_plateau_length = mean(plateau_length>0.05);
        disp(['Mean conductance = ' num2str(f24.b1) '+' num2str(f24.c1) ' G0']);
        disp(['Mean length  = ' num2str(max(fin_z_mean)) ' nm']);
        text(ax_2d,'units','normalized','position',[0.35 0.8],'string',['Mean length  = ' num2str(round(max(fin_z_mean),2)) ' nm'],'fontsize',7);
        text(ax_2d,'units','normalized','position',[0.28 0.75],'string',['Mean conductance = ' num2str(round(f24.b1,1)) ' G0'],'fontsize',7);
        text(ax_2d,'units','normalized','position',[0.4 0.7],'string',['Slope = ' num2str(round(p1(1),1)) ' nm-1'],'fontsize',7);
        if Seebeck_check==0
            hold(ax_2d_vth,'on');
            plot(ax_2d_vth,fin_z_mean,fin_v_mean,'k','linewidth',1.5);
            figure
            plot(fin_v_mean,fin_g_mean);
        else
            hold(ax_2d_vth,'on');
            plot(ax_2d_vth,fin_z_mean,fin_s_mean,'k','linewidth',1.5);
            f4=figure('units','normalized','position',[0.2635 0.0787 0.4865 0.7889]);
            ax1_m = axes(f4,'units','normalized','position',[0.107 0.0871 0.8000 0.4000]);
            ax2_m = axes(f4,'units','normalized','position',[0.107 0.5730 0.8000 0.4000]);
            errorbar(ax1_m,fin_z_mean,fin_s_mean,fin_s_std,'o');
            ylabel(ax1_m,'Seebeck (\muV/K)')
            
            errorbar(ax2_m,fin_z_mean,fin_g_mean,fin_g_std,'o');
            ylabel(ax2_m,'log(G/G_0)')
        end
    end

buton_fitpeak = uicontrol('style','pushbutton','parent',hp_save,...
    'units','normalized','position',[0.7106 0.0739 0.2068 0.8300],'TooltipString','Fit the G0 plateau extracting the length and the factor with 0.25 nm',...
    'string','G0',...
    'callback',@g0length);
    function g0length(~,~)
        cut_g0 = [log10(0.2) log10(1.1)];
        cut_z = -3;
        plateau_g0=[];
        lengths=[];
        %fg0=figure;
        % 10^0.15 = 1.4125   % 10^0.25 Cambio Juan
             % 10^-0.15 = 0.7079  10^-0.25 Cambio Juan it is different than previously defined (3e-1) but makes effectively no difference
        zz_g0=[];
        gg_g0=[];
        for k3 = 1:length(curva)
            zz=curva(k3).z;
            gg=(curva(k3).g);
            zz_dis1=zz(gg>0.5 & gg<3);
            gg_dis1=gg(gg>0.5 & gg<3);
            zz_g0=[zz_g0; zz_dis1];
            gg_g0=[ gg_g0; gg_dis1];

        end
        fg0=figure;
        %plateau_g0f = plateau_g0(plateau_g0<0.15);
       [Ng0,edgeg0]= histcounts(gg_g0,100);
       xxg0=(edgeg0(1:end-1)+edgeg0(2:end))/2;
       Nfit=Ng0(xxg0>0.8 & xxg0<1.1);
       xxfit=xxg0(xxg0>0.8 & xxg0<1.1);
       f = fit(xxfit.',Nfit.','gauss1');
       plot(xxg0,Ng0)
       hold on
       plot(f)
       plot(f.b1,f.a1,'r+')
       plot(f.b1+f.c1,f.a1/2,'b+')
       plot(f.b1-f.c1,f.a1/2,'b+')

       g_low=f.b1-f.c1;
       g_high=f.b1+f.c1;
       f3=figure('units','normalized','position',[0.2312 0.2630 0.6672 0.5185]);
       ax_g0 = axes(f3,'units','normalized','position',[0.0813 0.1339 0.4000 0.8000]);
       ax_g0_length = axes(f3,'units','normalized','position',[0.55 0.1339 0.4000 0.8000]);
       
G0_plateau = [];
        for k3 = 1:length(curva)
            zz=curva(k3).z;
            gg=(curva(k3).g);
            zz_g0_cut = zz(gg>g_low & gg<g_high);
            gg_g0_cut = gg(gg>g_low & gg<g_high);

          
           if isempty(zz_g0_cut)
                continue

            end
            if zz_g0_cut(1)<-1
                continue
            end
          
            length_g0=zz_g0_cut(end)-zz_g0_cut(1);
            cond_g0=gg_g0_cut(end);

             if length_g0<0.02
                continue
            end
          

            G0_plateau=[G0_plateau; length_g0];

             plot(ax_g0,zz_g0_cut,gg_g0_cut)
            hold (ax_g0,'on')


            plot(ax_g0_length,length_g0,cond_g0,'+')
            hold(ax_g0_length,'on')
           

        end
        [Ng0_fin,edgeg0_fin]= histcounts(G0_plateau,60);
       xxg0=(edgeg0_fin(1:end-1)+edgeg0_fin(2:end))/2;
       figure
       plot(xxg0,Ng0_fin)
       med_plateauG0=median(G0_plateau);
       disp('f')
        
        
       
        %tx_g0 = uicontrol('style','Text','parent',hp_information,...
        %    'units','normalized','position',[0.05,0.71,.9,.2],'String',[G0_lengt_str]);

    end
hp_select = uipanel(fig_general,'position',[0.0102 0.4654 0.1824 0.0500]);

chk_fit = uicontrol('style','checkbox','parent',hp_select,...
    'units','normalized','position',[0.5 0.0739 0.4 0.9],'TooltipString','Fit the slope of the tunnelling regime',...
    'string','Fit WF','Value',0,'callback',@check_wf)
    function check_wf(~,~)
        
        fit_wf = chk_fit.Value;
        individual_plot(ind_trace)
        

    end

buton_selec = uicontrol('style','pushbutton','parent',hp_select,...
    'units','normalized','position',[0.01 0.0739 0.4 0.9],...
    'string','Select',...
    'callback',@traceselect);
    function traceselect(~,~)
        prompt = 'Input all the traces that you want to select';
        sel_trace = input(prompt);
        curk = curva(sel_trace);
        nuk = length(curk);
        figna = get(gcf,'name');
         limits_general_clus = [xlimit(1) xlimit(2);
                              ylimit(1) ylimit(2)
                              vthlimit(1) vthlimit(2)
                              slimit(1) slimit(2)];
        
         checks_clust = [Seebeck_check;
                        Mean_check;
                        Hist_check;
                        GS_bool];
        
         pinta_traces(curk, figna,file_path,limits_general_clus,sat_2d,checks_clust);
        

    end



hp_smooth = uipanel(fig_general,'position',[0.0102 0.5169 0.1824 0.1145]);

sgolay_edit = uicontrol('style','edit','parent',hp_smooth,...
    'units','normalized','position',[0.4862 0.0423 0.4991 0.2777],...
    'string',num2str(filter_ord),'value',filter_ord,...
    'callback',@edit_sgol);
    function edit_sgol(~,~)
       filter_ord = str2num(get(sgolay_edit,'string'));
       individual_plot_vth(ind_trace);  
       individual_plot(ind_trace);
       if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end

pop_filt = uicontrol('style','popup','parent',hp_smooth,...
    'units','normalized','position',[0.0292 0.1897 0.4000 0.1618],...
    'string',{'sgolay';'movmean'; 'movmedian';'rloess'},'Value',1,'callback',@filt_fun)
    function filt_fun(~,~)
        filter_type = pop_filt.String{pop_filt.Value};
    end

seebeck_fit = uicontrol('style','checkbox','parent',hp_smooth,...
    'units','normalized','position',[0.0407 0.3884 0.4000 0.23],'TooltipString','Display Seebeck coefficient values',...
    'string','Seebeck','Value',0,'callback',@check_seeb)
    function check_seeb(~,~)
        Seebeck_check = seebeck_fit.Value;
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end

gs_check = uicontrol('style','checkbox','parent',hp_smooth,...
    'units','normalized','position',[0.0407 0.7 0.4000 0.23],'TooltipString','Display Seebeck coefficient values',...
    'string','GS Plot','Value',0,'callback',@check_gs)
    function check_gs(~,~)
        GS_bool = gs_check.Value;
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end

mean_fit = uicontrol('style','checkbox','parent',hp_smooth,...
    'units','normalized','position',[0.5 0.3884 0.4600 0.23],'TooltipString','Display mean trace of thermovoltage values',...
    'string','Mean Trace','Value',0,'callback',@check_mean)
    function check_mean(~,~)
        Mean_check = mean_fit.Value;    
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end
hist_fit = uicontrol('style','checkbox','parent',hp_smooth,...
    'units','normalized','position',[0.5 0.7 0.4600 0.23],'TooltipString','Display mean trace of thermovoltage values',...
    'string','Hist Fit','Value',0,'callback',@check_hist)
    function check_hist(~,~)
        Hist_check = hist_fit.Value;    
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
    end

hp_select = uipanel(fig_general,'position',[0.0102 0.6322 0.1824 0.1145]);

edit_negative  = uicontrol('style','edit','Parent',hp_select,'units','normalized','Position',[0.3 0.0500 0.2 0.3000],...
    'String',num2str(ed_negative),'Callback',@edfun_negative);
    function edfun_negative(~,~)
        ed_negative = str2num(get(edit_negative,'string'));
    end
but_neg_traces = uicontrol('style','pushbutton','Parent',hp_select,'units','normalized','Position',[0.017 0.0500 0.2782 0.3000],...
    'String','Neg.Traces','Callback',@button_negative);
    function button_negative(~,~)
        

        for k3=1:length(curva)
            zz=curva(k3).z;
            gg=curva(k3).g;
            vv = smoothdata(curva(k3).vth*1e3,filter_type,filter_ord);
            Temp = curva(k3).Temp;
              dp = diff(smooth(zz ));
            dp_zer = dp-min(dp);
            dp_norm = dp_zer/max(dp_zer);
            zz_stop = zz(dp_norm==0);
            distance_threshold(k3)=zz_stop(1);

            lg=log10(abs(gg));
            zz_cut = zz(lg>-4.5 & lg<-3);
            gg_cut = lg(lg>-4.5  & lg<-3);
            vv_cut = vv(lg>-4.5  & lg<-3);
            ss_cut = -vv_cut.*1e3/Temp;
            seeb_num = mean(ss_cut);
            neg_num = length(ss_cut<0);
            if seeb_num<ed_negative
                indice_neg(k3)=1;
            else
                indice_neg(k3)=0;
            end
           % disp('d')

        end
        clean_thres=distance_threshold(distance_threshold>-0.9 & distance_threshold<0.9);
        curva_neg = curva(indice_neg==1);
        curva_pos = curva(indice_neg==0);
        figna = get(gcf,'name');
        limits_general_clus = [xlimit(1) xlimit(2);
            ylimit(1) ylimit(2)
            vthlimit(1) vthlimit(2)
            slimit(1) slimit(2)];

        checks_clust = [Seebeck_check;
            Mean_check;
            Hist_check;
            GS_bool];
        pinta_traces(curva_neg, [figna '_Neg'],file_path,limits_general_clus,sat_2d,checks_clust);
        pinta_traces(curva_pos, [figna '_Pos'],file_path,limits_general_clus,sat_2d,checks_clust);
    end

but_long_traces = uicontrol('style','pushbutton','Parent',hp_select,'units','normalized','Position',[0.52 0.05 0.22 0.3],...
    'String','Long.Traces','Callback',@button_long);
    function button_long(~,~)
        ZZ_length_indiv=[];
        SS_indiv=[];

        for k3=1:length(curva)
            zz=curva(k3).z;
            gg=curva(k3).g;
            vv = smoothdata(curva(k3).vth*1e3,filter_type,filter_ord);
            Temp = curva(k3).Temp;

            lg=log10(abs(gg));
            zz_cut = zz(lg>-4.5 & lg<-3);
            gg_cut = lg(lg>-4.5  & lg<-3);
            vv_cut = vv(lg>-4.5  & lg<-3);
            ss_cut = -vv_cut.*1e3/Temp;
            seeb_num = mean(ss_cut);
            DZ = zz_cut(end)-zz_cut(1);
            

            if DZ<3
                indice_neg(k3)=1.0;
                ZZ_length_indiv=[ZZ_length_indiv; DZ];
            SS_indiv=[SS_indiv; mean(seeb_num)];
            else
                indice_neg(k3)=0;
            end
           % disp('d')

        end

        figure
        plot(ZZ_length_indiv,SS_indiv,'ro')
        curva_neg = curva(indice_neg==1);
        curva_pos = curva(indice_neg==0);
        figna = get(gcf,'name');
        limits_general_clus = [xlimit(1) xlimit(2);
            ylimit(1) ylimit(2)
            vthlimit(1) vthlimit(2)
            slimit(1) slimit(2)];

        checks_clust = [Seebeck_check;
            Mean_check;
            Hist_check;
            GS_bool];
        pinta_traces(curva_neg, [figna '_Long'],file_path,limits_general_clus,sat_2d,checks_clust);
        pinta_traces(curva_pos, [figna '_Short'],file_path,limits_general_clus,sat_2d,checks_clust);
    end

but_mean_G = uicontrol('style','pushbutton','Parent',hp_select,'units','normalized','Position',[0.75 0.05 0.22 0.3],...
    'String','MeanGZ','Callback',@button_meanGZ);
    function button_meanGZ(~,~)
        GG = [];
        ZZ = [];
        for k1=1:length(curva)
            zz=curva(k1).z;
            gg=abs((curva(k1).g));
            zz_cut1 = zz(zz>xlimit(1) & zz<xlimit(2));
            gg_cut1 = gg(zz>xlimit(1) & zz<xlimit(2));
            zz_cut = zz_cut1(gg_cut1>ylimit(1) & gg_cut1<ylimit(2));
            gg_cut = gg_cut1(gg_cut1>ylimit(1) & gg_cut1<ylimit(2));
            GG=[GG; log10(gg_cut)];
            ZZ =[ZZ; zz_cut];
        end
        N_pts = 150;
        z_fake = linspace(xlimit(1),xlimit(2),N_pts);

        for k2 = 1:N_pts-1
           g_mean(k2)= mean(GG(ZZ>z_fake(k2) & ZZ<z_fake(k2+1)));
           z_mean(k2)= mean(ZZ(ZZ>z_fake(k2) & ZZ<z_fake(k2+1)));
        end
        plot(ax_2d,z_mean,g_mean,'k','linewidth',1);

    end

tx_sat = uicontrol('style','text','units','normalized','Parent',hp_select,'position',...
    [0.7824 0.3579 0.2000 0.4000],'String',num2str(sat_2d));

slide_2d = uicontrol('style','slider','units','normalized','Parent',hp_select,'position',...
    [0.0170 0.5316 0.7500 0.2764],'Min',0.001,'Max', 0.03, 'Value', 0.003,'TooltipString','Change the saturation level of the 2D Histogram', ...
    'callback',@slidemove);
    function slidemove(~,~)
        %disp('f')
        sat_2d = slide_2d.Value;
        Histogram_plot(curva)
        if GS_bool==1
            Histogram_plot_GS(curva)
        else
            individual_plot_vth(ind_trace)
            Histogram_plot_vth(curva)
        end
        tx_sat.String = num2str(round(100*sat_2d,3));
    end

hp_linear = uipanel(fig_general,'position',[0.0102 0.7500 0.1824 0.0399]);
but_linear = uicontrol('style','pushbutton','Parent',hp_linear,'units','normalized','Position',[0.0170 0.1516 0.3859 0.7355],...
    'String','Lineal Plot','Callback',@button_linear);
    function button_linear(~,~)
        glin_lim = 5;
        G_lin = [];
        Z_lin = [];
        for k3 = 1:length(curva)
            zz=curva(k3).z;
            gg=(curva(k3).g);
            z_cut1 = zz(zz>xlimit(1) & zz<xlimit(2)); % & gg<glin_lim);
            g_cut1 = gg(zz>xlimit(1) & zz<xlimit(2)); % & gg<glin_lim);
            z_cut = z_cut1(g_cut1<glin_lim);
            g_cut = g_cut1(g_cut1<glin_lim);

            G_lin=[G_lin; g_cut];
            Z_lin=[Z_lin; z_cut];
        end

        f_lin = figure;
        ax_lin = axes(f_lin);
        eje0=[xlimit(1)+0.05,xlimit(2)-0.05,0.05,glin_lim-0.05];
        nhi20=30;
        %f1=figure
        namess{1}='2D';
        axesLabel={'Displacement (nm)','G/G_0'};
        Hist2D(ax_lin,Z_lin,G_lin,eje0,sig+0.3,nhi20,namess,axesLabel,sat_2d);
        xlim(ax_lin,[xlimit]);
        ylim(ax_lin,[0 glin_lim]);

    end

        % Functions

    function Histogram_plot_GS(curva_hist)
XX=[];
YY=[];
VV=[];
ZF=[];
cla(ax_2d_vth);
colorbar('off')
%cla(cb)

for k3=1:length(curva_hist)
    xx=curva_hist(k3).z;
    yy=log10((curva_hist(k3).g));
    vv = smoothdata(curva_hist(k3).vth*1e3,filter_type,filter_ord);
    if size(xx) == size(yy)
        XX=[XX; xx];
        YY=[YY; yy];
        VV=[VV; vv];
    end
end

YY_cut = real(YY(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));
XX_cut = real(XX(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));
VV_cut = real(VV(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));
if Seebeck_check ==0

    eje0=[log10(ylimit(1))+0.02,log10(ylimit(2))-0.02,vthlimit(1)+0.01,vthlimit(2)-0.01];
    nhi20=30;
    %f1=figure
    namess{1}='2D';
    axesLabel={'log({\itG}/{\itG_0})','{\itS} (\muV/K)'};
    Hist2D(ax_2d_vth,YY_cut,VV_cut,eje0,sig+0.8,nhi20,namess,axesLabel,sat_2d);
    hold(ax_2d_vth,'on')
    cb = colorbar('SouthOutside');
    cb.Position = [0.6964 0.9123 0.1235 0.0221];
    cb.LineWidth = 1;
    cb.Limits = [0 sat_2d*1600];
    cb.TickLabels = [];

    xlim(ax_2d_vth,log10(ylimit));
    ylim(ax_2d_vth,vthlimit);

    if Mean_check==1
        N = 500;
        dist_array = linspace(log10(ylimit(1)),log10(ylimit(2)),N);
        %zer_arr = zeros(1,N-1);

        for m1 = 1:N-1
            mean_arr(m1) = mean(VV_cut(YY_cut>dist_array(m1) & YY_cut<dist_array(m1+1)));
            std_arr(m1) = std(VV_cut(YY_cut>dist_array(m1) & YY_cut<dist_array(m1+1)));
        end
        dist_mean=(dist_array(1:end-1)+dist_array(2:end))./2;
        plot(ax_2d_vth, dist_mean,mean_arr,'linewidth',1.2,'color','k')
        % plot(ax_2d_vth, dist_mean,zer_arr,'--','linewidth',1,'color','k')

    end

    cla(ax_1d_vth);
    yyvt = real(VV(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));% & YY>log10(ylimit(1)) & YY<log10(ylimit(2))));
    [N,edges] = histcounts(yyvt(:),100);%, 'Normalization', 'pdf');
    xx5=(edges(1:end-1)+edges(2:end))/2;
    plot(ax_1d_vth,N,xx5,'linewidth',line_width);
    %yy_1d = N;
    %xx_1d = xx5;
    ylim(ax_1d_vth, [vthlimit(1), vthlimit(2)]);
    xticklabels(ax_1d_vth,[]);
    yticklabels(ax_1d_vth,[]);
    xlabel(ax_1d_vth,'Counts (a.u.)');
    set(ax_1d_vth,'Fontsize',fontsize,'linewidth',thick);
    set(ax_2d_vth,'Fontsize',fontsize,'linewidth',thick);

    if Hist_check ==1
        f = fit(xx5.',N.','gauss1');
        gaussy= f.a1.*exp(-((xx5-f.b1)./f.c1).^2);
        hold(ax_1d_vth,'on')
        plot(ax_1d_vth,gaussy,xx5,'r--','linewidth',1)
        tx_pl = text(ax_1d_vth,'units','normalized','position',[0.3394 0.9070 0],'String',['V_{th} = ' num2str(round(f.b1,2)) ' mV'])
        %disp('f')
    end

else
    VV_cut =  -VV_cut.*1e3./curva(1).Temp;
    eje0=[log10(ylimit(1))+0.02,log10(ylimit(2))-0.02,slimit(1)+0.5,slimit(2)-0.5];
    nhi20=30;

    %f1=figure
    namess{1}='2D';
    axesLabel={'log({\itG}/{\itG_0})','{\itS} (\muV/K)'};
    Hist2D(ax_2d_vth,YY_cut,VV_cut,eje0,sig+0.8,nhi20,namess,axesLabel,sat_2d);
    hold(ax_2d_vth,'on')
    cb = colorbar('SouthOutside');
    cb.Position = [0.6964 0.9123 0.1235 0.0221];
    cb.LineWidth = 1;
    cb.Limits = [0 sat_2d*1600];
    cb.TickLabels = [];

    xlim(ax_2d_vth,log10(ylimit));
    ylim(ax_2d_vth,slimit);

    if Mean_check==1
        N = 500;
        dist_array = linspace(log10(ylimit(1)),log10(ylimit(2)),N);
        %zer_arr = zeros(1,N-1);

        for m1 = 1:N-1
            mean_arr(m1) = mean(VV_cut(YY_cut>dist_array(m1) & YY_cut<dist_array(m1+1)));
            std_arr(m1) = std(VV_cut(YY_cut>dist_array(m1) & YY_cut<dist_array(m1+1)));
        end
        dist_mean=(dist_array(1:end-1)+dist_array(2:end))./2;
        plot(ax_2d_vth, dist_mean,mean_arr,'linewidth',1.2,'color','k')
        dist_cut = dist_mean(dist_mean>0.0708 & dist_mean<0.5914);
        arr_cut = mean_arr(dist_mean>0.0708 & dist_mean<0.5914);
        % plot(ax_2d_vth, dist_cut,arr_cut,'linewidth',1.2,'color','k')
        % plot(ax_2d_vth, dist_mean,zer_arr,'--','linewidth',1,'color','k')

    end

    cla(ax_1d_vth);
    yyvt = real(VV(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));% & YY>log10(ylimit(1)) & YY<log10(ylimit(2))));
    ssvt = -yyvt.*1e3./curva(1).Temp;
    [N,edges] = histcounts(ssvt(:),100);%, 'Normalization', 'pdf');
    xx5=(edges(1:end-1)+edges(2:end))/2;
    plot(ax_1d_vth,N,xx5,'linewidth',line_width);
    %yy_1d = N;
    %xx_1d = xx5;
    ylim(ax_1d_vth, [slimit(1), slimit(2)]);
    xticklabels(ax_1d_vth,[]);
    yticklabels(ax_1d_vth,[]);
    xlabel(ax_1d_vth,'Counts (a.u.)');
    set(ax_1d_vth,'Fontsize',fontsize,'linewidth',thick);
    set(ax_2d_vth,'Fontsize',fontsize,'linewidth',thick);
    if Hist_check ==1
        f = fit(xx5.',N.','gauss1');
        gaussy= f.a1.*exp(-((xx5-f.b1)./f.c1).^2);
        hold(ax_1d_vth,'on')
        plot(ax_1d_vth,gaussy,xx5,'r--','linewidth',1)
        tx_pl = text(ax_1d_vth,'units','normalized','position',[0.3394 0.9070 0],'String',['S = ' num2str(round(f.b1,2)) ' \muV/K'])
        %disp('f')

    end


end
zer_arr = zeros(1,500);
dist_array = linspace(log10(ylimit(1)),log10(ylimit(2)),500);
plot(ax_2d_vth, dist_array,zer_arr,'--','linewidth',1,'color','k')


end
    
    function Histogram_plot_vth(curva_hist)
        XX=[];
        YY=[];
        VV=[];
        ZF=[];
        fac_2d =1.8;
        cla(ax_2d_vth);
        colorbar('off')
        %cla(cb)

        for k3=1:length(curva_hist)
            xx=curva_hist(k3).z;
            yy=log10((curva_hist(k3).g));
            vv = smoothdata(curva_hist(k3).vth*1e3,filter_type,filter_ord);
           % vv=curva_hist(k3).vth*1e3;  % mV
            if size(xx) == size(yy)
                XX=[XX; xx];
                YY=[YY; yy];
                VV=[VV; vv];
            end
        end
       
        YY_cut = real(YY(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));
        XX_cut = real(XX(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));
        VV_cut = real(VV(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));
 if Seebeck_check ==0

 
        eje0=[xlimit(1)+0.02,xlimit(2)-0.02,vthlimit(1)-0.5,vthlimit(2)+0.5];
        nhi20=30;

        %f1=figure
        namess{1}='2D';
        axesLabel={'Displacement (nm)','V_{th} (mV)'};
        Hist2D(ax_2d_vth,XX_cut,VV_cut,eje0,sig,nhi20,namess,axesLabel,sat_2d*fac_2d);
        hold(ax_2d_vth,'on')
        cb = colorbar('SouthOutside');
        cb.Position = [0.6964 0.9123 0.1235 0.0221];
        cb.LineWidth = 1;
        cb.Limits = [0 sat_2d*1600];
        cb.TickLabels = [];

        xlim(ax_2d_vth,xlimit);
        ylim(ax_2d_vth,vthlimit);

        if Mean_check==1
            N = 500;
            dist_array = linspace(xlimit(1),xlimit(2),N);
            %zer_arr = zeros(1,N-1);
           
            for m1 = 1:N-1
                mean_arr(m1) = mean(VV_cut(XX_cut>dist_array(m1) & XX_cut<dist_array(m1+1)));
                std_arr(m1) = std(VV_cut(XX_cut>dist_array(m1) & XX_cut<dist_array(m1+1)));
            end
            dist_mean=(dist_array(1:end-1)+dist_array(2:end))./2;
            plot(ax_2d_vth, dist_mean,mean_arr,'linewidth',1.2,'color','k')
           % plot(ax_2d_vth, dist_mean,zer_arr,'--','linewidth',1,'color','k')

        end

         cla(ax_1d_vth);
        yyvt = real(VV(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));% & YY>log10(ylimit(1)) & YY<log10(ylimit(2))));
        [N,edges] = histcounts(yyvt(:),100);%, 'Normalization', 'pdf');
        xx5=(edges(1:end-1)+edges(2:end))/2;
        plot(ax_1d_vth,N,xx5,'linewidth',line_width);
        %yy_1d = N;
        %xx_1d = xx5;
        ylim(ax_1d_vth, [vthlimit(1), vthlimit(2)]);
        xticklabels(ax_1d_vth,[]);
        yticklabels(ax_1d_vth,[]);
        xlabel(ax_1d_vth,'Counts (a.u.)');
        set(ax_1d_vth,'Fontsize',fontsize,'linewidth',thick);
        set(ax_2d_vth,'Fontsize',fontsize,'linewidth',thick);

        if Hist_check ==1
            f = fit(xx5.',N.','gauss1');
            gaussy= f.a1.*exp(-((xx5-f.b1)./f.c1).^2);
            hold(ax_1d_vth,'on')
            plot(ax_1d_vth,gaussy,xx5,'r--','linewidth',1)
            tx_pl = text(ax_1d_vth,'units','normalized','position',[0.3394 0.9070 0],'String',['V_{th} = ' num2str(round(f.b1,2)) ' mV'])
            %disp('f')
        end

 else
     VV_cut =  -VV_cut.*1e3./curva(1).Temp;
     eje0=[xlimit(1)+0.02,xlimit(2)-0.02,slimit(1)+1,slimit(2)-1];
     nhi20=30;

     %f1=figure
     namess{1}='2D';
     axesLabel={'Displacement (nm)','Seebeck Coeff. (\muV/K)'};
        Hist2D(ax_2d_vth,XX_cut,VV_cut,eje0,sig+0.8,nhi20,namess,axesLabel,sat_2d*fac_2d);
        hold(ax_2d_vth,'on')
        cb = colorbar('SouthOutside');
        cb.Position = [0.6964 0.9123 0.1235 0.0221];
        cb.LineWidth = 1;
        cb.Limits = [0 sat_2d*1600];
        cb.TickLabels = [];

        xlim(ax_2d_vth,xlimit);
        ylim(ax_2d_vth,slimit);

        if Mean_check==1
            N = 500;
            dist_array = linspace(xlimit(1),xlimit(2),N);


            for m1 = 1:N-1
                mean_arr(m1) = mean(VV_cut(XX_cut>dist_array(m1) & XX_cut<dist_array(m1+1)));
                std_arr(m1) = std(VV_cut(XX_cut>dist_array(m1) & XX_cut<dist_array(m1+1)));
            end
            dist_mean=(dist_array(1:end-1)+dist_array(2:end))./2;
            %plot(ax_2d_vth, dist_mean,mean_arr,'linewidth',1.2,'color','k');
            dist_cut = dist_mean(dist_mean>0 & dist_mean<0.6);
            arr_cut = mean_arr(dist_mean>0 & dist_mean<0.6);
            plot(ax_2d_vth, dist_mean,mean_arr,'linewidth',1.2,'color','k');


        end

        cla(ax_1d_vth);
        yyvt = real(VV(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2)) & VV>vthlimit(1) & VV<vthlimit(2)));% & YY>log10(ylimit(1)) & YY<log10(ylimit(2))));
        ssvt = -yyvt.*1e3./curva(1).Temp;
        [N,edges] = histcounts(ssvt(:),100);%, 'Normalization', 'pdf');
        xx5=(edges(1:end-1)+edges(2:end))/2;
        plot(ax_1d_vth,N,xx5,'linewidth',line_width);
        %yy_1d = N;
        %xx_1d = xx5;
        ylim(ax_1d_vth, [slimit(1), slimit(2)]);
        xticklabels(ax_1d_vth,[]);
        yticklabels(ax_1d_vth,[]);
        xlabel(ax_1d_vth,'Counts (a.u.)');
        set(ax_1d_vth,'Fontsize',fontsize,'linewidth',thick);
        set(ax_2d_vth,'Fontsize',fontsize,'linewidth',thick);
        if Hist_check ==1
            f = fit(xx5.',N.','gauss1');
            gaussy= f.a1.*exp(-((xx5-f.b1)./f.c1).^2);
            hold(ax_1d_vth,'on')
            plot(ax_1d_vth,gaussy,xx5,'r--','linewidth',1)
            tx_pl = text(ax_1d_vth,'units','normalized','position',[0.3394 0.9070 0],'String',['S = ' num2str(round(f.b1,2)) ' \muV/K'])
            tx_pl_std = text(ax_1d_vth,'units','normalized','position',[0.25 0.8070 0],'String',['std = ' num2str(round(f.c1,2)) ' \muV/K'])
            %disp('f')

        end


 end
 zer_arr = zeros(1,500);
 dist_array = linspace(xlimit(1),xlimit(2),500);
 plot(ax_2d_vth, dist_array,zer_arr,'--','linewidth',1,'color','k')


    end
    
    function individual_plot_vth(ind)
        cla(ax_ind_vth);
        %cbx.String
        sumin=-1;
        if length(curva)==1
            ind = ind(1);
        end
        vzer = zeros(1,500);
        dzer = linspace(xlimit(1),xlimit(2),500);

        for k1=1:length(ind)
            sumin=sumin+1;
            k_trace = ind(k1);
            zz = curva(k_trace).z;
            gg = log10(curva(k_trace).g);
            vv =curva(k_trace).vth*1e3;

          

            gg_cut = real(gg(zz>xlimit(1) & zz<xlimit(2) & gg>log10(ylimit(1)) & gg<log10(ylimit(2)) & vv>vthlimit(1) & vv<vthlimit(2)));
            zz_cut = real(zz(zz>xlimit(1) & zz<xlimit(2) & gg>log10(ylimit(1)) & gg<log10(ylimit(2)) & vv>vthlimit(1) & vv<vthlimit(2)));
            vv_cut = real(vv(zz>xlimit(1) & zz<xlimit(2) & gg>log10(ylimit(1)) & gg<log10(ylimit(2)) & vv>vthlimit(1) & vv<vthlimit(2)));

            %semilogy(ax_ind,curva(k_trace).z+sumt*(sumin),curva(k_trace).g,'linewidth',line_width);
            %plot(ax_ind_vth,zz_cut+sumt*(sumin),vv_cut,'linewidth',line_width);
            if Seebeck_check ==0
                plot(ax_ind_vth,zz_cut+sumt*(sumin),smoothdata(vv_cut,filter_type,filter_ord),'linewidth',line_width);
                hold(ax_ind_vth, 'on');
                temp_trace(k1) = curva(k_trace).Temp;
                temp_trace_str{k1} = ['\DeltaT = ' num2str(round(curva(k_trace).Temp)) 'K'];

                xlim(ax_ind_vth,[xlimit(1) xlimit(2)]);
                ylim(ax_ind_vth,[vthlimit(1) vthlimit(2)]);
                xlabel(ax_ind_vth,'Displacement (nm)');
                ylabel(ax_ind_vth,'V_{th} (mV)');
                set(ax_ind_vth,'Fontsize',fontsize,'linewidth',thick);
            else
                plot(ax_ind_vth,zz_cut+sumt*(sumin),smoothdata(-vv_cut.*1e3,filter_type,filter_ord)./curva(k_trace).Temp,'linewidth',line_width);
                hold(ax_ind_vth, 'on');
                temp_trace(k1) = curva(k_trace).Temp;
                temp_trace_str{k1} = ['\DeltaT = ' num2str(round(curva(k_trace).Temp)) 'K'];

                xlim(ax_ind_vth,[xlimit(1) xlimit(2)]);
                ylim(ax_ind_vth,[slimit]);
                xlabel(ax_ind_vth,'Displacement (nm)');
                ylabel(ax_ind_vth,'Seebeck (\muV/K)');
                set(ax_ind_vth,'Fontsize',fontsize,'linewidth',thick);
            end
        end
        plot(ax_ind_vth,dzer,vzer,'--k','linewidth',1)
        legend(ax_ind_vth, temp_trace_str)
        linkaxes([ax_ind ax_ind_vth], 'x')

    end
    
    function Histogram_plot(curva_hist)

        XX=[];
        YY=[];
        ZF=[];
        cla(ax_2d);
        colorbar('off')
        %cla(cb)

        for k3=1:length(curva_hist)
            xx=curva_hist(k3).z;
            yy=log10((curva_hist(k3).g));
            if size(xx) == size(yy)
                XX=[XX; xx];
                YY=[YY; yy];
                if fit_wf==1
                    zcut = xx(yy>-5 & yy<-3);
                    gcut = yy(yy>-5 & yy<-3);
                    gfit = linspace(-5,-3,100);
                    p1 = polyfit(gcut,zcut,1);
                    %zfit = polyval(p,gfit);
                    if ~isnan(abs(p1(1)))
                        ZF=[ZF; p1];
                    end
                    %disp('g')
                end
            end
        end


        eje0=[xlimit(1)+0.02,xlimit(2)-0.02,log10(ylimit(1))+0.02,log10(ylimit(2))-0.02];
        nhi20=30;
        YY_cut = real(YY(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2))));
        XX_cut = real(XX(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2))));
        %f1=figure
        namess{1}='2D';
        axesLabel={'Displacement (nm)','log({\itG}/{\itG_0})'};
        Hist2D(ax_2d,XX_cut,YY_cut,eje0,sig,nhi20,namess,axesLabel,sat_2d);
        hold(ax_2d,'on')
        if fit_wf ==1
            ZFmean = mean(abs(ZF));
            zfit = polyval(-ZFmean,gfit);
            wf = (ZFmean(1)/3.5)^2;
            disp(wf)
            disp(ZFmean(1))
            plot(ax_2d,zfit,gfit,'k--','linewidth',1.5)
        end
        cb = colorbar('SouthOutside');
        cb.Position = [0.6964 0.9123 0.1235 0.0221];
        cb.LineWidth = 1;
        cb.Limits = [0 sat_2d*1600];
        cb.TickLabels = [];
        xlim(ax_2d,[xlimit]);
        ylim(ax_2d,[log10(ylimit)])
        xlabel(ax_2d,'');
        xticklabels(ax_2d,[])


        cla(ax_1d);
        yyvt = real(YY(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2))));
        [N,edges] = histcounts(yyvt(:),150);%, 'Normalization', 'pdf');
        xx5=(edges(1:end-1)+edges(2:end))/2;
        plot(ax_1d,N,xx5,'linewidth',line_width);
        yy_1d = N;
        xx_1d = xx5;
        ylim(ax_1d, log10(ylimit));
        xticklabels(ax_1d,[]);
        yticklabels(ax_1d,[]);
        xlabel(ax_1d,'Counts (a.u.)');
        set(ax_1d,'Fontsize',fontsize,'linewidth',thick);
        set(ax_2d,'Fontsize',fontsize,'linewidth',thick);
        xlabel(ax_1d,'');
        if edges(end)>-0.1
            N_g0=max(N(xx5>-0.5 & xx5<1.1));
            %   xlim(ax_1d,[0 2*N_g0])
        end
    end

    function individual_plot(ind)
        colors_ind = [0 0.45 0.74;
                     0.85 0.33 0.1;
                     0.93 0.69 0.13;
                     0.49 0.18 0.56];

        yyaxis(ax_ind,'right') 
        cla(ax_ind);
        yyaxis(ax_ind,'left') 
        cla(ax_ind);
        %cbx.String
        sumin=-1;
        if length(curva)==1
            ind = ind(1);
        end

        for k1=1:length(ind)
            sumin=sumin+1;
            k_trace = ind(k1);
            g_original = log10(curva(k_trace).g);
            z_original = curva(k_trace).z;
            
            z_ind = z_original(z_original>xlimit(1) & z_original<xlimit(2) & g_original>log10(ylimit(1)) & g_original<log10(ylimit(2)));
            g_ind = real(g_original(z_original>xlimit(1) & z_original<xlimit(2) & g_original>log10(ylimit(1)) & g_original<log10(ylimit(2))));



             smoothed_g = smoothdata(g_ind,'movmedian',100);
            df = abs(diff(smoothed_g)./diff(z_ind));
            dx = (z_ind(1:end-1)+z_ind(2:end))/2;
          
            % Dor plotting Derivative Uncomment this part
               % yyaxis(ax_ind,'right') % Derivative   
               % plot(ax_ind,dx+sumt*(sumin),smoothdata(df,'movmedian',30),'-','linewidth',line_width,'color',[0.5 0.5 0.5 0.3]);
               % yyaxis(ax_ind,'left')
            plot(ax_ind,z_ind+sumt*(sumin),g_ind,'-','linewidth',line_width,'color',colors_ind(k1,:));
            hold(ax_ind, 'on');
            xlim(ax_ind,[xlimit(1) xlimit(2)]);
            xticklabels(ax_ind,[])
            ylim(ax_ind,[log10(ylimit(1)) log10(ylimit(2))]);
            xlabel(ax_ind,'');
            ylabel(ax_ind,'log({\itG}/{\itG_0})');



            set(ax_ind,'Fontsize',fontsize,'linewidth',thick);
        end

        if fit_wf==1
            sumin=-1;
            for k1=1:length(ind)
                sumin=sumin+1;
                k_trace = ind(k1);
                log_g = log10(abs(curva(k_trace).g));
                zcut = curva(k_trace).z(log_g>-5 & log_g<-2);
                gcut = log_g(log_g>-5 & log_g<-2);
                zfit = linspace(min(zcut)+sumt*(sumin),max(zcut)+sumt*(sumin),100);
                p = polyfit(zcut,gcut,1);
                sprintf('The work function is estimated to %.3e', (1e-20) * ((p(2)*2.303*1e9)^2))
                f1 = polyval(p,zcut);
                semilogy(ax_ind,zcut+sumt*(sumin),f1,'k--','linewidth',2);
            end

        end
    end
    
    function M2Mx = histo2M(curstruct)
        edges2y = linspace(log10(ylimit(1)),log10(ylimit(2)),40);
        edges2x = linspace(xlimit(1),xlimit(2),30);
        centers2y = (edges2y(1:end-1)+edges2y(2:end))/2;
        centers2x = (edges2x(1:end-1)+edges2x(2:end))/2;
        mh = zeros(29-1);
        for k2=1:length(curstruct)
            mh = histcounts2(real(curstruct(k2).z),log10(abs(curstruct(k2).g)),edges2x,edges2y);
            M2Mx(:,:,k2) = mh';
        end
    end

    function MMd = histoDer(curstruct)
        edges2y = linspace(0,100,40);
        edges2x = linspace(xlimit(1),xlimit(2),30);
        centers2y = (edges2y(1:end-1)+edges2y(2:end))/2;
        centers2x = (edges2x(1:end-1)+edges2x(2:end))/2;

        for k2=1:length(curstruct)
            g_original = log10(abs(curstruct(k2).g));
            z_original = curstruct(k2).z;
            z_ind = z_original(z_original>xlimit(1) & z_original<xlimit(2) & g_original>log10(ylimit(1)) & g_original<log10(ylimit(2)));
            g_ind = real(g_original(z_original>xlimit(1) & z_original<xlimit(2) & g_original>log10(ylimit(1)) & g_original<log10(ylimit(2))));


            smoothed_g = smoothdata(g_ind,'movmedian',100);
            df = abs(diff(smoothed_g)./diff(z_ind));
            dx = (z_ind(1:end-1)+z_ind(2:end))/2;

            mh = histcounts2(dx,smoothdata(df,'movmedian',30),edges2x,edges2y);
            MMd(:,:,k2) = mh';
           % MMx = [MMx;mmx];
        end

    end
    
    function MMx = histoM(curstruct)
        edges = linspace(log10(ylimit(1)),log10(ylimit(2)),100);
        centers = (edges(1:end-1)+edges(2:end))/2;
        MMx = zeros(0,length(centers));
        for k2=1:length(curstruct)
            mmx = histcounts(log10(abs(curstruct(k2).g)),edges);
            MMx = [MMx;mmx];
        end
    end

    function MMx = histoM_centre(curstruct,trace_centre)
        edges = linspace(log10(ylimit(1)),log10(ylimit(2)),100);
        centers = (edges(1:end-1)+edges(2:end))/2;
        MMx = zeros(0,length(centers));
        for k2=1:length(curstruct)
            mmx = histcounts(log10(abs(curstruct(k2).g)),edges);
            MMx = [MMx;mmx];
        end
        MMx=MMx-MMx(:,trace_centre);
    end
   
    function dM2Mx = histo2Md(curstruct)  % Cluster Derivative
        edges2y = linspace(log10(ylimit(1)),log10(ylimit(2)),40);
        edges2x = linspace(xlimit(1),xlimit(2),30);
        centers2y = (edges2y(1:end-1)+edges2y(2:end))/2;
        centers2x = (edges2x(1:end-1)+edges2x(2:end))/2;
        mh = zeros(29-1);
        for k2=1:length(curstruct)
            mh = histcounts2(real(curstruct(k2).z),log10(abs(curstruct(k2).g)),edges2x,edges2y);
            M2Mx(:,:,k2) = mh';
        end
    end

    function M2Mx = histo2S(curstruct)
        edges2y = linspace(slimit(1),slimit(2),40);
        edges2x = linspace(xlimit(1),xlimit(2),30);
        centers2y = (edges2y(1:end-1)+edges2y(2:end))/2;
        centers2x = (edges2x(1:end-1)+edges2x(2:end))/2;
        mh = zeros(29-1);
        for k2=1:length(curstruct)
            xc = curstruct(k2).z;
            yc = log10(abs(curstruct(k2).g));
            s = -curstruct(k2).vth*1e6./curstruct(k2).Temp;

            z_cut = xc(xc>xlimit(1) & xc<xlimit(2) & yc>log10(ylimit(1)) & yc<log10(ylimit(2)) & s>slimit(1) & s<slimit(2));
            s_cut = s(xc>xlimit(1) & xc<xlimit(2) & yc>log10(ylimit(1)) & yc<log10(ylimit(2)) & s>slimit(1) & s<slimit(2));
            
            mh = histcounts2(z_cut,s_cut,edges2x,edges2y);
            M2Mx(:,:,k2) = mh';
        end
   end 

    function M2Mx = histo2SG(curstruct)
        edges2y = linspace(slimit(1),slimit(2),40);
        edges2x = linspace(log10(ylimit(1)),log10(ylimit(2)),30);
        centers2y = (edges2y(1:end-1)+edges2y(2:end))/2;
        centers2x = (edges2x(1:end-1)+edges2x(2:end))/2;
        mh = zeros(29-1);
        for k2=1:length(curstruct)
            xc = curstruct(k2).z;
            yc = log10(abs(curstruct(k2).g));
            s = -curstruct(k2).vth*1e6./curstruct(k2).Temp;
            y_cut = yc(xc>xlimit(1) & xc<xlimit(2) & yc>log10(ylimit(1)) & yc<log10(ylimit(2)) & s>slimit(1) & s<slimit(2));
            s_cut = s(xc>xlimit(1) & xc<xlimit(2) & yc>log10(ylimit(1)) & yc<log10(ylimit(2)) & s>slimit(1) & s<slimit(2));
            mh = histcounts2(y_cut,s_cut,edges2x,edges2y);
            M2Mx(:,:,k2) = mh';
        end
    end 

    function MMx = histoS(curstruct)
        edges = linspace(slimit(1),slimit(2),100);
        centers = (edges(1:end-1)+edges(2:end))/2;
        MMx = zeros(0,length(centers));
        for k2=1:length(curstruct)
            xc = curstruct(k2).z;
            yc = log10(abs(curstruct(k2).g));
           
            s = -curstruct(k2).vth*1e6./curstruct(k2).Temp;
            
            s_cut = s(xc>xlimit(1) & xc<xlimit(2) & yc>log10(ylimit(1)) & yc<log10(ylimit(2)) & s>slimit(1) & s<slimit(2));
            mmx = histcounts(s_cut,edges);
            MMx = [MMx;mmx];
        end
    end
    
    function MML = histoL(cura)
        G_Lorentz = linspace(log10(ylimit(1)),log10(ylimit(2)),100);
        MML = [];

        for p=1:1:length(cura)
            f = zeros(1,length(G_Lorentz));
            f2 = zeros(1,length(G_Lorentz));
            yycut1=cura(p).g(cura(p).g<ylimit(2) & cura(p).g>ylimit(1));
            xxcut1=cura(p).z(cura(p).g<ylimit(2) & cura(p).g>ylimit(1));
            yycut2=yycut1(xxcut1<xlimit(2) & xxcut1>xlimit(1));
            xxcut2=xxcut1(xxcut1<xlimit(2) & xxcut1>xlimit(1));
            lyycut2 = log10(yycut2);
            for h = 1:1:length(yycut2)
                c = [];
                c = imag(-1./(G_Lorentz + 1i*0.2 - lyycut2(h)));
                for j = 1:1:length(G_Lorentz)
                    f(j) = f(j) + c(j);
                    %            f2(j) = f2(j) + c(j);
                end
            end
            %            if rnorm.Value==0
            %                f=f;
            %            else
            f = f/max(f);
            %            end
            MML = [MML;f];
        end
        MML(isnan(MML)) = 0;
        %  gg=sum(MML);
        %  G_Lorentz = linspace(log10(yymax),log10(yymin),lon_G);
        %  figure
        %  plot(G_Lorentz,gg);
    end
    
    function [icx,C,sumd,D] = doclusters(M,nk)
        opts = statset('Display','final');
        [idx,C,sumd,D] = kmeans(M,nk,...
            'Replicates',20,'Options',opts);
        icx = idx;
        U.idx = idx;
        U.C = C;
        U.sumd = sumd;
        U.D = D;
        set(gcf,'userdata',U)
    end

end
   


% Functions Histogram 2D

function [data,l] = Hist2D(ha,dataxx,datayy,eje0,radio,altura,namess,axesLabel,saturation,inform,axpos,num)

global grosorcurva labelsize grosorejes fontejes letrasize labelsizein 
    
axes(ha)
eje.x = eje0(1:2);
eje.y = eje0(3:4);

nxb = linspace(eje.x(1),eje.x(2),160);
nyb = linspace(eje.y(1),eje.y(2),160);
% COMENTADO POR JUAN
% res2 = round((max(eje.y)-min(eje.y))/bins);
% res1 = res2;
% if res1>300; res1 = 300; res2 = 300; end
% bins = (max(eje.x)-min(eje.x))/res1;
%COMENTADO POR JUAN

% histograma de Andrés
% res1=256;
% res2=256;
%C5ambio Juan
 % res1=530;
 % res2=566;
  
 res1=850;
  res2=850;
%res1=1080;
%res2=1080;
bins = (max(eje.x)-min(eje.x))/res1;
%bins=100;
%Cambio Juan
fun = 'gauss';
con = 'conv2';

% Cambio CHATGPT

%Rx = max((eje.x(2)-eje.x(1))/1000, 1.9 * bins);
%Rx = max((eje.x(2)-eje.x(1))/1.5, 30 * bins);
%Ry = max((eje.x(2)-eje.x(1))/1.5, 30 * bins);
%Ry = max((eje.y(2)-eje.y(1))/1000, 1.9 * bins);

% Cambio CHATGPT

 
Rx = radio;
Ry = Rx;
Rs = 2; %da igual para la gaussiana
   
ind = find(dataxx > eje.x(1) & dataxx < eje.x(2));
   
hh.x = dataxx(ind);
hh.y = datayy(ind);
ind = find(hh.y > eje.y(1) & hh.y < eje.y(2));
hh.x = hh.x(ind);
hh.y = hh.y(ind);

limites = [eje.x eje.y];
[H,vX,vY,F] = hist2conv(hh.x,hh.y,limites,res1,res2,fun,con,Rx,Ry,Rs);

%normf = 1;
box on 
grid on
%colm = load('Colormap_UCL_2.mat');


 colm = load('mycolormap.mat');

%colm = load('Colormap_UCL.mat'); 
%B=magma;  % Perceptually uniform colormaps: viridis; plasma; magma; inferno; fake_parula
colormap(colm.mycmap);
%colormap(flipud(B))
%colormap(B)
%colormap(colm1.nuevo_mapa);

%colormap hsv;
%colormap(colm.Colormap_UCL)
%colormapeditor
%normf=0.1*max(max(H));
%normf=saturation*max(max(H));
normf = sum(H(:))*bins^2;

%  Cambio CHATGPT

area = bins^2;
numPoints = length(hh.x);
if numPoints ~= 0
    normf = numPoints * area; % Total area ocupada por los puntos
    H = H / normf; % Densidad por unidad de área
else
    warning('No hay puntos en el histograma.');
    normf = 1; % Evita división por cero
end

%  cambio CHATGPT

hhiloA = pcolor(vX,vY,H'/normf);
set(hhiloA,'linestyle','none');

%normf=saturation*max(max(H));

caxis ([0 altura/normf]);

inform.Hisdata.vX = vX;
inform.Hisdata.vY = vY;
inform.Hisdata.H = H;
inform.initialData.x = dataxx;
inform.initialData.y = datayy;
inform.binsize = bins;
inform.normFactor = normf;

if ~isempty(axesLabel)
    xlabel(axesLabel{1});%,'FontSize',12); 
    ylabel(axesLabel{2});%,'FontSize',12);
end
p = [];
for n = 1:length(namess)
    modifnamef = strrep(namess{n}, '_', '\_');
   p=[p modifnamef];
end

data = inform;
l.pname = p;

%set(ha,'Fontsize',13);
%set(ha,'linewidth',2,'TickLength',[0.015 0.015]);

    
end
function [H,vX,vY,F] = hist2conv(X,Y,limites,res1,res2,fun,con,Rx,Ry,Rs)

% H = hist2conv(X,Y,res1,res2,fun,R1,R2,R3) devuelve la matriz resultante
% de convolucionar los datos X,Y con una matriz rellena según la función
% fun. El resultado es una matriz res1xres1.
%  Rx = radio en X
%  Ry = radio en Y
%  Rs = parametro de smearing
%  fun = {'gauss','bell'}

% Si no introducimos smearing lo toma como 1
if nargin == 8
    Rs = 1;
end


% Calculamos la matriz de Kronecker de nuestros datos XY
%K = hist3([X,Y],[res1,res1]) ;
%vX = linspace(min(X),max(X),res1+1);
%vY = linspace(min(Y),max(Y),res1+1);

%modificado por Nicolás: los límites son comunes a varios histogramas, así
%el fondo queda uniforme
vX = linspace(limites(1),limites(2),res1+1);
vY = linspace(limites(3),limites(4),res1+1);
[nxout,xout]=hist(X,length(vX));
Unim = ones(1,length(vX));
norm = Unim'*nxout;
K = hist3([X,Y],{vX,vY}) ;
%K = K./norm';


% Calculamos la matriz F con la que vamos a convolucionar
switch fun
    case 'gauss'
        Fx = gaussmf(1:res2,[Rx,res2/2+1]);
        Fy = gaussmf(1:res2,[Ry,res2/2+1]);
        F = Fy'*Fx;
    case 'bell'
        Fx = gbellmf(1:res2,[Rx,Rs,res2/2+1]);
        Fy = gbellmf(1:res2,[Ry,Rs,res2/2+1]);
        F = Fy'*Fx;
    case 'user'
        Fx = gauss2mf(1:res2,[Rx,res2/2+1,Ry,res2/2+1]);
        Fy = gauss2mf(1:res2,[Rx,res2/2+1,Ry,res2/2+1]);
        F = Fy'*Fx;
    otherwise
        disp('function not recognised: USING GAUSS');
        Fx = gaussmf(1:res2,[Rx,res2/2+1]);
        Fy = gaussmf(1:res2,[Ry,res2/2+1]);
        F = Fy'*Fx;        
end

% Calculamos la matriz de convolución H
%H = conv2(K,F,'shape');
 switch con
     case 'conv2'
%          H = conv2(K,F,'shape'); %%%SHAPE must be 'full', 'same', or 'valid'.
         H = conv2(K,F,'same');
     case 'conv2fft'
         H = conv2fft(K,F);
     otherwise
         disp('conv2 kind not recognized: USING CONV2');
         H = conv2(K,F,'shape');
 end
H(res1+1,:)=0;
H(:,res1+1)=0;        




end
function [h,x,y] = hist2pdf2D(dat,res,sig)
% dat : is a 2 column matrix ([X Y])
% res : number of points on each side (histogram boxes = res^2)
% sig : [sigx sigy] sigma of gaussian in x and y (in units of the x-axis and y-axis)
% The integral of the pdf is the number of elements in dat


%dat = .5*rand(100,2);
%dat = [dat; .9 .9; .9 .9; .1 .9; .1 .9];
%res = 50;
%sig = [.01 .01];

%figure(100)
%hist3(dat,[res res])

[K,C] = hist3(dat,[res res]);

dx = mean(C{1}(2:end)-C{1}(1:end-1));
dy = mean(C{2}(2:end)-C{2}(1:end-1));

if mod(res,2)==0 %is even, ng debe ser siempre impar
    ng = res+1;
else
    ng = res;
end

xx = dx*((1:ng)-ceil(ng/2));
yy = dy*((1:ng)-ceil(ng/2));
%definimos la gaussiana en el mismo intervalo del histograma
Fx = gaussmf(xx,[sig(1),0]);
Fy = gaussmf(yy,[sig(2),0]);
F = Fy'*Fx;
F = F/sig(1)/sig(2)/2/pi;

%H = conv2(K,F,'shape');
H = conv2(K,F,'same');
if ~nargout 
    %surf(C{1},C{2},H')
    contourf(C{1},C{2},H',50,'linestyle','none')
    xlabel('Z (nm)')
    ylabel('Conductance log(G/G_0)')
    title('G0-11C')
else
    h = H';
    x = C{1};
    y = C{2};
end
disp(' ')
end
end