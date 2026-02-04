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
            curva_ini(num_curva).vth=estructuraActual(k3).vth;
            curva_ini(num_curva).z=estructuraActual(k3).z*factor_dist;
            curva_ini(num_curva).piezoV=estructuraActual(k3).piezoV;
            curva_ini(num_curva).Temp = estructuraActual(k3).Temp;
        end
    end
    curva = [];
    title_ini=file{1}(1:end-4);
end

superpinta(curva_ini,title_ini,caminonu);


function superpinta(curva,title1,file_path)

ind_trace =1;
limits_gen = [-0.1 1;  % Time
                -6 3;  % Conductance
                -1 1;  % Thermo Voltage
              -20 20]; % Seebeck
seebeck_bool = 1;
hist_bool =1;
mean_bool =0;
pf_bool =0;
clust_number =2;

fig_general = figure('units','normalized','position',[0.0302 0.0657 0.9344 0.8083]);
ax1_ind = axes(fig_general,'units','normalized','position',[0.2331 0.6501 0.2510 0.2861]);
ax2_ind = axes(fig_general,'units','normalized','position',[0.2331 0.3660 0.2510 0.2867]);
ax3_ind = axes(fig_general,'units','normalized','position',[0.58 0.1243 0.1700 0.3119]);
ax4_ind = axes(fig_general,'units','normalized','position',[0.2331 0.1251 0.2510 0.2432]);

ax1_tog = axes(fig_general,'units','normalized','position',[0.8 0.55 0.17 0.3119]);
ax2_tog = axes(fig_general,'units','normalized','position',[0.8 0.1243 0.17 0.3119]);
ax3_tog = axes(fig_general,'units','normalized','position',[0.58 0.55 0.1700 0.3119]);
set(fig_general,'name',title1);



hp_movetrace = uipanel(fig_general,'position',[0.0096 0.0148 0.1559 0.1283]);
edit_numtrace = uicontrol('style','edit','parent',hp_movetrace,...
    'units','normalized','position',[0.0384 0.6752 0.4391 0.3000],...
    'string',num2str(ind_trace),...
    'callback',@e2);
    function e2(~,~)
        ind_trace = str2num(get(edit_numtrace,'string'));
        individual_plot(ind_trace);
       % individual_plot_vth(ind_trace);
    end

but_hist2d = uicontrol('style','pushbutton','parent',hp_movetrace,...
    'units','normalized','position',[0.5384 0.6752 0.4391 0.3000],...
    'String','Hist 2D','callback',@but2d);
    function but2d(~,~)
        individual_plot(ind_trace);
        together_plot(curva)
    end
text_trace=uicontrol(fig_general,'style','text','parent',hp_movetrace,...
        'units','normalized','position',[0.5231 0.2822 0.4146 0.3980],...
        'string',['Number of Traces = ' num2str(length(curva))]);


  bmenos = uicontrol('style','pushbutton','parent',hp_movetrace,...
        'units','normalized','position',[0.0327 0.0100 0.4500 0.3000],...
        'string','-',...
        'callback',@minus);
    function minus(~,~)
        if ind_trace(1) < 2
            ind_trace = [1];
        else
            ind_trace = ind_trace-1;
        end
        set(edit_numtrace,'string',num2str(ind_trace));
        individual_plot(ind_trace)
      %  individual_plot_vth(ind_trace);
    end

 bmas = uicontrol('style','pushbutton','parent',hp_movetrace,...
        'units','normalized','position',[0.5231 0.0100 0.4500 0.3000],...
        'string','+',...
        'callback',@mas);
    function mas(~,~)
        if ind_trace(end) > (length(curva)-1)
            ind_trace = [length(curva)-1   length(curva)];
        else
            ind_trace = ind_trace+1;
        end
        set(edit_numtrace,'string',num2str(ind_trace));
        individual_plot(ind_trace)
      %  individual_plot_vth(ind_trace);
    end

bzero = uicontrol('style','pushbutton','parent',hp_movetrace,...
    'units','normalized','position',[0.0327 0.3408 0.4500 0.3000],...
    'string','Reset',...
    'callback',@res);
    function res(~,~)
        ind_trace = [1];
        set(edit_numtrace,'string',num2str(ind_trace));
        individual_plot(ind_trace)
       % individual_plot_vth(ind_trace);
    end


hp_parameters = uipanel(fig_general,'position',[0.0096 0.1463 0.1559 0.1769]);

tx_time = uicontrol('style','text','parent',hp_parameters,...
    'units','normalized','position',[0.0285 0.1147 0.2900 0.1389],...
    'string','Time (s)');

ed_time = uicontrol('style','edit','parent',hp_parameters,...
    'units','normalized','position',[0.3285 0.0726 0.6400 0.2000],...
    'string',num2str(limits_gen(1,:)),'value',limits_gen(1,:),...
    'callback',@edfun_time);
    function edfun_time(~,~)
         limits_gen(1,:) = str2num(get(ed_time ,'string'));
         individual_plot(ind_trace);
         together_plot(curva);
    end

tx_cond = uicontrol('style','text','parent',hp_parameters,...
    'units','normalized','position',[0.0285 0.2645 0.2900 0.1905],...
    'string','G(G0)');

ed_g = uicontrol('style','edit','parent',hp_parameters,...
    'units','normalized','position',[0.3285 0.2883 0.6400 0.2000],...
    'string',num2str(limits_gen(2,:)),'value',limits_gen(2,:),...
    'callback',@edfun_g);
    function edfun_g(~,~)
         limits_gen(2,:) = str2num(get(ed_g ,'string'));
         individual_plot(ind_trace);
         together_plot(curva);
    end

tx_vth = uicontrol('style','text','parent',hp_parameters,...
    'units','normalized','position',[0.0285 0.4783 0.2900 0.1816],...
    'string','Vth (mV)');

ed_vth = uicontrol('style','edit','parent',hp_parameters,...
    'units','normalized','position',[0.3285 0.4931 0.6400 0.2000],...
    'string',num2str(limits_gen(3,:)),'value',limits_gen(3,:),...
    'callback',@edfun_vth);
    function edfun_vth(~,~)
         limits_gen(3,:) = str2num(get(ed_vth ,'string'));
         individual_plot(ind_trace);
    end

tx_s = uicontrol('style','text','parent',hp_parameters,...
    'units','normalized','position',[0.0285 0.7265 0.2900 0.1576],...
    'string','S (uV/K)');

ed_s = uicontrol('style','edit','parent',hp_parameters,...
    'units','normalized','position',[0.3285 0.7197 0.6400 0.2000],...
    'string',num2str(limits_gen(4,:)),'value',limits_gen(4,:),...
    'callback',@edfun_s);
    function edfun_s(~,~)
         limits_gen(4,:) = str2num(get(ed_s ,'string'));
         individual_plot(ind_trace);
    end

hp_options = uipanel(fig_general,'position',[0.0102 0.3288 0.1559 0.2194]);

chk_seeb = uicontrol('style','checkbox','parent',hp_options,...
    'units','normalized','position',[0.0442 0.0476 0.3894 0.1746],...
    'string','Seebeck','Value',1,'callback',@check_sb);
    function check_sb(~,~)
        seebeck_bool = chk_seeb.Value;
        individual_plot(ind_trace);
        together_plot(curva);
    end

chk_hist = uicontrol('style','checkbox','parent',hp_options,...
    'units','normalized','position',[0.0408 0.2046 0.3894 0.1746],...
    'string','2D Hist','Value',1,'callback',@check_hist);
    function check_hist(~,~)
        hist_bool = chk_hist.Value;
        individual_plot(ind_trace);
        together_plot(curva);
    end

chk_pf = uicontrol('style','checkbox','parent',hp_options,...
    'units','normalized','position',[0.0408 0.3684 0.3894 0.1746],...
    'string','Power F','Value',0,'callback',@check_pf);
    function check_pf(~,~)
        pf_bool = chk_pf.Value;
        individual_plot(ind_trace);
        together_plot(curva);
    end

chk_mean = uicontrol('style','checkbox','parent',hp_options,...
    'units','normalized','position',[0.0408 0.3684 0.3894 0.1746],...
    'string','Mean Trace','Value',0,'callback',@check_mean);
    function check_mean(~,~)
        mean_bool = chk_mean.Value;
        individual_plot(ind_trace);
        together_plot(curva);
    end

but_save = uicontrol('style','pushbutton','parent',hp_options,...
    'units','normalized','position',[0.4712 0.0521 0.4799 0.1730],...
    'string','Save','callback',@fun_save);
    function fun_save(~,~)
        but_save.BackgroundColor = [1 0 0];
        but_save.String = 'Wait...';
        save([file_path '\' title1 '_Cluster'],'curva', '-v7.3');
         but_save.BackgroundColor = [0.9400    0.9400    0.9400];
         but_save.String = 'Save';
        disp('File saved');
    end
but_divide = uicontrol('style','pushbutton','parent',hp_options,...
    'units','normalized','position',[0.4712 0.2521 0.4799 0.1730],...
    'string','Div S','callback',@fun_div);
    function fun_div(~,~)
       
        lc = length(curva);
        curva_pos = struct;
        curva_neg = struct;
        curva_both =struct;
        indicep = 0;
        indicen =0;
        indiceb =0;
        DP =[];
        DN =[];
        DB =[];

        SP =[];
        SN =[];
        SB =[];

        for j1 = 1:lc
            vth = curva(j1).vth;
            piezo = curva(j1).piezoV;
            xx = linspace(1,length(curva(j1).z),length(curva(j1).z))*462e-6;   % Sampling ratre 462 us
            dp = diff(smooth(piezo));
            Temp = curva(j1).Temp;
            dp_zer = dp-min(dp);
            dp_norm = dp_zer/max(dp_zer);
            
            vth_stop = -vth(dp_norm==1);
            x_stop = xx(dp_norm==1);
            dt=x_stop(end)-x_stop(1);

            pos_vth = length(vth_stop(vth_stop>0));
           % neg_vth = length(vth_stop(vth_stop<0));
           divis = 4;
           thres = length(vth_stop)/divis;
           if dt<0.02
               type_trace(j1)=4;
               continue;

           end

           if pos_vth>=(length(vth_stop)-thres)
               %classt = 'Positive';
               type_trace(j1)=1;
               DP = [DP; dt];
               SP = [SP; mean(vth_stop*1e6)/Temp];
           end
           if pos_vth<=thres
               %classt = 'Negative';
               type_trace(j1)=2;
               DN = [DN; dt];
               SN = [SN; mean(vth_stop*1e6)/Temp];
           end
           %  if thres<pos_vth<(length(vth_stop)-thres)
           if (thres<pos_vth) && (pos_vth<(length(vth_stop)-thres))
               %classt = 'Both';
               type_trace(j1)=3;
               DB = [DB; dt];
               SB = [SB; mean(vth_stop*1e6)/Temp];
           end

        end
           curva_pos = curva(type_trace==1);
           curva_neg = curva(type_trace==2);
           curva_both =curva(type_trace==3);
           superpinta(curva_pos,[title1 '_Positive'],file_path)
           superpinta(curva_neg,[title1 '_Negative'],file_path)
           superpinta(curva_both,[title1 '_Both'],file_path)
           per_short=length(type_trace(type_trace==4))*100/length(curva);
           per_pos = length(curva_pos)*100/length(curva);
           per_neg = length(curva_neg)*100/length(curva);
           per_both = length(curva_both)*100/length(curva);
           disp(['Positive = ' num2str(round(per_pos)) '%'])
           disp(['Negative = ' num2str(round(per_neg)) '%'])
           disp(['Both = ' num2str(round(per_both)) '%'])
           disp(['Short = ' num2str(round(per_short)) '%'])

           figure
          % plot(DB,2*ones(length(DB)),'.')
          plot(DB,SB,'-')
           hold on
           plot(DN,SN,'-')
           plot(DP,SP,'-')
          % plot(mean(DB),2,'+k')
          % plot(DP,3*ones(length(DP)),'.')
          % plot(mean(DP),3,'+k')
          % plot(DN,1*ones(length(DN)),'.')
          % plot(mean(DN),1,'+k')
          % ylim([0.5 3.5])
    end

but_sel_trace = uicontrol('style','pushbutton','parent',hp_options,...
    'units','normalized','position',[0.05 0.6521 0.4799 0.1730],...
    'string','Sel Trace','callback',@fun_sel_trace);
    function fun_sel_trace(~,~)
        traces_selected = input('');
        curva_sel = struct;
        for k2 =1:length(curva)
            index_curva=find(traces_selected==k2);
           % trace_ind = traces_selected(k2);
            if ~isempty(index_curva)
                type_trace(k2)=1;
            else
                type_trace(k2)=0;

            end
           % curva_sel(k2)=curva(trace_ind);
        end
        curva_sel = curva(type_trace==1);
        superpinta(curva_sel,[title1 '_Selected'],file_path)

    end

but_divide_bounds = uicontrol('style','pushbutton','parent',hp_options,...
    'units','normalized','position',[0.4712 0.6521 0.4799 0.1730],...
    'string','Div Bound','callback',@fun_div_bounds);
    function fun_div_bounds(~,~)
       
        lc = length(curva);
        curva_pos = struct;
      %  curva_neg = struct;
      %  curva_both =struct;
        indicep = 0;
       % indicen =0;
       % indiceb =0;
        for j1 = 1:lc
               
            yy = log10(real(curva(j1).g));
            vth = curva(j1).vth;
            k = (vth> limits_gen(3,1) & vth< limits_gen(3,2) & yy>limits_gen(2,1) & yy<limits_gen(2,2));
            
            piezo = curva(j1).piezoV(k);
            vth = vth(k);
            xx = linspace(1,length(piezo),length(piezo))*462e-6;  
            
            % Sampling ratre 462 us
            dp = diff(smooth(piezo));
            dp1 = dp-dp(1);
            dp_pos = dp1(dp1>0);
            dif_difpos = abs(diff(dp_pos));
            dd_norm = dif_difpos/max(dif_difpos);

            num_slopes = length(dd_norm(dd_norm>0.4));

          
           % neg_vth = length(vth_stop(vth_stop<0));
           
           if num_slopes<40
               type_trace(j1)=1;
               continue;

           end

           
       

        end
           curva_pos = curva(type_trace==1);
          % curva_neg = curva(type_trace==2);
          % curva_both =curva(type_trace==3);
           superpinta(curva_pos,[title1 '_Stable'],file_path)
         %  superpinta(curva_neg,[title1 '_Negative'],file_path)
         %  superpinta(curva_both,[title1 '_Both'],file_path)
         %  per_short=length(type_trace(type_trace==4))*100/length(curva);
           per_pos = length(curva_pos)*100/length(curva);
         %  per_neg = length(curva_neg)*100/length(curva);
        %   per_both = length(curva_both)*100/length(curva);
           disp(['Stable = ' num2str(round(per_pos)) '%'])
       %    disp(['Negative = ' num2str(round(per_neg)) '%'])
       %    disp(['Both = ' num2str(round(per_both)) '%'])
       %    disp(['Short = ' num2str(round(per_short)) '%'])
    end

but_dividet = uicontrol('style','pushbutton','parent',hp_options,...
    'units','normalized','position',[0.4712 0.4521 0.4799 0.1730],...
    'string','Div Time','callback',@fun_divt);
    function fun_divt(~,~)

        lc = length(curva);
        curva_short = struct;
        curva_long = struct;
        Spos = [];
        Sneg = [];
        DT = [];

        f_time = figure('units','normalized','position',[0.0786 0.2574 0.7901 0.5111]);
        ax1_time = axes(f_time,'units','normalized','position',[0.0858 0.2002 0.3671 0.7179]);
        ax2_time = axes(f_time,'units','normalized','position',[0.6 0.2002 0.3671 0.7179]);
        ylabel(ax2_time,'Seebeck (\muV/K)')
        xlabel(ax2_time,'Time (s)')

        xlabel(ax1_time,'Time (s)')
        ylabel(ax1_time,'Counts')
        

        indicep = 0;
        indicen =0;
        indiceb =0;
        for j1 = 1:lc
            vth = curva(j1).vth;
            piezo = curva(j1).piezoV;
            xx = linspace(1,length(curva(j1).z),length(curva(j1).z))*462e-6;   % Sampling ratre 462 us
            Temp = curva(j1).Temp;

            dp = diff(smooth(piezo));
            dp_zer = dp-min(dp);
            dp_norm = dp_zer/max(dp_zer);
            
            vth_stop = -(vth(dp_norm==1)*1e6)/Temp;
            x_stop = xx(dp_norm==1);
            dt=x_stop(end)-x_stop(1);
            

            pos_vth = length(vth_stop(vth_stop>0));
           % neg_vth = length(vth_stop(vth_stop<0));
           divis = 4;
           thres = length(vth_stop)/divis;
           if dt<0.05
              type_trace(j1)=2;
              continue;
           else
               type_trace(j1) =1 ;

           end
          
           
       

        end


        Nhist = 50;
        % [Np,edgesp] = histcounts(Spos(Spos<0.8),Nhist);%, 'Normalization', 'pdf');
        % xx5p=(edgesp(1:end-1)+edgesp(2:end))/2;
        % 
        % [Nn,edgesn] = histcounts(Sneg(Spos<0.8),Nhist);%, 'Normalization', 'pdf');
        % xx5n=(edgesn(1:end-1)+edgesn(2:end))/2;

        % 
        % 
        % plot(ax1_time,xx5p,Np);
        % hold(ax1_time,'on')
        % plot(ax1_time,xx5n,Nn);
        % legend(ax1_time,'Positive','Negative')


            
        %     plot(ax1_tog,N,xx5,'linewidth',1);
        curva_short = curva(type_trace==2);
        curva_long = curva(type_trace==1);
        
       % superpinta(curva_short,[title1 '_Short'],file_path)
        superpinta(curva_long,[title1 '_Long'],file_path)
        % 
        %per_short=length(type_trace(type_trace==1))*100/length(curva);
        % per_long=length(type_trace(type_trace==2))*100/length(curva);
        % 
        % disp(['Short = ' num2str(round(per_short)) '%'])
        % disp(['Long = ' num2str(round(per_long)) '%'])
    end

hp_cluster = uipanel(fig_general,'position',[0.0102 0.6 0.1559 0.2194]);
ed_numclus = uicontrol('style','edit','parent',hp_cluster,...
    'units','normalized','position',[0.0080 0.0094 0.2844 0.1738],...
    'string',num2str(clust_number),'Value',clust_number,'callback',@fun_numberclust);
    function fun_numberclust(~,~)
        clust_number = str2num(get(ed_numclus ,'string'));

    end

but_clustPF = uicontrol('style','pushbutton','parent',hp_cluster,...
    'units','normalized','position',[0.63 0.0109 0.3249 0.1730],...
    'string','ClustPF','callback',@fun_CPF);
    function fun_CPF(~,~)
        DTG2 = histo2PF(curva);
        nclust=clust_number;
        sz = size(DTG2);
        M = reshape(DTG2,sz(1)*sz(2),sz(3));
        [icx,C,sumd,D]=doclusters(M',nclust);
        for k=1:nclust
            curk = curva(icx==k);
            nuk = length(curk);
            superpinta(curk,[title1 '_ClusterPF' num2str(k)],file_path);  
        end
    end

but_clustSG = uicontrol('style','pushbutton','parent',hp_cluster,...
    'units','normalized','position',[0.63 0.19 0.3249 0.1730],...
    'string','ClustSG','callback',@fun_CSG);
    function fun_CSG(~,~)
        DTG2 = histo2SG(curva);
        nclust=clust_number;
        sz = size(DTG2);
        M = reshape(DTG2,sz(1)*sz(2),sz(3));
        [icx,C,sumd,D]=doclusters(M',nclust);
        for k=1:nclust
            curk = curva(icx==k);
            nuk = length(curk);
            superpinta(curk,[title1 '_ClusterSG' num2str(k)],file_path);  
        end
    end

but_datats = uicontrol('style','pushbutton','parent',hp_cluster,...
    'units','normalized','position',[0.63 0.55 0.3249 0.1730],...
    'string','Data ST','callback',@fun_datast);
    function fun_datast(~,~)
        lc = length(curva);
        DP =[];
        SP =[];

        for j1 = 1:lc
            vth = curva(j1).vth;
            piezo = curva(j1).piezoV;
            xx = linspace(1,length(curva(j1).z),length(curva(j1).z))*462e-6;   % Sampling ratre 462 us
            dp = diff(smooth(piezo));
            Temp = curva(j1).Temp;
            dp_zer = dp-min(dp);
            dp_norm = dp_zer/max(dp_zer);
            vth_stop = -vth(dp_norm==1);
            piezoV_stop = piezo(dp_norm==1);
            x_stop = xx(dp_norm==1);
            dt=x_stop(end)-x_stop(1);
            DP = [DP; dt];
            SP = [SP; mean(vth_stop*1e6)/Temp];
        end
        figure
        plot(DP,SP);
        disp(['MeanTime = ' num2str(mean(DP))]);
        disp(['STDTime = ' num2str(std(DP))]);
    end

but_timestat = uicontrol('style','pushbutton','parent',hp_cluster,...
    'units','normalized','position',[0.63 0.37 0.3249 0.1730],...
    'string','TimeStat','callback',@fun_timestat);
    function fun_timestat(~,~)
         
        for j1 = 1:length(curva)
           
            %vth = curva(j1).vth;
            piezo = curva(j1).piezoV;
            xx = linspace(1,length(curva(j1).z),length(curva(j1).z))*462e-6;   % Sampling ratre 462 us
            %Temp = curva(j1).Temp;

            dp = diff(smooth(piezo));
            dp_zer = dp-min(dp);
            dp_norm = dp_zer/max(dp_zer);

            x_stop = xx(dp_norm==1);
            time_trace(j1) = x_stop(end)-x_stop(1);
        end
        mean(time_trace)
        std(time_trace)
        disp('f')
        
    end


but_clustST = uicontrol('style','pushbutton','parent',hp_cluster,...
    'units','normalized','position',[0.3082 0.0109 0.3249 0.1730],...
    'string','ClustST','callback',@fun_CST);
    function fun_CST(~,~)
        DTG2 = histo2M(curva);
        nclust=clust_number;
        sz = size(DTG2);
        M = reshape(DTG2,sz(1)*sz(2),sz(3));
        [icx,C,sumd,D]=doclusters(M',nclust);
        for k=1:nclust
            curk = curva(icx==k);
            nuk = length(curk);
            superpinta(curk,[title1 '_ClusterST' num2str(k)],file_path);  
        end

    end
but_clustGT = uicontrol('style','pushbutton','parent',hp_cluster,...
    'units','normalized','position',[0.3082 0.19 0.3249 0.1730],...
    'string','ClustGT','callback',@fun_CGT);
    function fun_CGT(~,~)
        DTG2 = histo2GT(curva);
        nclust=clust_number;
        sz = size(DTG2);
        M = reshape(DTG2,sz(1)*sz(2),sz(3));
        [icx,C,sumd,D]=doclusters(M',nclust);
        for k=1:nclust
            curk = curva(icx==k);
            nuk = length(curk);
            superpinta(curk,[title1 '_ClusterGT' num2str(k)],file_path);  
        end

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

    function M2Mx = histo2PF(curstruct)
        edges2y = linspace(0,1,40);
        edges2x = linspace(limits_gen(1,1),limits_gen(1,2),30);
        centers2y = (edges2y(1:end-1)+edges2y(2:end))/2;
        centers2x = (edges2x(1:end-1)+edges2x(2:end))/2;
        mh = zeros(29-1);
        for k2=1:length(curstruct)
            xx = linspace(1,length(curstruct(k2).z),length(curstruct(k2).z))*462e-6;   % Sampling ratre 462 us
            yy = log10(curstruct(k2).g);
            xx_zer1 = (xx(yy>-0.5 & yy<0.1));
            vth = curstruct(k2).vth;
            Temp = curstruct(k2).Temp;
            Seeb = -vth*1e6./Temp;

            if isempty(xx_zer1)
                xx_zer =0;
            else
                xx_zer = xx_zer1(end);
            end
            xx_norm = xx-xx_zer;
            x_cut = xx_norm(yy>limits_gen(2,1) & yy<limits_gen(2,2));
            seeb_cut = Seeb(yy>limits_gen(2,1) & yy<limits_gen(2,2));
            yy_cut = yy(yy>limits_gen(2,1) & yy<limits_gen(2,2));
            cond_stop = (10.^yy_cut)*7.75e-5; % Simens
            s_stop = seeb_cut*1e-6; % V/K
            PF_cut = real(((s_stop.^2).*cond_stop)*1e15); % Fempto PF
            PF_norm = PF_cut/max(PF_cut);

            mh = histcounts2(x_cut',PF_norm,edges2x,edges2y);
            M2Mx(:,:,k2) = mh';
        end
    end

    function M2Mx = histo2M(curstruct)
        edges2y = linspace(limits_gen(4,1),limits_gen(4,2),40);
        edges2x = linspace(limits_gen(1,1),limits_gen(1,2),30);
        centers2y = (edges2y(1:end-1)+edges2y(2:end))/2;
        centers2x = (edges2x(1:end-1)+edges2x(2:end))/2;
        mh = zeros(29-1);
        for k2=1:length(curstruct)
            xx = linspace(1,length(curstruct(k2).z),length(curstruct(k2).z))*462e-6;   % Sampling ratre 462 us
            yy = log10(curstruct(k2).g);
            xx_zer1 = (xx(yy>-0.5 & yy<0.1));
            vth = curstruct(k2).vth;
            Temp = curstruct(k2).Temp;
            Seeb = -vth*1e6./Temp;

            if isempty(xx_zer1)
                xx_zer =0;
            else
                xx_zer = xx_zer1(end);
            end
            xx_norm = xx-xx_zer;
            x_cut = xx_norm(yy>limits_gen(2,1) & yy<limits_gen(2,2));
            seeb_cut = Seeb(yy>limits_gen(2,1) & yy<limits_gen(2,2));

            mh = histcounts2(x_cut',seeb_cut,edges2x,edges2y);
            M2Mx(:,:,k2) = mh';
        end
    end

    function M2Mx = histo2SG(curstruct)
        edges2y = linspace(limits_gen(4,1),limits_gen(4,2),40);
        edges2x = linspace(limits_gen(2,1),limits_gen(2,2),30);
        centers2y = (edges2y(1:end-1)+edges2y(2:end))/2;
        centers2x = (edges2x(1:end-1)+edges2x(2:end))/2;
        mh = zeros(29-1);
        for k2=1:length(curstruct)
            xx = linspace(1,length(curstruct(k2).z),length(curstruct(k2).z))*462e-6;   % Sampling ratre 462 us
            yy = log10(curstruct(k2).g);
            xx_zer1 = (xx(yy>-0.5 & yy<0.1));
            vth = curstruct(k2).vth;
            Temp = curstruct(k2).Temp;
            Seeb = -vth*1e6./Temp;

            if isempty(xx_zer1)
                xx_zer =0;
            else
                xx_zer = xx_zer1(end);
            end
            xx_norm = xx-xx_zer;
            x_cut = xx_norm(yy>limits_gen(2,1) & yy<limits_gen(2,2));
            seeb_cut = Seeb(yy>limits_gen(2,1) & yy<limits_gen(2,2));
            yy_cut = real(yy(yy>limits_gen(2,1) & yy<limits_gen(2,2)));
            [y_sorted,I] = sort(yy_cut);
            seeb_sorted = seeb_cut(I);

            mh = histcounts2(y_sorted,seeb_sorted,edges2x,edges2y);
            M2Mx(:,:,k2) = mh';
        end
    end

    function M2Mx = histo2GT(curstruct)
        edges2y = linspace(limits_gen(2,1),limits_gen(2,2),40);
        edges2x = linspace(limits_gen(1,1),limits_gen(1,2),30);
        centers2y = (edges2y(1:end-1)+edges2y(2:end))/2;
        centers2x = (edges2x(1:end-1)+edges2x(2:end))/2;
        mh = zeros(29-1);
        for k2=1:length(curstruct)
            xx = linspace(1,length(curstruct(k2).z),length(curstruct(k2).z))*462e-6;   % Sampling ratre 462 us
            yy = log10(curstruct(k2).g);
            xx_zer1 = (xx(yy>-0.5 & yy<0.1));
            vth = curstruct(k2).vth;
            Temp = curstruct(k2).Temp;
            Seeb = -vth*1e6./Temp;

            if isempty(xx_zer1)
                xx_zer =0;
            else
                xx_zer = xx_zer1(end);
            end
            xx_norm = xx-xx_zer;
            x_cut = xx_norm(yy>limits_gen(2,1) & yy<limits_gen(2,2));
            seeb_cut = Seeb(yy>limits_gen(2,1) & yy<limits_gen(2,2));
            yy_cut = real(yy(yy>limits_gen(2,1) & yy<limits_gen(2,2)));
            % [y_sorted,I] = sort(yy_cut);
            % seeb_sorted = seeb_cut(I);

            mh = histcounts2(x_cut',yy_cut,edges2x,edges2y);
            M2Mx(:,:,k2) = mh';
        end
    end

individual_plot(ind_trace);
together_plot(curva);

    function together_plot(curve_tog)
        cla(ax1_tog)
        cla(ax2_tog)
        cla(ax3_tog)
        lc = length(curve_tog);
        XX= [];
        YY= [];
        VTH = [];
        STOT = [];
        XX_total = [];
        YY_total = [];

        for j1=1:lc

            xx = linspace(1,length(curva(j1).z),length(curva(j1).z))*462e-6;   % Sampling ratre 462 us
            yy = log10(real(curva(j1).g));
            piezo = curva(j1).piezoV;
            vth = curva(j1).vth*1e3;
            Temp = curva(j1).Temp;

            xx_zer1 = (xx(yy>-0.5 & yy<0.1));
            if ~isempty(xx_zer1)
                xx_zer = xx_zer1(end);
            else
                xx_zer = 0;
            end
            xx_norm = xx-xx_zer';

            dp = diff(smooth(piezo));
            dp_zer = dp-min(dp);
            dp_norm = dp_zer/max(dp_zer);

            x_stop = xx_norm(dp_norm==1);
            y_stop = yy(dp_norm==1);
            vth_stop = vth(dp_norm==1);


            XX= [XX, x_stop];
            XX_total = [XX_total; xx_norm'];
            YY_total = [YY_total; yy];
            YY= [YY, y_stop'];
            VTH = [VTH, vth_stop'];
            STOT = [STOT, -vth_stop'*1e3/Temp];

        end

        XX_cut = XX(YY>limits_gen(2,1) & YY<limits_gen(2,2) & VTH>limits_gen(3,1) & VTH<limits_gen(3,2));
        YY_cut = YY(YY>limits_gen(2,1) & YY<limits_gen(2,2) & VTH>limits_gen(3,1) & VTH<limits_gen(3,2));
        VTH_cut = VTH(YY>limits_gen(2,1) & YY<limits_gen(2,2) & VTH>limits_gen(3,1) & VTH<limits_gen(3,2));
        S_cut = STOT(YY>limits_gen(2,1) & YY<limits_gen(2,2) & VTH>limits_gen(3,1) & VTH<limits_gen(3,2));

        if hist_bool==0

            [N,edges] = histcounts(real(YY_cut),50);%, 'Normalization', 'pdf');
           % [N,edges] = histcounts(real(XX_cut),100);%, 'Normalization', 'pdf');
            xx5=(edges(1:end-1)+edges(2:end))/2;
            plot(ax1_tog,N,xx5,'linewidth',1);
            ylim(ax1_tog,[limits_gen(2,:)]);
            %ylim(ax1_tog,[limits_gen(1,:)]);
            ylabel(ax1_tog,'log(\it{G}/\it{G_0})');
            xlabel(ax1_tog,[]);
            xticklabels(ax1_tog,[]);

            if seebeck_bool ==0
                [Nv,edgesv] = histcounts(real(VTH_cut),100);%, 'Normalization', 'pdf');
                xx5v=(edgesv(1:end-1)+edgesv(2:end))/2;
                plot(ax2_tog,Nv,xx5v,'linewidth',1);
                ylim(ax2_tog,[limits_gen(3,:)]);
                xlim(ax2_tog,[0 max(Nv)]);
                ylabel(ax2_tog,'V_{th}(mV)');
                xlabel(ax2_tog,[]);
                xticklabels(ax2_tog,[]);
            else
                [Nv,edgesv] = histcounts(real(S_cut),50);%, 'Normalization', 'pdf');
                xx5v=(edgesv(1:end-1)+edgesv(2:end))/2;
                plot(ax2_tog,Nv,xx5v,'linewidth',1);
                ylim(ax2_tog,[limits_gen(4,:)]);
                xlim(ax2_tog,[0 max(Nv)]);
                ylabel(ax2_tog,'Seebeck (\muV/K)');
                xlabel(ax2_tog,[]);
                %xticklabels(ax2_tog,[]);

            end

        else

            eje0=[limits_gen(1,1),limits_gen(1,2),limits_gen(2,1),limits_gen(2,2)];
            zero_g = linspace(limits_gen(2,1),limits_gen(2,2),200);
            zero_s = zeros(200);
            nhi20=100;
            %f1=figure
            namess{1}='2D';
            axesLabel={'Time (s)','log({\itG}/{\itG_0})'};
            Hist2D(ax1_tog,XX_cut',YY_cut',eje0,0.6,nhi20,namess,axesLabel,0.4);
          %Hist2D(ax1_tog,XX_total,YY_total,eje0,0.6,nhi20,namess,axesLabel,0.3);
            ylim(ax1_tog,[limits_gen(2,1)-0.1,limits_gen(2,2)+0.1]);
            xlim(ax1_tog,[limits_gen(1,1)-0.03,limits_gen(1,2)+0.03]);
           

            if seebeck_bool ==0
                eje2=[limits_gen(2,1),limits_gen(2,2),limits_gen(3,1),limits_gen(3,2)];
                nhi20=30;
                %f1=figure
                namess{1}='2D';
                axesLabel={'log(G/G_0)','V_{th}'};
                Hist2D(ax2_tog,real(YY_cut'),VTH_cut',eje2,0.8,nhi20,namess,axesLabel,0.2);
                 if mean_bool ==1
                    g_range=linspace(limits_gen(2,1),limits_gen(2,2),300);
                    G = real(YY_cut);
                    for g1=1:length(g_range)-1
                        V_mean(g1) = mean(VTH_cut(G>g_range(g1) & G<g_range(g1+1)));
                        G_mean(g1) = (g_range(g1)+g_range(g1+1))/2;
                    end
                    hold(ax2_tog,'on')
                    plot(G_mean,V_mean,'k','linewidth',1.5)

                 end
                 
                xlim(ax2_tog,[limits_gen(2,1)-0.1,limits_gen(2,2)+0.1]);
                ylim(ax2_tog,[limits_gen(3,1)-0.03,limits_gen(3,2)+0.03]);
            else
                eje2=[limits_gen(2,1),limits_gen(2,2),limits_gen(4,1),limits_gen(4,2)];
                % eje2=[limits_gen(1,1),limits_gen(1,2),limits_gen(4,1),limits_gen(4,2)];
                nhi20=30;
                namess{1}='2D';
                axesLabel={'log(\it{G}/\it{G_0})','Seebeck Coeff. (\muV/K)'};
                Hist2D(ax2_tog,real(YY_cut'),S_cut',eje2,0.8,nhi20,namess,axesLabel,0.2);
               %  Hist2D(ax2_tog,real(XX_cut'),S_cut',eje2,0.8,nhi20,namess,axesLabel,0.2);
                hold(ax2_tog,'on')
                plot(ax2_tog,zero_g,zero_s,'--k')
                %  xlim(ax2_tog,[limits_gen(2,1)-0.1,limits_gen(2,2)+0.1]);
                %  ylim(ax2_tog,[limits_gen(4,1)-1,limits_gen(4,2)+1]);
                        % f_ext=figure;
                        % ax_ext=axes(f_ext);
                        % Hist2D(ax_ext,real(YY_cut'),S_cut',eje2,1,nhi20,namess,axesLabel,0.2);
                        %  hold(ax_ext,'on')
                        % plot(ax_ext,zero_g,zero_s,'--k','linewidth',1)
                        % xlim(ax_ext,[limits_gen(2,1)-0.1,limits_gen(2,2)+0.1]);
                        % ylim(ax_ext,[limits_gen(4,1)-1,limits_gen(4,2)+1]);
                        % set(ax_ext,'linewidth',1.5,'fontsize',12)

                cond_stop = (10.^YY_cut)*7.75e-5; % Simens
                s_stop = S_cut*1e-6; % V/K
                PF_cut = ((s_stop.^2).*cond_stop)*1e15; % Fempto PF
                eje3=[limits_gen(1,1),limits_gen(1,2),-0.002,0.2];
                nhi20=40;
                namess{1}='2D';
                axesLabel={'Time (s)','PF (fW/K^2)'};
                Hist2D(ax3_tog,real(XX_cut'),PF_cut',eje3,0.8,nhi20,namess,axesLabel,0.0006);
                xlim(ax3_tog,[limits_gen(1,1)-0.01,limits_gen(1,2)+0.01]);
                ylim(ax3_tog,[-0.0025,0.2005]);
                
                


                if mean_bool ==1
                    g_range=linspace(limits_gen(2,1),limits_gen(2,2),300);
                    G = real(YY_cut);
                    for g1=1:length(g_range)-1
                        S_mean(g1) = mean(S_cut(G>g_range(g1) & G<g_range(g1+1)));
                        G_mean(g1) = (g_range(g1)+g_range(g1+1))/2;
                    end
                    hold(ax2_tog,'on')
                    plot(G_mean,S_mean,'k','linewidth',1.5)

                end
                xlim(ax2_tog,[limits_gen(2,1)-0.1,limits_gen(2,2)+0.1]);
               % xlim(ax2_tog,[limits_gen(1,1)-0.01,limits_gen(1,2)+0.01]);
                ylim(ax2_tog,[limits_gen(4,1)-1,limits_gen(4,2)+1]);

            end


        end

    end
    
    function individual_plot(ind_plot_ini)
        cla(ax1_ind)
        cla(ax2_ind)
        cla(ax3_ind)
        cla(ax4_ind)
        cla(ax1_ind)

        length_tra = length(ind_plot_ini);

        for k3 = 1:length_tra

            ind_plot = ind_plot_ini(k3);

            y_zero = zeros(1,500);
            xx = linspace(1,length(curva(ind_plot).z),length(curva(ind_plot).z))*462e-6;   % Sampling ratre 462 us
            yy = log10(curva(ind_plot).g);
            xx_zer1 = (xx(yy>-0.5 & yy<0.1));
            if isempty(xx_zer1)
                xx_zer =0;
            else
                xx_zer = xx_zer1(end);
            end
            xx_norm = xx-xx_zer;
            x_zero = linspace(xx_norm(1),xx_norm(end),500);
            x_zerog = linspace(limits_gen(2,1),limits_gen(2,2),500);
            piezo = curva(ind_plot).piezoV;
            dp = diff(smooth(piezo));
            dp_zer = dp-min(dp);
            dp_norm = dp_zer/max(dp_zer);


            vth = curva(ind_plot).vth;
           % % Just for plotting bigger than -5
           % vth = vth(yy>-5);
           % xx_cut = 
            % Just for plotting bigger than -5
            mvth = mean(vth);

            x_stop = xx_norm(dp_norm==1);
            y_stop = yy(dp_norm==1);
            vth_stop = vth(dp_norm==1);

            pos_vth = length(vth_stop(vth_stop>0));
            neg_vth = length(vth_stop(vth_stop<0));
            divis = 4;
            thres = length(vth_stop)/divis;

            if pos_vth>=(length(vth_stop)-thres)
                classt = 'Positive';
            end
            if pos_vth<=thres
                classt = 'Negative';
            end
          %  if thres<pos_vth<(length(vth_stop)-thres)
            if (thres<pos_vth) && (pos_vth<(length(vth_stop)-thres))
                classt = 'Both';
            end

            plot(ax2_ind,x_zero,y_zero,'--k')
            hold(ax2_ind,'on')

            plot(ax3_ind,x_zerog,y_zero,'--k')
            hold(ax3_ind,'on')

            yyaxis(ax1_ind,'left')
            plot(ax1_ind,real(xx_norm),real(yy),'-b')
            hold(ax1_ind,'on')
            plot(ax1_ind,real(x_stop),real(y_stop),'color',[0.3 0.44 0.12],'LineStyle','-')
            ylabel(ax1_ind,'log(G/G0)')
            ylim(ax1_ind,limits_gen(2,:))

            yyaxis(ax1_ind,'right')
            plot(ax1_ind,xx_norm,piezo,'--r')
            ylabel(ax1_ind,'Piezo movement (a.u.)')
            xlabel(ax1_ind,[])
            xticklabels(ax1_ind,[])
            legend(ax1_ind,classt)
            

            if seebeck_bool==0
                Temp = curva(ind_plot).Temp;
                xx_cut = xx_norm(yy>-5);
                vth_cut = vth(yy>-5);
                plot(ax2_ind,xx_cut,vth_cut*1e3,'r')
                plot(ax2_ind,x_stop,vth_stop*1e3,'color',[0.3 0.44 0.12],'LineStyle','-')
                ylabel(ax2_ind,'V_{th} (mV)')
                xlabel(ax2_ind,[])
                xticklabels(ax2_ind,[]);
                ylim(ax2_ind,[limits_gen(3,1) limits_gen(3,2)]);
                xlim(ax2_ind,[limits_gen(1,1), xx_norm(end)])
                linkaxes([ax1_ind,ax2_ind],"x")
                legend(ax2_ind,['\DeltaT = ' num2str(Temp) 'K'],'Location','northwest');

                plot(ax3_ind,real(y_stop),real(vth_stop*1e3),'.','color',[0.3 0.44 0.12])
                xlabel(ax3_ind,'log(G/G_0)')
                ylabel(ax3_ind,'V_{th} (mV)')
                ylim(ax3_ind,[limits_gen(3,1) limits_gen(3,2)]);
                xlim(ax3_ind,limits_gen(2,:))

            else
                Temp = curva(ind_plot).Temp;
                xx_cut = xx_norm(yy>-4.8);
                vth_cut = vth(yy>-4.8);
                plot(ax2_ind,xx_cut,-vth_cut*1e6./Temp,'r')
                plot(ax2_ind,x_stop,-vth_stop*1e6./Temp,'color',[0.3 0.44 0.12],'LineStyle','-')
                ylabel(ax2_ind,'Seebeck (\muV/K)')
                xlabel(ax2_ind,[])
                xticklabels(ax2_ind,[]);
                ylim(ax2_ind,[limits_gen(4,1) limits_gen(4,2)]);
                xlim(ax2_ind,[limits_gen(1,1), xx_norm(end)])
                linkaxes([ax1_ind,ax2_ind,ax4_ind],"x")
                legend(ax2_ind,['\DeltaT = ' num2str(Temp) 'K']);

                vcut = vth(yy>limits_gen(2,1) & yy<limits_gen(2,2));
                gcut = yy(yy>limits_gen(2,1) & yy<limits_gen(2,2));

                plot(ax3_ind,gcut,-vcut*1e6./Temp,'.','color',[0.5 0.5 0.5])
                hold(ax3_ind,'on')
                plot(ax3_ind,y_stop,-vth_stop*1e6./Temp,'.','color',[0.3 0.44 0.12])
                xlabel(ax3_ind,'log(G/G_0)')
                ylabel(ax3_ind,'Seebeck (\muV/K)')
                ylim(ax3_ind,[limits_gen(4,1) limits_gen(4,2)]);
                xlim(ax3_ind,limits_gen(2,:))


            end
            con_low_lim = -4.7;
            cond_tot_log = yy(yy>con_low_lim & yy<-1);
            time_tot = xx_norm(yy>con_low_lim & yy<-1);
            vth_tot = vth(yy>con_low_lim & yy<-1); % Volts

            cond_tot_lin = (10.^cond_tot_log)*7.75e-5; % Simens
            s_tot = -vth_tot./Temp; % V/K
            pf_tot = (s_tot.^2).*cond_tot_lin;
            plot(ax4_ind,real(time_tot),real(pf_tot)*1e15,'.','color',[0.5 0.5 0.5])
            ylabel(ax4_ind,'Power Factor (fW/K^2)')
            xlabel(ax4_ind,'Time (s)')
            xlim(ax4_ind,[limits_gen(1,1), xx_norm(end)])
            hold(ax4_ind,'on')

            cond_stop = (10.^y_stop)*7.75e-5; % Simens
            s_stop = -vth_stop./Temp; % V/K
            pf_stop = (s_stop.^2).*cond_stop;
            plot(ax4_ind,real(x_stop),real(pf_stop)*1e15,'--.','color',[0.3 0.44 0.12])
            ylim(ax4_ind,[0, 0.01])
            box(ax4_ind,'on')

        end
        hold(ax1_ind,'off')
    end

end

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
%colm = load('Colormap_UCL_2.mat');

colm = load('mycolormap.mat');
%colm = load('CustomColormap4.mat'); 
colormap(colm.mycmap);
%colormap hsv;
%colormap(colm.CustomColormap4)
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


