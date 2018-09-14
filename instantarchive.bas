OPTION _EXPLICIT

' for debugging purposes:
' if you need to copy text from the console window,
' activate the following:
' $CONSOLE
' _DEST _CONSOLE

_TITLE "InstantArchive"
' _SCREENHIDE

' If you get the following error:
' File 'backup.ico' not found
' Copy the icon file to the location of qb64.exe temporarily.
' qb64.exe searches the icon file in its own directory
' instead of the project directoy.
$EXEICON:'backup.ico'


' TODO: 4 structured documentation for functions
' TODO: 5 general mac and Linux compatibility and tests
' TODO: 6 default compression options.

CALL Main
' CALL MainTest


FUNCTION CharBackslash$ ()
    ' Returns \ character.
    ' The main reason to use this function instead of a literal constant,
    ' is Vim itself.
    ' Even though BASIC is a language without escape characters,
    ' Vim renders to code as if there are escape characters.
    ' That results unbalanced and incorrect rendering.
    ' This function ensures that backslash is not used in the code.
    CharBackslash$ = CHR$(92)
END FUNCTION


FUNCTION CharFrontslash$ ()
    ' Returns / character.
    CharFrontslash$ = CHR$(47)
END FUNCTION


FUNCTION ExePath$
    ' Get path of the executable.
    ' http://www.qb64.net/wiki/index.php?title=QB64_FAQ#Q:_How_do_I_find_the_current_QB64_program_path_in_Windows_or_Linux.3F
    ' TODO: 5 integrate Linux path on the same page.

    ' Get path to executable in Windows
    DECLARE LIBRARY ' Directory Information using KERNEL32 provided by Dav
        FUNCTION GetModuleFileNameA (BYVAL Module AS LONG, FileName AS STRING, BYVAL nSize AS LONG)
    END DECLARE

    DIM fileName$
    DIM result AS INTEGER
    DIM start AS INTEGER
    DIM posit AS INTEGER
    DIM last AS INTEGER

    fileName$ = SPACE$(400) ' Sometimes 256 characters for a full path name is not enough
    result = GetModuleFileNameA(0, fileName$, LEN(fileName$)) '0 designates the current program
    IF result THEN ' Result returns the length or bytes of the string information
        ExePath$ = LEFT$(fileName$, result)
        start = 1
        DO
            posit = INSTR(start, ExePath$, CharBackslash$)
            IF posit THEN
                last = posit
            END IF
            start = posit + 1
        LOOP UNTIL posit = 0
        ExePath$ = LEFT$(ExePath$, last)
    ELSE
        ExePath$ = ""
    END IF
    fileName$ = ""
END FUNCTION


FUNCTION StartsWith% (haystack AS STRING, needle AS STRING)
    ' Returns -1 if haystack starts with needle, 0 otherwise.
    DIM result AS INTEGER
    DIM haystack2 AS STRING
    DIM needle2 AS STRING
    haystack2 = LCASE$(haystack)
    needle2 = LCASE$(needle)
    IF LEFT$(haystack2, LEN(needle2)) = needle2 THEN
        result = -1
    ELSE
        result = 0
    END IF
    StartsWith% = result
END FUNCTION


FUNCTION EndsWith% (haystack AS STRING, needle AS STRING)
    ' Returns 1 if haystack ends with needle, 0 otherwise.
    ' this function is case insensitive.
    DIM result AS INTEGER
    result = 0
    IF LCASE$(RIGHT$(haystack, LEN(needle))) = LCASE$(needle) THEN
        result = 1
    END IF
    EndsWith% = result
END FUNCTION


FUNCTION PathSeparator$
    ' Returns \ for Windows, / for Linux and Mac OS.
    DIM result AS STRING
    ' _OS$ example:
    ' [WINDOWS][32BIT]
    IF StartsWith%(_OS$, "[WINDOWS]") = -1 THEN
        result = CharBackslash$
    ELSE
        result = "/"
    END IF
    PathSeparator$ = result
END FUNCTION


FUNCTION ReplaceAll$ (haystack AS STRING, needle AS STRING, replacement AS STRING)
    ' Replaces all occurrences of needle with replacement in haystack.
    ' haystack : big text
    ' needle : old string
    ' replacement : new string to be put instead of needle
    DIM result AS STRING
    DIM position AS LONG
    DIM strBefore AS STRING
    DIM strAfter AS STRING
    result = haystack
    position = INSTR(1, result, needle)
    WHILE position
        strBefore = LEFT$(result, position - 1)
        strAfter = RIGHT$(result, ((LEN(result) - (position + LEN(needle) - 1))))
        result = strBefore + replacement + strAfter
        position = INSTR(1, result, needle)
    WEND
    ReplaceAll$ = result
END FUNCTION


FUNCTION PathCombine$ (path1$, path2$)
    ' Combines 2 paths,
    ' making sure that there is one path separator between them.
    ' This function is compatible with Windows, Linux and Mac.
    DIM result AS STRING
    DIM allReplaced AS INTEGER
    DIM len1 AS INTEGER
    DIM len2 AS INTEGER
    result = path1$ + PathSeparator$ + path2$
    result = ReplaceAll$(result, "/", CharBackslash$)
    DO
        len1 = LEN(result)
        result = ReplaceAll$(result, CharBackslash$ + CharBackslash$, CharBackslash$)
        len2 = LEN(result)
        IF len1 = len2 THEN
            allReplaced = -1
        END IF
    LOOP UNTIL allReplaced = -1

    ' at this point, all the separators are '\'
    ' convert them to "/" if the OS is not Windows:
    IF PathSeparator$ = "/" THEN
        result = ReplaceAll$(result, CharBackslash$, "/")
    END IF

    PathCombine$ = result
END FUNCTION


FUNCTION TimeStamp$
    ' Returns the timestamp as a string.
    ' example:
    ' 20170820_1720

    ' http://www.qb64.net/wiki/index.php/DATE$
    ' http://www.qb64.net/wiki/index.php/TIME$

    DIM result AS STRING
    DIM currentDate AS STRING
    DIM currentTime AS STRING

    DIM year AS STRING
    DIM month AS STRING
    DIM day AS STRING
    DIM hour_minute_second AS STRING
    DIM hour AS STRING
    DIM minute AS STRING
    DIM second AS STRING

    currentDate = DATE$
    currentTime = TIME$

    ' DATE$ is formatted as:
    ' mm-dd-yyyy
    ' 08-20-2017
    year = RIGHT$(currentDate, 4)
    month = LEFT$(currentDate, 2)
    day = MID$(currentDate, 4, 2)

    ' TIME$ is already ordered as hour:minute:second, so no need to split.
    ' simply remove : characters.
    hour_minute_second = ReplaceAll$(currentTime, ":", "")

    result = year + month + day + "_" + hour_minute_second
    TimeStamp$ = result
END FUNCTION


FUNCTION DetermineZipFileName$ (item AS STRING)
    ' Returns the zip file name to be created.
    ' item : a file or folder.
    DIM result AS STRING
    result = item
    ' result = ReplaceAll$(result, ".", "_")
    result = result + "_" + TimeStamp$ + ".zip"
    DetermineZipFileName$ = result
END FUNCTION


FUNCTION DetermineCommentFileName$ (item AS STRING)
    ' Returns the comment file name to be created.
    ' item : a file, but not a folder.
    DIM result AS STRING
    result = item
    result = result + ".txt"
    DetermineCommentFileName$ = result
END FUNCTION


FUNCTION CompressionLevelSwitch$
    ' Returns the compression level switch for 7-Zip.

    ' https://www.dotnetperls.com/7-zip-examples
    DIM result AS STRING

    'Switch -mx0: Don't compress at all.
    '             This is called "copy mode."

    'Switch -mx1: Low compression.
    '             This is called "fastest" mode.

    'Switch -mx3: Fast compression mode.
    '             Will automatically set various parameters.

    'Switch -mx5: Same as above, but "normal."

    'Switch -mx7: This means "maximum" compression.

    'Switch -mx9: This means "ultra" compression.
    '             You probably want to use this.

    result = "-mx9"
    CompressionLevelSwitch$ = result
END FUNCTION


FUNCTION SevenZipPath$
    ' Returns the absolute path to 7za.exe file.

    ' TODO: 5 7z for Linux and Mac compatibility
    DIM result AS STRING
    result = PathCombine$(ExePath$, "7z")
    result = PathCombine$(result, "7za.exe")
    SevenZipPath$ = result
END FUNCTION


FUNCTION CompressionType$
    ' Returns the compression type as a string.
    ' CompressionType$ = "-t7z"
    CompressionType$ = "-tzip"
END FUNCTION


SUB BackupItem (item AS STRING)
    ' Actually backups the item.
    ' item : a file or folder.

    ' https://www.dotnetperls.com/7-zip-examples

    ' in our current algorithm,
    ' file or directory does not matter for 7z.
    ' they are both zipped using the same command.
    ' if a difference is required, _FILEEXISTS and _DIREXISTS can be used.

    DIM zipFileName AS STRING
    DIM q AS STRING
    zipFileName = DetermineZipFileName$(item)
    PRINT zipFileName

    q = CHR$(34)
    DIM cmd AS STRING
    ' TODO: 4 check if it works when instantarchive.exe is placed to a folder with spaces.
    ' TODO: 4 same test should be done with files with spaces to backup.
    ' could not surround SevenZipPath$ with q, it gives an error after the call.
    cmd = SevenZipPath$ + " a " + CompressionType$ + " " + CompressionLevelSwitch$ + " " + q + zipFileName + q + " " + q + item + q
    PRINT cmd
    SHELL cmd
END SUB


FUNCTION IsBackupFile% (fileName AS STRING)
    ' Returns 1 if the file is a backup file created by InstantArchive, 0 otherwise.
    ' TODO: 4 FUNCTION IsFileZipped% (filename AS STRING)
    ' sample file name:
    '          1         2
    ' 12345678901234567890123456789
    ' file1.bas_20170904_202048.zip
    ' 98765432109876543210987654321
    '          2         1

    DIM result AS INTEGER
    result = 1

    DIM temp AS STRING
    ' unify the extensions for easy detection
    temp = ReplaceAll$(fileName, ".7z", ".zip")

    ' check the file extension
    IF EndsWith%(temp, ".zip") = 0 THEN
        result = 0
    END IF

    ' check the first _
    IF result = 1 THEN
        temp = RIGHT$(temp, 20)
        ' temp -> _20170904_202048.zip

        IF LEFT$(temp, 1) <> "_" THEN
            result = 0
        END IF
    END IF

    ' check the last _
    IF result = 1 THEN
        IF MID$(temp, 10, 1) <> "_" THEN
            result = 0
        END IF
    END IF

    ' replace _ and numbers to see if there is anything left.
    IF result = 1 THEN
        temp = ReplaceAll$(temp, ".zip", "")
        temp = ReplaceAll$(temp, "_", "")
        temp = ReplaceAll$(temp, "0", "")
        temp = ReplaceAll$(temp, "1", "")
        temp = ReplaceAll$(temp, "2", "")
        temp = ReplaceAll$(temp, "3", "")
        temp = ReplaceAll$(temp, "4", "")
        temp = ReplaceAll$(temp, "5", "")
        temp = ReplaceAll$(temp, "6", "")
        temp = ReplaceAll$(temp, "7", "")
        temp = ReplaceAll$(temp, "8", "")
        temp = ReplaceAll$(temp, "9", "")

        IF LEN(temp) <> 0 THEN
            result = 0
        END IF

    END IF

    IsBackupFile% = result
END FUNCTION


SUB OpenTextEditor (fileName AS STRING)
    ' Opens the file with default text editor.
    DIM operatingSystem AS STRING
    operatingSystem = DetectOs$
    IF operatingSystem = "windows" THEN
        SHELL _DONTWAIT "notepad " + CHR$(34) + fileName + CHR$(34)
    ELSEIF operatingSystem = "debian" THEN
        ' TODO: 6 OpenTextEditor() Debian compatibility
    ELSEIF operatingSystem = "macosx" THEN
        ' TODO: 6 OpenTextEditor() Mac OS x compatibility
    END IF
END SUB


SUB AddCommentsForFile (backupFileName AS STRING)
    ' Saves user comments to a file.
    DIM commentFileName AS STRING ' the file to contain comments.
    DIM fileHandle AS INTEGER

    commentFileName = DetermineCommentFileName(backupFileName)

    ' enter the name of the backup file to the comment file.
    fileHandle = FREEFILE
    OPEN commentFileName FOR APPEND AS #fileHandle
    PRINT #fileHandle, commentFileName
    CLOSE #fileHandle

    OpenTextEditor (commentFileName)
END SUB


FUNCTION DetectOs$ ()
    ' Detects the operating system and returns a string accordingly.
    ' For Windows : "windows"
    ' Note that the strings in BuildShellCommand$ and DetectOs$()
    ' must be compatible.
    ' If one of them is modified, the other must be modified too.

    ' TODO: 5 Linux and Mac Support
    DIM result AS STRING
    IF ENVIRON$("windir") <> "" THEN
        result = "windows"
    END IF
    DetectOs$ = result
END FUNCTION


SUB PressAnyKey
    ' Spin-waits until a key is pressed.
    DO
        ' wait for a second
        SLEEP 1
    LOOP UNTIL INKEY$ <> ""
END SUB


SUB DisplayHelp

    DIM pressedkey AS STRING
    DIM cmd AS STRING

    COLOR 9, 1
    PRINT "InstantArchive                                                                   "
    COLOR 7, 0
    PRINT
    PRINT "Instantly backup files and folders with timestamp and compression without configuration."
    CALL PressAnyKey

    ' TODO: 6 more display info needed.
END SUB


SUB Main
    ' Program starts here.
    DIM i AS INTEGER
    DIM item AS STRING

    IF _COMMANDCOUNT = 0 THEN
        CALL DisplayHelp
    ELSE
        FOR i = 1 TO _COMMANDCOUNT
            item = COMMAND$(i)
            IF item = "/help" OR item = "/?" THEN
                CALL DisplayHelp
            ELSE
                IF IsBackupFile%(item) = 1 THEN
                    ' this is a backup file already.
                    ' get user comments and save them to a separate file.
                    CALL AddCommentsForFile(item)
                ELSE
                    ' backup this file.
                    CALL BackupItem(item)
                END IF
            END IF
        NEXT
    END IF

    ' passes press any key to continue
    SYSTEM
END SUB


SUB MainTest
    ' Just a function for debugging purposes.
    ' DIM tempFileName AS STRING

    'tempFileName = "C:\temp\file1.txt"
    'CALL BackupItem(tempFileName)

    'tempFileName = "C:\temp\folder1"
    'CALL BackupItem(tempFileName)
END SUB
