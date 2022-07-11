function mm=minmax(a)
% function MINMAX(A)
% Return minimum, maximum and mean value of matrix A
%
% See also MMIN MMAX MMEAN CLOSEST

% d menemenlis 8/21/94

ix=find(~isnan(a));
mm(1)=min(a(ix));
mm(2)=max(a(ix));
mm(3)=mean(a(ix));
