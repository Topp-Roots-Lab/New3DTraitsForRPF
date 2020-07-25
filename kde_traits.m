%This is part of the features derived for the manuscript
%Shao et al. Root Pulling Force

function [f, cf] = kde_traits(inputPath, slicethickness, sampling)
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
    Depth = cast(round(200 / scale), 'double'); %fix a depth
    pts = linspace(floor(Depth / 20), Depth, 20);
    [f, xi] = ksdensity(z, pts, 'bandwidth', 20); %density estimator
    ConvH = zeros(size(BW));

    for k = 1:length(file)
        CH = bwconvhull(BW(:, :, k)); %convex hull for each slices
        ConvH(:, :, k) = CH;
    end

    [cx, cy, cz] = findND(ConvH == 1);

    [cf, cxi] = ksdensity(cz, pts, 'bandwidth', 20); %density estimator for the convex hull

    for i = 1:length(f)
        fprintf(1, "%s biomass_vhist%d %f\n", inputPath, i, f(i));
    end

    for i = 1:length(cf)
        fprintf(1, "%s convexHull_vhist%d %f\n", inputPath, i, cf(i));
    end
