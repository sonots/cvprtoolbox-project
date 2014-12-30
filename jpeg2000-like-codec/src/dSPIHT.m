function [Aout, level] = dSPIHT(st, bits)
% Paul Heideman
% Rhodes University
% 27/3/4
%
% adapted from cSPIHT3 written by Erik Sjoblom

sigBit = st(1,1);
xDim = st(1,2);
yDim = st(1,3);
level = st(1,4);

% Set up output array
Ad = zeros(xDim, yDim);

% Do a 3-D SPIHT encoding of the wavelet decomposition
scaling = 2^level;

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

% Assume that sigBit < 10 => 1024 < Cmax < 2048
bitCount = 10;
% Initial threshold
T = 2^sigBit;

% size of output vector
bitSize = bits;
% Increase size for output vector
bitInc = 50;
% Send the initial threshold

while (bitCount < bits)
    % Process the members of LIP
    % Each coordinate stored as a row
    for k = 1:LIPsize
        % Get coefficient at the current coordinate
        % need to move currCoeff = Ad(LIP(k,2), LIP(k,1));
        % Larger than the threshold the move to LSP
        if (st(1, bitCount) == 1)
            bitCount = bitCount + 1;
            % update coefficient with regards sign and magnitude
            if (st(1, bitCount) == 0)
                Ad(LIP(k, 1), LIP(k, 2)) = Ad(LIP(k, 1), LIP(k, 2)) - T;
            else
                Ad(LIP(k, 1), LIP(k, 2)) = Ad(LIP(k, 1), LIP(k, 2)) + T;            
            end
            bitCount = bitCount + 1;
            
            % Update the LSP and LIP
            LSP(LSPcount, :) = LIP(k, :);
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
            bitCount = bitCount + 1;
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
        sign = st(1, bitCount);
        if (LIS(currSet, 4) == -1)
            if (sign == 0)
                LIS(currSet, 4) = T;
            end
        end
        bitCount = bitCount + 1;
        
        if (sign)
            desc = getChildren(LIS(currSet, :), xDim, yDim, level);
            % This is a type D set
            if (LIS(currSet, 3) == D)
                % Four children to check significance for.
                for k = 1:4 % check
                    % nood to move currCoeff = Ad(desc(k,2), desc(k, 1));
                    % Is this coefficient larger than T?
                    if (st(1, bitCount) == 1)   % abs(currCoeff) >= T                        
                        bitCount = bitCount + 1;                       
                    
                        % Is it positive?
                        if (st(1, bitCount) == 1)
                            Ad(desc(k,1), desc(k,2)) = Ad(desc(k,1), desc(k,2)) + T;
                        % or negative?
                        else
                            Ad(desc(k,1), desc(k,2)) = Ad(desc(k,1), desc(k,2)) - T;
                        end
                        bitCount = bitCount + 1;
                    
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
                        bitCount = bitCount + 1;
                    
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
        end 
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
        if (Ad(LSP(k,1), LSP(k,2)) > 0)
            Ad(LSP(k,1), LSP(k,2)) = Ad(LSP(k,1), LSP(k,2)) + st(1, bitCount) * (T);
        else
            Ad(LSP(k,1), LSP(k,2)) = Ad(LSP(k,1), LSP(k,2)) - st(1, bitCount) * (T);
        end
        bitCount = bitCount + 1;
    end
    % End refinement pass
    OldLSPCount = LSPcount - 1;
    if (T == 1) 
        break;
    end
    T = T/2;
end
% End dSPIHT
Aout = Ad;

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