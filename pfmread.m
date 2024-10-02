function [I, scale] = pfmread(filename)
%PFMREAD  Read a PFM image.
%   I = PFMREAD(FILENAME) reads a PFM image from a file specified by FILENAME.
%   
%   I, SCALE = PFMREAD(FILENAME) also returns the scale parameter stored in the
%   PFM file.
%
%   See also PFMWRITE.

fid = fopen(filename);

id = fscanf(fid,'%c\n', 2);

if strcmp(id, 'Pf')
  nchannels = 1;
elseif strcmp(id, 'PF')
  nchannels = 3;
else
  error('Unknown image type %s', header)
end

dims = fscanf(fid, '%d %d\n', 2);

order = fscanf(fid, '%f\n', 1);
scale = abs(order);
machinefmt = 'ieee-le';
if order > 0.0
  machinefmt = 'ieee-be';  
end

skip = 0;
[I, count] = fread(fid, [nchannels, dims(1) * dims(2)], "single=>single", skip, machinefmt);

assert(count == nchannels * dims(1) * dims(2));
assert(isa(I, 'single'));

% Reshape to declared size plus deinterlace if working with RGB images 
if nchannels == 3
  I = cat(3, ...
    reshape(I(1, :), [dims(1) dims(2)]), ...
    reshape(I(2, :), [dims(1) dims(2)]), ...
    reshape(I(3, :), [dims(1) dims(2)]));
else
  I = reshape(I, [dims(1) dims(2)]);
end

% fread() extracts in column order; raster is organized by row, bottom to top. 
% Correct with rot90().
I = rot90(I);

fclose(fid);
