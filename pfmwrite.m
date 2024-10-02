function pfmwrite(I, filename, varargin)
%PFMWRITE  Write a PFM image.
%   PFMWRITE(I, FILENAME) writes a floating-point image I to a file specified by
%   FILENAME.
%   
%   PFMWRITE(I, FILENAME, SCALE) allows the user to specify a positive scale
%   parameter SCALE that tells the units of the samples in the raster.
%   
%   PFMWRITE(I, FILENAME, SCALE, MACHINEFMT) controls endianness of the raster 
%   storage. Valid values are "ieee-le" (little endian, default) and "ieee-be"
%   (big endian).
%
%   See also PFMREAD.

assert(isa(I, 'single'), 'Unsupported class "%s". Use "single".', class(I));

nchannels = size(I, 3);
if nchannels == 1
  id = 'Pf';
elseif nchannels == 3
  id = 'PF';
else
  error('Unsupported number of channels.')
end

scale = 1.0;
if nargin >= 3
  scale = varargin{1};
end

assert(scale > 0.0, "Scale must be positive")

machinefmt = 'ieee-le';
if nargin == 4
  machinefmt = varargin{2};
end

if strcmp(machinefmt, 'ieee-le')
  order = -scale;
elseif strcmp(machinefmt, 'ieee-be')
  order = scale;
else 
  error('Invalid machine format "%s"')
end

rows = size(I, 1);
cols = size(I, 2);

fid = fopen(filename, 'wb');

fprintf(fid, '%s\n', id);
fprintf(fid, '%d %d\n', cols, rows);
fprintf(fid, '%f\n', order);

% The PFM raster stores pixels by row, bottom to top
I = flipud(I);

% To use fwrite(), which scans matrices in column order, the raster is 
% transposed (and channels interlaced if writing RGB images) via permute().
if nchannels == 1
  I = permute(I, [2, 1]);
else
  I = permute(I, [3, 2, 1]);
end

skip = 0;
assert(numel(I) == fwrite(fid, I, 'single', skip, machinefmt));

fclose(fid);
