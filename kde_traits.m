%This is part of the features derived for the manuscript
%Shao et al. Root Pulling Force

function [f, cf] = kde_traits(inputPath, slicethickness, sampling, depth = 200)
    slicethickness = str2double(slicethickness);
    sampling = str2num(sampling);
    %compute vertical density for fixed depth
    filePattern = fullfile(inputPath, '*.png');
    file = dir(filePattern); %3D X-ray binary image slices
    clear BW

    for k = 1:length(file)
        I = imread(fullfile(file(k).folder, file(k).name));
        BW(:, :, k) = I;
    end

    [x, y, z] = findND(BW == 255); %white voxels are the roots

    %biomass distribution
    scale = sampling * slicethickness;
    Depth = cast(round(depth / scale), 'double'); %fix a depth
    depth_cm = depth / 10;
    pts = linspace(floor(Depth / depth_cm), Depth, depth_cm);
    [f, xi] = ksdensity(z, pts, 'bandwidth', depth_cm); %density estimator
    ConvH = zeros(size(BW));

    for k = 1:length(file)
        CH = bwconvhull(BW(:, :, k)); %convex hull for each slices
        ConvH(:, :, k) = CH;
    end

    [cx, cy, cz] = findND(ConvH == 1);

    [cf, cxi] = ksdensity(cz, pts, 'bandwidth', depth_cm); %density estimator for the convex hull

    for i = 1:length(f)
        fprintf(1, "%s biomass_vhist%d %.13f\n", inputPath, i, f(i));
    end

    for i = 1:length(cf)
        fprintf(1, "%s convexHull_vhist%d %.13f\n", inputPath, i, cf(i));
    end
