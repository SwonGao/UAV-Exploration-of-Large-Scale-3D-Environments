function flag = ifconnected(curpos, curpos2, m, MAP)
    % Breseham's algorithm return a set of points
    %global MAP;
    curpos = round(curpos);
    curpos2 = round(curpos2);
    points = bresenham(curpos,curpos2);    
    flag = 1;
    [sizex,~] = size(points);
    %for every point in Bresenham's Algorithm
    for i = 1 : sizex
        if MAP(m+1-points(i,2),points(i,1)) == 1
            flag = 0; 
            return;
        end 
    end
end