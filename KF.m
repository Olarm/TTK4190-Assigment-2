classdef KF
    % FILL IN THE DOTS
    properties
        model
        
        Q
        R
        ak
        Ak
        Bk
        ck
        Ck
        Ek

    end
    methods 
        function obj = EKF(model)
            obj = obj.setModel(model);
        end
        
        function obj = setModel(obj, model)
           % sets the internal functions from model
           obj.model = model;
           
           obj.Ak = model.Ak;
           obj.ak = model.ak;
           obj.Bk = model.Bk;
           obj.Ek = model.Ek;
           obj.Ck = model.Ck;
           obj.ck = model.ck;

           obj.Q = model.Q;
           obj.R = model.R;
        end
        
        function [xp, Pp] = predict(obj, x, u, P, Ts)
            % returns the predicted mean and covariance for a time step Ts
            
            xp = obj.Ak(x, Ts) + obj.Bk(u, Ts);
            Pp = A*P*A.' + obj.Q(x, Ts);
        end

        function [yk, Sk] = innovation(obj, z, x, P)
            % returns the innovation and innovation covariance
            
            yk = z - obj.ck(x);
            Hk = obj.Ck(x);
            Sk = Hk * P * Hk' + obj.R(x);
        end

        function [xupd, Pupd] = update(obj, z, x, P)
            % returns the mean and covariance after conditioning on the
            % measurement
            
            [yk, Sk] = obj.innovation(z, x, P);
            Hk = obj.H(x);
            I = eye(size(P));
            
            Kk = P * Hk' / Sk;

            xupd = x + Kk * yk;
            %Pupd = (I-Wk*Hk)*P*(I-Wk*Jk)' + Wk*obj.R*Wk';
            Pupd = (I - Kk * Hk) * P;
        end

        function NIS = NIS(obj, z, x, P)
            % returns the normalized innovation squared
            [vk, Sk] = obj.innovation(z, x, P);
            
            NIS = vk'*(Sk \ vk);
        end

        function ll = loglikelihood(obj, z, x, P)
            % returns the logarithm of the marginal mesurement distribution
            [yk, Sk] = obj.innovation(z, x, P);
            NIS = obj.NIS(z, x, P);

            ll = -0.5 * (NIS + log(det(2*pi*Sk)));
        end

    end
end