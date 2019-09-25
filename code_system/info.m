function info(string, level)

%% Output info string to file identifier
ident = (level - 1) * 2;
padding = char(ones(1,ident) * 32);

fid = 1; % standard output
string = strrep(string, '\', '\\');
fprintf(fid, [padding, string, '\n']);