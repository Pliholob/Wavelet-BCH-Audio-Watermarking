function [odge snr mbit]=emb(sdlm,ubc,em,levdw,att,cwl,k,file,imw,inten,fram,lwband)
 warning('off','all')
%% Inisialisasi percobaan
%BCH Code
% cwl=15;  %panjang codeword
% k = 7;   %segmentasi pesan

% lwband='high';
levd=0;  %dibiarkan 0. ubah dari fungsi
% file='lf10.wav';
kotak=  2;    %harus 2^n
% fram= 256;
% fram= kotak^2;
% imw='water.bmp';
% inten=0.03;  %intensitas watermark. skala 0 sampai 1

%% init aud
[y fs]=audioread(file);
y=y.';
x=y;
    
%% impreproc
reim=imread(imw);
[pa leb]=size(reim);
strim=double(reshape(reim,[1 pa*leb]));

switch ubc
    case 0
        emim=strim;
    case 1
        padd= ceil(length(strim)/k)*k-length(strim);
        strimm=[strim zeros(1,padd)];
        enc=comm.BCHEncoder(cwl,k);
        emim=step(enc,strimm.').';
    otherwise
        msg = 'input UBC hanya boleh 0 atau 1';
        error(msg);
end

kapwat=length(emim);


%% embed
switch sdlm
    case 1 %SWT
        mframe=floor(length(y)/fram);   %maxbit
        mbit=capcheckswt(fram,mframe,kotak);
        if kapwat  > mbit
            msg = 'Kapasitas yang tersedia tidak cukup untuk menampung watermark';
            error(msg);
        end
        
        inim=1;
        sus=0;
        for i=1:mframe
            framed_aud=y(fram*(i-1)+1:i*fram);
            
%             winh=hamming(fram);
%             framed_aud=framed_aud.*winh.';
%             
            
            
            taud=swt(framed_aud,2,'db1');
            procdet=taud(2,:);
            dzmat=double(reshape(procdet,[kotak fram/kotak]));
            for kot=1:(size(dzmat,2)/kotak)
                pdzmat=dzmat(:,(kot-1)*kotak+1:kot*kotak);
                
                
                switch em
                    case 1   %SVD
                        
                        [u s v]=svd(pdzmat);
                        
                        
                        switch emim(inim)
                            case 0
                                s(1,1)=floor(s(1,1)/inten)*inten+inten/2;
                            case 1
                                s(1,1)=round(s(1,1)/inten)*inten;
                        end
                        
                        inim=inim+1;
                        emsam=u*s*v.';
                        
                    case 2   %QR
                        [q r]=qr(pdzmat);
                        rtop=r;
                        switch emim(inim)
                            case 0
                                rtop(1,1)=floor(r(1,1)/inten)*inten+inten/2;
                            case 1
                                rtop(1,1)=round(r(1,1)/inten)*inten;
                        end
                        inim=inim+1;
                        emsam=double(q*rtop);
                end
                
                ndzmat(:,(kot-1)*kotak+1:kot*kotak)=emsam;
                
                if inim > kapwat
                    sus=1;
                    break
                end
                
            end
            
            fidz=reshape(ndzmat,[1 fram]);
            taud(2,:)=fidz;
            procaud=iswt(taud,'db1');
            
%             procaud=procaud./winh.';
            
            y(fram*(i-1)+1:i*fram)=procaud;
            
            if sus==1
                break
            end
            
        end
        
    case 2 %DWT
        levd=levdw;   %wajib diganti tiap ganti level
        mframe=floor(length(y)/fram);   %maxbit
        mbit=capcheckdwt(fram,mframe,kotak,levd);
        if kapwat  > mbit
            msg = 'Kapasitas yang tersedia tidak cukup untuk menampung watermark';
            error(msg);
        end
        
        inim=1;
        sus=0;
        for i=1:mframe
            framed_aud=y(fram*(i-1)+1:i*fram);
            [c l]=wavedec(framed_aud,3,'db1');
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
                        
                        
                        switch emim(inim)
                            case 0
                                s(1,1)=floor(s(1,1)/inten)*inten+inten/2;
                            case 1
                                s(1,1)=round(s(1,1)/inten)*inten;
                        end
                        
                        inim=inim+1;
                        emsam=u*s*v.';
                        
                    case 2   %QR
                        [q r]=qr(pdzmat);
                        rtop=r;
                        switch emim(inim)
                            case 0
                                rtop(1,1)=floor(r(1,1)/inten)*inten+inten/2;
                            case 1
                                rtop(1,1)=round(r(1,1)/inten)*inten;
                        end
                        inim=inim+1;
                        emsam=double(q*rtop);
                end
                
                ndzmat(:,(kot-1)*kotak+1:kot*kotak)=emsam;
                
                if inim > kapwat
                    sus=1;
                    break
                end
                
            end
            
            fidz=reshape(ndzmat,[1 fram/(2^levd)]);
            
            switch levd
                case 1
                    c(end/2+1:end)=fidz;
                case 2
                    c(end/4+1:end/2)=fidz;
                case 3
                    c(end/8+1:end/4)=fidz;
            end
            
            
            procaud=waverec(c,l,'db1');
            y(fram*(i-1)+1:i*fram)=procaud;
            
            if sus==1
                break
            end
            
        end
        
         case 3 %LWT
        levd=levdw;   %wajib diganti tiap ganti level
        mframe=floor(length(y)/fram);   %maxbit
        mbit=capchecklwt(fram,mframe,kotak,levd);
        if kapwat  > mbit
            msg = 'Kapasitas yang tersedia tidak cukup untuk menampung watermark';
            error(msg);
        end
        
        inim=1;
        sus=0;
        for i=1:mframe
            framed_aud=y(fram*(i-1)+1:i*fram);
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
                        
                        
                        switch emim(inim)
                            case 0
                                s(1,1)=floor(s(1,1)/inten)*inten+inten/2;
                            case 1
                                s(1,1)=round(s(1,1)/inten)*inten;
                        end
                        
                        inim=inim+1;
                        emsam=u*s*v.';
                        
                    case 2   %QR
                        [q r]=qr(pdzmat);
                        rtop=r;
                        switch emim(inim)
                            case 0
                                rtop(1,1)=floor(r(1,1)/inten)*inten+inten/2;
                            case 1
                                rtop(1,1)=round(r(1,1)/inten)*inten;
                        end
                        inim=inim+1;
                        emsam=double(q*rtop);
                end
                
                ndzmat(:,(kot-1)*kotak+1:kot*kotak)=emsam;
                
                if inim > kapwat
                    sus=1;
                    break
                end
                
            end
            
            fidz=reshape(ndzmat,[1 fram/(2)]);
            
              
            switch lwband
                case 'low'
            c(1:2:end)=fidz;
                case 'high'
            c(2:2:end)=fidz;
            end
            
            
            procaud=ilwt(c,'db1',levd);
            y(fram*(i-1)+1:i*fram)=procaud;
            
            if sus==1
                break
            end
            
        end
        
        case 4 %LWT-DCT
        levd=levdw;   %wajib diganti tiap ganti level
        mframe=floor(length(y)/fram);   %maxbit
        mbit=capchecklwt(fram,mframe,kotak,levd);
        if kapwat  > mbit
            msg = 'Kapasitas yang tersedia tidak cukup untuk menampung watermark';
            error(msg);
        end
        
        inim=1;
        sus=0;
        for i=1:mframe
            framed_aud=y(fram*(i-1)+1:i*fram);
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
                        
                        
                        switch emim(inim)
                            case 0
                                s(1,1)=floor(s(1,1)/inten)*inten+inten/2;
                            case 1
                                s(1,1)=round(s(1,1)/inten)*inten;
                        end
                        
                        inim=inim+1;
                        emsam=u*s*v.';
                        
                    case 2   %QR
                        [q r]=qr(pdzmat);
                        rtop=r;
                        switch emim(inim)
                            case 0
                                rtop(1,1)=floor(r(1,1)/inten)*inten+inten/2;
                            case 1
                                rtop(1,1)=round(r(1,1)/inten)*inten;
                        end
                        inim=inim+1;
                        emsam=double(q*rtop);
                end
                
                ndzmat(:,(kot-1)*kotak+1:kot*kotak)=emsam;
                
                if inim > kapwat
                    sus=1;
                    break
                end
                
            end
            
            fidz=reshape(ndzmat,[1 fram/(2)]);
            fidz=idct(fidz);
              
            switch lwband
                case 'low'
            c(1:2:end)=fidz;
                case 'high'
            c(2:2:end)=fidz;
            end
            
            
            procaud=ilwt(c,'db1',levd);
            y(fram*(i-1)+1:i*fram)=procaud;
            
            if sus==1
                break
            end
            
        end
end


foldaw=pwd;
audiowrite([foldaw '\wfold\temp.wav'],y,fs);
cd(foldaw)
if att~=0
    alltestbed(att,'wfold\','afold\',16);
end
[snr mse]=hitungsnr('wfold\temp.wav',file);

% h=waitbar(0,'Quality Checking in process...');
odef=PQevalAudio(file,file,1,length(y),fs);
% waitbar(1/2,h);
odge=PQevalAudio(file,'wfold\temp.wav',1,length(y),fs)-odef;
% waitbar(1,h);
% close(h);

delete dat.mat
save dat.mat inten fram kapwat pa leb cwl k strim kotak levd lwband imw

return