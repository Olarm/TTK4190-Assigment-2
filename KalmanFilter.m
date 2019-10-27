classdef KalmanFilter < matlab.System
    % untitled Add summary here
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        model

        f % discrete prediction function
        F % jacobian of prediction function
        Q % additive discrete noise covariance

        h % measurement function
        H % measurement function jacobian
        R % additive measurement noise covariance

    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)

    end

    methods(Access = protected)
        
        function obj = KF(model)
            obj = obj.setModel(model);
        end
        
        
        function obj = setModel(obj, model)
           % sets the internal functions from model
           obj.model = model;
           
           obj.f = model.f;
           obj.F = model.F;
           obj.Q = model.Q;
           
           obj.h = model.h;
           obj.H = model.H;
           obj.R = model.R;
        end
          
        
        function [xp, Pp] = predict(obj, x, P, Ts)
          
     
            
        end
        
        
        function [vk, Sk] = innovation(obj, z, x, P)

            
        end
            
        
        function [xupd, Pupd] = updates(obj, z, x, P)

            
        end     
    end
end
