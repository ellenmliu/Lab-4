imagefile = 'rice.jpg';

%source image
sampleI = im2double(rgb2gray(imread(imagefile)));
%target image
imagefile1 = im2double(rgb2gray(imread('face.jpg')));
alpha = .3; %alpha for texture transfer
N = 3; %iterations
ntilesout = size(imagefile1);   % how many tiles wide and tall the output should be
tilesize = 40;    % the size of the tiles we paste down (assumed square)
overlap = 10;      % how much overlap should there be between neighboring tiles
K = 1;            %number of top candidate matches we choose from
alltiles = true;  %use overlapping sample tiles, setting this to false 
                 % will generate fewer tiles in the database

% load in our texture example image and resize it
% sampleI = imresize(im2double(rgb2gray(imread(imagefile))),.5);

% extract sample tiles from sampleI 
tile_vec = sampletiles(sampleI,tilesize,alltiles);
nsampletiles = size(tile_vec,2);
if (nsampletiles<K)
  error('sample tile database is not big enough!');
end

% define a mask for the right,left,top and bottom edges of a tile
% the mask should be 1 in the overlap zone and zero everywhere else
maskR = [zeros(tilesize,tilesize-overlap) ones(tilesize,overlap)];
maskL = [ones(tilesize,overlap) zeros(tilesize,tilesize-overlap)];
maskT = [ones(overlap,tilesize); zeros(tilesize-overlap,tilesize)];
maskB = [zeros(tilesize-overlap,tilesize); ones(overlap,tilesize)];

% get the indices of patch pixels that are in right,left,top and bottom 
indR = find(maskR);
indL = find(maskL);
indT = find(maskT);
indB = find(maskB);

% now loop over output tiles 
tindex = imagefile1;
for iterations = 1:N
    for i = 1:ntilesout(1)
      for j = 1:ntilesout(2)
         % the first row and first column are a bit special because we don't have 
         % tiles to the left or above us at that point.
         if (i==1)&(j==1) %the first tile we just choose at random as in version 0
           matches = 1:nsampletiles;
         elseif (i==1) %first row (but not the first tile), only consider the tile to our left
             lefttile = tile_vec(:,tindex(i,j-1));
             strip = lefttile(indR); %the right strip of that tile
             %compare to the left strip of all our candidates
             matches = topkmatch(strip,tile_vec(indL,:),K);
         elseif (j==1) %first column (but not first row)
             toptile = tile_vec(:,tindex(i-1,j));
             strip = toptile(indB); %the bottom strip of that tile above us
             %compare to the top of all our candidates
             matches = topkmatch(strip,tile_vec(indT,:),K); 
         else % i>1 and j>1
             lefttile = tile_vec(:,tindex(i,j-1));
             stripR = lefttile(indR); %the right strip of that tile
             toptile = tile_vec(:,tindex(i-1,j));
             stripB = toptile(indB); %the bottom strip of that tile above us
             strip = [stripR;stripB];
             indLT = [indL;indT];
             % compare to the top of all our candidates
             matches = topkmatch(strip,tile_vec(indLT,:),K); 
         end
         % choose one of the top K match
         tile_vec(:,tindex(i,j))
         tindex(i,j) = matches(randi(K));
      end
    end
end

%synthesize output images based on the tile may stored in tindex
output_paste = synth_paste(tindex,tile_vec,tilesize,overlap);  %just paste down the tiles

output_quilt = synth_quilt(tindex,tile_vec,tilesize,overlap);  %quilt together the tiles... you should implement this function


imshow(output_quilt); axis image;  title('synthesized, quilted');