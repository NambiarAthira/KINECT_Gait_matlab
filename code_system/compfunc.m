function [ans]=compfunc(a,b)

filename1=a.name;
filename2=b.name;
[number1 st en]=regexp(filename1,'[0-9]','match');
[number2 st en]=regexp(filename2,'[0-9]','match');
number1;
horzcat(number1{:});
number1{:};
a=str2double(horzcat(number1{:}));
b=str2double(horzcat(number2{:}));

if a>b
ans=-1;
elseif a<b
ans=1;
else
ans=0;
end

end