function [st, bitCount] = cSPIHT(Ain, level, bitbudget)
% Paul Heideman
% Rhodes University
% 27/3/4
%
% adapted from cSPIHT3 written by Erik Sjoblom


global Ad;
global D;
global L;
Ad = Ain;
% Do a 3-D SPIHT encoding of the wavelet decomposition
scaling = 2^level;
xDim = size(Ad, 2);
yDim = size(Ad, 1);

% Init SPIHT
% Subset type representation
D = 0;
L = 1;

% Use a caching strategy for LSP. When the size is reach increase LSP with
% LSPinc rows
LSPcount = 1;
% Keep track of index for coefficients added prior to the current pass
OldLSPCount = 0;
LSPinc = 50;
LSPsize = 0;
LSP = zeros(LSPinc, 2);

% To keep track of the actual size of LIS
% Number of entries in LIS
LISsize = 0;
LIScount = 1;
% Index position to the next position in LIS
LISinc = 50;

% Number of actual entries in LIP
LIPsize = 0;
% Index of next position in LIP
LIPcount = 1;
% Increment size of LIP
LIPinc = 50;

% DO NOT USE STRUCTURES. REALLY SLOW!!!
LIP = zeros((yDim/scaling)*(xDim/scaling) + LIPinc, 2);
% Every 4th node does not have any children->4/4-1/4=3/4 * nrCoefficients
% number of coefficients have children
LIS = zeros(3/4 * ((yDim/scaling)*(xDim/scaling)) + LISinc, 4);

% Initialise LIS and LIP
for l = 1:yDim/scaling
    for m = 1:xDim/scaling
        % Enter all lowlevel subband nodes into LIP
        % Store as [XCoord YCoord]
        LIP(LIPcount, :) = [m l];
        LIPcount = LIPcount + 1;
        % Check for parent node
        if(~(bitand(l, 1) & bitand(m,1)))
            % Store as [XCoord YCoord marker]
            LIS(LIScount, :) = [m l D -1];
            LIScount = LIScount + 1;
        end
    end
end

LIPsize = LIPcount - 1;
LISsize = LIScount - 1;

% Find the max initial threshold
Cmax = max(max(abs(Ad)));
% Find the most significant bit
sigBit = floor(log2(Cmax));
% Assume that sigBit < 10 => 1024 < Cmax < 2048
bitCount = 10;
% Initial threshold
T = 2^sigBit;

% Start with the bitbudget as the initial size
st = zeros(1, bitbudget);
% size of output vector
bitSize = bitbudget;
% Increase size for output vector
bitInc = 50;
% Send the initial threshold
st(1,1) = sigBit;
st(1,2) = xDim;
st(1,3) = yDim;
st(1,4) = level;

while (bitCount < bitbudget)
    % Process the members of LIP
    % Each coordinate stored as a row
    for k = 1:LIPsize
        % Get coefficient at the current coordinate
        currCoeff = Ad(LIP(k,1), LIP(k,2));
        % Larger than the threshold the move to LSP
        if (abs(currCoeff) >= T)
            % Update the output vector
            % This coefficient is larger than the threshold
            st(1, bitCount) = 1;                       
            
            % Update size of st?
            % Next index in the list.
            bitCount = bitCount + 1;
            if (bitCount > bitSize)
                st = [st zeros(1, bitInc)];
                bitSize = bitSize + bitInc;
            end
            % End update size of st
            
            if (currCoeff >= 0)
                % Mark that this coefficient is positive
                st(1, bitCount) = 1;
            else
                % Mark that this coefficient is negative
                st(1, bitCount) = 0;
            end
            
            % Update size of st?
            % Next index in the list.
            bitCount = bitCount + 1;
            if (bitCount > bitSize)
                st = [st zeros(1, bitInc)];
                bitSize = bitSize + bitInc;
            end
            % End update size of st
            
            % Update the LSP and LIP
            LSP(LSPcount, :) = LIP(k, :);
            %fprintf('LIP->LSP: %d\n', LSPcount);
            % Mark as moved
            LIP(k, :) = [0 0];
            % The actual number of entries in LIP.
            LIPsize = LIPsize - 1;
            
            % Update the size of LSP?
            LSPcount = LSPcount + 1;
            LSPsize = LSPsize + 1;
            if (LSPcount > size(LSP, 1))
                LSP = [LSP; zeros(LSPinc, 2)];
            end
            % End update size of LSP
        % The coefficient was not significant. So send a zero.    
        else
            st(1, bitCount) = 0;
            
            % Update size of st?
            % Next index in the list.
            bitCount = bitCount + 1;
            if (bitCount > bitSize)
                st = [st zeros(1, bitInc)];
                bitSize = bitSize + bitInc;
            end
            % End update size of st
        end
    end
    % End of LIP treatment
    
    % Keep only the elements in LIP who are not in LSP
    tmpLIP = zeros(LIPsize + LIPinc, 2);
    tmpLIPcount = 1;
    % only investigate to the last used index
    for k = 1:(LIPcount-1)
        % If a coordinate entry is 0 it is marked and moved
        if (LIP(k,1) ~= 0)
            tmpLIP(tmpLIPcount, :) = LIP(k, :);
            tmpLIPcount = tmpLIPcount + 1;
        end
    end
    LIP = tmpLIP;
    % Free up temporary memory
    clear tmpLIP;
    % Update the next index
    LIPcount = tmpLIPcount;
    % Update the size of the list
    LIPsize = tmpLIPcount - 1;
    % Check the sets in LIS if any
    
    notDone = 1;
    currSet = 1;
    % If LIS is empty do not enter the loop
    if (LISsize <= 0)
        notDone = 0;
    end
    
    while (notDone)
        % Find all elements of the set. Uses D, L information
        if (LIS(currSet, 4) == -1)
            [desc, coeffMax] = checkSignificance(LIS(currSet, :), T, xDim, yDim, level);
            sign = 1;
            if (isempty(desc))
                LIS(currSet, 4) = coeffMax;
                sign = 0;
            end
        else
            % Significant now?
            if (LIS(currSet, 4) >= T)
                sign = 1;
                desc = getChildren(LIS(currSet, :), xDim, yDim, level);
            else
                sign = 0;
            end
        end
        
        % Either 0 or 1 depending on the significance of the set
        st(1, bitCount) = sign;
        % Update size of st?
        % Next index in the list.
        bitCount = bitCount + 1;
        if (bitCount > bitSize)
            st = [st zeros(1, bitInc)];
            bitSize = bitSize + bitInc;
        end
        % End update size of st
        
        if (sign)
            % This is a type D set
            if (LIS(currSet, 3) == D)
                % Four children to check significance for.
                for k = 1:4 % check
                    currCoeff = Ad(desc(k,1), desc(k, 2));
                    % Is this coefficient larger than T?
                    if (abs(currCoeff) >= T)
                        st(1, bitCount) = 1;
                        % Update size of st?
                        % Next index in the list.
                        bitCount = bitCount + 1;
                        if (bitCount > bitSize)
                            st = [st zeros(1, bitInc)];
                            bitSize = bitSize + bitInc;
                        end
                        % End update size of st
                        
                    
                        % Is it positive?
                        if (currCoeff >= 0)
                            st(1, bitCount) = 1;
                        % or negative?
                        else
                            st(1, bitCount) = 0;
                        end
                        % Update size of st?
                        % Next index in the list.
                        bitCount = bitCount + 1;
                        if (bitCount > bitSize)
                            st = [st zeros(1, bitInc)];
                            bitSize = bitSize + bitInc;
                        end
                        % End update size of st
                    
                        % Move this coefficient to LSP
                        LSP(LSPcount, :) = [desc(k,1) desc(k,2)];
                        % Update size of LSP
                        % Next index in the list.
                        LSPcount = LSPcount + 1;
                        LSPsize = LSPsize + 1;
                        if (LSPcount > size(LSP, 1))
                            LSP = [LSP; zeros(LSPinc, 2)];                    
                        end
                        % End update size of LSP
                    
                    % Not significant coefficient    
                    else
                        st(1, bitCount) = 0;
                        % Update size of st?
                        % Next index in the list.
                        bitCount = bitCount + 1;
                        if (bitCount > bitSize)
                            st = [st zeros(1, bitInc)];
                            bitSize = bitSize + bitInc;
                        end
                        % End update size of st
                    
                        % Move coefficient to LIP
                        LIP(LIPcount, :) = [desc(k,1) desc(k,2)];
                        % Update size of LIP
                        % Next index in the list.
                        LIPcount = LIPcount + 1;
                        LIPsize = LIPsize + 1;
                        if (LIPcount > size(LIP, 1))
                            LIP = [LIP; zeros(LIPinc, 2)];                    
                        end
                        % End update size of LIP
                    
                    end
                    % Coefficient test in LIS
                end
                % Take next coefficent from the children
            
                % This means that (L(i,j) = [])
                if (LsetEmpty(LIS(currSet,:), xDim, yDim, level))
                    % Remove this entry from LIS
                    LIS(currSet, :) = [0 0 0 0];
                    LISsize = LISsize-1;
                else
                    LIS(LIScount, :) = [LIS(currSet, 1) LIS(currSet, 2) L -1];
                    % Remove the D-entry from LIS
                    LIS(currSet, :) = [0 0 0 0];
                    % End remove 
                    LIScount = LIScount + 1;
                end
                % End type D test, begin type L test
            else
                % Add each child to the current coordinate as a new D set.
                for k = 1:4
                    LIS(LIScount, :) = [desc(k,1) desc(k,2) D -1];
                    LIScount = LIScount + 1;
                    LISsize = LISsize + 1;
                    if (LIScount > size(LIS, 1))
                        LIS = [LIS; zeros(LISinc, 4)];
                    end
                end
                % Should we remove the L-Set from the LIS?
                LIS(currSet, :) = [0 0 0 0];
                LISsize = LISsize - 1;
            end
        end % Not sure about this one
        % End testing this set of LIS. If it was insignificant we have already
        % sent a zero.
        currSet = currSet + 1;
        % The next set is not yet in LIS, so we're done
        if (currSet > (LIScount - 1))
            notDone = 0;
        end
    end
    % End processing of LIS
    % Pack LIS to save memory
    tmpLIS = zeros(LISsize+LISinc, 4);
    tmpLIScount = 1;
    % Only investigate to the last used index
    for k = 1:(LIScount-1)
        if (LIS(k,1) ~= 0)
            tmpLIS(tmpLIScount, :) = LIS(k, :);
            tmpLIScount = tmpLIScount + 1;
        end
    end
    LIS = tmpLIS;
    clear tmpLIS;
    LISsize = tmpLIScount - 1;
    LIScount = tmpLIScount;
    % Significance map pass completed. Goto refinement pass. Scan coefficients
    % added prior to pass
    for k = 1:OldLSPCount
        % Send the n'th most significant bit of |coeff|
        st(1, bitCount) = bitand(fix(abs(Ad(LSP(k,1), LSP(k,2)))/T), 1);
        % Update size of st?
        % Next index in the list.
        bitCount = bitCount + 1;
        if (bitCount > bitSize)
            st = [st zeros(1, bitInc)];
            bitSize = bitSize + bitInc;
        end
        % End update size of st
    end
    % End refinement pass
    OldLSPCount = LSPcount - 1;
    if (T == 1) 
        break;
    end
    T = T/2;
end
% End SPIHT
% How many bits were actually used?
bitCount = bitCount - 1;
% Only return the actual bits used.
st = st(1:bitCount);

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function desc = getChildren(currSet, xDim, yDim, level)
% function returns descendents of currSet if they exist
%
global D;
scaling = 2^level;
x = currSet(1);
y = currSet(2);
desc = [];
xDimscal = floor(xDim / scaling);
yDimscal = floor(yDim / scaling);

% if not in highest level subband
if ((x <= xDim/2)&(y <= yDim/2))

    if ((x <= xDimscal/2)&(y <= yDimscal/2))
        if (bitand(x,1) == 0)
            Lx = xDimscal-3+x;
        else
            Lx = (x-1);
        end
        if (bitand(y,1) == 0)
            Ly = yDimscal-3+y;
        else
            Ly = (y-1);
        end
    else
        Lx = x - 1;
        Ly = y - 1;
    end
    desc = [x + Lx, y + Ly, D;
        x + Lx, y + Ly + 1, D; 
        x + Lx + 1, y + Ly, D;
        x + Lx + 1, y + Ly + 1, D];       
end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [desc, max] = checkSignificance(set, T, xDim, yDim, level)
% function return the children of a set if it is found to be significant, 
% it also returns the max coefficient...
%
global D;
global L;
global Ad;
scaling = 2^level;
result = [];
newX = set(1);
newY = set(2);
max = -1;
xDimscal = floor(xDim / (2^level));
yDimscal = floor(yDim / (2^level));
firsttime = true;
significant = false;
checkit = false;
if (set(3) == D)
    checkit = true;
end

i = 1;

while (((i <= size(result, 1)) | firsttime) & (~significant))
    if (firsttime)
        firsttime = false;
    else % get the node for which to generate children
        newX = result(i, 1);
        newY = result(i, 2);
    end
    
    % if not in highest level subband
    %fprintf('%d %d %d %d %d %d\n', newX, newY, xDim/2, yDim/2, ((newX < xDim/2)&&(newY < yDim/2)), (~(bitand(newX, 1) & bitand(newY, 1))));
    if ((newX <= xDim/2)&(newY <= yDim/2))
        
        if (newX <= xDimscal/2)&(newY <= yDimscal/2)
            if (bitand(newX,1) == 0)
                Lx = xDimscal-3+newX;
            else
                Lx = (newX-1);
            end
            if (bitand(newY,1) == 0)
                Ly = yDimscal-3+newY;
            else
                Ly = (newY-1);
            end
        else
            Lx = newX - 1;
            Ly = newY - 1;
        end   

        % Start adding children of this coordinate. Do significance testing
        % while adding childrin.
        tmp = [newX + Lx, newY + Ly, D];
        magnitude = abs(Ad(tmp(1), tmp(2)));
        if (magnitude >= T)
            significance = true;
        end
        if (magnitude > max)
            max = magnitude;
        end
        result = [result; tmp];
	
        tmp = [newX + Lx, newY + Ly + 1, D];
        magnitude = abs(Ad(tmp(1), tmp(2)));
        if (magnitude >= T)
            significance = true;
        end
        if (magnitude > max)
            max = magnitude;
        end
        result = [result; tmp];
	
        tmp = [newX + Lx + 1, newY + Ly, D];
        magnitude = abs(Ad(tmp(1), tmp(2)));
        if (magnitude >= T)
            significance = true;
        end
        if (magnitude > max)
            max = magnitude;
        end
        result = [result; tmp];
        
        tmp = [newX + Lx + 1, newY + Ly + 1, D];
        magnitude = abs(Ad(tmp(1), tmp(2)));
        if (magnitude >= T)
            significance = true;
        end
        if (magnitude > max)
            max = magnitude;
        end
        result = [result; tmp];
	
        % Ensure that we do not check the immediate offspring for L-Sets.
        significant = significant & checkit;
        if (~checkit)
            checkit = ~checkit;
            max = -1;
        end
    end    
    i = i + 1;
end

desc = [];
if (significant)
    desc = result(1:4, 1:3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empty = LsetEmpty(set, xDim, yDim, level)
% Test if L-set is empty
% L-set is all descendents minus the offspring
% 

if (level > 1)
    desc = [];
    newX = set(1);
    newY = set(2);
    xDimscal = floor(xDim / (2^level));
    yDimscal = floor(yDim / (2^level));
    firsttime = true;
    
    i = 1;
    while ((i <= size(desc, 1)) || firsttime)
        if (firsttime)
            firsttime = false;
        else % get the node for which to generate children
            newX = desc(i, 1);
            newY = desc(i, 2);
        end
        
        % if not in highest level subband
        if ((newX < xDim/2)&(newY < yDim/2))
            
            if (newX <= xDimscal/2)&(newY <= yDimscal/2)
                if (bitand(newX,1) == 0)
                    Lx = xDimscal-3+newX;
                else
                    Lx = (newX-1);
                end
                if (bitand(newY,1) == 0)
                    Ly = yDimscal-3+newY;
                else
                    Ly = (newY-1);
                end
            else
                Lx = newX - 1;
                Ly = newY - 1;
            end
            
            % Start adding children of this coordinate. 
            desc = [desc; newX + Lx, newY + Ly];
            desc = [desc; newX + Lx, newY + Ly + 1];
            desc = [desc; newX + Lx + 1, newY + Ly];
            desc = [desc; newX + Lx + 1, newY + Ly + 1];
        end    
        i = i + 1;
    end
    
    if (~isempty(desc)) 
        offspring = desc(1:4, 1:2);
        Lset = setdiff(desc, offspring, 'rows');
        empty = isempty(Lset);
    else
        empty = true;
    end
else
    empty = true;
end