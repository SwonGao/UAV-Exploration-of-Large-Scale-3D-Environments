function MapConfiguration
% This function is a temporal function used for development
% Codes here has been integrated to "Pacman.m"

%clc,clear;
myAxes1 = axes('Units','normalized','Position',[0 0.04 1 0.90],...                                            
    'XLim',[-3 30],'YLim',[-3 50]); 
hold(myAxes1,'on');
axis(myAxes1,'off','equal');
m = 50 ; n = m * 0.6; %n=30
wall = [0,0; n,0; n,m; 0,m; 0,0; NaN,NaN;       ...
    0,0.4*m; 0.4*m,0.4*m; NaN,NaN;                            ...
    0,0.8*m; 0.12*m,0.8*m; NaN,NaN;  0.28*m,0.8*m; 0.4*m,0.8*m; NaN,NaN;   ...
    0.4*m,0.8*m; 0.4*m,0.28*m; NaN,NaN; 0.4*m,0.12*m; 0.4*m,0 ;  NaN,NaN   ]';
allWallsPlot = plot(myAxes1,wall(1,:),wall(2,:),'b-','LineWidth',2);    % plot all walls
hold(myAxes1,'on')
axis(myAxes1,'off','equal')

%% Coins & Directions
MAP = map(m);
k=1;
for i = 1 : m
    for j = 1 : n
        if MAP(i,j) == 0
            coins.data(:,k) = [j ,1+m-i];          
            k = k + 1;
        end
    end
end
%coins.data(:,k) = [1,1];    k = k+1;
coins.data = coins.data';
coins.originalData = coins.data;
coins.plot = plot(coins.data(:,1),coins.data(:,2),'.','Color',[255 185 151]/255,'MarkerSize',7); % plot all coins

