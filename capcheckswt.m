function maxs=capcheckswt(fram,mfr,kota)
maxs=floor(mfr*fram/(kota^2));

% maxs=0;
% for i=1:mfr
%     framed_aud=y(fram*(i-1)+1:i*fram);
%     
%     taud=swt(framed_aud,2,'db1');
%     procdet=taud(2,:);
%     dzmat=reshape(procdet,[4 fram/4]);
%     for kot=1:(size(dzmat,2)/4)
%         pdzmat=dzmat(:,(kot-1)*4+1:kot*4);
%         %     if s(1,1) ~=0
%         maxs=maxs+1;
%         %     end
%     end
% end