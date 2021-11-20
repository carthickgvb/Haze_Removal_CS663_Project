%% dark channel prior based haze removal

clear;
close all;

I = im2double(imread("hazy_images/0001_0.95_0.2.jpg"));
%I = double(I);
Ir = I(:,:,1); % Red channel
Ig = I(:,:,2); % Green channel
Ib = I(:,:,3); % Blue channel
figure(1); imshow(I);

%% determining dark channel

J_dark = zeros(size(Ir));
I_min = min(I,[],3);
K = 15; % patch size
[r, c] = size(I_min);
for x = 1:c
    for y = 1:r
        i1 = max(y-(K-1)/2,1); i2 = min(y+(K-1)/2,r); % local patch start and end rows
        j1 = max(x-(K-1)/2,1); j2 = min(x+(K-1)/2,c); % local patch start and end columns
        local_patch = I_min(i1:i2,j1:j2);
        J_dark(y,x) = min(local_patch(:));
    end
end
figure(2); imshow(J_dark); 

%% determining air light: A

% A = zeros(1,3);
% brightest = max(J_dark,[],'all');
% bright_pixel_loc = J_dark>(brightest*(0.999)); % top 0.1% brightest pixels
% A(1) = max(Ir(bright_pixel_loc),[],'all');
% A(2) = max(Ig(bright_pixel_loc),[],'all');
% A(3) = max(Ib(bright_pixel_loc),[],'all');
A = Estimating_Atmospheric_Light(I,J_dark);

%% determing transmission: t

w = 0.95;
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

%% actual scene

t0 = 0.1;
J = zeros(size(I));
J(:,:,1) = ((Ir-A(1))./max(t,t0)) + A(1);
J(:,:,2) = ((Ig-A(2))./max(t,t0)) + A(2);
J(:,:,3) = ((Ir-A(3))./max(t,t0)) + A(3);

J1 = rgb2hsv(J);
%J1(:,:,1) = (J1(:,:,1)-min(J1(:,:,1),[],'all'))/(max(J1(:,:,1),[],'all')-min(J1(:,:,1),[],'all'));
%J1(:,:,2) = (J1(:,:,2)-min(J1(:,:,2),[],'all'))/(max(J1(:,:,2),[],'all')-min(J1(:,:,2),[],'all'));
J1(:,:,3) = (J1(:,:,3)-min(J1(:,:,3),[],'all'))/(max(J1(:,:,3),[],'all')-min(J1(:,:,3),[],'all'));
J1 = hsv2rgb(J1);

figure(); imshow(J);
figure(); imshow(J1);

