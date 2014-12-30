function b = bytes(f)
% Obtain the number of bytes
%
%  [b] = bytes(f)
%
% Input arguments ([]s are optional):
%  f: a file name or a variable
%
% Output arguments ([]s are optional):
%  b (scalar): The number of bytes
%
% Example:
%  bytes('filename')
%  bytes(X)
if ischar(f)
    info=dir(f);
    b=info.bytes;
elseif isstruct(f)
    b=0;
    fields=fieldnames(f);
    for k=1:length(fields)
        b = b + bytes(f.(fields{k}));
    end
else
    info=whos('f');
    b=info.bytes;
end
 