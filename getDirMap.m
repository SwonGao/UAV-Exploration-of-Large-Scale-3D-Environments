function direction = getDirMap(MAP)
[m,n] = size(MAP);
MAP_extension = ones(m+2,n+2);
MAP_extension(2:m+1,2:n+1) = MAP;
direction = cell(n,m);
for i = 2 : m + 1
    for j = 2 : n + 1
        if MAP_extension(i,j) == 0
            if MAP_extension(i+1,j) == 0 % up 2
                if MAP_extension(i-1,j) == 0 % down 4
                    if MAP_extension(i,j+1) == 0 % right 1
                        if MAP_extension(i,j-1) == 0 % left 3
                            direction{j-1,m-i+2} = [1,2,3,4]; continue;
                        else
                            direction{j-1,m-i+2} = [1,2,4]; continue;
                        end
                    else % no 1
                        if MAP_extension(i,j-1) == 0 % left 3
                            direction{j-1,m-i+2} = [2,3,4]; continue;
                        else
                            direction{j-1,m-i+2} = [2,4]; continue;
                        end
                    end
                else %no 4 
                    if MAP_extension(i,j+1) == 0 % right 1
                        if MAP_extension(i,j-1) == 0 % left 3
                            direction{j-1,m-i+2} = [1,2,3]; continue;
                        else
                            direction{j-1,m-i+2} = [1,2]; continue;
                        end
                    else % no 4
                        if MAP_extension(i,j-1) == 0 % left 3
                            direction{j-1,m-i+2} = [2,3]; continue;
                        else
                            direction{j-1,m-i+2} = [2]; continue;
                        end
                    end
                end
            else %no 2    
                if MAP_extension(i-1,j) == 0 % down 4
                    if MAP_extension(i,j+1) == 0 % right 1
                        if MAP_extension(i,j-1) == 0 % left 3
                            direction{j-1,m-i+2} = [1,3,4]; continue;
                        else
                            direction{j-1,m-i+2} = [1,4]; continue;
                        end
                    else % no 1
                        if MAP_extension(i,j-1) == 0 % left 3
                            direction{j-1,m-i+2} = [3,4]; continue;
                        else
                            direction{j-1,m-i+2} = [4]; continue;
                        end
                    end
                else %no 4 
                    if MAP_extension(i,j+1) == 0 % right 1
                        if MAP_extension(i,j-1) == 0 % left 3
                            direction{j-1,m-i+2} = [1,3]; continue;
                        else
                            direction{j-1,m-i+2} = [1]; continue;
                        end
                    else % no 4
                        if MAP_extension(i,j-1) == 0 % left 3
                            direction{j-1,m-i+2} = [3]; continue;
                        else
                            direction{j-1,m-i+2} = []; continue;
                        end
                    end
                end                
            end
        else 
            direction{j-1,m-i+2} = [];
        end
    end
end

fileID = fopen('direction.txt','w');%NumerateTree/numeratetree/
fprintf(fileID,'%d\n',m*n);
for i = 1 : n
    for j = 1 : m
        [~,col] = size(direction{i,j});
        switch col
            case 1 
                fprintf(fileID,'%d\n',direction{i,j});
            case 2 
                fprintf(fileID,'%d%d\n',direction{i,j});  
            case 3 
                fprintf(fileID,'%d%d%d\n',direction{i,j});
            case 4 
                fprintf(fileID,'%d%d%d%d\n',direction{i,j});
            otherwise
                fprintf(fileID,'\n');
        end
    end
end
fclose(fileID);

end