# TargetDevelopment

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
    <b><a href="#----">↥ back to top</a></b>
</div>
<br/>

## Getting Started

## Create the Framework

To start developing a target with custom hardware boards based on STM32F4 Discovery Board,
I (AK) started by loading a target from support packages provided by Mathworks to use as a
reference to build my own target and its hardware.

First, start by instantiating a reference target object by loading an already existing target by using a command `discCopy=loadTarget('STMicroelectronics STM32F4-Discovery')`. The string name 'STMicroelectronics STM32F4-Discovery' can be found in a xml file within SupportPackage directory: (C:/ProgramData/MATLAB/SupportPackages/R2018a/toolbox/target/supportpackages/stm32f4discovery/registry/parameters/STM32F4Discovery.xml) and is unique to MATLAB that cannot be duplicated.

After creating a target object to use as a reference, instantiate another target object which will be the target I will be developing.
Use the command `tgt=createTarget(myNewTargetName,referenceTargetName,myNewTargetRootFolder);`. Note that variable named referenceTargetName is not the same target as an object discCopy. Variable referenceTargetName is the base target which will support my new target and has a name 'ARM Cortex-M'. This string name is also a unique name which cannot be duplicated.
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

If everything was setup right, the test function `testTarget()` will return PASSED. If something goes wrong and the test returns FAILED or INCOMPLETE, a link to the test diagnostic logs is shown below the test summary.
<br/>
<div align="right">
    <b><a href="#----">↥ back to top</a></b>
</div>
<br/>
## Create a New Hardware from Reference Target






## Current Issues






https://dspace.vutbr.cz/bitstream/handle/11012/43045/eeict2015-470-otava.pdf?sequence=1&isAllowed=y
