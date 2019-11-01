classdef KalmanFilter < matlab.System
    % untitled Add summary here
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties

        Q = eye(4);
        R = eye(2);
        Ak = [-0.322 0.052 0.028 -1.12;
            0 0 1 -0.001;
            -10.6 0 -2.87 0.46;
            6.87 0 -0.04 -0.32];
        Bk = [0.002; 0; -0.65; -0.02];
        Ck = [[0 0; 0 0] eye(2,2)];
        Ek = eye(4);

    end

    properties(DiscreteState)
        Pp;
        P;
        xp;
        x;

    end

    % Pre-computed constants
    properties(Access = private)

    end

    methods(Access = protected)
        function setupImpl(obj)

            % Perform one-time calculations, such as computing constants
        end
        
        
        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            obj.Pp = zeros(4);
            obj.P = zeros(4);
            obj.xp = zeros(4,1);
            obj.x = zeros(4,1);
        end
        
        
        function [xp, Pp] = predict(obj, x, P)
            xp = obj.Ak*x + obj.Bk*u;
            Pp = obj.Ak*P*obj.Ak' + obj.Q;
        end
        
        
        function [yk, Sk] = innovation(obj, z, x, P)
            yk = z - obj.Ck*x;
            Sk = obj.Ck*P*obj.Ck' + obj.R;
        end
            
        
        function [xupd, Pupd] = updates(obj, z, x, P)
            [yk, Sk] = innovation(z);
            I = eye(4);
            Kk = P * Hk' / Sk;

            xupd = x + Kk * yk;
            Pupd = (I - Kk * obj.Ck) * P * (I - Kk * obj.Ck)' + Kk * obj.R() * Kk';
        end     
    end
end
