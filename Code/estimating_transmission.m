function t = estimating_transmission(Ir,Ig,Ib,A,J_dark,w,K)
% Estimating the tramsmission t from the r,g,b channels of image I.
% w = 0.95;
% K = 15; % patch size
IbyA = cat(3,Ir./A(1),Ig./A(2),Ib./A(3));
IbyA_min = min(IbyA,[],3);
t = zeros(size(J_dark));
[r, c] = size(t);
for x = 1:c
    for y = 1:r
        i1 = max(y-(K-1)/2,1); i2 = min(y+(K-1)/2,r); % local patch start and end rows
        j1 = max(x-(K-1)/2,1); j2 = min(x+(K-1)/2,c); % local patch start and end columns
        local_patch = IbyA_min(i1:i2,j1:j2);
        t(y,x) = 1-w*min(local_patch(:));
    end
end
end

