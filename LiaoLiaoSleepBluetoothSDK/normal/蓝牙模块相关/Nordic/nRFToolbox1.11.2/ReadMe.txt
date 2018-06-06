nRF Toolbox
===========

The source code for nRF Toolbox has been separated into 3 projects. The DFU service has been moved to a new library project which may now be easily
integrated with your application. To keep the Android support v4 and v7-appcompat libraries up-to-date we have created another project with just one jar file in
the libs folder.

The nrf-logger-v2.0 library has been moved to DFULibrary.
The android-support-v4 library has been moved to AndroidSupportLibrary.

Usage:
Import all projects: nRFToolbox, AndroidSupportLibrary and DFULibrary into Eclipse ADT. 
The projects should compile without any changes if Android 5 SDK (API 21) is installed.

