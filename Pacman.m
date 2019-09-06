function Pacman
% This program is developed for "Autonomous Exploration and Mapping"
% For now you can only control it manually, PacmanAI has not been developed
% This game is adapted from Markus Petershofen's Pacman packages
%                                           Songqun Gao Aug,27,2019
% notes:
% rightarrow 1 downarrow 2
% leftarrow  3 uparrow 4
%
% Controls:
% - use arrow keys or "WASD"-keys to control pacman
% - press "P" to pause
% - press "Q" for to let pacman be controlled by the computer
% - press "H" to show highscores
% - press "M" to show menu
% - press "U" to toggle sounds on or off
% - press "I" for super fast invincible mode
% Programmer:   Markus Petershofen
% Date:         06.06.2017

%close all
clc,clear
%% General configurations
%gameData = load('gameData.mat');
% change the game configurations to suit yourself
game.speed = 0.025;         % game speed (time-increment between two frames) maximum possible without lag on my machine: 0.008
game.faster = 0;       % make game faster every level by this amount (default: 0)
game.maxSpeed = 0.015;      % maximimum game speed (default: 0.01)
AI.init = 0.0;              % initial AI-> 0: (almost) no randomness, 1: full randomness
AI.improve = -0.1;          % AI-improvement per level (default: -0.1)
pacman.speed = 1/6;         % pacman speed (default: 1/6 => pacman eats exactly two coins with every mouth open/close cycle, maximum possible: 1/2)
showGhostTarget = 0;        % flag whether to show where each ghost is heading towards or not
autoPlay = 0;               % flag whether auto play is on or not
invincible = 0;             % make pacman invincible
soundsFlag = 1;             % flag whether sounds are on or off

% Use "Courier New" Font if available. But "Arial" is also ok.字体
if any(strcmp(listfonts,'Courier New'))
    pacFont = 'Courier New';
else
    pacFont = 'Arial';
end

% create figure
screen_size = get(0,'ScreenSize');                  % get screen size
screenCenter = screen_size(3:4)/2;                  % calculate screen center
figure_size = [700*0.9 700];                        % figure-size
limit_left = screen_size(3)/2-figure_size(1)/2;     % figure centered horizontally
limit_down = screen_size(4)/2-figure_size(2)/2;     % figure centered vertically
pacman_Fig = figure('units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
    'Color','k','Resize','on','MenuBar','none','Visible','on',...
    'NumberTitle','off','Name','Pacman','doublebuffer','on',...
    'WindowKeyPressFcn',@KeyAction,...              % Keyboard-Callback
    'CloseRequestFcn',@(s,e)PacmanCloseFcn);        % when figure is closed

m = 25 ; n = m*0.6; %n=30
myAxes1 = axes('Units','normalized','Position',[0 0.04 1 0.90],...                                            
    'XLim',[-3 n],'YLim',[-3 m]); 
hold(myAxes1,'on');
axis(myAxes1,'off','equal');

%% wall Map
wall = [0,0; n,0; n,m; 0,m; 0,0; NaN,NaN;       ...
    0,0.4*m; 0.4*m,0.4*m; NaN,NaN;                            ...
    0,0.8*m; 0.12*m,0.8*m; NaN,NaN;  0.28*m,0.8*m; 0.4*m,0.8*m; NaN,NaN;   ...
    0.4*m,0.8*m; 0.4*m,0.28*m; NaN,NaN; 0.4*m,0.12*m; 0.4*m,0 ;  NaN,NaN   ]';
allWallsPlot = plot(myAxes1,wall(1,:),wall(2,:),'b-','LineWidth',2);    % plot all walls
hold(myAxes1,'on')
axis(myAxes1,'off','equal')

%% Coins Map
dir = cell(m,n);
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
coins.data = coins.data';
coins.originalData = coins.data;
coins.plot = plot(coins.data(:,1),coins.data(:,2),'.','Color',[255 185 151]/255,'MarkerSize',7); % plot all coins
WriteCoin(coins.data);


%% Directions
allDirections = getDirMap(MAP);

%% Initialize pacman
pacman.size = 1.5;          % pacman size
pacman.pos = [12 8];      % position of pacman
pacman.dir = 0;             % direction of pacman
pacman.oldDir = 1;          % old direction of pacman
pacman.status = -2;         % -2 is normal,maybe useless

% Calculate all pacman frames, from closed to fully open
for ii = 0:18
    pacman.frames{1,ii+1} = [[-0.3 sin(linspace(pi/2+ii*pi/18,5/2*pi-ii*pi/18,50))*pacman.size -0.3];[0 cos(linspace(pi/2+ii*pi/18,5/2*pi-ii*pi/18,50))*pacman.size 0]];
    pacman.frames{2,ii+1} = [[0 sin(linspace(pi/2+ii*pi/18+pi/2,5/2*pi-ii*pi/18+pi/2,50))*pacman.size 0];[0.3 cos(linspace(pi/2+ii*pi/18+pi/2,5/2*pi-ii*pi/18+pi/2,50))*pacman.size 0.3]];
    pacman.frames{3,ii+1} = [[0.3 sin(linspace(pi/2+ii*pi/18-pi,5/2*pi-ii*pi/18-pi,50))*pacman.size 0.3];[0 cos(linspace(pi/2+ii*pi/18-pi,5/2*pi-ii*pi/18-pi,50))*pacman.size 0]];
    pacman.frames{4,ii+1} = [[0 sin(linspace(pi/2+ii*pi/18-pi/2,5/2*pi-ii*pi/18-pi/2,50))*pacman.size 0];[-0.3 cos(linspace(pi/2+ii*pi/18-pi/2,5/2*pi-ii*pi/18-pi/2,50))*pacman.size -0.3]];
end

curFrame = 1;           % open-close-frame
frameDirection = 1;     % direction-frame
pacman.plot = fill(pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1),pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2),'y','EdgeColor','y','Parent',myAxes1);
%pacman.targetPlot = patch('XData',ghostMode.form(1,:),'YData',ghostMode.form(2,:),'FaceColor','y','Parent',myAxes1,'Visible','off');
pacman.curAutoDir = [1 0];

%% lives, score, level, info, animations...
lives.orig = 1;             % lives of pacman
lives.data = lives.orig;    % remember default lives of pacman         
lives.plot = gobjects(1,lives.data);
for ii = 1:lives.data
    lives.plot(ii) = fill(pacman.frames{3,5}(1,:)+1+3*(ii-1),pacman.frames{3,5}(2,:)-2,'y','Parent',myAxes1);
end
score.data = 0;             % glod score
score.data2 = 0;            % time punish
score.plot = text(29,50.5,['Score: ' num2str(score.data) ' - ' num2str(round(score.data2))],'Color','w','FontSize',10,'HorizontalAlign','Right','FontName',pacFont,'FontUnits','normalized','FontWeight','bold','Parent',myAxes1);
level.data = 1;          	% level
level.plot = text(0,50.5,['Level: ' num2str(level.data)],'Color','w','FontSize',10,'HorizontalAlign','Left','FontName',pacFont,'FontUnits','normalized','FontWeight','bold','Parent',myAxes1);
info.text = text(14.65,13.9,'READY!','Color','g','FontSize',20,'FontWeight','bold','horizontalAlignment','center','FontName',pacFont,'FontUnits','normalized','FontWeight','bold','Parent',myAxes1);

%% Timer
isPause = 0; % game pause flag
myTimer = timer('TimerFcn',@(s,e)GameLoop,'Period',game.speed,'ExecutionMode','fixedRate');

%% 图形化界面 UI-controls
newGameButton        = createUIcontrol('pushbutton',[0.3 0.87 0.4 0.05],'New Game',    ...
    18,pacFont,'k',get(0,'DefaultUicontrolBackgroundColor'),pacman_Fig,'on',@(s,e)newGameButtonFun);
createLabyButton   = createUIcontrol('pushbutton',[0.3 0.81 0.4 0.05],'Create Laby',...
    18,pacFont,'k',get(0,'DefaultUicontrolBackgroundColor'),pacman_Fig,'on',@(s,e)createLabyFun);
showHighScoresButton     = createUIcontrol('pushbutton',[0.3 0.75 0.4 0.05],'Highscores', ...
    18,pacFont,'k',get(0,'DefaultUicontrolBackgroundColor'),pacman_Fig,'on',@(s,e)showHighScore);

%% HighScores
highScoreTemp = load('highScore.mat');
highScore.data = highScoreTemp.HighScore;
figure_size = figure_size/1.5;                      % figure-size
limit_left = screen_size(3)/2-figure_size(1)/2;     % figure centered horizontally
limit_down = screen_size(4)/2-figure_size(2)/2;     % figure centered vertically
highScore.fig = figure('units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
    'Color','w','Resize','on','MenuBar','none','Visible','off',...
    'NumberTitle','off','Name','Highscore',...
    'CloseRequestFcn',@(s,e)HighScoreCloseFcn);
highScore.texts = gobjects(10);
highScore.values = gobjects(10);
createUIcontrol('text',[0.05 0.9 0.2 0.07],'Place',18,pacFont,'k','w',highScore.fig,'on','');
createUIcontrol('text',[0.28 0.9 0.4 0.07],'Name',18,pacFont,'k','w',highScore.fig,'on','');
createUIcontrol('text',[0.7 0.9 0.3 0.07],'Score',18,pacFont,'k','w',highScore.fig,'on','');
for ii = 1:10
    createUIcontrol('text',[0.05 0.9-ii/11.5 0.2 0.07],[num2str(ii) '.'],16,pacFont,'k','w',highScore.fig,'on','');
    highScore.texts(ii) = createUIcontrol('edit',[0.28 0.9-ii/11.5 0.4 0.07],highScore.data{ii,1},16,pacFont,'k','w',highScore.fig,'on',{@HighScoreEdit,ii});
    highScore.texts(ii).Enable = 'off';
    highScore.values(ii)= createUIcontrol('text',[0.7 0.9-ii/11.5 0.3 0.07],num2str(highScore.data{ii,2}),16,pacFont,'k','w',highScore.fig,'on','');
end
info.highScoreText = text(14.5,50.5,['Highest: ' num2str(highScore.data{1,2})],'Color','w','FontSize',10,'HorizontalAlign','Center','FontName',pacFont,'FontUnits','normalized','FontWeight','bold','Parent',myAxes1);

%% Sounds
% special thanks to: http://www.classicgaming.cc/classics/pac-man/sounds
[b_y,b_Fs] = audioread('Sounds/pacman_beginning.wav');
[c_y,c_Fs] = audioread('Sounds/pacman_chomp.wav');
[i_y,i_Fs] = audioread('Sounds/pacman_intermission.wav');
c_y(end-round(length(c_y)/2):end) = []; % shorten waka-waka sound
sounds.beginning = audioplayer(b_y, b_Fs);
sounds.coin1 = audioplayer(c_y, c_Fs);
sounds.coin2 = audioplayer(c_y, c_Fs);
sounds.coin3 = audioplayer(c_y, c_Fs);
sounds.intermission1 = audioplayer(i_y, i_Fs);
sounds.intermission2 = audioplayer(i_y, i_Fs);
sounds.timer_c = timer('TimerFcn',@(s,e)soundManager_c,'Period',round(length(c_y)/c_Fs*1000)/1000-0.031,'ExecutionMode','fixedRate'); % -0.12
sounds.coinEating = 0;

musicIcon.data = load('Sounds/musicIcon.mat');
musicIcon.data = musicIcon.data.musicIcon;
musicIcon.data(musicIcon.data==1) = 8;
musicIcon.data(musicIcon.data==0) = 1;
musicIcon.plot = imagesc('XData',[0 1.5]-2,'YData',[1.5 0]-2.75,'CData',musicIcon.data,'Visible','on','Parent',myAxes1,'ButtonDownFcn',@(s,e)musicOnOff);

%% functions are given below

pacmanLabyCreator_Fig = figure('Visible','off');
    function newGameButtonFun
        if soundsFlag
            play(sounds.beginning)
        end
        coins.data = coins.originalData;
        level.data = 1;
        set(level.plot,'String',['Level: ' num2str(level.data)]);
        score.data = 0;
        score.data2 = 0;
        set(score.plot,'String',['Score: ' num2str(score.data) ' - ' num2str(round(score.data2))])
        lives.data = lives.orig;
        % set parameters 
        set(lives.plot(:),'Visible','on')
        set(newGameButton,'Visible','off')
        set(pacmanLabyCreator_Fig,'Visible','off')
        set(createLabyButton,'Visible','off')
        set(showHighScoresButton,'Visible','off')
        % ugly workaround for focussing on figure after buttonpress (needed
        % for WindowKeyPressFcn to work properly)
        set(0,'PointerLocation',screenCenter)
        robot = java.awt.Robot;
        robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
        robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
        
        newGame
        set(info.text,'Visible','off')
    end

    function createLabyFun
        labyCreator(pacmanLabyCreator_Fig);
    end

    function GameLoop
        pacmanMoveFun
        coinsFun
    end

    function musicOnOff
        soundsFlag = ~soundsFlag;
        if soundsFlag
            musicIcon.data(musicIcon.data==3) = 8;
        else
            musicIcon.data(musicIcon.data==8) = 3;
            stop(sounds.beginning)
            stop(sounds.coin1)
            stop(sounds.coin2)
            stop(sounds.coin3)
            stop(sounds.intermission1)
            stop(sounds.intermission2)
        end
        set(musicIcon.plot,'CData',musicIcon.data)
    end

    function soundManager_c % manages the waka waka coin eating sound
        if sounds.coinEating && soundsFlag
            if isplaying(sounds.coin1)
                play(sounds.coin2)
            elseif isplaying(sounds.coin2)
                play(sounds.coin3)
            else
                play(sounds.coin1)
            end
            sounds.coinEating = 0;
        else
            stop(sounds.timer_c)
        end
    end

    function newGame
        stop(myTimer)
        pacman.pos = [12 8];
        pacman.dir = 0;
        pacman.oldDir = 1;
        pacman.status = -2;
        set(pacman.plot,'XData',pacman.frames{pacman.oldDir,1}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,1}(2,:)+pacman.pos(2),'Visible','on')
        set(info.text,'String','READY!','Color','g','Visible','on')
        pause(1)
        set(info.text,'Visible','off')
        start(myTimer)
%         % Debug Mode
%         while 1
%             GameLoop
%             pause(0.01)
%         end
    end


%% GameLoop==================================================================
    function pacmanMoveFun
        % calculate cost function every loop
        prepos = pacman.pos;
        % position limitation
        if pacman.pos(1) > n
            pacman.pos(1) = n;
        elseif pacman.pos(1) < 1
            pacman.pos(1) = 1;
        elseif pacman.pos(2) > m
            pacman.pos(2) = m;
        elseif pacman.pos(2) < 1
            pacman.pos(2) = 1;
        end        
        % Pacman AI
        if autoPlay
            curSquare1 = findSquare(pacman,pacman.dir);
            curSquare2 = pacmanAI(pacman,allDirections,coins);
            pacman.dir = shortestPath(curSquare1,curSquare2,pacman);
            %if showGhostTarget
            %    set(pacman.targetPlot,'XData',curSquare2(1),'YData',curSquare2(2),'Visible','on')
            %end
        end % end AI        
        %if ~showGhostTarget || ~autoPlay
            %set(pacman.targetPlot,'Visible','off') 
        %end
        pacman = pathWayLogic(pacman,pacman.speed);
        %calculate cost
        score.data2 = score.data2 + norm(pacman.pos - prepos);
        %animation
        if frameDirection   % if mouth is opening 
            curFrame = curFrame+1;
        else                % if mouth is closing
            curFrame = curFrame-1;
        end
        if curFrame == 1        % if mouth is fully closed
            frameDirection = 1;
        elseif curFrame == 7    % if mouth is fully open
            frameDirection = 0;
        end
        % update pacman plot
        set(pacman.plot,'XData', pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1) ,...
            'YData', pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2) )
    end

    function coinsFun
        %if any(ismember(coins.data,findSquare(pacman,pacman.oldDir),'rows'))
            %这里可以编程吃豆豆的
            %tmp = coins.data(ismember(coins.data,findSquare(pacman,pacman.oldDir),'rows'),:);
            tmp = pacman.pos;
            %if tmp
                x = tmp(1);   y = tmp(2);      
                for tmp1 = floor(-pacman.size):ceil(pacman.size)
                    for tmp2 = floor(-pacman.size):ceil(pacman.size)
                        if (x+tmp1)<0 || (y+tmp2)<0 || (x+tmp1)>n || (y+tmp2)>m
                            break;
                        end
                        if norm([tmp1 tmp2]) <= pacman.size
                            num = deletecoin(x+tmp1,y+tmp2,coins.data);
                            if num > 0
                                coins.data(num,:) = [];
                                score.data = score.data + 10;
                            end
                        end
                    %coins.data(ismember(coins.data,findSquare(pacman,pacman.oldDir),'rows'),:) = [];
                    %score.data = score.data+10;
                    end
                end
                sounds.coinEating = 1;
                if strcmp(get(sounds.timer_c,'Running'),'off')
                    start(sounds.timer_c)
                end
            %end
        %end
        
        set(coins.plot,'XData',coins.data(:,1),'YData',coins.data(:,2))
        set(score.plot,'String',['Score: ' num2str(score.data) ' - ' num2str(round(score.data2))])
        
        if isempty(coins.data) % next Level
            level.data = level.data+1;
            set(level.plot,'String',['Level: ' num2str(level.data)]);
            game.speed = game.speed+game.faster;
            if game.speed < game.maxSpeed   
                game.speed = game.maxSpeed; % limit game speed, so screen has time to update itself
            end
            stop(myTimer)
            set(myTimer,'Period',game.speed)
            coins.data = coins.originalData;
            newGame
        end
    end
%% GameLoop==================================================================


    function curSquare = findSquare(entity,dir)
        if dir == 1 || dir == 4
            curSquare = [round(entity.pos(1)-0.45),round(entity.pos(2)-0.45)];
        else
            curSquare = [round(entity.pos(1)+0.45),round(entity.pos(2)+0.45)];
        end
    end

    function possibleMoves = allPossibleMoves(entity)
        curSquare = findSquare(entity,entity.dir);
        possibleMoves = allDirections{curSquare(1),curSquare(2)};
    end

    % simple -> simpler -> simplest -> my AI
    function nextMove = shortestPath(square1,square2,entity)
        possibleMoves = allDirections{square1(1),square1(2)};
        if abs(square1(1)-square2(1)) > abs(square1(2)-square2(2))
            if square1(1) > square2(1)
                nextMove = 3;
            else                
                nextMove = 1;
            end
        else
            if square1(2) > square2(2)
                nextMove = 2;
            else                
                nextMove = 4;
            end
        end
        curAI = AI.init+AI.improve*(level.data-1);
        curAI(curAI<0.05) = 0.05; % always keep some rest randomness
        if entity.status == 3 % eyes are very clever, but for their own sake, not too clever
            curAI = 0.1;
        end
        if ~any(possibleMoves==nextMove) && any(possibleMoves==entity.dir)
            nextMove = entity.dir;
        elseif ~isempty(possibleMoves) && (~any(possibleMoves==nextMove) || entity.status == 2 || rand < curAI)
            nextMove = possibleMoves(randi(length(possibleMoves),1));
        end
    end

    function entity = pathWayLogic(entity,speed)
        possibleDirections_minus = allDirections{round(entity.pos(1)-0.45),round(entity.pos(2)-0.45)};
        possibleDirections_plus = allDirections{round(entity.pos(1)+0.45),round(entity.pos(2)+0.45)};
        switch entity.dir
            case 0
                entity.oldDir = 1;
            %entity: pacman in the main
            %round 四舍五入 any of the elements is valid    
            case 1  % right             
                if rem(round(entity.pos(2)/speed)*speed,1) == 0 && any(possibleDirections_minus==entity.dir)
                    entity.pos(2) = round(entity.pos(2)/speed)*speed;
                    entity.pos(1) = entity.pos(1)+speed;
                    entity.oldDir = 1;
                elseif entity.oldDir == 2 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)-speed; 
                elseif entity.oldDir == 4 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)+speed; 
                elseif entity.status > -2
                    entity.pos(2) = entity.pos(2)+speed;
                end
            case 2 % down
                if rem(round(entity.pos(1)/speed)*speed,1) == 0 && any(possibleDirections_plus==entity.dir)
                    entity.pos(1) = round(entity.pos(1)/speed)*speed;
                    entity.pos(2) = entity.pos(2)-speed; 
                    entity.oldDir = 2;
                elseif entity.oldDir == 1 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)+speed; %right
                elseif entity.oldDir == 3 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)-speed; %left
                elseif entity.status > -2
                    entity.pos(1) = entity.pos(1)-speed;
                end
            case 3 % left
                if rem(round(entity.pos(2)/speed)*speed,1) == 0 && any(possibleDirections_plus==entity.dir)
                    entity.pos(2) = round(entity.pos(2)/speed)*speed;
                    entity.pos(1) = entity.pos(1)-speed;
                    entity.oldDir = 3;
                elseif entity.oldDir == 2 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)-speed;
                elseif entity.oldDir == 4 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)+speed;
                elseif entity.status > -2
                    entity.pos(2) = entity.pos(2)+speed;
                end
            case 4 % up
                if rem(round(entity.pos(1)/speed)*speed,1) == 0 && any(possibleDirections_minus==entity.dir)
                    entity.pos(1) = round(entity.pos(1)/speed)*speed;
                    entity.pos(2) = entity.pos(2)+speed;
                    entity.oldDir = 4;
                elseif entity.oldDir == 1 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)+speed;
                elseif entity.oldDir == 3 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)-speed;
                elseif entity.status > -2
                    entity.pos(1) = entity.pos(1)-speed;
                end
        end
    end

    function KeyAction(~,evt)
        switch evt.Key
            case {'d','rightarrow'}
                if ~autoPlay
                    pacman.dir = 1;
                end
            case {'s','downarrow'}
                if ~autoPlay
                    pacman.dir = 2;
                end
            case {'a','leftarrow'}
                if ~autoPlay
                    pacman.dir = 3;
                end
            case {'w','uparrow'}
                if ~autoPlay
                    pacman.dir = 4;
                end
            case 'p'
                if isPause
                    start(myTimer)
                    isPause = 0;
                    set(info.text,'Visible','off')
                    set(newGameButton,'Visible','off')
                    set(createLabyButton,'Visible','off')
                    set(showHighScoresButton,'Visible','off')
                else
                    stop(myTimer)
                    isPause = 1;
                    set(info.text,'String','Press "P"','Color','w','Visible','on')
                end
            case 'h'
                stop(myTimer)
                isPause = 1;
                set(highScore.fig,'Visible','on')
                set(info.text,'String','Press "P"','Color','w','Visible','on')
            case 'm'
                stop(myTimer)
                isPause = 1;
                set(info.text,'String','Press "P"','Color','w','Visible','on')
                set(newGameButton,'Visible','on')
                set(createLabyButton,'Visible','on')
                set(showHighScoresButton,'Visible','on')
            case 't'
                showGhostTarget = ~showGhostTarget;
            case 'q'
                autoPlay = ~autoPlay;
            case 'u'
                musicOnOff
            case 'i'
                invincible = ~invincible;
                if invincible
                    pacman.speed = 1/2;
                else
                    pacman.speed = 1/6;
                end
        end
        if strcmp(get(newGameButton,'Visible'),'on') && ~isPause
            newGameButtonFun
        end
    end

    function showHighScore
        isPause = 1;
        set(highScore.fig,'Visible','on')
    end

    function setHighscore
        allHighscores = highScore.data;
        onlyHighScores = allHighscores(:,2);
        onlyHighScores = cell2mat(onlyHighScores);
        if score.data >= onlyHighScores(end,1)
            onlyHighScores(10,1) = score.data;
            [~,sortedIndices] = sort(onlyHighScores,'descend');
            onlyHighScores = onlyHighScores(sortedIndices);
            allHighscores = allHighscores(sortedIndices,:);
            highScore.data = allHighscores;
            for kk = 1:10         
                highScore.data{kk,2} = onlyHighScores(kk);
                set(highScore.texts(kk),'String',highScore.data{kk,1})
                set(highScore.values(kk),'String',num2str(highScore.data{kk,2}))
            end
            set(highScore.texts(sortedIndices==10),'Enable','on','String','');
            uicontrol(highScore.texts(sortedIndices==10))
            showHighScore
        end
    end

    function HighScoreEdit(~,~,curRow)
        highScore.data{curRow,1} = highScore.texts(curRow).String;
        m = matfile('highScore.mat','Writable',true);
        m.HighScore = highScore.data;
        highScore.texts(curRow).Enable = 'off';
        set(info.highScoreText,'String',['High Score: ' num2str(highScore.data{1,2})])
    end

    function HighScoreCloseFcn
        set(highScore.fig,'Visible','off');
        for kk = 1:10
            highScore.data{kk,1} = highScore.texts(kk).String;
            highScore.data{kk,2} = str2double(highScore.values(kk).String);
            highScore.texts(kk).Enable = 'off';
        end
        m = matfile('HighScore.mat','Writable',true);
        m.HighScore = highScore.data;
    end

    function PacmanCloseFcn
        stop(myTimer)
        delete(myTimer)
        stop(sounds.timer_c)
        delete(sounds.timer_c)
        delete(pacman_Fig)
        delete(pacmanLabyCreator_Fig)
        delete(highScore.fig)
    end

    function UIvar = createUIcontrol(varType,varPos,varStr,varFontSize,varFont,varFColor,varBColor,varParent,varVis,varCallback)
        UIvar = uicontrol('Style',varType,...
            'units','normalized',...
            'Position',varPos,...
            'String',varStr,...
            'FontSize',varFontSize,...
            'FontName',varFont,...
            'FontUnits','normalized',...
            'ForegroundColor',varFColor,...
            'BackgroundColor',varBColor,...
            'Parent',varParent,...
            'Visible',varVis,...
            'Callback',varCallback,...
            'HorizontalAlignment','center');
    end
end