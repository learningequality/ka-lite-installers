KA-Lite Monitor OS X App
========================

For creating the .dmg file, follow steps below:


1. Create a new image using Disk Utility, leaving all the options at their defaults, sized such that it will contain all your files.

2. Create a folder inside the mounted DMG and name it “.background”. Drop the background (ka-lite-logo.png) PNG into this.

3. Drop your app into the root of the DMG. (e.g. KA-Lite Minitor app)

4. From the View menu of Finder, choose Show View Options, and customize the view to show icons only, no sideview, etc. Also switch off the toolbar in the view menu.

5. Set the window background to picture, and use Cmd-Shift-G in combination with the full path (e.g. /KALiteSample1/.background) to set your background PNG as the background for the view.

6. Move the app icon into the right place versus the background image, changing the font size and the dimensions of the icons.

7. Now just add a shortcut to the Application Folder, place it inside the DMG, and then position the shortcut.
    Steps to create a Applications shortcut:

        1. Click on Go in navigation menu
        2. Click on Computer
        3. Click on Macintosh HD
        4. Right-click on Applications
        5. Click on Make alias
        6. Copy `Application alias` and paste it into the root of the DMG
        7. Rename `Applications alias` to `Applications` 

8. Do a final resize on the Window such that it is the same size of your background. Your DMG should now look as you expect.

9. Eject the DMG, then go to Disk Utilities, select the DMG and choose “convert“, then “compression” and save again. Now the DMG is compressed (as small as possible) and made unwritable. Note that's its a really good idea to save to a different name, so that you can use the uncompressed DMG as a template for future releases, and not have to go through this whole process again.

10. That's it

Reference: 
    (http://chromasoft.blogspot.com/2010/02/building-dmg-installer-for-mac-simple.html)