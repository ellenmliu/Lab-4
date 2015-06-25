function [result] = stitch(leftI,rightI,overlap);

% 
% stitch together two grayscale images with a specified overlap
%
% leftI : the left image of size (W1 x H)  
% rightI : the right image of size (W2 x H)
% overlap : the width of the overlapping region.
%
% result : an image of size (W1+W2-overlap)xH
%
if (size(leftI,1)~=size(rightI,1)); % make sure the images have compatible heights
  error('left and right image heights are not compatible');
end

%size and new size
[h1, w1] = size(leftI);
[h2, w2] = size(rightI);
result = nan(h1, w1+w2-overlap);

%extracting the two strips from image
left = leftI(:,w1-overlap+1:end);
right = rightI(:,1:overlap);

%new rightI and leftI
rightI = rightI(:,overlap+1:end);
leftI = leftI(:,1:(w1-overlap));

%finding the difference
diff = left-right;
dif = diff.^2;

%find shortest path
newpath = shortest_path(dif);

%making a mask for both half
leftImask = ones(h1,overlap);
rightImask = ones(h2,overlap);
for r  = 1:h1
    for c = 1:overlap
        if(c > newpath(r))
            leftImask(r,c) = 0;
        else
            rightImask(r,c) = 0;
        end
    end
end

%new overlap
newoverlap = left.*leftImask + right.*rightImask;

% dummy code that produces result by 
% simply pasting the left image over the
% right image. replace this with your own
% code!
result = [leftI newoverlap rightI];



