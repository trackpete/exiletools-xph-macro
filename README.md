# Note: GGG eventually added some basic XPH functionality into the game.

At the time of writing they still didn't add support to copy this text to the clipboard, so they don't provide tracking and metrics like this macro, but I haven't performed any additional development on the macro and OCR and can't guarantee it will work. It's kinda a bummer because the spreadsheet tracking was pretty cool.


# ExileTools In-Game XP/Hour Macro

## Check your XP Efficiency in a zone, log it over time, and find the optimum zone to level in without leaving the game!

*What it Does:* This macro uses Optical Character Recognition (OCR) to read a screenshot of the XP information presented when mousing over the XP bar. It does not interact with the game client.

The XP information is then saved as a checkpoint and you can repeatedly check your XP Efficiency to see how much XP you are getting over time. You can reset the checkpoint whenever you want, and even save the XPH information to a log file that you can view and sort in-game.

*Why use this when you can just hover over the XP bar to see your XPH?* This macro gives you full control over your XP tracking, allowing you to reset at specific checkpoints (such as map start), check XP since checkpoints, etc. Most importantly though it provides a very simple interface for actually *saving your XPH data* and referencing it. This makes finding the optimal zone for XP very easy, as you can quickly do 2-3 runs in one zone then 2-3 runs in another and compare them without having to constantly take notes and do math. ;)

Oh yeah, and this macro supports Gems too. Want to see how your gems are leveling? Super easy!

*Please Note: This can be tricky to get working reliably sometimes. I use it and it works great for me, but I can't guarantee it works equally well for everyone. A little effort is required to ensure the most accuracy. Also, it will only work for numbers with commas and decimals - if you have spaces, you will need to adjust the macro to lower accuracy.*

# How to Install:

1. Download [AutoHotKey](http://ahkscript.org/download/) 1.1.15+ from ahkscript.org (not autohotkey.com - that's different!).
2. Download [Capture2Text](http://capture2text.sourceforge.net/) and extract it to a simple location (I use c:\temp).
3. Save the [XPH OCR Macro](https://raw.githubusercontent.com/trackpete/exiletools-xph-macro/master/poe_ocr_xph.ahk) anywhere on your computer.
4. Open the `poe_ocr_xph.ahk` file in an editor such as Wordpad (Notepad may have problems with the carriage returns)
5. Optional: Read through all the information in the script to learn about it and why it's wonky
6. Search for `%CaptureToTextPATH%` and set the path of the capture2text files
7. Set the `MinWidth`, `MinHeight`, and `XSpace` variables appropriately for your resolution (may require some tweaking)
8. Optional: Change other global variables if desired, such as the XPH log file name
9. Save the file, then double click it to load it... then play Path of Exile!

*Gem Support:* Version 2+ also supports Gems! You must take a gem out of the slot and put it in your inventory. Once this is done, use any of the hotkeys as normal and it will start tracking gem XP. It can track different gems as long as they have different names, and these will all be tracked separately (even at the same time as a character). Logging works the same for gems as well!

*Please note:* You must play Path of Exile in Windowed Fullscreen or Windowed mode for the tooltip to show up. You also may need to run the macro as Administrator for it to work properly.

# Using the Macro:

These macros should only run if Path of Exile is in the foreground:

* `CTRL-x` : Hover over the XP bar to see popup, then this macro will attempt to show you XPH information since checkpoint. If no checkpoint is set, it will create a new checkpoint.
* `CTRL-SHIFT-x` : Hover over the XP bar to see popup, then this macro will attempt to show you XPH information since checkpoint. It will also set a new checkpoint from the current time and XP.
* `CTRL-s` : Saves the current XPH information to a log file and asks you to input a note into a dialogue box.
* `CTRL-SHIFT-s` : Saves the current XPH information to a log file and asks you to input a note into a dialogue box, then resets the checkpoint.
* `CTRL-l` : Opens all XPH log file information into a basic listview

# Examples:

![Examples](http://exiletools.com/img/xph_example.jpg)

# Using the List View and XPH Log:

When you press ctrl-l, you will get an AHK List View with the information from your log file. This log file is by default stored as "xph.log" in the directory where the macro resides. The log file is a CSV file with information you have saved via ^s.

You may sort the list view by clicking on any of the headers. Shift-clicking a header will "add" it to the list of sort fields, allowing you to do multi field sorting. For example, if you would like to see your XPH sorted by the character level, click the XPH header then shift-click the level header.

Sometimes you will notice that the OCR pulled the incorrect level information. It tries to use logic to prevent weird XP readings, but isn't so good at levels. If everything else is accurate, you can simply open up the "xph.log" file in a text editor and fix the bad reading. Here is an example:

```
Character,20150920133727,20150920134122,824191669,832516108,235,8324439,127522800,79,79,"Reef, 70, White, Edge"
Character,20150920134218,20150920134521,832516108,837622949,183,5106841,100461600,79,79,"Vaal Pyramid, 70, White, Speed"
Character,20150920134722,20150920135201,837622949,847237830,279,9614881,124063200,9,79,"Ghetto, 70, White, Speed"
Character,20150920135258,20150920135846,847237830,858043688,348,10805858,111783600,79,80,"Mountain Ledge, 69, Blue random, speed"
```

Obviously the cpLevel in the third line should have been "79" instead of "9" so we quickly edit the file and fix it. Closing and re-opening the list view will show the correct data.

If you'd like to manipulate the CSV data in Excel/etc., you can just copy/paste the following header line into the file:

`Target,CheckpointTime,EndTime,cpXP,EndXP,Seconds,XPgain,XPH,cpLevel,endLevel,Notes`

# Tuning the OCR Image Capture Box:

You will want to tune the OCR capture box to ensure it is ONLY capturing the black bordered box and NOT any of the random graphics around it. You can do this by keeping an eye on the raw capture2text output files. These sit in the "output" directory for capture2text.

Run the macro in-game, then open up the output folder and look at the "screen_capture.bmp" and "ocr_in.tif" files. In the first file, you want to make sure there are NO extra pixels around the dark box. In the second file, you can verify this by ensuring the file only contains a white background with black text (or vice versa) and that there are NO random characters. The "ocr.txt" file contains the exact copy of the text the OCR program extracted.

You can tune this by trial and error, or be more precise by opening the image up in an image editor (like Paint) and checking the actual pixel size of the dark box.

* `XSpace`: This is the amount of space between the mouse cursor and the start of the box on the left. It is static at 33px in my testing, but may vary for you.
* `MinWidth`: This is the width of the box. It should match the pixels of the dark box in Paint, or be a couple pixels smaller. Even two extra pixels in size can cause noise. This variable WILL change depending on screen resolution.
* `MinHeight`: This is the height of the XP box. You should test it with the extra "Exp Per Hour" line in it, otherwise you may make the box too small (go kill one mob). You don't need to have the entire Exp Per Hour line in the OCR image, but it's nice if extra features are added.
* `YSpace`: Ideally you should NOT USE THIS. It allows you to add extra padding to the bottom of the image so that you can be lazy and not place the mouse cursor at the very bottom of the window (this matters for Windowed mode when the mouse cursor isn't locked, for example). As long as you have the Exp Per Hour line it still shouldn't be necessary, it should just cut some of that off.

### Examples of GOOD image files
![Example](http://exiletools.com/img/screen_capture_good.jpg)
![Example](http://exiletools.com/img/ocr_in_good.jpg)

### Examples of BAD image files
![Example](http://exiletools.com/img/screen_capture_bad.jpg)
![Example](http://exiletools.com/img/ocr_in_bad.jpg)
**Note the extra pixels/false characters on the left (XSpace variable), right (MinWidth variable), and top (MinHeight variable)**

# Known Issues

* The OCR can be finicky, especially due to the transparency effect on the popup. It works best on a dark background (such as when the XP bar is in a shadow) and if the XP numbers are not placed over the skill icons. You should be able to get the hang of it.
* The listview can't be resized properly, because I am not very good at AHK. I'll figure it out someday.
* To edit the logs, you have to go in manually and rename stuff, delete lines, whatever. Sometimes you may end up with some bad data when the OCR detects "100,000,000" as "100,000" for example.
