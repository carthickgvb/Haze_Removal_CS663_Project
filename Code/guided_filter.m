function t_hat = guided_filter(Ir,Ig,Ib,t,wk,eps)
% Refining the transmission map using guided filter.
% Linear model: t_hat = ax.*Ik+bx, where Ik is the patch of size wk
[M,N] = size(Ir);
% wk = 75; % window size 
% eps = 1e-3;
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
end

