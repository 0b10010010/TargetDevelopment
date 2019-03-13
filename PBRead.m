classdef PBRead < realtime.internal.SourceSampleTime ... % Inherits from matlab.System
        & coder.ExternalDependency ...
        & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    %
    % System object template for a source block.
    % 
    % This template includes most, but not all, possible properties,
    % attributes, and methods that you can implement for a System object in
    % Simulink.
    %
    % NOTE: When renaming the class name Source, the file name and
    % constructor name must be updated to use the class name.
    %
    
    % Copyright 2014 The MathWorks, Inc.
    %#codegen
    %#ok<*EMCA>
    
    properties
        % Public, tunable properties.
    end
    
    properties (Nontunable)
        % Public, non-tunable properties.
    end
    
    properties (Access = private)
        % Pre-computed constants.
    end
    
    methods
        % Constructor
        function obj = Source(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    
    methods (Access=protected)
        function setupImpl(obj) %#ok<MANU>
            if coder.target('Rtw')
                % Call C-function implementing device initialization
                coder.cinclude('stm32f4disc_gpio_wrapper.h');
                coder.ceval('Disc_GPIO_ReadBit_Init');
            else
                % Place simulation setup code here
            end
        end
        
        function y = stepImpl(obj)   %#ok<MANU>
            y = double(0); % initialize the size of y output
            if coder.target('Rtw')
                % Call C-function implementing device output
                y = coder.ceval('Disc_GPIO_ReadBit');
                %y = coder.ceval('source_output');
            else
                % Place simulation output code here
            end
        end
        
        function releaseImpl(obj) %#ok<MANU>
            if coder.target('Rtw')
                % Call C-function implementing device termination
                %coder.ceval('source_terminate');
            else
                % Place simulation termination code here
            end
        end
    end
    
    methods (Access=protected)
        %% Define output properties
        function num = getNumInputsImpl(~)
            num = 0;
        end
        
        function num = getNumOutputsImpl(~)
            num = 1;
        end
        
        function flag = isOutputSizeLockedImpl(~,~)
            flag = true;
        end
        
        function varargout = isOutputFixedSizeImpl(~,~)
            varargout{1} = true;
        end
        
        function flag = isOutputComplexityLockedImpl(~,~)
            flag = true;
        end
        
        function varargout = isOutputComplexImpl(~)
            varargout{1} = false;
        end
        
        function varargout = getOutputSizeImpl(~)
            varargout{1} = [1,1];
        end
        
        function varargout = getOutputDataTypeImpl(~)
            varargout{1} = 'double';
        end
        
        function icon = getIconImpl(~)
            % Define a string as the icon for the System block in Simulink.
            icon = 'PBRead';
        end    
    end
    
    methods (Static, Access=protected)
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end
        
        function isVisible = showSimulateUsingImpl
            isVisible = false;
        end
    end
    
    methods (Static)
        function name = getDescriptiveName()
            name = 'PBRead';
        end
        
        function b = isSupportedContext(context)
            b = context.isCodeGenTarget('rtw');
        end
        
        function updateBuildInfo(buildInfo, context)
            if context.isCodeGenTarget('rtw')
                % Update buildInfo
                srcDir = fullfile(fileparts(mfilename('fullpath')),'source');
                incDir = fullfile(fileparts(mfilename('fullpath')),'source','include');
                buildInfo.addIncludePaths(incDir);
                % Use the following API's to add include files, sources and
                % linker flags
                addIncludeFiles(buildInfo,'stm32f4disc_gpio_wrapper.h');         
                addIncludeFiles(buildInfo,'stm32f4xx_gpio.h');
                addIncludeFiles(buildInfo,'stm32f4xx_rcc.h');
                addSourceFiles(buildInfo,'stm32f4xx_gpio.c', srcDir);
                addSourceFiles(buildInfo,'stm32f4xx_rcc.c', srcDir);
                addSourceFiles(buildInfo,'stm32f4disc_gpio_wrapper.c',srcDir);
                %addLinkFlags(buildInfo,{'-llibSink'});
            end
        end
    end
end

