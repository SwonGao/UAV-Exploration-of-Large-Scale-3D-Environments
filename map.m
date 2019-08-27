function map = map(m)
    % this fuction create the map in the array form
    % it mainly includes some geometic information
    n = 0.6*m;
    map = zeros(m,n);
    map(1,:) = ones(1,n);     %map(m,:) = ones(1,n);     
    map(:,n) = ones(m,1);     %map(:,1) = ones(m,1);     
    map(round( m/5 )+1,1:round(0.2*n)) = ones(1,round(0.2*n));
    map(round( m/5 )+1,round(0.2*n) +round(0.8*n/3) : round(2*n/3) ) = ones(1,round(0.2*n)+1);
    map(round(3*m/5)+1,1:round(2*n/3)) = ones(1,round(2*n/3));
    map(round(m/5)+1 : round(3*m/5)+round(0.12*m)+1 , round(2*n/3) ) = ones(round(0.52*m)+1,1);
    map(round(3*m/5)+round(0.28*m)+1 : m , round(2*n/3) ) = ones(round(0.12*m),1);
end