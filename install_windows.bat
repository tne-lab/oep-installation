@echo off

set rootdir=%cd%
set logdir=%rootdir%\install_log

if not exist %logdir% (
    mkdir %logdir%
)

set config=%1
if [%config%]==[] set config=Release

rem prepare 64-bit build toolset
if not defined DevEnvDir (
    call "%ProgramFiles(x86)%\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" amd64
)

if errorlevel 1 (
    echo.
    echo Could not prepare Visual Studio compiler - do you have Visual Studio 2013 installed?
    exit /b 1
)

echo Downloading GUI and dependencies...

if not exist asiosdk (
    echo.
    echo Downloading ASIO...
    echo.
    PowerShell -ExecutionPolicy RemoteSigned -File download_asio.ps1
    
    if errorlevel 1 (
        echo Error downloading ASIO
        exit /b 1
    )
    
    echo Make sure to install ASIO4ALL to use ASIO.
)

if not exist plugin-GUI (
    echo.
    echo Downloading Open Ephys GUI...
    echo.

    git clone https://github.com/tne-lab/plugin-GUI
    
    if errorlevel 1 (
        echo Error downloading Open Ephys GUI
        exit /b 1
    )
)

if not exist ZMQPlugins (
    echo.
    echo Downloading ZeroMQ plugins....
    echo.

    git clone https://github.com/open-ephys-plugins/ZMQPlugins
    
    if errorlevel 1 (
        echo Error downloading ZeroMQ plugins
        exit /b 1
    )
)

if not exist HDF5Plugins (
    echo.
    echo Downloading HDF5 plugins...
    echo.

    git clone https://github.com/open-ephys-plugins/HDF5Plugins
    
    if errorlevel 1 (
        echo Error downloading HDF5 plugins
        exit /b 1
    )
)

if not exist OpenEphysFFTW (
    echo.
    echo Downloading OpenEphysFFTW library...
    echo.
    
    git clone https://github.com/tne-lab/OpenEphysFFTW
    
    if errorlevel 1 (
        echo Error downloading OpenEphysFFTW library
        exit /b 1
    )
)

if not exist phase-calculator (
    echo.
    echo Downloading Phase Calculator...
    echo.

    git clone https://github.com/tne-lab/phase-calculator
    
    if errorlevel 1 (
        echo Error downloading Phase Calculator
        exit /b 1
    )
)

if not exist crossing-detector (
    echo.
    echo Downloading Crossing Detector...
    echo.

    git clone https://github.com/tne-lab/crossing-detector
    
    if errorlevel 1 (
        echo Error downloading Crossing Detector
        exit /b 1
    )
)

if not exist sample-math (
    echo.
    echo Downloading Sample Math...
    echo.

    git clone https://github.com/tne-lab/sample-math
    
    if errorlevel 1 (
        echo Error downloading Sample Math
        exit /b 1
    )
)

if not exist continuous-stats (
    echo.
    echo Downloading Continuous Stats...
    echo.

    git clone https://github.com/tne-lab/continuous-stats
    
    if errorlevel 1 (
        echo Error downloading Continuous Stats
        exit /b 1
    )
)

if not exist mean-spike-rate (
    echo.
    echo Downloading Mean Spike Rate...
    echo.

    git clone https://github.com/tne-lab/mean-spike-rate
    
    if errorlevel 1 (
        echo Error downloading Mean Spike Rate
        exit /b 1
    )
)

rem for ICA
echo.
echo Checking for installed Eigen3...
reg query HKCU\Software\Kitware\CMake\Packages\Eigen3

if errorlevel 1 (
    echo.
    echo Downloading and installing Eigen...
    echo.

    git clone https://github.com/eigenteam/eigen-git-mirror
    cd eigen-git-mirror
    git checkout 3.3.7
    mkdir Build
    cd Build
    cmake ..
    cd %rootdir%
)

if not exist ica-plugin (
    echo.
    echo Downloading ICA...
    echo.

    git clone https://github.com/tne-lab/ica-plugin
    
    if errorlevel 1 (
        echo Error downloading ICA
        exit /b 1
    )
)

echo Building GUI and dependencies...

cd plugin-GUI
git checkout low-latency
cd Build
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=gui_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building Open Ephys GUI...
devenv open-ephys-GUI.sln /build %config% /project ALL_BUILD /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%\ZMQPlugins\Build
git pull
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=zmq_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building ZeroMQ plugins...
devenv OE_ZMQ.sln /build %config% /project INSTALL /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%\HDF5Plugins\Build
git pull
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=hdf5_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building HDF5 plugins...
devenv OE_HDF5.sln /build %config% /project INSTALL /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%\OpenEphysFFTW\OpenEphysFFTW\Build
git fetch origin
git checkout cmake-gui
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=fftw_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building OpenEphysFFTW...
devenv OE_COMMONLIB_OpenEphysFFTW.sln /build %config% /project INSTALL /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%\phase-calculator
git fetch origin
git checkout cmake-gui
cd PhaseCalculator\Build
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=phase_calculator_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building Phase Calculator...
devenv OE_PLUGIN_PhaseCalculator.sln /build %config% /project INSTALL /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%\crossing-detector
git fetch origin
git checkout cmake-gui
cd CrossingDetector\Build
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=crossing_detector_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building Crossing Detector...
devenv OE_PLUGIN_CrossingDetector.sln /build %config% /project INSTALL /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%\sample-math
git fetch origin
git checkout cmake-gui
cd SampleMath\Build
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=sample_math_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building Sample Math...
devenv OE_PLUGIN_SampleMath.sln /build %config% /project INSTALL /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%\continuous-stats
git fetch origin
git checkout cmake-gui
cd ContinuousStats\Build
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=continuous_stats_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building Continuous Stats...
devenv OE_PLUGIN_ContinuousStats.sln /build %config% /project INSTALL /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%\mean-spike-rate
git fetch origin
git checkout cmake-gui
cd MeanSpikeRate\Build
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=mean_spike_rate_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building Mean Spike Rate...
devenv OE_PLUGIN_MeanSpikeRate.sln /build %config% /project INSTALL /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%\ica-plugin
git fetch origin
git checkout cmake-gui
cd ICA\Build
cmake -G "Visual Studio 12 2013" -A x64 ..

set logfile=ica_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo Building ICA...
devenv OE_PLUGIN_ICA.sln /build %config% /project INSTALL /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%

rem make links to the executable
PowerShell -ExecutionPolicy RemoteSigned "$s=(New-Object -COM WScript.Shell).CreateShortcut('%rootdir%\open-ephys (%config%).lnk');$s.TargetPath='%rootdir%\plugin-GUI\Build\%config%\open-ephys.exe';$s.Save()"
PowerShell -ExecutionPolicy RemoteSigned "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\open-ephys (%config%).lnk');$s.TargetPath='%rootdir%\plugin-GUI\Build\%config%\open-ephys.exe';$s.Save()"