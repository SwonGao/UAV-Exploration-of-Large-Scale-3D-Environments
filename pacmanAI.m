function targetSquare = pacmanAI(pacman,allDirections,coins)

% targetSquare = pacmanAI(pacman,enemies,allDirections) 
% Input:
% pacman: struct-array with all of the pacman information
% pacman.pos: current position [x,y]
% allDirections: cell-array with all possible moves for each tile in the game
% coins: struct-array with all of the coins information
% Output:
% targetSquare: this is the tile where pacman is sent to after this function is done

%% Nested functions:
% curSquare = findSquare(entity,dir):
% returns the current tile a ghost or pacman (entity) is at right now
% possibleMoves = allPossibleMoves(entity):
% returns all possible moves the entity (pacman or ghost) can go to at its current position

%% AI
    N = 100;
    curPos = pacman.pos;
    list = zeros(N,2);
    gain = zeros(N,1);
    for i = 1 : N
        list(i,:) = [rand rand];
        list(i,:) = list(i,:) ./ norm(list(i,:)) .* pacman.size; %normalize
        gain(i) = 0;        %Gain(nk) = Gain(nk-1) + Visible(M,xk)exp( )
    end

    while 1
        [bestgain, besti] = max(gain);
        curPos2 = curPos + list(besti,:) * pacman.size * rand;
        % Breseham's algorithm return a set of points
        flag = ifconnected(curPos,curPos2, coins.origindata);
        if flag
            break;
        end
    end
    
    % return curSquare2 
    % shortest path from (findSquare(curDist), findSquare(curSquare2))   
        %{
        if norm(curDist) < 5
            if rand < 0.01 || pacman.pos(1) <= 2 || pacman.pos(1) >= 30
                pacman.curAutoDir = (-1+2*round(rand))*round(rand(1,2));
            end
            curSquare2 = pacman.pos + pacman.curAutoDir;
        else
            if curDist(1) >= 0 && curDist(2) > 0
                curSquare2 = enemies(minDist1_Index).pos + [6 -6]*2;
            elseif curDist(1) <= 0 && curDist(2) < 0
                curSquare2 = enemies(minDist1_Index).pos + [-6 6]*2;
            elseif curDist(1) >= 0 && curDist(2) < 0
                curSquare2 = enemies(minDist1_Index).pos + [-6 -6]*2;
            elseif curDist(1) <= 0 && curDist(2) > 0
                curSquare2 = enemies(minDist1_Index).pos + [6 6]*2;
            else
                if rand < 0.01 || pacman.pos(1) <= 2 || pacman.pos(1) >= 30
                    pacman.curAutoDir = (-1+2*round(rand))*round(rand(1,2));
                end
                curSquare2 = pacman.pos + pacman.curAutoDir;
            end
        end
    %else
    %    curSquare2 = enemies(minDist2_Index).pos;
    %end
    %}
    %target limit
    if curSquare2(1) < 1 
        curSquare2(1) = 1;
    elseif curSquare2(1) > 28 
        curSquare2(1) = 28;
    end
    if curSquare2(2) < 1 
        curSquare2(2) = 1;
    elseif curSquare2(2) > 31 
        curSquare2(2) = 31;
    end
    targetSquare = curSquare2;
    
%% Nested Functions
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
end