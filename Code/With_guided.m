%% dark channel prior based haze removal

clear;
close all;

I = im2double(imread("hazy_images/0001_0.95_0.2.jpg"));
Ir = I(:,:,1); % Red channel
Ig = I(:,:,2); % Green channel
Ib = I(:,:,3); % Blue channel
[M,N] = size(Ir);
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

A = zeros(1,3);
brightest = max(J_dark,[],'all');
bright_pixel_loc = J_dark>(brightest*(0.999)); % top 0.1% brightest pixels
A(1) = max(Ir(bright_pixel_loc),[],'all');
A(2) = max(Ig(bright_pixel_loc),[],'all');
A(3) = max(Ib(bright_pixel_loc),[],'all');

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

%% guided filter 

% Linear model: t_hat = ax.*Ik+bx, where Ik is the patch of size wk
wk = 75; % window size 
eps = 1e-3;
p = floor((wk-1)/2);
Ir_pad = padarray(Ir, [p,p], 'replicate', 'both'); 
Ig_pad = padarray(Ig, [p,p], 'replicate', 'both');
Ib_pad = padarray(Ib, [p,p], 'replicate', 'both');
t_pad = padarray(t, [p,p], 'replicate', 'both');

t_hat = zeros(size(t));
for i = 1:M
    for j = 1:N
        Ir_patch = Ir_pad(i:i+wk-1, j:j+wk-1);
        Ig_patch = Ig_pad(i:i+wk-1, j:j+wk-1);
        Ib_patch = Ib_pad(i:i+wk-1, j:j+wk-1);
        t_patch = t_pad(i:i+wk-1, j:j+wk-1);
        
        Ir_mean = mean(Ir_patch, 'all');
        Ig_mean = mean(Ig_patch, 'all');
        Ib_mean = mean(Ib_patch, 'all');
        t_mean = mean(t_patch, 'all');
        
        var_Ir = mean(Ir_patch.*Ir_patch, 'all')-(Ir_mean.*Ir_mean);
        cov_Ir_t = mean(Ir_patch.*t_patch, 'all')-(Ir_mean.*t_mean);
        var_Ig = mean(Ig_patch.*Ig_patch, 'all')-(Ig_mean.*Ig_mean);
        cov_Ig_t = mean(Ig_patch.*t_patch, 'all')-(Ig_mean.*t_mean);
        var_Ib = mean(Ib_patch.*Ib_patch, 'all')-(Ib_mean.*Ib_mean);
        cov_Ib_t = mean(Ib_patch.*t_patch, 'all')-(Ib_mean.*t_mean);
        
        a1 = cov_Ir_t./(var_Ir+eps); b1 = t_mean-(a1.*Ir_mean);
        a2 = cov_Ig_t./(var_Ig+eps); b2 = t_mean-(a2.*Ig_mean);
        a3 = cov_Ib_t./(var_Ib+eps); b3 = t_mean-(a3.*Ib_mean);
        
        t_hat(i,j) = (a1.*Ir(i,j)+b1+a2.*Ig(i,j)+b2+a3.*Ib(i,j)+b3)./3;
    end
end

%% actual scene

t0 = 0.1;
J = zeros(size(I));
J(:,:,1) = ((Ir-A(1))./max(t_hat,t0)) + A(1);
J(:,:,2) = ((Ig-A(2))./max(t_hat,t0)) + A(2);
J(:,:,3) = ((Ib-A(3))./max(t_hat,t0)) + A(3);

J1(:,:,1) = ((Ir-A(1))./max(t,t0)) + A(1);
J1(:,:,2) = ((Ig-A(2))./max(t,t0)) + A(2);
J1(:,:,3) = ((Ib-A(3))./max(t,t0)) + A(3);

figure(); imshow(J);
figure(); imshow(J1);
rmse = error_fn(J, I);
fprintf('RMSE between J and I %d.\n', rmse);

%% RMSE function

function rmse = error_fn(I_obt, I_gnd_truth)
    rmse = sqrt(mean((I_gnd_truth).^2 - (I_obt.^2), 'all'));
end