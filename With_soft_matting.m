%% dark channel prior based haze removal

clear;
close all;

I = im2double(imread("hazy_images/0001_0.95_0.2.jpg"));
Ir = I(:, :, 1); % Red channel
Ig = I(:, :, 2); % Green channel
Ib = I(:, :, 3); % Blue channel
[M, N] = size(Ir);
figure(1); imshow(I);

%% determining dark channel

J_dark = zeros(size(Ir));
I_min = min(I, [], 3);
K = 15; % patch size
[r, c] = size(I_min);

for x = 1:c

    for y = 1:r
        i1 = max(y - (K - 1) / 2, 1); i2 = min(y + (K - 1) / 2, r); % local patch start and end rows
        j1 = max(x - (K - 1) / 2, 1); j2 = min(x + (K - 1) / 2, c); % local patch start and end columns
        local_patch = I_min(i1:i2, j1:j2);
        J_dark(y, x) = min(local_patch(:));
    end

end

figure(2); imshow(J_dark);

%% determining air light: A

A = zeros(1, 3);
brightest = max(J_dark, [], 'all');
bright_pixel_loc = J_dark > (brightest * (0.999)); % top 0.1 % brightest pixels
A(1) = max(Ir(bright_pixel_loc), [], 'all');
A(2) = max(Ig(bright_pixel_loc), [], 'all');
A(3) = max(Ib(bright_pixel_loc), [], 'all');

%% determing transmission: t

w = 0.95;
IbyA = cat(3, Ir ./ A(1), Ig ./ A(2), Ib ./ A(3));
IbyA_min = min(IbyA, [], 3);
t = zeros(size(J_dark));
[r, c] = size(t);

for x = 1:c

    for y = 1:r
        i1 = max(y - (K - 1) / 2, 1); i2 = min(y + (K - 1) / 2, r); % local patch start and end rows
        j1 = max(x - (K - 1) / 2, 1); j2 = min(x + (K - 1) / 2, c); % local patch start and end columns
        local_patch = IbyA_min(i1:i2, j1:j2);
        t(y, x) = 1 - w * min(local_patch(:));
    end

end

%% soft matting

% Matting Laplacian matrix: L
win_size = 3; % window size
win = floor((win_size - 1) / 2);
reg_par = 0.0001;
[r, c] = size(Ir);
L = zeros(r * c, r * c);

for x = 1 + win:c - win

    for y = 1 + win:r - win
        i1 = y - win; i2 = y + win; % window start and end rows
        j1 = x - win; j2 = x + win; % window start and end columns
        local_win = I(i1:i2, j1:j2, :);
        mean_vec = reshape(mean(local_win, [1 2]), 3, 1);
        covar_mat = cov(reshape(local_win, 9, 3));
        mid_mat = covar_mat + (reg_par / win_size^2) * eye(3);
        Ii_T = [reshape(local_win(:, 1, :), win_size, win_size);
            reshape(local_win(:, 2, :), win_size, win_size);
            reshape(local_win(:, 3, :), win_size, win_size)];
        Ij = Ii_T';
        idx_vec = M * (x - win - 1:x + win - 1) + (y - win:y + win)';
        L(idx_vec, idx_vec) = L(idx_vec, idx_vec) + eye(win_size^2, win_size^2) - (1 / win_size^2) * (1 + (Ii_T - mean_vec') * (mid_mat \ (Ij - mean_vec)));
    end

end

% refined t: t_ref
lambda = 0.0001;
t_ref = pcg(L + lambda * eye(size(L)), lambda * t); % Preconditioned Conjugate Gradient algorithm

%% actual scene

t0 = 0.1;
J = zeros(size(I));
J(:, :, 1) = ((Ir - A(1)) ./ max(t, t0)) + A(1);
J(:, :, 2) = ((Ig - A(2)) ./ max(t, t0)) + A(2);
J(:, :, 3) = ((Ib - A(3)) ./ max(t, t0)) + A(3);

figure(); imshow(J);
