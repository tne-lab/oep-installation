# oep-installation

This repository houses scripts for easy installation of Open Ephys and useful plugins.

## Prerequisites

* Git must be installed.
  * If on Windows, you can find the installer [here](https://git-scm.com/download/win). When installing, you must select "Git from the command line and also from 3rd-party software" on the "Adjusting your PATH environment" page.

* [CMake](https://cmake.org/) must be installed.

* On Windows, you must have Visual Studio 2013 (or just the 2013 Build Tools for Visual Studio) installed.

* If you are on Windows and want to use ASIO for lower-latency processing, you must install ASIO4ALL [here](http://www.asio4all.org/).


## Installation

* Either download as a ZIP file and unzip, or clone using `git clone https://github.com/tne-lab/oep-installation` at a terminal.

* Run `install_windows.bat` on Windows, or `source install_linux.sh` on Linux.
    * Note install_windows is for Visual Studio 2013. 2017 and 2019 versions are also provided.

* The scripts will build the Release GUI by default, but to use a different configuration (such as Debug), you can pass it as an argument, i.e. run `install_windows.bat Debug`.

* You can re-run the install script at any time to update to the latest version.

## Post-installation

* If this is the first time you are using the Open Ephys hardware on a Windows computer, you must run `plugin-GUI/Resources/DLLs/FrontPanelUSB-DriverOnly-4.4.0.exe` to install the Opal Kelly driver.

* If you are using the Python Plugin in Windows be sure to follow the instructions at https://github.com/tne-lab/PythonPlugin/tree/cmake_build to build and configure your installation after running the .bat script. Then see https://github.com/MemDynLab/PythonPlugin/issues/23 if you have issues loading python modules in.

