# oep-installation

This repository houses scripts for easy installation of Open Ephys and useful plugins.

## Prerequisites

* Git must be installed.
  * If on Windows, you can find the installer [here](https://git-scm.com/download/win). When installing, you must select "Git from the command line and also from 3rd-party software" on the "Adjusting your PATH environment" page.

* [CMake](https://cmake.org/) must be installed.

* On Windows, you must have Visual Studio 2013, 2017, 2019, or 2022 (or just the Build Tools for Visual Studio) installed from [here](https://visualstudio.microsoft.com/vs/community/).

* If you are on Windows and want to use ASIO for lower-latency processing, you must install ASIO4ALL [here](http://www.asio4all.org/).


## Installation

* Either download as a ZIP file and unzip, or clone using `git clone https://github.com/tne-lab/oep-installation` at a terminal.

* Run the install script for your platform:

  * Linux: `source install_linux.sh`
  
  * Windows: Script must be run from a Command Prompt shortcut that came with your Visual Studio installation which sets environment variables for the compiler. In the Start menu, find and open `Visual Studio 20XX/x64 Native Tools Command Prompt for VS 20XX` (where `20XX` is 2013, 2017, 2019, or 2022), navigate to the `oep-installation` directory, and run `install_windows.bat`.


* The scripts will build the Release GUI by default, but to use a different configuration (such as Debug), you can pass it as an argument, i.e. run `install_windows.bat Debug`.

* You can re-run the install script at any time to update to the latest version.

## Post-installation

* If this is the first time you are using the Open Ephys hardware on a Windows computer, you must run `plugin-GUI/Resources/DLLs/FrontPanelUSB-DriverOnly-4.4.0.exe` to install the Opal Kelly driver.

* If you are using the Python Plugin in Windows be sure to follow the instructions at https://github.com/tne-lab/PythonPlugin/tree/cmake_build to build and configure your installation after running the .bat script. Then see https://github.com/MemDynLab/PythonPlugin/issues/23 if you have issues loading python modules in.

## Additional note: Visual Studio full or VS build tools installation
Installing Visual Studio Community Edition for C++ Development:
*	Download & Run Installer: Get the Visual Studio Community Installer from the official website, then run it.
*	Edition & Workloads: Choose "Community" edition. Select "Desktop development with C++" workload.
*	Components: Optionally, customize components under "Individual components."
*	Location, Options & Install: Pick installation directory, set preferences, and click "Install."
*	Wait & Finish: Allow installation to complete, then launch Visual Studio.
*	Sign In (Optional): Log in with Microsoft account.
*	Start Using: Open Visual Studio for C++ development.

Installing Visual Studio Build Tools for C++:
*	Download & Run Installer: Download the Visual Studio Build Tools Installer, then run it.
*	Workloads & Components: Select "Desktop development with C++" workload. Optionally customize "Individual components."
*	Installation Options & Install: Choose location and other preferences, then click "Install."
*	Wait & Finish: Allow installation to complete.
