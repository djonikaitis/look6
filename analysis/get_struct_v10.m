% Loads a structure and renames it

function y = get_struct_v10(path1)


var1 = struct; 
varx = load(path1);
f1 = fieldnames(varx);
if length(f1)==1
    var1 = varx.(f1{1});
end
y = var1;