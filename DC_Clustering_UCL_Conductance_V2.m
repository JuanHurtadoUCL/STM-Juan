% Preliminary code for Kmeans UCLouvain

%[file,path] = uigetfile;
[file path] = uigetfile({'*.*'},'chose blq or mat', 'MultiSelect','on' )
if isequal(file,0)
    disp('User selected Cancel');
else
    disp(['User selected ', fullfile(path,file)]);
    caminonu=path;
end

factor_dist = 1;

t=length(file);
curva=[];
if iscell(file)==0
    cura =load([path '\' file]);
    curva_ini=cura.curva;
    title_ini=file(1:end-4);
else
    for m=1:t
        curva{m}=[];
        cura =load([path '\' file{m}]);
        curva{m}=cura.curva;
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
            curva_ini(num_curva).z=estructuraActual(k3).z*factor_dist;
        end
    end
    curva = [];
    title_ini=file{1}(1:end-4);
end


limits_general1 = [-0.25 1;    % Xlimits
                   1e-6 3];   % Ylimits
sat_ini = 0.003;
pinta_traces(curva_ini,title_ini, path,limits_general1,sat_ini);



function pinta_traces(curva, title1,file_path,limits_general,saturation_value)

fig_general=figure('units','normalized','Position',[0.1518 0.2305 0.6429 0.5495]);
ax_ind=axes(fig_general,'position',[0.2927 0.1500 0.2589 0.8000]);
ax_2d=axes(fig_general,'Position',[0.6277 0.1500 0.2000 0.8000]);
ax_1d=axes(fig_general,'Position',[0.8265 0.1500 0.1500 0.8000]);
set(fig_general,'name',title1)


num_traces=length(curva);

%xlimit=[-0.25 3];
xlimit = limits_general(1,:);
ylimit = limits_general(2,:);
%limits_general
%ylimit=[1e-6 3];
ind_trace=[1,2];
num_clust=3;
fontsize=11;
thick=1;
line_width=1;
sumt = 0;
sig=0.8;
xx_1d=[];
yy_1d=[];
fit_wf = 0;
sat_2d = saturation_value;
G0_lengt_str = 'G0 = Press G0 button'
wf_lengt_str = 'WF = Press WF checkbox'


individual_plot(ind_trace);
Histogram_plot(curva);


hp_information = uipanel(fig_general,'position',[0.0102 0.8350 0.1824 0.1572],'BackgroundColor',[0.7 1 0.6]);
tx_g0 = uicontrol('style','Text','parent',hp_information,...
    'units','normalized','position',[0.0500 0.5796 0.9000 0.3978],'String',[G0_lengt_str],'BackgroundColor',[0.7 1 0.6],'TooltipString','Information display');
tx_wf = uicontrol('style','Text','parent',hp_information,...
    'units','normalized','position',[0.0500 0.2361 0.9000 0.4673],'String',[wf_lengt_str],'BackgroundColor',[0.7 1 0.6],'TooltipString','Information display');

% information_curva = isfield(curva(1),'Info');
% if information_curva == 1
%     info_str = curva(1).Info
%     string_disp = ['Vb=' info_str.Vbias{1} ' Rs=' info_str.Rserie{1} ' Rg=' info_str.Rgain{1}];
%     tx_infocurva = uicontrol('style','Text','parent',hp_information,...
%         'units','normalized','position',[-2.1065e-04 -0.0293 0.9910 0.4673],'String',string_disp,'BackgroundColor',[0.7 1 0.6],'TooltipString','Information display');
% else
%     tx_infocurva = uicontrol('style','Text','parent',hp_information,...
%         'units','normalized','position',[-2.1065e-04 -0.0293 0.9910 0.4673],'String','No info available','BackgroundColor',[0.7 1 0.6],'TooltipString','Information display');
% end

text_trace=uicontrol(fig_general,'style','text',...
        'units','normalized','position',[0.0102 0.1556 0.1824 0.0306],...
        'string',['Number of Traces = ' num2str(length(curva))]);

hp_movetrace = uipanel(fig_general,'position',[0.0102 0.0223 0.1824 0.1267]);
edit_numtrace = uicontrol('style','edit','parent',hp_movetrace,...
    'units','normalized','position',[0.05,0.61,.9,.3],...
    'string',num2str(ind_trace),...
    'callback',@e2);
    function e2(~,~)
        ind_trace = str2num(get(edit_numtrace,'string'));
        individual_plot(ind_trace);
    end

 
  uicontrol('style','pushbutton','parent',hp_movetrace,...
        'units','normalized','position',[0.05,0.01,.45,.3],...
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
    end

 uicontrol('style','pushbutton','parent',hp_movetrace,...
        'units','normalized','position',[0.5,0.01,.45,.3],...
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
    end

uicontrol('style','pushbutton','parent',hp_movetrace,...
    'units','normalized','position',[0.05,0.31,.45,.3],...
    'string','Reset',...
    'callback',@res);
    function res(~,~)
        ind_trace = [1, 2];
        set(edit_numtrace,'string',num2str(ind_trace));
        individual_plot(ind_trace)
    end

cbx = uicontrol('style','checkbox','parent',hp_movetrace,...
    'units','normalized','position',[0.5060 0.3100 0.4455 0.3000],'String','Sum Dis','TooltipString','Display the traces with 1nm extra between them',...
    'callback',@checksum);
    function checksum(~,~)
        sumt=cbx.Value;
        individual_plot(ind_trace)
    end

hp_limits = uipanel(fig_general,'position',[0.0102 0.1947 0.1824 0.1267]);
text_xlims=uicontrol('parent',hp_limits,'style','text',...
    'units','normalized','position',[0.0206 0.0917 0.4000 0.3849],...
    'string','Xlmits');
text_ylims=uicontrol('parent',hp_limits,'style','text',...
    'units','normalized','position',[0.0206 0.5495 0.4000 0.2996],...
    'string','Ylmits');
edit_xlimit = uicontrol('style','edit','parent',hp_limits,...
    'units','normalized','position',[0.4500 0.0935 0.5239 0.4000],...
    'string',num2str(xlimit),...
    'callback',@exlim);
    function exlim(~,~)
        xlimit = str2num(get(edit_xlimit,'string'));
        individual_plot(ind_trace);
        Histogram_plot(curva)
    end
edit_ylimit = uicontrol('style','edit','parent',hp_limits,...
    'units','normalized','position',[0.4500 0.4935 0.5239 0.4000],...
    'string',num2str(ylimit),...
    'callback',@eylim);
    function eylim(~,~)
        ylimit = str2num(get(edit_ylimit,'string'));
        individual_plot(ind_trace);
        Histogram_plot(curva)
    end


hp_cluster = uipanel(fig_general,'position',[0.0102 0.3263 0.1824 0.1267]);
edit_numClust = uicontrol('style','edit','parent',hp_cluster,...
    'units','normalized','position',[0.4679 0.0551 0.5000 0.4000],'TooltipString','Number of clusters',...
    'string',num2str(num_clust),...
    'callback',@enumclust);
    function enumclust(~,~)
        num_clust = str2num(get(edit_numClust,'string'));
    end
text_method = uicontrol('style','text','parent',hp_cluster,...
    'units','normalized','position',[0.0846 0.4634 0.3197 0.4000],...
    'string','Method');
pop_clust = uicontrol('style','popup','parent',hp_cluster,...
    'units','normalized','position',[0.4679 0.5339 0.5000 0.4000],...
    'string',{'1D Histogram';'1D-2D Histogram'; '2D Histogram';'Lorentzian'},'Value',2)
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
            case 1
               % ma2 = histo2M(curva);
                ma = histoM(curva);
                %sz = size(ma2);
               % M = reshape(ma2,sz(1)*sz(2),sz(3));
                mart=[ma'];
            case 2
                ma2 = histo2M(curva);
                ma = histoM(curva);
                sz = size(ma2);
                M = reshape(ma2,sz(1)*sz(2),sz(3));
                mart=[ma';M];
            case 3
                ma2 = histo2M(curva);
                % ma = histoM(curva);
                sz = size(ma2);
                M = reshape(ma2,sz(1)*sz(2),sz(3));
                mart=[M];

            case 4
                mL=histoL(curva);
                mart=[mL'];
                disp('Finished')
%                gg=sum(mL);
%                G_Lorentz = linspace(log10(ylimit(1)),log10(ylimit(2)),lon_G);
        end

        %            newref=ma3(:,crefv);
        [icx,C,sumd,D]= doclusters(mart',num_clust);
        limits_general_clus = [xlimit(1) xlimit(2);
                              ylimit(1) ylimit(2)];

        for k=1:num_clust
            curk = curva(icx==k);
            nuk = length(curk);
           % pinta_traces(curk, [figna ' Clust' num2str(k)], file_path)
            pinta_traces(curk,[figna ' Clust' num2str(k)],file_path,limits_general_clus,sat_2d)
           
        end
    end
hp_save = uipanel(fig_general,'position',[0.0102 0.4592 0.1824 0.0914]);

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
    end
text_sigma = uicontrol('style','text','parent',hp_save,...
    'units','normalized','position',[0.2490 0.4939 0.2337 0.4900],...
    'string','Sigma');

buton_fitpeak = uicontrol('style','pushbutton','parent',hp_save,...
    'units','normalized','position',[0.5006 0.0739 0.2068 0.8300],'TooltipString','Fit gaussian to the main conductance peak',...
    'string','Fit',...
    'callback',@fitpeak);
    function fitpeak(~,~)
        cuts = log10(ylimit);
        xx_cut = xx_1d(xx_1d> cuts(1) & xx_1d<cuts(2));
        yy_cut = yy_1d(xx_1d> cuts(1) & xx_1d<cuts(2));

        f24 = fit(xx_cut.',yy_cut.','gauss1');
        xxlen=linspace(cuts(1),cuts(2),100);
        yff =  f24.a1*exp(-((xxlen-f24.b1)/f24.c1).^2);
        hold(ax_1d,'on')
        plot(ax_1d,yff,xxlen,'--r');

        g_min = f24.b1-f24.c1;
        g_max = f24.b1+f24.c1;
        N_plat = 100;
        G_P_Mean=[];
        Z_P_Mean=[];
        % plateau_length=zeros(1,length(curva));
        indf=0;
        for k3 = 1:length(curva)
            zz=curva(k3).z;
            gg=curva(k3).g;
            lg=log10(abs(gg));
            zz_cut = zz(lg>g_min & lg<g_max);
            gg_cut = lg(lg>g_min  & lg<g_max);

            z_plat_mean1 = linspace(min(zz_cut),max(zz_cut),N_plat);
            if min(zz_cut)>0.2
                continue
            end

            for j1 =1:N_plat-1
                z_low =z_plat_mean1(j1);
                z_high =z_plat_mean1(j1+1);
                g_plat_mean(j1) = mean(gg_cut(zz_cut>z_low & zz_cut<z_high));
                z_plat_mean = (z_plat_mean1(2:end)+z_plat_mean1(1:end-1))./2;

            end
            if isnan(mean(g_plat_mean))
            
            else
                G_P_Mean  = [G_P_Mean; g_plat_mean];
                Z_P_Mean  = [Z_P_Mean; z_plat_mean];
                indf=indf+1;
                plateau_length(indf)= zz_cut(end);
            end

        end
        fin_g_mean = mean(G_P_Mean);
        fin_z_mean = mean(Z_P_Mean);
        p1 = polyfit(fin_z_mean,fin_g_mean,1);  
        f2 = polyval(p1,fin_z_mean);
        hold(ax_2d,'on')

        plot(ax_2d,fin_z_mean,fin_g_mean,'k','linewidth',1.5);
        plot(ax_2d,fin_z_mean,f2,'.r','linewidth',2);
        plateau_length(isnan(plateau_length)) = [];
        mean_plateau_length = mean(plateau_length);
        disp(['Mean conductance = ' num2str(f24.b1) ' G0']);
        disp(['Mean length  = ' num2str(mean_plateau_length) ' nm']);
        text(ax_2d,'units','normalized','position',[0.35 0.8],'string',['Mean length  = ' num2str(round(mean_plateau_length,2)) ' nm'],'fontsize',7);
        text(ax_2d,'units','normalized','position',[0.28 0.75],'string',['Mean conductance = ' num2str(round(f24.b1,1)) ' G0'],'fontsize',7);
        text(ax_2d,'units','normalized','position',[0.4 0.7],'string',['Slope = ' num2str(round(p1(1),1)) ' nm-1'],'fontsize',7);
    end
buton_fitpeak = uicontrol('style','pushbutton','parent',hp_save,...
    'units','normalized','position',[0.7106 0.0739 0.2068 0.8300],'TooltipString','Fit the G0 plateau extracting the length and the factor with 0.25 nm',...
    'string','G0',...
    'callback',@g0length);
    function g0length(~,~)
        cut_g0 = [log10(0.2) log10(1.1)];
        cut_z = -0.1;
        plateau_g0=[];
        lengths=[];
        %fg0=figure;
        % 10^0.15 = 1.4125   % 10^0.25 Cambio Juan
             % 10^-0.15 = 0.7079  10^-0.25 Cambio Juan it is different than previously defined (3e-1) but makes effectively no difference
        
        for k3 = 1:length(curva)
            zz=curva(k3).z;
            gg=(curva(k3).g);
            zz_dis1=zz(gg>0.5 & gg<1.5);
            gg_dis1=gg(gg>0.5 & gg<1.5);
            zz_dis=zz_dis1(zz_dis1>-0.1 & zz_dis1<1);
            gg_dis=gg_dis1(zz_dis1>-0.1 & zz_dis1<1);
            lengths = [lengths; length(gg_dis)];
            xstart = find((gg_dis)>0.5,1,'last');
            xend = find((gg_dis)<-0.5,1,'first');
            
            if length(gg_dis)>15
                dz = (zz_dis(end)-zz_dis(1));
                plateau_g0 =[plateau_g0; dz];
            end
        end
        fg0=figure;
        plateau_g0f = plateau_g0(plateau_g0<0.15);
        
        
        [N,edges] = histcounts(plateau_g0,60);%, 'Normalization', 'pdf');
        xx5=(edges(1:end-1)+edges(2:end))/2;
        f = fit(xx5.',N.','gauss1')
        plot(xx5,N,'linewidth',line_width);
        hold on
        plot(f)
        mpg0 = f.b1;
        fac_g0 = 0.25/mpg0;
        xlabel('Length G_0 plateau')
        ylabel('Counts')
        disp(['Factor = ' num2str(fac_g0)]);
        disp(['Length = ' num2str(mpg0) ' nm']);

        G0_lengt_str = ['G0 = ' num2str(round(mpg0,2)) ' nm / Factor (' num2str(round(fac_g0,2)) ')']
        tx_g0.String = G0_lengt_str;

        %tx_g0 = uicontrol('style','Text','parent',hp_information,...
        %    'units','normalized','position',[0.05,0.71,.9,.2],'String',[G0_lengt_str]);

    end
hp_select = uipanel(fig_general,'position',[0.0102 0.5592 0.1824 0.05]);

chk_fit = uicontrol('style','checkbox','parent',hp_select,...
    'units','normalized','position',[0.5 0.0739 0.4 0.9],'TooltipString','Fit the slope of the tunnelling regime',...
    'string','Fit WF','Value',0,'callback',@check_wf)
    function check_wf(~,~)
        
        fit_wf = chk_fit.Value;
        individual_plot(ind_trace)
        disp('f') 

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
                              ylimit(1) ylimit(2)];
        pinta_traces(curk, figna,file_path,limits_general_clus,sat_2d);
        

    end

tx_sat = uicontrol('style','text','units','normalized','parent',fig_general,'position',...
    [0.1400 0.6073 0.0480 0.0500],'String',num2str(sat_2d));

slide_2d = uicontrol('style','slider','units','normalized','parent',fig_general,'position',...
    [0.0102 0.6174 0.13 0.0500],'Min',0.001,'Max', 0.03, 'Value', 0.003,'TooltipString','Change the saturation level of the 2D Histogram', ...
    'callback',@slidemove);
    function slidemove(~,~)
        %disp('f')
        sat_2d = slide_2d.Value;
        Histogram_plot(curva)
        tx_sat.String = num2str(round(100*sat_2d,3));
    end


% Functions

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

        %f1=figure
        namess{1}='2D';
        axesLabel={'Displacement (nm)','{\itG} ({\itG_0})'};
        Hist2D(ax_2d,XX*2,YY,eje0,sig,nhi20,namess,axesLabel,sat_2d);
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


        cla(ax_1d);
        yyvt = real(YY(XX>xlimit(1) & XX<xlimit(2) & YY>log10(ylimit(1)) & YY<log10(ylimit(2))));
        [N,edges] = histcounts(yyvt(:),100);%, 'Normalization', 'pdf');
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
        if edges(end)>-0.1
            N_g0=max(N(xx5>-0.5 & xx5<1.1));
         %   xlim(ax_1d,[0 2*N_g0])
        end
    end

    function individual_plot(ind)
        cla(ax_ind);
        %cbx.String
        sumin=-1;
        if length(curva)==1
            ind = ind(1);
        end
        for k1=1:length(ind)
            sumin=sumin+1;
            k_trace = ind(k1);
            %semilogy(ax_ind,curva(k_trace).z+sumt*(sumin),curva(k_trace).g,'linewidth',line_width);
            plot(ax_ind,curva(k_trace).z+sumt*(sumin),log10(curva(k_trace).g),'linewidth',line_width);
            hold(ax_ind, 'on');
            xlim(ax_ind,[xlimit(1) xlimit(2)]);
            ylim(ax_ind,[log10(ylimit(1)) log10(ylimit(2))]);
            xlabel(ax_ind,'Displacement (nm)');
            ylabel(ax_ind,'{\itG} ({\itG_0})');
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
            semilogy(ax_ind,zcut+sumt*(sumin),10.^f1,'k--','linewidth',2);
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

    function MMx = histoM(curstruct)
        edges = linspace(log10(ylimit(1)),log10(ylimit(2)),100);
        centers = (edges(1:end-1)+edges(2:end))/2;
        MMx = zeros(0,length(centers));
        for k2=1:length(curstruct)
            mmx = histcounts(log10(abs(curstruct(k2).g)),edges);
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
  
    res1=550;
  res2=550;
%res1=1080;
%res2=1080;
bins = (max(eje.x)-min(eje.x))/res1;
%bins=100;
%Cambio Juan
fun = 'gauss';
con = 'conv2';
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
normf = sum(H(:))*bins^2;
%normf = 1;
box on 
grid on
%colm = load('Colormap_UCL_V1.mat');
colm = load('mycolormap.mat');
%colm = load('colormap_new.mat'); 
colormap(colm.mycmap);
%colormap(colm.CustomColormap)
%colormapeditor
%normf=2*max(max(H));
hhiloA = pcolor(vX,vY,H'/normf);
set(hhiloA,'linestyle','none');

normf=saturation*max(max(H));

caxis ([0 altura/normf])

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