# filthmover
Sort your Porn Collection (BASH Script)

Porn is a very personal thing, and if you accumulate it, sometimes you need to sort it.
Having got fed up with a Windows based tool that was becoming a memory hog, i decided to attack this myself

The script uses lists of both performers and websites to help sort out your content
It will sort to multiple folders in the same run and download a preconfigured image file as a folder image

What can it do?
Take the following video file names for instance

Deeper.19.11.25.Naomi.Swann.And.Izzy.Lush.XXX.1080p.mp4
TushyRaw.19.11.25.Emily.Willis.And.Kendra.Spade.XXX.1080p.mp4
TeensLikeItBig.19.11.25.Gabbie.Carter.Naughty.Date.With.The.Neighbor.XXX.1080p.mp4

Lets say you are a fan of Gabbie Carter, Kendra Spade, Naomi Swan, and want to keep a collection of TeensLikeItBig
In the .list file, you have entries for Gabbie, Kendra and Naomi
In the .site file, you have an entry for TeensLikeItBig

Running the script will do the following to the files
- Move Deeper.19.11.25.Naomi.Swann.And.Izzy.Lush.XXX.1080p.mp4 to the Naomi Swan Folder
- Move TushyRaw.19.11.25.Emily.Willis.And.Kendra.Spade.XXX.1080p.mp4 to the Kendra Spade Folder
- Copy TeensLikeItBig.19.11.25.Gabbie.Carter.Naughty.Date.With.The.Neighbor.XXX.1080p.mp4 to the Gabbie Carter folder
- Move TeensLikeItBig.19.11.25.Gabbie.Carter.Naughty.Date.With.The.Neighbor.XXX.1080p.mp4 to the TeensLikeItBig folder

List Files
List files contain performer names which will be searched for within the whole file name

Site Files
Site Files contain website names will will be searched for only at the start of the file name

You need to provide either a list (or all lists option), site (or all sites option) or everything option for processing to initiate
Default:
Logging - Off
Verbose - Off
Time - files older than 7 days

You will need to edit the list or site files and update the destination folder locations to match your requirements

Usage:
  Execute the script in the folder where video files are stored with the following options
   --log -  Enable logging to "Script Folder Location"
    -v | --verbose - Enable some verbose screen logging
   -l= | --list= - The name of a performer list stored in the same folder as the script (.list)
   -s= | --site= - The name of a website collection stored in the same folder as the script (.site)
   -al | --allists - All Performer lists
   -as | --allsites - All Website Lists
   -t= | --time= - Specify the age of the files to search for, default is 7 days or older
   --everything - Processes all list files and site files found
   --test - Run through all processing, but dont do any file actions
   Anything not matched will form part of a search name either performer or site and only process the matched item.

  List will do a wild card search for the performer name in the file name
  Site will match the site name only at the start of the file name

  eg -l=us Gabbie Carter - Will process the list file us.list, but only match files for Gabbie Carter
  -s=vixen - Will process the Vixen sites
