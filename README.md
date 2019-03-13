# Target Development

Develop a target using MATLAB&copy; target SDK for Cortex-M based hardware board.

### Table of Contents
**[Prerequisites](#prerequisites)**<br>
**[Getting Started](#getting-started)**<br>
**[Create the Framework](#create-the-framework)**<br>
**[Create a New Hardware from Reference Target](#create-a-new-hardware-from-reference-target)**<br>
**[Add a New Deployer](#add-a-new-deployer)**<br>
**[Current Issues](#current-issues)**<br>
~~**[Workaround](#workaround)**<br>~~
**[Reading Materials](#reading-materials)**<br>
**[To Do List](#to-do-list)**<br>

## Prerequisites

Before getting started, basic information about what a target is and the implementation of it is explained in the following MathWorks&copy; [webpage](https://www.mathworks.com/help/supportpkg/armcortexm/ug/what-is-a-target.html "What Is a Target?").
Also a Target SDK documentation that is specific to ARM&copy; Cortex-M&copy; processors can be found [here](https://www.mathworks.com/help/supportpkg/armcortexm/target-sdk.html "Develop a Target")
<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## Getting Started

<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## Create the Framework

To start developing a target with custom hardware boards based on STM32F4 Discovery Board,
I (AK) started by loading a target from support packages provided by Mathworks to use as a
reference to build my own target and its hardware.

First, start by instantiating a reference target object by loading an already existing target by using a command `discCopy=loadTarget('STMicroelectronics STM32F4-Discovery')`. The string name 'STMicroelectronics STM32F4-Discovery' can be found in a xml file within SupportPackage directory: (C:/ProgramData/MATLAB/SupportPackages/R2018a/toolbox/target/supportpackages/stm32f4discovery/registry/parameters/STM32F4Discovery.xml) and is unique to MATLAB that cannot be duplicated.

After creating a target object to use as a reference, instantiate another target object which will be the target I will be developing.
Use the command `tgt=createTarget(myNewTargetName,referenceTargetName,myNewTargetRootFolder);`.

> Note: a variable named referenceTargetName is not the same target as an object `discCopy`. `referenceTargetName` variable is the base target which will support my new target and has a name `'ARM Cortex-M'`. This string name is also a unique name which cannot be duplicated.

Below code snippet shows the entire process of creating a new target framework.
``` matlab
%% Create a framework
discCopy = loadTarget('STMicroelectronics STM32F4-Discovery'); % use this object to find specific attributes to reuse for my own target
referenceTargetName = 'ARM Cortex-M';
myNewTargetName = 'STM32F4-Discovery Copy';
myNewTargetRootFolder = 'C:\temp\alexkim92\DiscCopy'; % location of your new target
tgt = createTarget(myNewTargetName,referenceTargetName,myNewTargetRootFolder);
% tgt = createTarget(myNewTargetName,referenceTargetName,myNewTargetRootFolder, 'initialize');
saveTarget(tgt); % saving the target will autogenerate files and direcotries
testTarget(tgt, 'framework');
```
In the code snippet above, a line with a function `createTarget(myNewTargetName,referenceTargetName,myNewTargetRootFolder, 'initialize')` which is commented out contains an argument string `'initialize'`. This argument will initialize all the features your reference target supports. Since my hardware will not have same features as the reference target, I did not initialize my new target with its reference target.

If everything was setup right, the test function `testTarget(tgt, 'framework')` will return PASSED. If something goes wrong and the test returns FAILED or INCOMPLETE, a link to the test diagnostic logs is shown below the test summary.

> Note: passing a function `testTarget(tgt)` without the argument will test the entirety of the target which can take a while.
<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## Create a New Hardware from Reference Target

Name of my hardware can be specified here after creating a target object that is being developed. The following code snipped contains creating a hardware:
``` matlab
%% Create a new hardware board from reference target
hw = createHardware('My Disc Board');
hw.DeviceID = 'ARM Cortex-M4F'; % a unique device ID
map(tgt, hw, 'My Disc Board')
show(tgt);
refHw = getHardware(discCopy, 'mapped'); % get the reference hardware
% hw.IOInterface = refHw{1,1}.IOInterface; % Using an object causes a bug

io = addNewSerialInterface(hw,'My Serial');
io.DefaultBaudrate = 460800;
io.AvailableBaudrates = 'NaN';
saveTarget(tgt);
testTarget(tgt, 'hardware');

% Check the Simulink Configuration to see my target is created
```
By calling a function `createHardware('Name of your Hardware')`, a new hardware can be created with the name you specified as a string. Once the hardware has been created, a `DeviceID` property can be set. String name `'ARM Cortex-M4F'` is also a unique value which cannot be different from what MATLAB recognizes.

A function `map(tgt, hw, 'My Disc Board')` will map your new hardware to the target. You can have multiple hardware mapped to a single target and have different features mapped to each hardware. This will be covered in the following section.

A variable `refHw` above in the code snippet is calling a function `getHardware(discCopy, 'mapped')` which creates a hardware object that is mapped to my loaded target object, `'discCopy'`. This function can be useful since you can see and use the object's property values. I used this variable to get property values `DeviceID` and `IOInterface` (i.e. using the command `refHw{1,1}.IOInterface`). To add a new `IOInterface` property, use the function `addNewSerialInterface(harware, 'My Serial')`. `hardware` is your hardware object and `'My Serial'` is the name for your new interface. This string name is important when creating and mapping an External feature since you have to specify the unique name of the IO interface you created here.

> Note: when using an object created with `getHardware()` function, there is a small bug present(R2018a) which does not populate your target object's properties until MATLAB is restarted. It would be much easier to set my target's properties values with the created object but due to this bug I will copy its values one by one.

Once the values have been set call the function `saveTarget(tgt)` to save your target and test your target with `testTarget(tgt, 'hardware')` function.

After you mapped your hardware to your target, you can check Simulink&copy;'s configuration panel to see that your hardware is present in drop down menu. To check this, create a new Simulink model and select **Simulation > Model Configuration Parameters**. In the Configuration Parameter dialog box, select **Hardware Implementation**. In the drop down menu of **Hardware Board**, you should see your new hardware available.
<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## Add a New Deployer

Deployer is 

This is where my code starts to get messy with build configuration values of the hardware. Start the process by creating a deployer object `dep` with the function `addNewDeployer(tgt, 'My New Deployer')`. Arguments are: target object to add your deployer to and the string name for your new deployer. Check your target by using the command `show(tgt)`. You should see 0 under the name of your hardware. This indicated the feature has not been mapped to your hardware. Map the feature by using `map(tgt, hw, dep)` and check your target again with `show(tgt)`. Now there should be 1 under your hardware name indicating the feature has been mapped.

Once you have created a new deployer, create a new deployer object to use as a reference with `getDeployer(discCopy, 'mapped')`. Similar to previous steps with using the `get` function, you can look at its properties to copy over to your hardware.

Below code snippet shows the process of adding a new deployer and its build configuration using the reference deployer.
> Pay attention to certain property values since they contain the name of source files, location of directories, compiler flags and etc. which are specific to the toolchain for the processor we are using.
``` matlab
%% Add a new deployer
dep = addNewDeployer(tgt, 'My New Deployer');
show(tgt)
% mapping the feature to hardware indicated by 1
map(tgt, hw, dep);
show(tgt)

refDep = getDeployer(discCopy, 'mapped'); % use this object as a reference
saveTarget(tgt)

toolChain = dep.addNewToolchain('GNU Tools for ARM Embedded Processors');
buildConfig = toolChain.addNewBuildConfiguration('My Build Configuration');
buildConfig.CompilerFlags = '-mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork -mfpu=fpv4-sp-d16 -mfloat-abi=hard -include stm32f4discovery_wrapper.h';
buildConfig.IncludePaths = {'$(ARM_CORTEX_M_ROOT_DIR)/scheduler/include','$(MATLAB_ROOT)/rtw/c/src/ext_mode/serial','$(STM32F4DISCOVERY peripheral firmware examples)/Libraries/CMSIS/ST/STM32F4xx/Include','$(CMSIS)/CMSIS/Include','$(STM32F4DISCOVERY peripheral firmware examples)/Project/Peripheral_Examples/SysTick','$(STM32F4DISCOVERY peripheral firmware examples)/Libraries/STM32F4xx_StdPeriph_Driver/inc','$(TARGET_ROOT)/include','$(ARM_CORTEX_M_ROOT_DIR)/cmsis_rtos_rtx/include'};
buildConfig.LinkerFlags = {'-mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork -mfpu=fpv4-sp-d16 -mfloat-abi=hard --specs=nano.specs','-T"$(TARGET_ROOT)/src/arm-gcc-link.ld"'};
buildConfig.AssemblerFlags = '-mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork -mfpu=fpv4-sp-d16 -mfloat-abi=hard';
buildConfig.Defines = {'USE_STDPERIPH_DRIVER','USE_STM32F4_DISCOVERY','STM32F4XX','ARM_MATH_CM4=1','__FPU_PRESENT=1','__FPU_USED=1U','HSE_VALUE=8000000','NULL=0','__START=_start','EXIT_FAILURE=1','EXTMODE_DISABLEPRINTF','EXTMODE_DISABLETESTING','EXTMODE_DISABLE_ARGS_PROCESSING=1'};
buildConfig.LinkObjects = {'$(CMSIS)/CMSIS/Lib/GCC/libarm_cortexM4lf_math.a','$(CMSIS)/CMSIS/RTOS/RTX/LIB/GCC/libRTX_CM4.a'};
buildConfig.SourceFiles = {'$(TARGET_ROOT)/src/blapp_support.c','$(TARGET_ROOT)/src/startup_stm32f4xx.c','$(TARGET_ROOT)/src/syscalls_stm32f4xx.c','$(TARGET_ROOT)/src/stm32f4xx_init_board.c','$(TARGET_ROOT)/src/system_stm32f4xx.c'};

dep.Tokens{1} = struct('Name', 'ARM_CORTEX_M_ROOT_DIR', 'Value', 'codertarget.armcortexmbase.internal.getRootDir');
dep.Tokens{2} = struct('Name', 'STM32F4DISCOVERY peripheral firmware examples', 'Value', 'codertarget.stm32f4discovery.internal.getSTM32F4DiscoveryFwDir');
dep.Tokens{3} = struct('Name', 'CMSIS', 'Value', 'codertarget.arm_cortex_m.internal.getCMSISDir');
dep.Tokens{4} = struct('Name', 'ARMCORTEXM_ROOT_DIR', 'Value', 'matlabshared.target.stmicroelectronicsstm32f4discovery.getReferenceTargetRootFolder');

loader = dep.addNewLoader('My New Loader');
loader.LoadCommand = 'matlab:codertarget.stm32f4discovery.utils.downloadToTarget';
loader.LoadCommandArguments = '-f board/stm32f4discovery.cfg';

dep.MainIncludeFiles = {'system_stm32f4xx.h','blapp_support.h','stm32f4discovery_wrapper.h'};
dep.AfterCodeGenFcn = 'codertarget.stm32f4discovery.registry.BootloaderSourceAddition';
dep.HardwareInitializationFcn = {['#ifndef USE_RTX' char(10) '' char(9) '#if defined(MW_MULTI_TASKING_MODE) && (MW_MULTI_TASKING_MODE == 1)' char(10) '' char(9) '' char(9) 'MW_ASM (" SVC #1");' char(10) '' char(9) '#endif' char(10) '' char(9) '__disable_irq();' char(10) '#endif' char(10) ''],'stm32f4xx_init_board()','SystemCoreClockUpdate()','bootloaderInit()'};

saveTarget(tgt);

testTarget(tgt, 'deployer'); % does not return PASSED yet
```
After saving the target with its new feature properties set as above code, add all required source, header, and library files and folders into the <targetroot
Add all required source, header, and library files and folders into the `myNewTargetRootFolder` specified in **[Create the Framework](#create-the-framework)**<br>
<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## Current Issues

Many fields within autogenerated xml files do not contain the same contents as the reference target. My guess is that due to this my target is not able to pass the target's deployer test even though I copy everything within MATLAB using target SDK by looking at loaded reference target.
<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## Workaround

Due to a limited documentation on the issue I had where my target did not pass the deployer test even though I had the exact same values
from its reference target: some xml files did not create or some fileds within the xml file were missing when compared to the reference target. So instead I copied the entire reference target folder `\stm32f4discovery` and created a copy with a name `\stm32f4discoveryCopy`. Also, make sure to put the directory copy in C directory.
Once the directory was replicated, I compared xml files to make sure my copy did not have the same string names as the original target since they need to be unique names. The following file has been modified: `stm32f4discoveryCopy\rtwTargetInfo.m`.
Within the file:
```matlab
function config =loc_createPILConfig
config(1) = rtw.connectivity.ConfigRegistry;
config(1).ConfigName = 'STM32F4-Discovery Copy (ST-LINK)';                               % added 'Copy' at the end
config(1).ConfigClass = 'codertarget.stm32f4discoverycopy.pil.ConnectivityConfig';
config(1).isConfigSetCompatibleFcn = @i_isConfigSetCompatible;
config(2) = rtw.connectivity.ConfigRegistry;
config(2).ConfigName = 'STM32F4-Discovery Copy (Serial)';                                % added 'Copy' at the end
config(2).ConfigClass = 'codertarget.stm32f4discoverycopy.pil.SerialConnectivityConfig'; % added 'copy' after `stm32f4discovery`
config(2).isConfigSetCompatibleFcn = @i_isConfigSetCompatibleSerial;
end
 
% -------------------------------------------------------------------------
function boardInfo =loc_registerBoardsForThisTarget
target = 'STMicroelectronics STM32F4-Discovery Copy';                                    % added 'Copy' at the end
[targetFolder, ~, ~] = fileparts(mfilename('fullpath'));
boardFolder = codertarget.target.getTargetHardwareRegistryFolder(targetFolder);
boardInfo = codertarget.target.getTargetHardwareInfo(targetFolder, boardFolder, target);
end
 
% -------------------------------------------------------------------------
function ret =loc_registerThisTarget
ret.Name = 'STMicroelectronics STM32F4-Discovery Copy';                                  % added 'Copy' at the end
ret.ShortName = 'stmicroelectronicsstm32f4discoverycopy';                                % added 'copy' after `stm32f4discovery`
[targetFilePath, ~, ~] = fileparts(mfilename('fullpath'));
ret.TargetFolder = targetFilePath;
ret.ReferenceTargets = { 'ARM Cortex-M' };
end
```
Add `\stm32f4discoveryCopy` and `\stm32f4discoveryCopy\registry` to the path and run the command `sl_refresh_customizations`.

Once the above fields have been modified I was able to run the deployer test and pass.

<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## Reading Materials

https://dspace.vutbr.cz/bitstream/handle/11012/43045/eeict2015-470-otava.pdf?sequence=1&isAllowed=y
<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## To Do List

- [x] Create a target
- [x] Add a new hardware to target
- [ ] Pass the targetTest(tgt, 'deployer')
- [x] Pass the workaround targetTest(tgt, 'deployer')
<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>
