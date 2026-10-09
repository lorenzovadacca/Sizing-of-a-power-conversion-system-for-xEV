% close all
function SetPlot(varargin)
%Run this script to plot a single figure with a set of results.
if nargin==1
    PicStyle = varargin{1};
    if(strcmpi(PicStyle,'paper'))   %Single column for IEEE papers
        %External size in cm (double column IEEE paper)
        width = 8.58;
        height = 4; 
        % Text size. 8pt as figure caption size.
        TextSize = 8;
    end
    if(strcmpi(PicStyle,'paperDouble')) %Single column, larger height (e.g. double plots
        %External size in cm (double column IEEE paper)
        width = 19;
        height = 6; 
        % Text size. 8pt as figure caption size.
        TextSize = 8;
    end
    if(strcmpi(PicStyle,'large'))   %Format Single Column for thesis
        width = 15;
        height = 7.5; 
        TextSize = 10;
    end
elseif nargin==2            % Custom width&height
  width = varargin{1};
  height = varargin{2};
  TextSize = 8;
elseif nargin==3            % Custom width&height&TextFont
  width = varargin{1};
  height = varargin{2};
  TextSize = varargin{3};
else
  error('Wrong parameters given!')
end



AxesFontSize=TextSize;
figure
currFig=gcf;

% Definitions for plotting figures

set(gcf,'defaultTextInterpreter','Latex');
set(gcf,'defaultLegendInterpreter','Latex');
set(gcf,'defaultAxesTickLabelInterpreter','Latex');

% Must use this to save svg vector format
set(gcf,'defaultFigureRenderer','painters');
set(gcf,'Renderer','painters');

set(gcf,'defaultAxesLineWidth',1);
set(gcf,'defaultLineLineWidth',2);

% set(gcf,'defaultAxesGridLineStyle',':');
set(gcf,'defaultAxesYGrid','on');
set(gcf,'defaultAxesXGrid','on');
set(gcf,'defaultAxesZGrid','on');
set(gcf,'defaultAxesXColor',0*[1 1 1]);
set(gcf,'defaultAxesYColor',0*[1 1 1]);
set(gcf,'defaultAxesZColor',0*[1 1 1]);

% Grid transparency
set(gcf,'defaultAxesGridAlpha',0.35);

%set(gcf,'defaultAxesLayer','top');

set(gcf,'defaultAxesBox','on');

set(gcf,'defaultAxesNextPlot','add');

set(gcf,'defaultAxesFontSize',AxesFontSize);
set(gcf,'defaultTextFontSize',TextSize);
set(gcf,'defaultAxesFontSizeMode','manual');
set(gcf,'defaultTextFontSizeMode','manual');
set(gcf,'defaultAxesLabelFontSizeMultiplier',1);
set(gcf,'defaultAxesTitleFontSizeMultiplier',1);
set(gcf,'defaultLegendFontSize',TextSize);

set(gcf,'defaultAxesFontName','Times');
set(gcf,'defaultTextFontName','Times');

screenPos=get(groot,'ScreenSize')/get(groot,'ScreenPixelsPerInch')*2.54; % cm
figPos(1)=screenPos(3)/2-width/2;
figPos(2)=screenPos(4)/2-height/2;
figPos(3)=width;
figPos(4)=height;

set(gcf,'Units','centimeters');
set(gcf,'Position',figPos);
set(gcf,'Color',[1 1 1]);
set(gcf,'PaperUnits','centimeter','PaperPosition',[0 0 width height])
set(gcf,'PaperSize',[width height])
end