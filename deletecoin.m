function i = deletecoin(x,y,data)
    x = round(x); y= round(y);
    [datax,~] = size(data);
    %search for this point
    for i = 1:datax
        if y == data(i,2)
            if x == data(i,1)
                return;
            end
        end
    end
    i = -1;
end