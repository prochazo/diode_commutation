%% main setup
close all
clear all
clc

save_fig = false;

set(0,'defaulttextinterpreter','latex')

%% read names of the data files from the folder named data
d = dir(strcat('data'));                                % load models dir
scripts = d(~ismember({d(:).name},{'.','..', 'fig'}));  % remove nonscripts '.' and '..' ()
list = {scripts.name};                                  % list of data files


for i=2%:length(list)

    % load exact data
    fprintf("Loading data from file %s\n", list{i})
    data = readtable(strcat('data/', list{i}));
    
    % store data into nicer variables
    time =( data.Var1+abs(min(data.Var1)))*1e6;
    urrm =  movmean(data.Var2, 10);
    ifm = movmean(data.Var3, 10);

    % find peaks in data - just for curious people
%     findpeaks(ifm,'MinPeakDistance', 5, 'MinPeakProminence',5)

% ------------------------------------------------------
    % create figure
    f = figure; 
    subplot(2,1,1)
    hold on             
    
    plot(time,ifm)
    
    % find local minima in the data
    loc_min = islocalmin(ifm, 'MinProminence',5);
%     display([i, list{i}, "number of mins: ", sum(loc_min)])
%     plot(time(loc_min),ifm(loc_min),'g*');
    
    % find data values that are bellow the threshold
    ifm_below = ifm.*(ifm<=0);
%     area(time, below, 'FaceColor', 'r')
    
    % find and plot global minima
    ifm_min = min(ifm);
    urrm_min = min(urrm);
    ifm_min_time = time(find(ifm==ifm_min));
    
    a = plot(ifm_min_time(1), ifm_min(1), 'x');
    a.Annotation.LegendInformation.IconDisplayStyle = 'off';
    a = plot([ifm_min_time(1), ifm_min_time(1)], [min(ifm_min, urrm_min), max(max(ifm), max(urrm))],'-.');
    a.Annotation.LegendInformation.IconDisplayStyle = 'off';
    
    plot([min(time), max(time)], 0.9*[ifm_min(1) ifm_min(1)],'--') % plot 90% value
    plot([min(time), max(time)], 0.25*[ifm_min(1) ifm_min(1)],'--')% plot 25% value
    
    % find intersection points with 25% line and 90% line
    [X1, Y1] = intersections(time, ifm, [min(time), max(time)], 0.9*[ifm_min ifm_min], true);
    a = plot(X1(2), Y1(2), 'o'); % take second point (2) (we want to identify intersection while value is rising)
    a.Annotation.LegendInformation.IconDisplayStyle = 'off';
    [X2, Y2] = intersections(time, ifm, [min(time), max(time)], 0.25*[ifm_min ifm_min], true);
    a = plot(X2(2), Y2(2), 'o'); % take second point (2) (we want to identify intersection while value is rising)
    a.Annotation.LegendInformation.IconDisplayStyle = 'off';
    
    % compute vector values and then recompute the x and y values which
    % defeine the line
    xvec = X2(2) - X1(2);
    yvec = Y2(2) - Y1(2);
    xx = X1(2) - xvec*((Y1(2) - min(urrm))/yvec);
    xxx = X2(2) - xvec*((Y2(2) - max(ifm))/yvec);
    a = plot([xx, xxx], [min(urrm), max(ifm)], '--', 'Color', 'red');
    a.Annotation.LegendInformation.IconDisplayStyle = 'off';
    
    % compute intersection with x-axis
    [XX, YY] = intersections(time, ifm, [min(time), max(time)], [0 0], true);
    a = plot([XX(1), XX(1)], [min(urrm), max(ifm)], '-.');
    a.Annotation.LegendInformation.IconDisplayStyle = 'off';
    a = plot(XX(1), YY(1), '+');
    a.Annotation.LegendInformation.IconDisplayStyle = 'off';
    
    [XXX, YYY] = intersections([xx, xxx], [min(urrm), max(ifm)], [min(time), max(time)], [0 0], true);
    a = plot([XXX(1), XXX(1)], [min(urrm), max(ifm)], '-.');
    a.Annotation.LegendInformation.IconDisplayStyle = 'off';
    a = plot(XXX(1), YYY(1), '+');
    a.Annotation.LegendInformation.IconDisplayStyle = 'off';
    
    title('Závislost proudu na čase','FontSize',9)
    xlabel('$t (\mu s)$')
    ylabel('$I_R (A)$')
    legend('proud', '0.9 I_{rrM}', '0.25 I_{rrM}')
    
    xlim([XX(1)-5, XXX(1)+5])
    ylim([min(ifm)-5, max(ifm)])
    grid on

% --------------------------------------------------
    % second graph
    subplot(2,1,2)
    hold on    
    
    plot(time,urrm)
    
    title('Závislost napětí na čase','FontSize',9)
    xlabel('$t (\mu s)$')
    ylabel('$U_R (V)$')
    legend('napětí')
    
    ylim([min(urrm)-5, max(max(urrm))])
    xlim([XX(1)-5, XXX(1)+5])
    grid on

% --------------------------------------------------
    trr = XXX(1)-XX(1);
    tf = XXX(1)-ifm_min_time(1);
    ts = ifm_min_time(1) - XX(1);
    Qrr = 1/2*ifm_min(1)*trr;
    
    display(strcat("$t_{rr} = $",num2str(trr), " $ (\mu s), t_f = $",num2str(tf), "$ (\mu s) , t_s = $",num2str(ts),"$ (\mu s)$", ",$ Q_{rr} = $", num2str(Qrr)))
    % resize figure for better output
    f.Position = [600 600 800 500];
    
    if save_fig
        saveas(f,strcat('figs/',num2str(i)),'epsc')
        saveas(f,strcat('figs/',num2str(i)),'png')
    end

end