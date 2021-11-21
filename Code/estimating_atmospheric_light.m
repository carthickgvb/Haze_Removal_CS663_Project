function A = estimating_atmospheric_light(Ir,Ig,Ib,J_dark)
% Estimaing the atmospheric light from the dark channel of image I.
A = zeros(1,3);
brightest = max(J_dark,[],'all');
bright_pixel_loc = J_dark>(brightest*(0.999)); % top 0.1% brightest pixels
A(1) = max(Ir(bright_pixel_loc),[],'all');
A(2) = max(Ig(bright_pixel_loc),[],'all');
A(3) = max(Ib(bright_pixel_loc),[],'all');
end

