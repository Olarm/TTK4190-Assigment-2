function Kalman(block)
%MSFUNTMPL_BASIC A Template for a Level-2 MATLAB S-Function
%   The MATLAB S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the 
%   name of your S-function.

%   Copyright 2003-2018 The MathWorks, Inc.

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C MEX counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 2;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions  = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;

block.InputPort(2).Dimensions  = 2;
block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).Complexity  = 'Real';
block.InputPort(2).DirectFeedthrough = true;

% Override output port properties
block.OutputPort(1).Dimensions  = 4;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms             = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C MEX counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
    block.NumDworks = 5;
  
    block.Dwork(1).Name            = 'xest';
 	block.Dwork(1).Dimensions      = 4;
 	block.Dwork(1).DatatypeID      = 0;      % double
 	block.Dwork(1).Complexity      = 'Real'; % real
   	block.Dwork(1).UsedAsDiscState = true;
        
    block.Dwork(2).Name            = 'Pest';
    block.Dwork(2).Dimensions      = 16;
    block.Dwork(2).DatatypeID      = 0;      % double
    block.Dwork(2).Complexity      = 'Real'; % real
    block.Dwork(2).UsedAsDiscState = true;
    
    block.Dwork(3).Name            = 'xpred';
 	block.Dwork(3).Dimensions      = 4;
 	block.Dwork(3).DatatypeID      = 0;      % double
 	block.Dwork(3).Complexity      = 'Real'; % real
   	block.Dwork(3).UsedAsDiscState = true;  

    block.Dwork(4).Name            = 'Pred';
    block.Dwork(4).Dimensions      = 16;
    block.Dwork(4).DatatypeID      = 0;      % double
    block.Dwork(4).Complexity      = 'Real'; % real
    block.Dwork(4).UsedAsDiscState = true;
    
    block.Dwork(5).Name            = 'Ts';
    block.Dwork(5).Dimensions      = 1;
    block.Dwork(5).DatatypeID      = 0;      % double
    block.Dwork(5).Complexity      = 'Real'; % real
    block.Dwork(5).UsedAsDiscState = true;
    

%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is 
%%                      present in an enabled subsystem configured to reset 
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C MEX counterpart: mdlInitializeConditions
%%
function InitializeConditions(block)

%end InitializeConditions


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C MEX counterpart: mdlStart
%%
function Start(block)

block.Dwork(1).Data = zeros(1, 4);  % xest
block.Dwork(2).Data = zeros(1, 16); % Pest
block.Dwork(3).Data = zeros(1, 4);  % xpred
block.Dwork(4).Data = zeros(1, 16); % Ppred
block.Dwork(5).Data = 0.001;            % Ts
%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C MEX counterpart: mdlOutputs
%%
function Outputs(block)

block.OutputPort(1).Data = block.Dwork(1).Data;
%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C MEX counterpart: mdlUpdate
%%
function Update(block)

    % Tuning parameters
    Q = [1e-08 0 0 0;
         0 1e-08 0 0;
         0 0 1e-06 0;
         0 0 0 1e-07];
     
%    R = [6.1685e-07 0;
%         0 6.1685e-07];
    R = [0.5 0;
        0 0.5];

    model = airplaneModel(Q, R);

    update_kalman(block, model);

    predict(block, model);

%end Update

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate


function predict(block, model)
    % Get block data
    xest = block.Dwork(1).Data;
    Pest = reshape(block.Dwork(2).Data, 4, 4);
    Ts = block.Dwork(5).Data;
    delta_ac = block.InputPort(1).Data;
    
    % Get model data
    Ak = model.Ak();
    Bk = model.Bk();
    Q = model.Q();
    
    % Predict
    xpred = Ak * xest * Ts + Bk * delta_ac;
    Ppred = Ak * Pest * Ak' * Ts + Q;
    
    % Return data
    block.Dwork(3).Data = xpred';
    block.Dwork(4).Data = reshape(Ppred, 1, 16);
%end predict


function [vk, Sk] = innovation(block, model)
    % Get block data
    xpred = block.Dwork(3).Data;
    Ppred = reshape(block.Dwork(4).Data, 4, 4);
    Ts = block.Dwork(5).Data;
    zk = block.InputPort(2).Data;

    % Get model data
    Ck = model.Ck();
    R = model.R();
    
    % Innovate
    vk = zk + Ck * xpred;
    Sk = Ck * Ppred * Ck' + R;
%end innovation


function update_kalman(block, model)
    % Get block data
    xpred = block.Dwork(3).Data;
    Ppred = reshape(block.Dwork(4).Data, 4, 4);
    Ts = block.Dwork(5).Data;

    % Get model data
    Ck = model.Ck();
    
    % Innovate
    [vk, Sk] = innovation(block, model);
    
    %Initialize variables
    I = eye(length(Ppred));
    
    % Update
    Kk = Ppred * Ck' / Sk;
    xest = xpred + Kk * vk;
    Pest = (I - Kk * Ck) * Ppred;
    
    % Return data
    block.Dwork(1).Data = xest';
    block.Dwork(2).Data = reshape(Pest, 1, 16);
%end update_kalman
