function output = synth_quilt(tindex,tile_vec,tilesize,overlap)
%
% synthesize an output image given a set of tile indices
% where the tiles overlap, stitch the images together
% by finding an optimal seam between them
%
%  tindex : array containing the tile indices to use
%  tile_vec : array containing the tiles
%  tilesize : the size of the tiles  (should be sqrt of the size of the tile vectors)
%  overlap : overlap amount between tiles
%
%  output : the output image

if (tilesize ~= sqrt(size(tile_vec,1)))
  error('tilesize does not match the size of vectors in tile_vec');
end

% each tile contributes this much to the final output image width 
% except for the last tile in a row/column which isn't overlapped 
% by additional tiles
tilewidth = tilesize-overlap;  

% compute size of output image based on the size of the tile map
outputsize = size(tindex)*tilewidth+overlap;

output = zeros(outputsize(1),outputsize(2));
[h,w] = size(tindex);
temp = zeros(h*tilesize, outputsize(2));
% stitch each row into a separate image by repeatedly calling your stitch function
% 
for i = 1:size(tindex,1)
  for j = 1:size(tindex,2)-1
     ioffset = (i-1)*tilewidth;

     %grab the selected tile
     if(j == 1)   
        tile_image1 = tile_vec(:,tindex(i,j));
        tile_image1 = reshape(tile_image1,tilesize,tilesize);
     else
        tile_image1 = temp((1:tilesize)+((i-1)*tilesize), 1:(tilewidth*j)+overlap);
     end
     
     tile_image2 = tile_vec(:,tindex(i,j+1));
     tile_image2 = reshape(tile_image2,tilesize,tilesize);
     
     %stitching the image together
     tile_image = stitch(tile_image1, tile_image2, overlap);
     
     %putting it as an input
     temp((1:tilesize)+((i-1)*tilesize),1:size(tile_image,2)) = tile_image;
  end
end

temp1 = temp';
%
% now stitch the rows together into the final result 
% (call your stitch function on transposed row images and then transpose the result back)
%
output = output';
for i = 1:size(tindex,1)-1
 %grab the selected tile
 if(i ==1)
      tile_image1 = temp1(:, 1:((tilesize*i)-(i-1)*overlap));
 else
      tile_image1 = output(:, 1:((tilesize*i)-(i-1)*overlap));
 end
 
 tile_image2 = temp1(:,(tilesize*i)+1:tilesize*(i+1));
 %stitching the image together
 tile_image = stitch(tile_image1, tile_image2, overlap);

 %putting it as an input
 output(1:size(tile_image,1),1:size(tile_image,2)) = tile_image;
end

output = output';