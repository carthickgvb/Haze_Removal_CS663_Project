function I_dehazed = image_dehazing(I,Ir,Ig,Ib,t,A,t0)
% Obtainig the de-hazed image.
% t0 = 0.1;
I_dehazed = zeros(size(I));
I_dehazed(:,:,1) = ((Ir-A(1))./max(t,t0)) + A(1);
I_dehazed(:,:,2) = ((Ig-A(2))./max(t,t0)) + A(2);
I_dehazed(:,:,3) = ((Ib-A(3))./max(t,t0)) + A(3);
end

