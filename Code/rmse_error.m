function rmse = rmse_error(I_obt, I_gnd_truth)
% Obtaining the rmse error.
rmse = sqrt(mean((I_gnd_truth).^2 - (I_obt.^2), 'all'));
end

