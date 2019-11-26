#! /bin/bash
#
# Porn Processing Script
# read list of stars and folders from file and search source path and move files older than specified age
#
# Run this script while in the folder where the files are
# 
# ToDo
# Command Line entry to 
#  - pass performer name for single performer sorting (must exist in sort list)
#  - change age of files
#  - reget image if size = 0

#VERSION=20191121.001

#Filth List Format
# The list file needs a blank line at the end (or the last entry wont be processed)
# The file should not be modified in Windows as CR/LF characters will break it
#Performer,Storage Location,Folder Image Source
#Blue Angel,/storage/filth/Stars/Sorted/Hungary/Blue Angel (Hungary),http://www.iafd.com/graphics/headshots/blueangel_f_odette-048.jpg
#Rae Lil Black,/storage/filth/Sorted/US/Rae Lil Black (US),http://www.iafd.com/graphics/headshots/raelilblack_f_4.jpg


# Default values of arguments

LOG_PATH="`dirname \"$0\"`"\filthmover.log
LOGGING="OFF"
FILEAGE=7
TESTMODE="FALSE"

####################  FUNCTIONS  ###########################

function log()
{
   CURTIME=$(date)
  if [ $LOGGING = "ON" ]
	  then
    if [ ! "$1" == "" ]
       then
		      echo "$CURTIME - $1" >> $LOG_PATH
          echo "$CURTIME - $1"              
    fi
  fi
}

function findbuilder()
{
    if [[ "$2" == "list" ]] 
        then    
           Perf=("$1")
           FullName=`echo ${Perf//[[:space:]]/}`
           
           FILEFINDER="find . -maxdepth 1 -type f -mtime +$FILEAGE -iname $FullName\* -o -iname \*$FullName\* -o -iname \"*"
                 
           PARMS=1
           for i in $Perf; do
                FILEFINDER+="$i"
                if [ $PARMS -lt `wc -w <<< $Perf` ]
                   then
                       FILEFINDER="$FILEFINDER?"
                   else
                       FILEFINDER="$FILEFINDER*\""
                   fi
                PARMS=$((PARMS + 1))
           done              
    fi
    
    if [[ "$2" == "site" ]] 
        then    
           FILEFINDER="find . -mtime +$FILEAGE -iname $1*"
    fi
}

function performerlists()
{
#    exec < $1 || exit 1
#    read header # read (and ignore) the first line
#    while IFS=$'\n' read -r line_data; do   
#      PerformerList[$PerformerCount]="`echo $line_data | sed 's/^ *//;s/ *$//;s/  */ /;'`"
#      #PerformerList[$PerformerCount]="${line_data}"
#      ((PerformerCount++))
#    done < $1

    if [[ "$1" == *"list"* ]]
       then
          SEARCHTYPE="list"
    fi          

    if [[ "$1" == *"site"* ]]
       then
          SEARCHTYPE="site"
    fi

    while IFS= read -r line_data; do   
      PerformerList[$PerformerCount]="`echo $line_data | sed 's/^ *//;s/ *$//;s/  */ /;'`"",$SEARCHTYPE"
      ((PerformerCount++))
      
    done < <(tail -n +2 $1)            
         
}

function verbose()
{
  [[ -v $VERBOSE ]]; echo -e $1

}

function usage()
{
      echo "Usage:"
      echo "  Execute the script in the folder where video files are stored with the following options"
      echo "   --log -  Enable logging to "`dirname \"$0\"`"\filthmover.log"
      echo "    -v | --verbose - Enable some verbose screen logging"
      echo "   -l= | --list= - The name of a performer list stored in the same folder as the script (.list)"
      echo "   -s= | --site= - The name of a website collection stored in the same folder as the script (.site)"
      echo "   -al | --allists - All Performer lists"
      echo "   -as | --allsites - All Website Lists"
      echo "   -t= | --time= - Specify the age of the files to search for, default is 7 days or older"
      echo "   --everything - Processes all list files and site files found"
      echo "   --test - Run through all processing, but dont do any file actions"
      echo -e "   Anything not matched will form part of a search name either performer or site and only process the matched item.\n"
      echo "  List will do a wild card search for the performer name in the file name"
      echo -e "  Site will match the site name only at the start of the file name\n"
      echo "  eg -l=us Gabbie Carter - Will process the list file us.list, but only match files for Gabbie Carter"
      echo "  -s=vixen - Will process the Vixen sites"  
  
      exit 1
}

# Configuration Processing

#   If run without any command line paramaters it will show usage
#   The command line must include either a -l or --list or -s or --site or there is nothing to do
#

CMDLINE="BAD"
VERBOSE="FALSE"
PERFORMERCOUNT=0
MOVEDFILES=0
MOVEDFILELIST=()
SINGLESTAR=""
MATCHFOUND=true
RUNLOCATION="`dirname \"$0\"`"

# Check there are some arguments or show usage

if [ $# = 0 ]
  then
      Usage
fi

# Loop through arguments and process them

for arg in "$@"
do
    case $arg in
        --log)
        LOGGING=ON
        shift # Remove --log from processing
        ;;

        -v|--verbose)
        VERBOSE=ON
        shift
        ;;

        -l=*|--list=*)
        FILTHLIST="$RUNLOCATION/${arg#*=}.list"
        CMDLINE="OK"
        performerlists $FILTHLIST
        MATCHFOUND=true
        shift # Remove --list= from processing
        ;;

        -s=*|--site=*)
        FILTHLIST="$RUNLOCATION/${arg#*=}.site"
        CMDLINE="OK"
        performerlists $FILTHLIST
        MATCHFOUND=true
        shift # Remove --site= from processing
        ;;

        -al|--allists)
        # find all lists in the runfolder
        # clear array (incase -i had preceeded)
        CMDLINE="OK"
        PERFORMERCOUNT=0
        unset PerformerList
        PerformerFiles=`find $RUNLOCATION -name *.list`
        FILTHLIST=$PerformerFiles
        for file in $PerformerFiles;
             do
             performerlists $file
        done      
        shift   
        ;;

        -as|--allsites)
        # find all lists in the runfolder
        # clear array (incase -i had preceeded)
        CMDLINE="OK"
        PERFORMERCOUNT=0
        unset PerformerList
        PerformerFiles=`find $RUNLOCATION -name *.site`
        FILTHLIST=$PerformerFiles
        for file in $PerformerFiles;
             do
             performerlists $file
        done      
        shift   
        ;;

        -t=*|--time=*)
        FILEAGE="${arg#*=}"
        shift # Remove --time= from processing
        ;;
        
        --everything)
        # find all lists in the runfolder
        # clear array (incase -i had preceeded)
        CMDLINE="OK"
        PERFORMERCOUNT=0
        unset PerformerList
        PerformerFiles=`find $RUNLOCATION -name *.list -o -name *.site`
        FILTHLIST=$PerformerFiles
        for file in $PerformerFiles;
             do
             performerlists $file
        done      
        shift   
        ;;
        
        --test)
        TESTMODE=TRUE
        shift
        ;;
        
        *)
        SINGLESTAR+=("$1")
        MATCHFOUND=false
        shift # Remaining arguments are the single performer name
        ;;
    esac
done

if [ "$CMDLINE" == "BAD" ]
     then
         echo "Missing a list or site file to check"
         usage
fi


if [ "${SINGLESTAR[*]}" != "" ]
    then
         IFS=' ' read SINGLESTAR <<<"${SINGLESTAR[*]}"  #Remove leading and trailing spaces
fi

verbose "# COMMANDLINE: $@"
verbose "#     LOGGING: $LOGGING"
verbose "#    TESTMODE: $TESTMODE"
verbose "#     VERBOSE: $VERBOSE"
verbose "#   List File: $FILTHLIST"
verbose "#    File Age: $FILEAGE"
verbose "#   Performer: '$SINGLESTAR'"



verbose "Found $PerformerCount performers"
verbose "There are ${#PerformerList[@]} performers in list"

# Remove Duplicates
IFS=$'\n' PerformerList=($(sort -u <<<"${PerformerList[*]}")); unset IFS
verbose "There are ${#PerformerList[@]} performers in unique list"
printf "[P %s]\n" "${PerformerList[@]}"
   
# Main Processing

Counter=0
while [ $Counter -le ${#PerformerList[@]} ]; do
    
    IFS=, read Performer StoreLocation FolderImage ListType <<< ${PerformerList[$Counter]}
    
    findbuilder "$Performer" "$ListType"
    
    if [ "$SINGLESTAR" != "" ]
       then
          if [ "$Performer" =  "$SINGLESTAR" ]
              then
                   verbose "Found Match while Checking ${PerformerName[*]} against Command Line: $SINGLESTAR"
                   MATCHFOUND=true
          fi
    fi

       
#    if [ ${#PerformerList[*]} != 0 -a $MATCHFOUND == true ]
    verbose "$Performer"
    
    if [ "$Performer" != "" -a $MATCHFOUND == true ]
      then
         log "Processing: $Performer into $StoreLocation and obtaining $FolderImage if required"
         
         unset FILEZ
         FILECOUNT=0
     
         verbose "Run Command is : $FILEFINDER | wc -l"
      
         set -o noglob
         FILESFOUND=`eval $FILEFINDER | wc -l`
         verbose "Found $FILESFOUND"
         
             if [ $FILESFOUND -gt 0 ] 
                  then
                  i=1
                  while [ $i -le $FILESFOUND ]; do
  	                FILEZ[$FILECOUNT]=`pwd``eval $FILEFINDER | grep -E "\.webm$|\.flv$|\.vob$|\.ogg$|\.ogv$|\.drc$|\.gifv$|\.mng$|\.avi$|\.mov$|\.qt$|\.wmv$|\.yuv$|\.rm$|\.rmvb$|/.asf$|\.amv$|\.mp4$|\.m4v$|\.mp4$|\.m?v$|\.svi$|\.3gp$|\.flv$|\.f4v$" | sort | sed -n ''$i'p' | sed 's/^\.//'`,$StoreLocation
                    ((i++))
                    ((FILECOUNT++))
                  done
              fi
         
         # Debug - print array contents
         printf '%s\n' "${FILEZ[@]}"
 
         # Transfer the files found into the master file list                 
         for val in "${FILEZ[@]}"
           do 
                MOVEDFILELIST+=("$val")              
           done
     
         log "Found $FILECOUNT files to move"
         MOVEDFILES=$(($MOVEDFILES+$FILECOUNT))
         
    if [ "$TESTMODE" == "FALSE" ]
    then        
         # Only process if files found
         if [ $FILECOUNT != 0 ] 
           then
           # Check for directory
              if [ ! -d  "$StoreLocation" ]
                 then 
         		  	   mkdir -p "$StoreLocation"
                   log "Creating Folder"
          			   if [ $? -gt 0 ]
	  			           then
		  		             log "Cannot create destination folder $StoreLocation.  Exiting"
			  	             end 2
                     else
                        chmod 777 "$StoreLocation"
			             fi
              fi             
         
           # Check for Folder image
             if [ ! -s "$StoreLocation/folder.jpg" -a "$FolderImage" != "" ]
                then
                log "Fetching $FolderImage"
                if [ -f "$FolderImage" ]
                   then
                     cp  "$FolderImage" "$StoreLocation/folder.jpg"
                   else   
                     wget --quiet -O "$StoreLocation/folder.jpg" "$FolderImage"
                   fi         
                fi
             fi
          fi
    fi               

                 
    if [ "$SINGLESTAR" != "" ]
       then
          MATCHFOUND=false
    fi
    ((Counter++))
done 


IFS=$'\n' FULLLIST=($(sort <<<"${MOVEDFILELIST[*]}")); unset IFS
echo "Full Sorted File List"
printf "[F %s]\n" "${FULLLIST[@]}"

# Read thru the list and check if the next array item is identical
# If the item isnt identical, the file can be moved
# if it is, it needs to be copied.

count=0
multi=0

while [ $count != $MOVEDFILES ]
do
   nxt=$count+1
   IFS=,
   read FILETOMOVE FILELOCATION <<< ${FULLLIST[$count]}
   read NEXTFILE NEXTFILELOCATION <<< ${FULLLIST[$nxt]}

   FILETOMOVE=`echo "$FILETOMOVE"`
   NEXTFILE=`echo "$NEXTFILE"`
   
#   verbose "Cur $FILETOMOVE \n"
#   verbose "Nxt $NEXTFILE \n"

   if [ "$TESTMODE" == "FALSE" ]
    then 
        verbose "F [$FILETOMOVE]"
        verbose "N [$NEXTFILE]"
        
        if [ "$FILETOMOVE" = "$NEXTFILE" ]
           then
               PROCESS=COPY
        fi

        if [ "$FILETOMOVE" != "$NEXTFILE" ]
           then
               PROCESS=MOVE
        fi
  
     echo Process is : $PROCESS
   
     case $PROCESS in
       COPY)
               echo "Copying $FILETOMOVE to $FILELOCATION"
               rsync --info=progress2 -t "$FILETOMOVE" "$FILELOCATION"      
       ;;
       MOVE)
               echo "Moving $FILETOMOVE to $FILELOCATION"
               mv -v "$FILETOMOVE" "$FILELOCATION"      
       ;;
     esac
   fi
   count=$(( $count + 1 ))
done

echo "$MOVEDFILES processed in this run"
log "$MOVEDFILES moved in this run"
