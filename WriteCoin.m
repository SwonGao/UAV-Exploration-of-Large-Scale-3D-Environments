function WriteCoin(data)
% This function writes the Coin data into the txt file for usage in the C++
[a,~] = size(data);
fileiD = fopen('coin.txt','w');

fprintf(fileiD,'%d\n',a);
for i = 1 : a
    fprintf(fileiD,'%d %d\n',data(i,1),data(i,2));
end
fclose(fileiD);
end