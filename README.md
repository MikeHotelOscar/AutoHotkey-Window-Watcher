# AutoHotkey-Window-Watcher

This is an AutoHotkey script (originally developed [here](https://sharats.me/posts/the-magic-of-autohotkey#window-watcher)) that allows for actions in AutoHotkey to be taken whenever a particular type of window is opened or closed. For example, you could have AutoHotkey automatically close Steam when a game is closed so that you have a clean desktop. You could use it to maximize certain windows, or windows that open under a certain percentage of the screen. Virtually anything that could be done in AutoHotkey can be triggered by a window opening or closing automatically using this script.

## Changes

The original script did not have the capability to trigger on a window closing. I have added this capability. In addition, I have run into an issue of AutoHotkey not being active when the last window on a desktop is closed, necessitating clicking the desktop to allow further use, this script fixes this issue.

## How to use

### Window Created
To trigger on a window opening, in the function OnWindowCreated() add one of the following lines:
```
if (winexist("ahk_class SomeClass " . hwnd)){
if (winexist("ahk_exe SomeExe ahk_id " . hwnd)){
if (winexist("ahk_group SomeGroup ahk_id " . hwnd)){
```

These lines will open a block of code that will trigger whenever a window of SomeClass, SomeExe or SomeGroup is opened. Simply change the SomeClass, SomeExe or SomeGroup to a program's Class or Exe, and the code in the block will trigger when the window opens. 

### Window Destroyed
Triggering on a window closing is a little bit more complicated. In the functionOnWindowDestroyed(), add one of the following lines:
```
if ((ExeClass[1] = "SomeExe") && !winexist("ahk_exe SomeExe ahk_id" . hwnd)){
if ((ExeClass[1] = "SomeExe") && !winexist("ahk_class SomeClass ahk_id" . hwnd)){
if ((ExeClass[2] = "SomeClass") && !winexist("ahk_exe SomeExe ahk_id" . hwnd)){
if ((ExeClass[2] = "SomeClass") && !winexist("ahk_class SomeClass ahk_id" . hwnd)){
```
These lines open a code block in the same way as OnWindowCreated(), but the blocks will trigger on a window being closed. This also prevents the code from being triggered by child windows opened by a program. ExeClass is an array that contains the Exe and Class names of a destroyed window, and is the primary way to identify a closed window. We then check if an applicable window exists, and if it doesn't, then the code triggers.
