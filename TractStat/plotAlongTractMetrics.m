function plotAlongTractMetrics(cweightFA,defn,metric,colorPlot)
% Plot the DTI/NODDI metrics along the tracts
% The mean value across the subjects and the 95% Confidence Interval
% calculated from the bootstrapping of the mean is plotted.
%
% Figures are saved after plotting
%
% Written by Esin Karahan, March, 2018
%

[ns,ntr,ndir]=size(cweightFA);

if ~exist('colorPlot','var')
    colorPlot{1} = [0 0 1]; %blue
    colorPlot{2} = [1 0 0]; %red
end

for itr = 1:ntr
    for idd = 1:ndir
        nPiece = length(cweightFA{1,itr,idd});
        weightFA{idd} = reshape(cell2mat(cweightFA(:,itr,idd)),nPiece,ns);
        weightFA{idd}(weightFA{idd}==0) = NaN;
    end
    plotShaded()
    f = gcf;
    f.PaperPosition = [0 0 600 350];
    f.Position = [0 0 600 350];
end

function plotShaded()
        x = 1:nPiece;
        figure('name',[defn.tr{itr}]),
        % change with SEM
%         shadedErrorBar(x,weightFA{1}',{@takemeanNan,@takesemNan},'lineprops',{'LineWidth',1,'Color',colorPlot{1}},'transparent',1),
        % change with 95 % CI interval
        shadedErrorBar(x,weightFA{1}',{@takemeanNan,@bootciMeanNan},'lineprops',{'LineWidth',1,'Color',colorPlot{1}},'transparent',1),
        
        hold on
        % change with SEM
%         shadedErrorBar(x,weightFA{2}',{@takemeanNan,@takesemNan},'lineprops',{'LineWidth',1,'Color',colorPlot{2}},'transparent',1);
        shadedErrorBar(x,weightFA{2}',{@takemeanNan,@bootciMeanNan},'lineprops',{'LineWidth',1,'Color',colorPlot{2}},'transparent',1),
        hold off
        axis tight
        ylabel(metric)
        ax = gca; 
        if sum(ismember('FA',metric))==2
            ay = [0.3:0.2:0.9 0.86];
            set(ax,'YTick',ay(1:end-1))
        elseif sum(ismember('ND',metric))==2
            ay = [0.4:0.2:0.8];
            set(ax,'YTick',ay(1:end))
        elseif sum(ismember('ISO',metric))==3
            ay = [0:0.1:0.3];
            set(ax,'YTick',ay(1:end))
        elseif sum(ismember('MD',metric))==2
            ay = 0.6:0.1:0.9;
            set(ax,'YTick',ay(1:end))
        elseif sum(ismember('ODI',metric))==3
            ay = 0:0.2:0.4;
            set(ax,'YTick',ay(1:end))
        end
        set(ax,'XTick',[1 10 20 30]);
        set(ax,'XTickLabel',{'1' '10' '20' '30'});

        set(ax,'YLim',[min(ay) max(ay)])
        ax.LineWidth = 0.5;
        print(fullfile(defn.outdir,['along-' defn.tr{itr} '-' metric]),'-cmyk','-painters', '-dsvg','-r600')

end

end