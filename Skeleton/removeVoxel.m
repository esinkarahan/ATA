function finalimage = removeVoxel(origimage,varargin)
%
% Remove outlier voxels from the image
%
% # This algorithm removes the voxels that do not have any neighbours in the
%   horizontal (rows) OR vertical (columns) directions in any slices (X, Y, Z) 
% # An adjancency matrix is used to count 1st neighbours
% # The algorithm could be repeated N times, which will work on the trimmed
%   image
%
% finalimage = removeVoxel(origimage,'some',nrp,nneig)
%
% Input
% origimage - 3D array
% show      - variable to control the plots created by the program
%             {'some'} | 'all'
% nrp       - numbers of repetitions (100)
% nneig     - number of neighbours to remove ({1}|2)
%
% Written by Esin Karahan, January 2018
%

if sum(ismember(origimage(:),[0 1]))~= numel(origimage)
    display('binarizing the image')
    origimage(origimage>0)=1;
end

if nargin < 2
    show = 'some';
    nrp = 100;
    nneig = 1;
elseif nargin < 3
    show = varargin{1}; 
    nrp = 100;
    nneig = 1;
elseif nargin < 4
    show = varargin{1}; 
    nrp = varargin{2};
    nneig = 1;
else
    show = varargin{1}; 
    nrp = varargin{2};
    nneig = varargin{3};
end

d  = size(origimage);
nd = length(d);

potVoxTotal = zeros(d);
ntrimVox    = zeros(nrp,1);

imask = origimage;

for irp = 1:nrp
    newimask = imask;
    potVox   = imask;
    for id = 1:nd
        perm = [id 1:id-1 id+1:nd];
        m = d(perm(1));
        n = d(perm(2));
        l = d(perm(3)); 

        % be careful about the first and the last pixels since they have
        % only one neighbour
        % but since the brain image is generally at the center, it does not
        % matter
        if nneig  == 1 % 1st order
            e  = ones(l,1);
            Lr = spdiags([e zeros(l,1) e],-1:1,l,l);
            e  = ones(n,1);
            Lc = spdiags([e zeros(n,1) e],-1:1,n,n);
        else % 2nd order
            e  = ones(l,1);
            Lr = spdiags([e e zeros(l,1) e e],-2:2,l,l);
            e  = ones(n,1);
            Lc = spdiags([e e zeros(n,1) e e],-2:2,n,n);
        end

        tempIm     = permute(imask,perm);
        tempNewIm  = permute(newimask,perm);
        tempPotVox = permute(potVox,perm);
        for i = 1:m
            A = squeeze(tempIm(i,:,:));
            if sum(A(:)) % the slice may not contain anything as well
                rowL = A*Lr;
                colL = A'*Lc;
                temp = abs(rowL) .* abs(colL)';
%                 temp(temp>0) = 1;
                % binarize
                temp(temp < nneig) = 0;
                temp(temp >= nneig) = 1;
                An = A.*temp;
                tempNewIm(i,:,:) = squeeze(tempNewIm(i,:,:)) .* An;
                tempPotVox(i,:,:) = squeeze(tempPotVox(i,:,:)).*(A-An);
            end
        end
        newimask = ipermute(tempNewIm,perm);
        potVox = ipermute(tempPotVox,perm);
    end
    ntrimVox(irp) = sum(potVox(:)>0);
    if strcmp(show,'all')
        visualizeObject({newimask,potVox})
        title(['potential vox = ' num2str(ntrimVox(irp)) ', repetition ' num2str(irp)]);
    end
    imask = newimask;
    potVoxTotal = potVoxTotal + potVox;
    if ntrimVox(irp) == 0
        display([num2str(irp) ' repetitions were enough']);
        break;
    end
end
if strcmp(show,'all') || strcmp(show,'some')
    visualizeObject({imask,potVoxTotal})
    title(['total deleted voxels = ' num2str(sum(ntrimVox(:)))])
end
imask(imask>0) = origimage(imask>0);
finalimage = imask;