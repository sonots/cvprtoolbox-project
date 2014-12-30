function demo_huffman
data = ['npzztttzzzzzz']
%data = ['ppppppppp']
[encoded, codewords, pad] = huffman(uint8(data), uint8('npzt'));
decoded = ihuffman(encoded, codewords, pad);
decoded = char(decoded)
% test
equal = isequal(data, decoded)
% display in bits form
fprintf('encoded = \n\n\t');
for i=1:length(encoded)
    if i == length(encoded),
        last = 8 - pad;
    else
        last = 8;
    end
    for bit=1:last
        fprintf('%d', bitget(encoded(i), bit));
    end
end
fprintf('\n\n');
% display codewords in bits form
fprintf('codewords = \n\n');
[codes, cols, words] = find(codewords);
for i=1:length(codes)
    fprintf('\t');
    code = NaN;
    for j=52:-1:1
        bit = bitget(codes(i), j);
        if ischar(code),
            code = sprintf('%d%s', bit, code);
        elseif bit == 1,
            code = '';
        end
    end
    fprintf('%s <=> %c\n', code, words(i)-1);
end
fprintf('\n');
end

