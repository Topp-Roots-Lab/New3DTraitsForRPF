%This is part of the features derived for the manuscript
%Shao et al. Root Pulling Force

%computer vertical density for fixed depth
file=dir('*.png'); %3D X-ray binary image slices
clear BW
for k=1:length(file)
I=imread(file(k).name);
BW(:,:,k)=I;
end
[x y z]=findND(BW==255); %white voxels are the roots

[COEFF SCORE latent]=pca([x y z]);
elong=sqrt(latent(2)/latent(1)); %measure elongation
flat=sqrt(latent(3)/latent(2));  %measure flatness

%biomass distribution
Depth=850; %fix a depth
pts=Depth/20:Depth/20:Depth; %850 for 113um
[f,xi] = ksdensity(z,pts,'bandwidth',20); %density estimator
ConvH=zeros(size(BW));
if length(file)>Depth
    Solidity=zeros(1,length(file));
else
    Solidity=zeros(1,Depth);
end
for k=1:length(file)
    CH=bwconvhull(BW(:,:,k)); %convex hull for each slices
    ConvH(:,:,k)=CH;
    if length(find(ConvH(:,:,k))==1)>0
        Solidity(k)=length(find(BW(:,:,k))==255)/length(find(ConvH(:,:,k))==1);
    end
end
[cx cy cz]=findND(ConvH==1);

[cf,cxi] = ksdensity(cz,pts,'bandwidth',20); %density estimator for the convex hull
sf = interp1([1:length(Solidity)],Solidity,pts,'spline');
volume=length(x)*0.113^3;

dlmwrite('biomd.txt', [volume elong flat f cf sf], 'delimiter', '\t');

%stem diameter for first few slices are not stem
file=dir('*.png');
clear BW
for k=1:length(file)
I=imread(file(k).name);
BW(:,:,k)=I;
end
P=max(BW,[],1);
hh=permute(P,[2 3 1]);
imtool(hh) %determine the slices are stem
y0=75;y2=109;
Area=0;
for k=y0:y2
    CC = bwconncomp(BW(:,:,k));
    numPixels = cellfun(@numel,CC.PixelIdxList);
   [biggest,idx] = max(numPixels);
   BBW=zeros(size(BW(:,:,k)));
   BBW(CC.PixelIdxList{idx}) = 1;
   BBW=imfill(BBW,'holes');
   Area=Area+length(find(BBW==1));
end
2*sqrt(Area/((y2-y0+1)*pi))*0.113*2