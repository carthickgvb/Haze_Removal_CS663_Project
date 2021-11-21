function J_dark = dark_channel(I,K)
% Determining the dark channel of the image I.
J_dark = zeros(size(I(:,:,1)));
I_min = min(I,[],3);
% K = 15; % patch size
[r, c] = size(I_min);
for x = 1:c
    for y = 1:r
        i1 = max(y-(K-1)/2,1); i2 = min(y+(K-1)/2,r); % local patch start and end rows
        j1 = max(x-(K-1)/2,1); j2 = min(x+(K-1)/2,c); % local patch start and end columns
        local_patch = I_min(i1:i2,j1:j2);
        J_dark(y,x) = min(local_patch(:));
    end
end
end

