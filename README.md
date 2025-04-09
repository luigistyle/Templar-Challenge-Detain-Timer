# Templar Challenge Detain Timer
The Templar Challenge Detain Timer (TCDT for short) is a script that displays a timer for when the next detain will occur, created for use in Solo Templar Challenge runs. The script comes with a generous amount of customization options, which you may read about in more detail in the [Settings](#settings) section.

## Installation
The recommended method of installing the script is to simply download [the latest release](https://github.com/luigistyle/Templar-Challenge-Detain-Timer/releases/latest) to a folder of your choosing. This method is recommended because it does not require the user to have AHK v2 nor the JXON_ahk2 library installed.

If you prefer to install the script manually, you may also download the uncompiled AHK file as well as the Lib folder to a directory of your choosing.

## Usage Instructions
Once you have downloaded the script and ran the script, it will automatically create a `settings.json` file in the directory the script is located in with the script's default settings. You will also notice the timer show up in the top-right corner of your screen. Listed below are the valid controls for the script:

- F: Activate the timer. The key for this bind can be changed in the Settings menu
- F3: Open the Settings menu
- F4: Enable draggability (click and drag the timer window to move it around!)
- Ctrl+J: Reset the timer
- Ctrl+K: Close the script

Activating the timer should be done at the same time as your relic super activation (hence why the keybind is set to the default super bind). Once the timer is active, it will count down to the next detain. Right as a detain is about to occur, the timer will play a sound. This will either be a Windows stock beep sound or a custom sound of the user's choice (see [Custom Sound](#custom-sound) for more information!)

## Support
If you run into an issue or find a bug while using the script, or even if you have a suggestion for a feature you would like to see, please don't hesitate to [create an issue](https://github.com/luigistyle/Templar-Challenge-Detain-Timer/issues/new/choose) or to reach out to me on Discord, @luigistyle.

## Settings
Listed below are the settings you may modify to your preference in the Settings menu:

### Text Background
Toggles the black background behind the timer text.

### Colored Text
Toggles color-coding the timer text based on the amount of remaining time before the next detain. The color-coding logic works like this:
If there is more than 10 seconds left, the text is green.
If there is 10 or less seconds left, the text is yellow.
If there is less than 5 seconds left, the text is red.

### Instant Break
If you are rallying to a flag and picking up the relic immediately afterwards in order to instantly break The Templar's shield, this option will modify the detain timings to remain accurate.

### Monitor Size Scaling
By default, the script makes all of its GUI elements smaller or larger depending on the resolution of your monitor. You may disable this functionality by disabling this setting. 
Note that modifying this setting will automatically reload the script in order to apply the changes, and that the alignment of the timer may be incorrect after said reload.

### Super Hotkey
Inside the hotkey box in this section, you may modify the hotkey that triggers the timer to your liking.

### Preset Alignments
Clicking one of the 4 buttons in this section will automatically align the timer to the specified corner of your screen.

### Custom Sound
This section of the Settings menu allows you to control what sound will play when you are about to be detained. Simply choose a sound file from your computer, or reset it back to the default if you don't like the sound you have selected.

## Credits
- luigistyle: Script creator
- Enskeria: Detain timings
- Shadow Rizzard: Instabreak detain timings
- TheArkive: Creator of the [JXON_ahk2](https://github.com/TheArkive/JXON_ahk2) library
