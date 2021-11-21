function [Ir,Ig,Ib] = img_to_channels(I)
% Gets the r,g,b channels from the image I.
Ir = I(:,:,1); % Red channel
Ig = I(:,:,2); % Green channel
Ib = I(:,:,3); % Blue channel
end

