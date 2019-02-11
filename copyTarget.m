%% When MATLAB has been restarted
% 1) set path to target's directory and the registry directory
% 2) sl_refresh_customizations
% 3) tgt = loadTarget('STM32F4-Discovery Copy');

%% Create a framework
discCopy = loadTarget('STMicroelectronics STM32F4-Discovery'); % look at its field and copy below
% referenceTargetName = 'STMicroelectronics STM32F4-Discovery';
referenceTargetName = 'ARM Cortex-M';
myNewTargetName = 'STM32F4-Discovery Copy 2';
myNewTargetRootFolder = 'C:\temp\alexkim92\DiscCopy2'; % name of the new target's root folder
tgt = createTarget(myNewTargetName,referenceTargetName,myNewTargetRootFolder);
% tgt = createTarget(myNewTargetName,referenceTargetName,myNewTargetRootFolder, 'initialize');
saveTarget(tgt);
testTarget(tgt, 'framework');

%% Create a new hardware board from reference target
hw = createHardware('My Disc Board');
hw.DeviceID = 'ARM Cortex-M4F';
map(tgt, hw, 'My Disc Board 2')
show(tgt);
% hw = getHardware(tgt, 'mapped');
refHw = getHardware(discCopy, 'mapped'); % get the reference hardware
% hw.IOInterface = refHw{1,1}.IOInterface;

io = addNewSerialInterface(hw,'My Serial');
io.DefaultBaudrate = 460800;
io.AvailableBaudrates = 'NaN';
% io = addNewSerialInterface(hw{1,1},'My Serial Interface'); % this line
% for when using loaded hardware obj hw.
saveTarget(tgt);
testTarget(tgt, 'hardware');

% Check the Simulink Configuration to see my target is created

%% Add a new deployer
dep = addNewDeployer(tgt, 'My New Deployer');
show(tgt)
% mapping the feature to hardware indicated by 1
map(tgt, hw, dep);
show(tgt)

refDep = getDeployer(discCopy, 'mapped');
show(tgt)
% map(tgt, hw, refDep)
show(tgt)
% unmap(tgt, hw, dep);
% unmap(tgt, hw, refDep);
show(tgt)
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

testTarget(tgt, 'deployer');

%% Add a new baremetal scheduler from reference target
refScheduler = getBaremetalScheduler(discCopy, 'mapped');
% map(tgt, hw, refScheduler);
% saveTarget(tgt)
show(tgt)

scheduler = addNewBaremetalScheduler(tgt, 'My Baremetal Scheduler');
show(tgt)
map(tgt, hw, scheduler)
show(tgt)

baseRateTrigger = addNewBaseRateTrigger(scheduler, 'My Base Rate Trigger');
% set up a hardware interrupt, such as a timer, at the rate that corresponds to the base rate of the model
baseRateTrigger.ConfigurationFcn = 'ARMCM_SysTick_Config(modelBaseRate)';
baseRateTrigger.EnableInterruptFcn = '__enable_irq()';
baseRateTrigger.DisableInterruptFcn = '__disable_irq()';

saveTarget(tgt);
testTarget(tgt, 'scheduler');


%% Add a new external mode
ext = addNewExternalMode(tgt,'My New External mode');
show(tgt)
map(tgt, hw, ext, 'My Serial'); % string name must match with the interface added to hardware above
show(tgt)

refExt = getExternalMode(discCopy, 'mapped');

ext.SourceFiles = {'$(MATLAB_ROOT)/rtw/c/src/ext_mode/serial/ext_serial_pkt.c','$(MATLAB_ROOT)/rtw/c/src/ext_mode/serial/rtiostream_serial_interface.c','$(MATLAB_ROOT)/rtw/c/src/ext_mode/serial/ext_svr_serial_transport.c','$(TARGET_ROOT)/src/rtiostream_serial_dma_stm32f4xx.c','$(STM32F4DISCOVERY peripheral firmware examples)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_usart.c','$(STM32F4DISCOVERY peripheral firmware examples)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_rcc.c','$(STM32F4DISCOVERY peripheral firmware examples)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_gpio.c','$(STM32F4DISCOVERY peripheral firmware examples)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_usart.c','$(STM32F4DISCOVERY peripheral firmware examples)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_gpio.c','$(STM32F4DISCOVERY peripheral firmware examples)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_dma.c','$(STM32F4DISCOVERY peripheral firmware examples)/Libraries/STM32F4xx_StdPeriph_Driver/src/misc.c'};
ext.PreConnectFcn = 'pause(5);';
ext.Protocol = 'Legacy';

saveTarget(tgt);

refOs = getOperatingSystem(discCopy, 'mapped');
refOs = getOperatingSystem(discCopy, 'name', 'Baremetal');

map(tgt, hw, refOs);
show(tgt)
saveTarget(tgt);