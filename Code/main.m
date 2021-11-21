clear;
close all;

I = cell(1,4);
dark_channels = cell(1,4);
I_dehazed = cell(1,4);
I_without_guided = cell(1,4);
I_gnd_truth = cell(1,4);
for i = 1:4
    fname_hazy = sprintf ('Datasets\\Our_dataset\\%d_hazy.jpg',i);
    I{i} = im2double(imread(fname_hazy));
    fname = sprintf ('Datasets\\Our_dataset\\%d.jpg',i);
    I_gnd_truth{i} = im2double(imread(fname));
    
    % Image dehazing
    [Ir, Ig, Ib] = img_to_channels(I{i});
    dark_channels{i} = dark_channel(I{i},15);
    A = estimating_atmospheric_light(Ir,Ig,Ib,dark_channels{i});
    t = estimating_transmission(Ir,Ig,Ib,A,dark_channels{i},0.95,15);
    t_hat = guided_filter(Ir,Ig,Ib,t,75,1e-3);
    I_without_guided{i} = image_dehazing(I{i},Ir,Ig,Ib,t,A,0.1);
    I_dehazed{i} = image_dehazing(I{i},Ir,Ig,Ib,t_hat,A,0.1);
    rmse = rmse_error(I_dehazed{i}, I_gnd_truth{i});
    fprintf('rmse for image %d is %d.\n', i, rmse);
end

for i = 1:4
    figure();
    subplot(2,2,1)
    imshow(I{i});
    title('Hazy Image');
    subplot(2,2,2)
    imshow(dark_channels{i});
    title('Dark Channel');
    subplot(2,2,3)
    imshow(I_without_guided{i});
    title('Without Guided');
    subplot(2,2,4)
    imshow(I_dehazed{i});
    title('Dehazed Image');
end
    