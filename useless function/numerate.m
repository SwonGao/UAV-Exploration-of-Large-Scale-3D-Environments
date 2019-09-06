function numerate(pos, predir, route, CoinMap, allDirections)
% This function is created to numerate and get the optimal path
% with highest score
% score = coin*10 - iterate

%304 coin 
%% initialize variables
persistent index bestScore bestRoute coin
if isempty(index)
    index = 1;
end
index = index+1;

if isempty(coin)
    coin = 0;
end

if isempty(bestScore)
    bestScore = 0;
end

if isempty(bestRoute)
    bestRoute = [0,0];
end

%% bestScore & bestRoute
if coin == 304
    score = 304 * 10 - index;
    if bestScore < score
        bestScore = score;
        bestRoute = route;
    end
end
%% coin && index
if CoinMap(pos) == 1
    coin = coin + 1;
    CoinMap(pos) = 0;
end
index = index + 1;

%% iterate
Dir = allDirections(pos);
[Dir,tmp] = pop(Dir,1);
while tmp %无限循环问题
    [Dir,tmp] = pop(Dir,1);
    if tmp == 1
        numerate(index, CoinMap, coin, pos+[0, 1], allDirections)
    elseif tmp == 2
        numerate(index, CoinMap, coin, pos+[1, 0], allDirections)
    elseif tmp == 3
        numerate(index, CoinMap, coin, pos+[0,-1], allDirections)
    elseif tmp == 4
        numerate(index, CoinMap, coin, pos+[-1,0], allDirections)
    end
    
end
    %pos(:,iterate+1) = pos + 

    
    
end