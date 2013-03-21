#!/bin/bash

#
#       cping is a bash script that visualize the ping in a differnt manner.
#
#       Copyright (C) 2013 Clemente di Caprio
#
#       This program is free software: you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by the
#       Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#       without even the implied warranty of MERCHANTABILITY or
#       FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License along with this program.
#       If not, see http://www.gnu.org/licenses/.
#
#       [Clem 29012013] new parameters can set the lower and upper value treshold of ping responce
#                       default is 100ms to 200ms. In case of incorrect parameters the program assume
#                       upper limit twise the lower.
#
#       [Clem 21032013] now we can interact with the script using the Q key to quit the program and
#                       using the p key to pause the command so you can scroll back the history.
#


hash tput &> /dev/null
if [ $? -eq 1 ]; then
    echo >&2 "ERROR: tput not found."
    exit 1;
fi

function int_handler {
        echo
        end=$(date '+%Y-%m-%d %T' )
        ((success=ok*100 / i ))
        ((loss=notok*100 / i ))
        echo "$Bold % $success success... % $loss packet loss... $BoldOff"
        echo "$Bold $i packets transmitted, $ok packet received $BoldOff"
        echo "$start - $end "
        exit
}

trap int_handler INT

[ $# -lt 2 ] && echo "usage:$0 <count> <IP_dest> [lwr ms] [upp ms]" >&2 && exit 1

Cnt=$1
Dest=$2

Lvl1=100
[ -z "$3" ] || Lvl1=$3
((Lvl2=Lvl1*2))
[ -z "$4" ] || Lvl2=$4
if [[ $Lvl1 -ge $Lvl2 ]]; then
        ((Lvl2=Lvl1*2))
fi

Bold=$(tput bold )
BoldOff=$(tput sgr0 )
Error=$(tput rev )
ErrorRed=$(tput setab 1 )
ErrorGreen=$(tput setab 2 )
ErrorYellow=$(tput setab 3 )
TmExceedBlue=$(tput setab 4 )
TmExceedPurple=$(tput setab 5 )
InvChar=$(tput setaf 0 )
ColSize=$(tput cols)
LineSize=$(tput lines)
SaveCur=$(tput sc)
RestCur=$(tput rc)
ClrEndLn=$(tput el)
ClrScrn=$(tput clear)
GotoHome=$(tput cup 0 0)
ok=0
notok=0
((ColSize=ColSize-22))
((LineSize=LineSize/2))

start=$(date '+%Y-%m-%d %T' )
echo "Sending $Cnt Ping Packets to $Dest [Lower lmt:$Lvl1 ms, Upper lmt:$Lvl2 ms]"
i=1
r=1
while ((i<=Cnt))
do
        ColSize=$(tput cols)
        ((ColSize=ColSize-22))
        LineSize=$(tput lines)
        ((LineSize=LineSize/2))
        #
        dping=$(ping -n -c 1 $Dest )
        data=$(echo $dping | grep "1 packets transmitted" )
        case "$data" in
                *100%*packet*loss*)
                        ((notok+=1))
                        if [ $notok -ge 60 ]; then
                                echo -n "$ErrorRed$InvChar!$BoldOff$ClrEndLn"
                        elif [ $notok -ge 30 ]; then
                                echo -n "$ErrorYellow$InvChar!$BoldOff$ClrEndLn"
                        elif [ $notok -ge 10 ]; then
                                echo -n "$ErrorGreen$InvChar!$BoldOff$ClrEndLn"
                        else
                                echo -n "$Error!$BoldOff$ClrEndLn"
                        fi
                        ;;
                *)      ((ok+=1))
                        trespt=$(echo "$dping" | cut -d'
' -f6 | cut -d' ' -f4 | cut -d'/' -f2 | tr -d "\n")
                        tresp=$(echo "$trespt" | cut -d'.' -f1)
                        if [ $tresp -ge $Lvl2 ]; then
                                echo -n "$TmExceedPurple.$BoldOff"
                        elif [ $tresp -ge $Lvl1 ]; then
                                echo -n "$TmExceedBlue.$BoldOff"
                        else
                                echo -n .
                        fi
                        echo -n "$SaveCur"
                        echo -n "  "
                        echo -n $trespt
                        echo -n "$RestCur"
                        ;;
        esac
        # Waiting for a character... for 1sec...
        if read -s -n 1 -t 1; then
                case $REPLY in
                        p)
                        # Pause...
                        echo -n "$SaveCur"
                        echo -n "$ErrorRed$InvChar Paused $BoldOff"
                        # Wait for any key...
                        while ( true); do
                                if read -s -n 1 -t 1; then
                                        break;
                                fi
                        done
                        echo -n "     "
                        echo -n "$RestCur"
                        ;;
                        Q)
                        # Quit...
                        break
                        ;;
                        *)
                        ;;
                esac
        fi

        if [ $(($i%$ColSize)) = 0 ]; then
                ((r+=1))
                if [ $(($r%$LineSize)) = 0 ]; then
                        echo "$Bold IP $Dest$BoldOff"
                else
                        snap=$(date '+%Y-%m-%d %T' )
                        echo " $snap"
                fi
        fi
        ((i+=1))
done

echo
end=$(date '+%Y-%m-%d %T' )
((success=ok*100 / Cnt ))
((loss=notok*100 / Cnt ))
echo "$Bold % $success success... % $loss packet loss... $BoldOff"
echo "$Bold $Cnt packets transmitted, $ok packet received $BoldOff"
echo "$start - $end "
exit
