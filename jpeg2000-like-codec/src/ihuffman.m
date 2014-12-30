function x = huff2norm(y, codewords, pad)
% Huffman Decoding
%  Decode y with codewords given by info. 
%
%  x = huff2norm(y, codewords, pad)
%
% Input arguments ([]s are optional):
%  y (vector) of size 1xP: Compressed Data (uint8)
%  codewords (vector): Huffman codewords
%  pad (scalar): # of zero padded bits to make uint8 output
%
% Output arguments ([]s are optional):
%  x (vector) of size 1xN: Decoded Original Data (uint8)
%
% See also: huffman.m

% ensure to handle uint8 input vector
if isempty(y) & isempty(codewords) & isempty(pad)
    x = [];
    return;
end
if ~isa(y,'uint8'),
	error('input argument must be a uint8 vector')
end

% create the 01 sequence
len = length(y);
string = repmat(uint8(0),1,len.*8);
bitindex = 1:8;
for index = 1:len,
	string(bitindex+8.*(index-1)) = uint8(bitget(y(index),bitindex));
end
	
% adjust string
string = logical(string(:)'); % make a row of it
len = length(string);
string((len-pad+1):end) = []; % remove 0 padding
len = length(string);

% build output
weights = 2.^(0:51);
% x = repmat(uint8(0),1,info.length);
vectorindex = 1;
codeindex = 1;
code = 0;
for index = 1:len,
	code = bitset(code,codeindex,string(index));
	codeindex = codeindex+1;
	byte = decode(bitset(code,codeindex),codewords);
	if byte>0, % a code has been found
		x(vectorindex) = byte-1;
		codeindex = 1;
		code = 0;
		vectorindex = vectorindex+1;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function byte = decode(code,codewords)
if code > length(codewords),
    byte = 0;
else
    byte = codewords(code);
end