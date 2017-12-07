# Release Notes ESP3

### Version 0.9.0
- Version 0.9.0 is a major update, that introduces major new functionnalities
- It requires to install the MCR version R2017b (9.3) availaible at https://au.mathworks.com/products/compiler/matlab-runtime.html
- If you have a CUDA compatible graphic card, it needs to be updated to the latest graphic driver to have CUDA 8.0 or higher.
- New Multifrequency display window that shows all availaible frequency in one window, synchronized with the main analysis window. WARNING: this might slow down ESP3, but will get back to normal if you close it.
- You can now select multiple regions to export, display or apply certain algorithms to those regions only.
- Separate display config file in each folder tso that you can save your grid display/integration size for each surveys.
- Export of 2D-sliced transect per cell now availaible as an output from the scrips (each transct in a separate *.xlsx file, to supplement the stadard output.)

### Version 0.8.1
- Version 0.8.0 was a bit of an early release with a lot of bugs there at multiple levels following major internal changes.
- Major and minor bug fixes
- Dedicated tabs to display of Sv(f) and TS(f) curves
- Performances improvements for loading of complex regions (saved from school-detection results)
- This version was calibrated against ESP2 on 4 different surveys. Identical results.


### Version 0.8.0
- Fixed bug for reading ASL files introduced in version 0.7.1
- Gives opportunity to the user to change certain tabs position
- New Map&Co tab with single target position and histogram
- Improved region/bottom database interface
- Added multi-frequency analysis tab
- Users can add and remove presets for algorithms parameters values


### Version 0.7.2
- New Bottom edit mode.
- New Bad transmit algorithm. Can be applyied on various selected area/regions. Much faster.
- Export integrated region via region context menu (right click)
- Export integrated transect via main menu
- Updated calibration tab with calculation options for environnemental variables
- Horizontal axis display estimated bottom backscatter when in bottom edit of bad transmit mode and show high values in red
- Undo/redo works for region creation/delation as well as bottom/ bad transmit edit/algorithms
- Minor bugs fixes and performances improvements. 


### Version 0.7.1
- Added functionnality so that you can apply target tracking to a region or a selected area (via context menu).
- Added Tracked Target export function in the export menu.
- Water Column region dialog box modified.

### Version 0.7.0
- Fixed Memory leak when changing layer that would not clean graphic objects properly and would slowly fill the ram.
- Changes in the integration method: 
    - sliced transect are now sliced independantly of region cell size (cell size defined in the scripts).
- Main edit bottom method changed. To stop editing double or right-click.
- Minor bugs fixes and performances improvements.


### Version 0.6.2
- Fixed some minor integration problems encountered while integrating shallow water data with small cell sizes and multiple complex regions.
- Added choice of Model for computation of absorbtion in the calibration tab. Default was Francois and Garisson (1982), now Doonan(2003) or override available.
- Added display of single target detected.
- Added templates for algorithms in echo scripts.
- Minor bugs fixes and performances improvements.

### Version 0.6.1
 - Fixed problem to read EK80 files where Frequency is not in the initial XML0 but only FrequencyStart and FrequecyEnd (Introduced in Version 0.6.0).
 - Added warning when aquisition parameters are changed during while file is recorded. Sv and or range will not be properly calculated if pulse length is changed during acquisition (this should be fixed soon).
 - Work on Normalization of frequency response for Sv/Sp/TS. Some more to do...
 - TS(f) processing is right (as compared to Simrad EK80 calibration programm).
 - Sv(f) processing might need some more testing.

### Version 0.6.0
 - Added multiple edit bottom modes
 - Created a Undo/Redo manager, working for bottom edit/algorithms and bad transmit edit/algorithms.
 - Improved raw FCV30 file reading.
 - Multi channel reading for ASL file now available.
 - Revamped the display tab.
 - You can now specify the transparency for under bottom data.
 - Multiple bug fixes...
 - WARNING: NOT SUITABLE TO READ CW EK80 files. New Version on the way...

### Version 0.5.4
 - This version has a bug... To work properly, you need to manually delete the config_echo.xml file in the C:\Program Files\ESP3_ver_0.5.4.0\config folder and restart ESP3. This will create a clean version of the config file.

