# Target Development

Develop a target using MATLAB&copy; target SDK for Cortex-M based hardware board.

### Table of Contents
**[Prerequisites](#prerequisites)**<br>
**[Getting Started](#getting-started)**<br>
**[Create the Framework](#create-the-framework)**<br>
**[Create a New Hardware from Reference Target](#create-a-new-hardware-from-reference-target)**<br>
**[Current Issues](#current-issues)**<br>

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

Note: a variable named referenceTargetName is not the same target as an object discCopy. referenceTargetName variable is the base target which will support my new target and has a name 'ARM Cortex-M'. This string name is also a unique name which cannot be duplicated.
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
In the code snippet above, a line with a function `createTarget()` which is commented out contains an argument string `'initialize'`. This argument will initialize all the features your reference target supports. Since my hardware will not have same features as the reference target, I did not initialize my new target with its reference target.

If everything was setup right, the test function `testTarget(tgt, 'framework')` will return PASSED. If something goes wrong and the test returns FAILED or INCOMPLETE, a link to the test diagnostic logs is shown below the test summary.

Note: passing a function `testTarget(tgt)` without the argument will test the entirety of the target which can take a while.
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

A variable `refHw` above in the code snippet is calling a function `getHardware(discCopy, 'mapped')` which creates a hardware object that is mapped to my loaded target object, `'discCopy'`. This function can be useful since you can see and use the object's property values. I used this variable to get property values `DeviceID` and `IOInterface`. To add a new `IOInterface` property, use the function `addNewSerialInterface(harware, 'My Serial')`. `hardware` is your hardware object and `'My Serial'` is the name for your new interface. This string name is important when creating and mapping an External feature since you have to specify the unique name of the IO interface you created here.

Note: when using an object created with `getHardware()` function, there is a small bug present(R2018a) which does not populate your target object's properties until MATLAB is restarted. It would be much easier to set my target's properties values with the created object but due to this bug I will copy its values one by one.
Once the values have been set call the function `saveTarget(tgt)` to save your target and test your target with `testTarget(tgt, 'hardware')` function.

After you mapped your hardware to your target, you can check Simulink&copy;'s configuration panel to see that your hardware is present in drop down menu. To check this, create a new Simulink model and select **Simulation > Model Configuration Parameters**. In the Configuration Parameter dialog box, select **Hardware Implementation**. In the drop down menu of **Hardware Board**, you should see your new hardware available.
<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## Add a New Deployer

## Current Issues

<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>

## Readings to do
https://dspace.vutbr.cz/bitstream/handle/11012/43045/eeict2015-470-otava.pdf?sequence=1&isAllowed=y
<br/>
<div align="right">
    <b><a href="#Target-Development">↥ back to top</a></b>
</div>
<br/>
