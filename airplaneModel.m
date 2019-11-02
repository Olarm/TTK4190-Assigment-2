function model = airplaneModel(Q, R)
    % returns a structure that implements a discrete time CV model with
    % continuous time accelleration covariance q and positional
    % measurement with noise with covariance r, both in two dimensions.
    
    model.ak = @(x, Ts) [-0.322 0.052 0.028 -1.12;  % f
                        0 0 1 -0.001;
                        -10.6 0 -2.87 0.46;
                        6.87 0 -0.04 -0.32] * x(1:4);
                    
    model.Ak = @() [-0.322 0.052 0.028 -1.12;  % F
                        0 0 1 -0.001;
                        -10.6 0 -2.87 0.46;
                        6.87 0 -0.04 -0.32];
                    
    model.Bk = @() [0.002; 0; -0.65; -0.02];   
    model.Q = @() Q;
    model.R = @() R;
    
    model.Ck = @() [[0 0; 0 0] eye(2,2)];          % H

    
    model.Ek = @(x) eye(4);
    
end

