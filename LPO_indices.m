function [sum_aij_010, sum_aij_001,aij_new, nGrains] = LPO_indices(aij_v)   
    nGrains = size(aij_v,1);
    aij_new = zeros(3,3,nGrains);
    sum_aij_010 = zeros(3,3);
    sum_aij_001 = zeros(3,3);

    for iGrain = 1:nGrains
        %aij_new(:,:,iGrain) = reshape(aij_v(iGrain,:),3,3);
        aij_new(:,:,iGrain) = [aij_v(iGrain,1), aij_v(iGrain,2), aij_v(iGrain,3);
              aij_v(iGrain,4), aij_v(iGrain,5), aij_v(iGrain,6);
              aij_v(iGrain,7), aij_v(iGrain,8), aij_v(iGrain,9)];

        %for [010]
        x010 = aij_new(2,1,iGrain);
        y010 = aij_new(2,2,iGrain);
        z010 = aij_new(2,3,iGrain);

        sum_aij_010(1,1) = sum_aij_010(1,1) + x010*x010;
        sum_aij_010(1,2) = sum_aij_010(1,2) + x010*y010;
        sum_aij_010(1,3) = sum_aij_010(1,3) + x010*z010;
        sum_aij_010(2,2) = sum_aij_010(2,2) + y010*y010;
        sum_aij_010(2,3) = sum_aij_010(2,3) + y010*z010;
        sum_aij_010(3,3) = sum_aij_010(3,3) + z010*z010;

        sum_aij_010(2,1) = sum_aij_010(1,2);
        sum_aij_010(3,1) = sum_aij_010(1,3);
        sum_aij_010(3,2) = sum_aij_010(2,3);

        %for [001]
        x001 = aij_new(3,1,iGrain);
        y001 = aij_new(3,2,iGrain);
        z001 = aij_new(3,3,iGrain);

        sum_aij_001(1,1) = sum_aij_001(1,1) + x001*x001;
        sum_aij_001(1,2) = sum_aij_001(1,2) + x001*y001;
        sum_aij_001(1,3) = sum_aij_001(1,3) + x001*z001;
        sum_aij_001(2,2) = sum_aij_001(2,2) + y001*y001;
        sum_aij_001(2,3) = sum_aij_001(2,3) + y001*z001;
        sum_aij_001(3,3) = sum_aij_001(3,3) + z001*z001;

        sum_aij_001(2,1) = sum_aij_001(1,2);
        sum_aij_001(3,1) = sum_aij_001(1,3);
        sum_aij_001(3,2) = sum_aij_001(2,3);
   
    end
end
