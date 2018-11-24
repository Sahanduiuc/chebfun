function varargout = subsref(f, index)
%SUBSREF   BALLFUN subsref.
%( )
%   F(X, Y, Z) returns the values of the BALLFUN F evaluated at the points 
%   (X, Y, Z) in cartesian coordinates.
%
%   F(R, L, TH, 'spherical') returns the values of the BALLFUN F evaluated 
%   at the points (R, L, TH) in spherical scoordinates.
%
%   G = F(0, :, :) is the slice of the BALLFUN F corresponding to 
%   the plane X = 0.
%
%   G = F(:, 0, :) is the slice of the BALLFUN F corresponding to 
%   the plane Y = 0.
%
%   G = F(:, :, 0) is the slice of the BALLFUN F corresponding to 
%   the plane Z = 0.
%
%   F(R, :, :, 'spherical') returns a spherefun representing the BALLFUN F
%   along a radial shell. 
% 
%   F(:, :, :) returns F.
%
%  .
%   F.PROP returns the property PROP of F as defined by GET(F,'PROP').
%
%{ } 
%   Not supported.
%
%   F.PROP returns the property of F specified in PROP.
%
% See also BALLFUN/FEVAL, BALLFUN/GET. 

% Copyright 2018 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

idx = index(1).subs;
switch index(1).type
    case '()'
        % FEVAL / COMPOSE
        if ( numel(idx) == 3 )
            % Find where to evaluate:
            x = idx{1};
            y = idx{2};
            z = idx{3};
            % If x, y, z are numeric or ':' call feval().
            if ( ( isnumeric(x) ) && ( isnumeric(y) ) && ( isnumeric(z) ) )
                out = feval(f, x, y, z);
            elseif ( isequal(x,0) && strcmpi(y, ':') && strcmpi(z, ':') )
                out = diskfun(f, 'x'); 
            elseif ( strcmpi(x, ':') && isequal(y,0) && strcmpi(z, ':') )
                out = diskfun(f, 'y'); 
            elseif ( strcmpi(x, ':') && strcmpi(y, ':') && isequal(z,0) )
                out = diskfun(f, 'z'); 
            elseif ( strcmpi(x, ':') && strcmpi(y, ':') && strcmpi(z, ':') )
                out = f; 
            else
                % Don't know what to do.
                error('CHEBFUN:BALLFUN:subsref:inputs3', ...
                    'Unrecognized inputs.')
            end            
        elseif ( numel(idx) == 4 && strcmpi(idx(4),'cart') )
            
            out = feval(f, idx{1}, idx{2}, idx{3});
            
        elseif ( numel(idx) == 4 && (strcmpi(idx(4),'spherical') || strcmpi(idx(4),'polar') ))
            
            r = idx{1};
            lam = idx{2};
            th = idx{3};
            if ( ( isnumeric(r) ) && ( isnumeric(lam) ) && ( isnumeric(th) ) )
                % Evaluate at spherical coordinates
                out = feval(f, r, lam, th, 'spherical');
            elseif ( isnumeric(r) && strcmpi(lam, ':') && strcmpi(th, ':') )
                % Evaluate at the boundary and return a spherefun
                out = extract_spherefun( f, r );
            end
            
        else
            error('CHEBFUN:BALLFUN:subsref:inputs', ...
                'Can only evaluate at triples (X,Y,Z) or (R,LAM,TH).')
        end
        varargout = {out};
        
    case '.'
        % Call GET() for .PROP access.
        out = get(f, idx);
        if ( numel(index) > 1 )
            % Recurse on SUBSREF():
            index(1) = [];
            out = subsref(out, index);
        end
        varargout = {out};
        
    case '{}'
        % RESTRICT
        error('CHEBFUN:BALLFUN:subsref:restrict', ...
                ['This syntax is reserved for restricting',...
                 'the domain of a ballfun. This functionality'...
                 'is not available in Ballfun.'])
        
end

end

function g = extract_spherefun(f, r)
% EXTRACT_SPHEREFUN SPHEREFUN corresponding to the value of f at radius r
%   EXTRACT_SPHEREFUN(f, r) is the SPHEREFUN function 
%   g(lambda, theta) = f(r, :, :)

% Copyright 2018 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

F = f.coeffs;
[m,n,p] = size(f);

if m == 1
    G = reshape(F(1,:,:),n,p);
else
    % Chebyshev functions evaluated at r
    T = zeros(1,m);
    T(1) = 1; T(2) = r;
    for i = 3:m
        T(i) = 2*r*T(i-1)-T(i-2);
    end

    % Build the array of coefficient of the spherefun function
    G = zeros(n,p);
    for i = 1:p
        G(:,i) = T*F(:,:,i);
    end
end
% Build the spherefun function; coeffs2spherefun takes the theta*lambda matrix
% of coefficients
g = spherefun.coeffs2spherefun(G.');
end