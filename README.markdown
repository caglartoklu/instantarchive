# InstantArchive
*InstantArchive* backups the files and folders at the same directory, adding a time stamp and compressing with 7z.

If you drag and drop a file or a directory (or a multiple mix of them) on to the icon of *InstantArchive*, it will create a archive file for each of them.

Here is a real-time screen recording of its usage:

![instantarchive_screen3](https://user-images.githubusercontent.com/2071639/31129245-a7f3c3da-a85c-11e7-8ab8-4db3b5120a3f.gif)

InstantArchive also makes it easy to add comments to backup files.
To do that, simply drag and drop the backup file to InstantArchive once more:

![instantarchive_screen4_comments](https://user-images.githubusercontent.com/2071639/31129250-ad990a16-a85c-11e7-803f-461e743b49c5.gif)


# Installation

No need to install, the package is portable.
Simply extract the package to a directory of your choice.


# Configuration

None, currently.


# Usage

There a few ways to use InstantArchive.

## Desktop Shortcut to create files next to the source file/dirs

Create a shortcut to InstantArchive.exe on your Desktop.
To create a shortcut, simply right click and drag InstantArchive.exe to your desktop, and drop it.
Then it will be ready to drag and drop files and directories.

## Desktop Shortcut to create files next to the source file/dirs

Create another shortcut to InstantArchive.exe on your Desktop.
Edit the shortcut, and add `/t` and a folder of your choice.
Full line for *Target* text box could look like this:

```
C:\bin\instantarchive\instantarchive.exe /t C:\Backups
```

![screenshot of shortcut with t parameter](https://user-images.githubusercontent.com/2071639/51331811-94c18e80-1a8b-11e9-8c54-ed9508ef0293.PNG)

`/t` and the target directory name next to it makes InstantArchive to move the archive files to the target directory.

## Copy your shortcuts to SendTo folder

Hit Windows Key+R and type: shell:sendto and hit Enter.
Copy your shortcuts from above steps to this folder.

## Use .bat files for job descriptions.

Samples have been provided in `backup_scripts` folder.
As a sample, the source code for `backup_vim.bat` is also provided here:

```
cd %~dp0
..\instantarchive.exe /t c:\BACKUPS\regular_backups\ C:\PortableApps\PortableApps\gVimPortable
```

Feel free to add more scripts.


# Tools and Libraries Used
- [QB64](http://www.qb64.net/), QuickBasic 4.5 compatible compiler which supports Windows, Linux and Mac OS X.

- [7-Zip](http://www.7-zip.org) as the compression tool.


# FAQ

### Where can I find the pre-built binaries for Windows ?

Check the _releases_ section of Github page.

### Where can I find the pre-built binaries for Linux distros and Mac OS ?

There are no pre-built binaries for Linux and Mac OS, but it will be available soon.


# License

InstantArchive is licensed with MIT.
See the [LICENSE](LICENSE.txt) file.

For 7-Zip, most of the source code is under the GNU LGPL license.
The unRAR code is under a mixed license: GNU LGPL + unRAR restrictions.
Check license information here: [7-Zip license](7z/License.txt).


# Legal

All trademarks and registered trademarks are the property of their respective owners.
