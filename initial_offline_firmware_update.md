# Initial Offline Firmware Update
The Max 4's shipped with likely a broken OTA check URL.  When you get your Max 4, if it's on a version older than `01.01.05.01` then you'll want to perform the following steps to update manually.

> [!NOTE]
> The file here was titled from Qidi as "NA", likely for "North America".  It's unclear what would be different between this and files for other regions.

1. Create a new folder on your USB drive named `QD_Update`.
2. Download [this file](./assets/QD_MAX4_01.01.05.01_20260123_Release_NA.zip).  Note that this is stored in this repository for history and openness.
3. Put the compressed zip file directly into the `QD_Update` folder, do not extract it.
4. Plug into your printer.
5. Perform offline update via the touch screen.

Your printer should now have working OTA updates.
