function mydisp(x)

% MYDISP Display array but do not change line
%    MYDISP(X) displays the array, without printing the array name.
%    If X is a string, the text is displayed.
% 
%    See also DISP, INT2STR, NUM2STR, SPRINTF, RATS, FORMAT.

if isstr(x)
  fprintf(1,'   %s\r',x)
else
  fprintf(1,'   %0.0f\r',x)
end
