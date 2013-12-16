function out = sum(f)
%SUM   Definite integral of a DELTAFUN.
%   SUM(F) is the integral of F on the domain of F.
%
% See also CUMSUM, DIFF.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org for Chebfun information.


%%
% Trivial case:
if ( isempty(f) )
    out = [];
    return
end

out = sum(f.funPart);

% Add integral of delta functions:
if ( ~isempty(f.impulses) )
    % What happens for the higher order, need derivatives etc?
    % Answer: Neglect higher order deltas, since the integral of any derivative
    % of a delta function can be considered as it's action on the function 1.
    deltaMag = f.impulses;
    out = out + sum(deltaMag(1, :));
end    
end