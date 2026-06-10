function STM_GUI_PRO()

    clc; close all;

    % =========================
    % LOAD DATA
    % =========================
    curva = load_and_merge_data();

    % =========================
    % DEFAULT STATE
    % =========================
    state.curva = curva;

    state.xlimit = [-0.25 2];
    state.ylimit = [1e-5 3];
    state.vthlimit = [-1 1];
    state.slimit = [-15 15];

    state.filter_type = 'sgolay';
    state.filter_order = 1;

    state.Seebeck = 0;
    state.GS = 0;

    state.ind = [1 2]; % traces

    % =========================
    % GUI
    % =========================
    fig = figure('Name','STM GUI PRO','Position',[100 100 1200 700]);

    ax_main = axes(fig,'Position',[0.25 0.55 0.4 0.4]);
    ax_hist = axes(fig,'Position',[0.7 0.55 0.2 0.4]);
    ax_ind  = axes(fig,'Position',[0.25 0.1 0.4 0.3]);

    % =========================
    % LIMITS PANEL
    % =========================
    uicontrol(fig,'Style','text','Position',[10 300 100 20],'String','Z limits');
    edit_x = uicontrol(fig,'Style','edit','Position',[10 280 100 20],...
        'String',num2str(state.xlimit),'Callback',@update_limits);

    uicontrol(fig,'Style','text','Position',[10 250 100 20],'String','G limits');
    edit_y = uicontrol(fig,'Style','edit','Position',[10 230 100 20],...
        'String',num2str(state.ylimit),'Callback',@update_limits);

    uicontrol(fig,'Style','text','Position',[10 200 100 20],'String','V limits');
    edit_v = uicontrol(fig,'Style','edit','Position',[10 180 100 20],...
        'String',num2str(state.vthlimit),'Callback',@update_limits);

    uicontrol(fig,'Style','text','Position',[10 150 100 20],'String','S limits');
    edit_s = uicontrol(fig,'Style','edit','Position',[10 130 100 20],...
        'String',num2str(state.slimit),'Callback',@update_limits);

    % =========================
    % CHECKBOXES
    % =========================
    cb_seeb = uicontrol(fig,'Style','checkbox','Position',[10 90 100 20],...
        'String','Seebeck','Callback',@toggle_seeb);

    cb_gs = uicontrol(fig,'Style','checkbox','Position',[10 60 100 20],...
        'String','G-S','Callback',@toggle_gs);

    % =========================
    % TRACE CONTROL
    % =========================
    edit_trace = uicontrol(fig,'Style','edit','Position',[10 20 100 20],...
        'String','1 2','Callback',@update_trace);

    uicontrol(fig,'Style','pushbutton','Position',[120 20 30 20],...
        'String','+','Callback',@plus_trace);

    uicontrol(fig,'Style','pushbutton','Position',[160 20 30 20],...
        'String','-','Callback',@minus_trace);

    % =========================
    % INITIAL PLOT
    % =========================
    update_plots();

    % =========================
    % CALLBACKS
    % =========================

    function update_limits(~,~)
        state.xlimit = str2num(edit_x.String);
        state.ylimit = str2num(edit_y.String);
        state.vthlimit = str2num(edit_v.String);
        state.slimit = str2num(edit_s.String);
        update_plots();
    end

    function toggle_seeb(~,~)
        state.Seebeck = cb_seeb.Value;
        update_plots();
    end

    function toggle_gs(~,~)
        state.GS = cb_gs.Value;
        update_plots();
    end

    function update_trace(~,~)
        state.ind = str2num(edit_trace.String);
        update_plots();
    end

    function plus_trace(~,~)
        state.ind = state.ind + 2;
        edit_trace.String = num2str(state.ind);
        update_plots();
    end

    function minus_trace(~,~)
        state.ind = max([1 2], state.ind - 2);
        edit_trace.String = num2str(state.ind);
        update_plots();
    end

    % =========================
    % MAIN UPDATE FUNCTION
    % =========================
    function update_plots()

        data = compute_dataset(state.curva, state);

        % ===== MAIN SCATTER =====
        cla(ax_main)

        if state.GS == 0
            scatter(ax_main, data.X, data.Y, 5, '.');
            ylabel(ax_main,'log(G/G0)')
        else
            scatter(ax_main, data.Y, data.V, 5, '.');
            ylabel(ax_main,'S or V')
        end

        xlabel(ax_main,'Z (nm)')

        % ===== HIST =====
        cla(ax_hist)
        histogram(ax_hist, data.Y, 100);

        % ===== INDIVIDUAL =====
        cla(ax_ind)

        for k = 1:length(state.ind)

            idx = state.ind(k);

            if idx > length(state.curva), continue, end

            z = state.curva(idx).z;
            g = log10(state.curva(idx).g);
            v = state.curva(idx).vth*1e3;

            plot(ax_ind, z, g)
            hold(ax_ind,'on')
        end

    end

end

function data = compute_dataset(curva, state)

    XX=[]; YY=[]; VV=[];

    for k=1:length(curva)

        z = curva(k).z;
        g = log10(curva(k).g);
        v = curva(k).vth*1e3;

        v = smoothdata(v, state.filter_type, state.filter_order);

        mask = z > state.xlimit(1) & z < state.xlimit(2) & ...
               g > log10(state.ylimit(1)) & g < log10(state.ylimit(2)) & ...
               v > state.vthlimit(1) & v < state.vthlimit(2);

        z=z(mask); g=g(mask); v=v(mask);

        if state.Seebeck==1
            s = -v*1e3./curva(k).Temp;
            mask2 = s>state.slimit(1) & s<state.slimit(2);
            z=z(mask2); g=g(mask2); v=s(mask2);
        end

        XX=[XX;z];
        YY=[YY;g];
        VV=[VV;v];
    end

    data.X=XX; data.Y=YY; data.V=VV;

end

function curva = load_and_merge_data()

[file,path]=uigetfile('*.mat','MultiSelect','on');

if ~iscell(file), file={file}; end

curva=[]; ccount=0;

for i=1:length(file)

    d=load(fullfile(path,file{i}));

    if isfield(d,'curva_ini')
        c=d.curva_ini;
    else
        c=d.curva;
    end

    for k=1:length(c)
        ccount=ccount+1;
        curva(ccount)=c(k);
    end
end

end