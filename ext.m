function [ber psr simm]=ext(sdlm,ubc,em,att)

if att~=0
filee=['afold\' num2str(att) '-mp.wav'];
else
filee='wfold\temp.wav';
end


load dat
y=audioread(filee);
y=y.';
mb=floor(length(y)/fram);

%% Extract

switch sdlm
    case 1  %SWT
        
        sus=0;
        ej=1;
        for in=1:mb
            framed_aud=y(fram*(in-1)+1:in*fram);
            
            
%              winh=hamming(fram);
%             framed_aud=framed_aud.*winh.';
%             
            
            taud=swt(framed_aud,2,'db1');
            procdet=taud(2,:);
            dzmat=reshape(procdet,[kotak fram/kotak]);
            
            for kot=1:(size(dzmat,2)/kotak)
                pdzmat=dzmat(:,(kot-1)*kotak+1:kot*kotak);
                
                switch em
                    case 1   %SVD
                        [u s v]=svd(pdzmat);
                        ev=mod(s(1,1),inten);
                        if ev>=inten/4 && ev<=3*inten/4;
                            wex(ej)=0;
                        else
                            wex(ej)=1;
                        end
                        
                        
                        ej=ej+1;
                        
                    case 2 %QR
                        [q r]=qr(pdzmat);
                        ev=mod(r(1,1),inten);
                        if ev>=inten/4 && ev<=3*inten/4;
                            wex(ej)=0;
                        else
                            wex(ej)=1;
                        end
                        ej=ej+1;
                end
                
                if ej>kapwat
                    sus=1;
                    break
                end
                
            end
            
            
            if sus==1
                break
            end
            
        end
        
    case 2 %DWT
        sus=0;
        ej=1;
%         levd=2;   %wajib diganti tiap ganti level
        for in=1:mb
            framed_aud=y(fram*(in-1)+1:in*fram);
            [c l]=wavedec(framed_aud,levd,'db1');
            
               switch levd
                case 1
                    pdzmat=c(end/2+1:end);
                case 2
                    pdzmat=c(end/4+1:end/2);
                case 3
                    pdzmat=c(end/8+1:end/4);
            end
            
            dzmat=double(reshape(pdzmat,[kotak (fram/(2^levd))/kotak]));
             
            for kot=1:(size(dzmat,2)/kotak)
                pdzmat=dzmat(:,(kot-1)*kotak+1:kot*kotak);
                
                switch em
                    case 1   %SVD
                        [u s v]=svd(pdzmat);
                        ev=mod(s(1,1),inten);
                        if ev>=inten/4 && ev<=3*inten/4;
                            wex(ej)=0;
                        else
                            wex(ej)=1;
                        end
                        
                        
                        ej=ej+1;
                        
                    case 2 %QR
                        [q r]=qr(pdzmat);
                        ev=mod(r(1,1),inten);
                        if ev>=inten/4 && ev<=3*inten/4;
                            wex(ej)=0;
                        else
                            wex(ej)=1;
                        end
                        ej=ej+1;
                end
                
                if ej>kapwat
                    sus=1;
                    break
                end
                
            end
            
            
            if sus==1
                break
            end
            
        end
        
         case 3 %LWT
        sus=0;
        ej=1;
%         levd=2;   %wajib diganti tiap ganti level
        for in=1:mb
            framed_aud=y(fram*(in-1)+1:in*fram);
            c=lwt(framed_aud,'db1',levd);
            
               switch lwband
                case 'low'
            pdzmat=c(1:2:end); 
                case 'high'
            pdzmat=c(2:2:end); 
            end
            
            dzmat=double(reshape(pdzmat,[kotak (fram/(2))/kotak]));
             
            for kot=1:(size(dzmat,2)/kotak)
                pdzmat=dzmat(:,(kot-1)*kotak+1:kot*kotak);
                
                switch em
                    case 1   %SVD
                        [u s v]=svd(pdzmat);
                        ev=mod(s(1,1),inten);
                        if ev>=inten/4 && ev<=3*inten/4;
                            wex(ej)=0;
                        else
                            wex(ej)=1;
                        end
                        
                        
                        ej=ej+1;
                        
                    case 2 %QR
                        [q r]=qr(pdzmat);
                        ev=mod(r(1,1),inten);
                        if ev>=inten/4 && ev<=3*inten/4;
                            wex(ej)=0;
                        else
                            wex(ej)=1;
                        end
                        ej=ej+1;
                end
                
                if ej>kapwat
                    sus=1;
                    break
                end
                
            end
            
            
            if sus==1
                break
            end
            
        end
        
          case 4 %LWT-DCT
        sus=0;
        ej=1;
%         levd=2;   %wajib diganti tiap ganti level
        for in=1:mb
            framed_aud=y(fram*(in-1)+1:in*fram);
            c=lwt(framed_aud,'db1',levd);
            
               switch lwband
                case 'low'
            pdzmat=c(1:2:end); 
                case 'high'
            pdzmat=c(2:2:end); 
               end
            
            pdzmat=dct(pdzmat);
               
            dzmat=double(reshape(pdzmat,[kotak (fram/(2))/kotak]));
             
            for kot=1:(size(dzmat,2)/kotak)
                pdzmat=dzmat(:,(kot-1)*kotak+1:kot*kotak);
                
                switch em
                    case 1   %SVD
                        [u s v]=svd(pdzmat);
                        ev=mod(s(1,1),inten);
                        if ev>=inten/4 && ev<=3*inten/4;
                            wex(ej)=0;
                        else
                            wex(ej)=1;
                        end
                        
                        
                        ej=ej+1;
                        
                    case 2 %QR
                        [q r]=qr(pdzmat);
                        ev=mod(r(1,1),inten);
                        if ev>=inten/4 && ev<=3*inten/4;
                            wex(ej)=0;
                        else
                            wex(ej)=1;
                        end
                        ej=ej+1;
                end
                
                if ej>kapwat
                    sus=1;
                    break
                end
                
            end
            
            
            if sus==1
                break
            end
            
        end
end

%% BCH or non
switch ubc
    case 0
        w=wex;
    case 1
        dec=comm.BCHDecoder(cwl,k);
        wet=step(dec,wex.').';
        wetb(1,:)=wet(1:pa*leb);
        w=wetb;
    otherwise
        msg = 'input UBC hanya boleh 0 atau 1';
        error(msg);
end

[jer ber]=symerr(strim,w);
w=reshape(w,[pa leb]);
water=im2bw(w*255);
imwrite(water,'ekstrak.bmp');

psr=psnr(uint8(imread('ekstrak.bmp'))*255,uint8(imread(imw))*255);
simm=ssim(uint8(imread('ekstrak.bmp'))*255,uint8(imread(imw))*255);
%nilai SSIM
% ssim(uint8(imread('water.bmp'))*255,uint8(imread('ekstrak.bmp'))*255);


return