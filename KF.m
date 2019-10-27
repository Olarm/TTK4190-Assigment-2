classdef KF < matlab.system
    properties
        model

        f % discrete prediction function
        F % jacobian of prediction function
        Q % additive discrete noise covariance

        h % measurement function
        H % measurement function jacobian
        R % additive measurement noise covariance
    end
    
    methods 
        
        
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
            
        
        function [xupd, Pupd] = update(obj, z, x, P)

        end
    end
end