#!/usr/bin/env bash

VOL_INC=2
VOL_MAX=130

declare -A SINK_NICKNAMES
SINK_NICKNAMES[alsa_output.usb-*]=""
SINK_NICKNAMES[alsa_output.pci-0000_00_??.?.pro-output*]="🔊"
SINK_NICKNAMES[alsa_output.pci-0000_00_??.?.analog-stereo]="🔊"
SINK_NICKNAMES[alsa_output.pci-0000_00_??.?.hdmi-stereo]=""
SINK_NICKNAMES[bluez_output.??_??_??_??_??_??.headset-head-unit*]=""
SINK_NICKNAMES[bluez_output.??_??_??_??_??_??.a2dp-sink*]="🎧"

if ! pactl info &>/dev/null; then
    echo "No pulseaudio" >&2
    exit 0;
fi

SELECTED_SINK_NAME=$(pactl info | awk -F': ' '/Default Sink/{print $2}')
SELECTED_SINK=$(pactl list sinks short | awk -v sink="$SELECTED_SINK_NAME" '{if ($2 == sink) { print $1} }')
MUTED=$(pactl list sinks | grep -A 15 "^Sink #$SELECTED_SINK" | awk '/Mute:/{print $2}')
VOLUME=$(pactl list sinks | grep -A 15 "^Sink #$SELECTED_SINK" | awk '/^\s*Volume:/{print $5}')
VOLUME=${VOLUME%*%}
VOLUME_UP=$((VOLUME + VOL_INC))
VOLUME_UP=$((VOLUME_UP > VOL_MAX ? VOL_MAX : VOLUME_UP))
VOLUME_DOWN=$((VOLUME - VOL_INC))
VOLUME_DOWN=$((VOLUME_DOWN < 0 ? 0 : VOLUME_DOWN))

output() {
    local icon="🔊? "
    for match in "${!SINK_NICKNAMES[@]}"; do
        case $SELECTED_SINK_NAME in
            $match*) icon=${SINK_NICKNAMES[$match]} ;;
        esac
    done
    if [ "$MUTED" == "yes" ]; then
        echo -n "%{F#6b6b6b}${icon}  ${VOLUME}%%{F-}"
    else
        echo -n "${icon}  ${VOLUME}%"
    fi

    glyphs="ﴐﴆﴇﴈﴉﴊﴋﴌﴍﴎﴅ"
    color_0="%{F#cc0033}"
    color_1="%{F#ffb52a}"
    color_2="%{F#ffb52a}"
    color_7="%{F#009966}"
    color_8="%{F#009966}"

    local headset_connected=
    case $SELECTED_SINK_NAME in
        bluez_output.4C_87_5D_06_32_13.*) headset_connected=1
    esac

    if [ "$headset_connected" ] ; then
        headset_file="$HOME/.headset-last-vol"

        vol=$(cat $headset_file 2>/dev/null)
        if [ "$vol" ]; then
            i=$(($vol * ${#glyphs} / 100))
            [ "$i" -eq 0 ] && i=8
            glyph=${glyphs:$i:1}
            color=$(eval echo '$color_'$i)
            echo -n "$color  $glyph ${vol}%%{F-}"
        fi
        if [ -f $headset_file ]; then
            changed_since_minutes=$(( ($(date +%s) - $(stat $headset_file -c %Y)) / 60 ))
        else
            changed_since_minutes=100
        fi
        if [ "$changed_since_minutes" -gt 10 ]; then
            based-connect -b 4C:87:5D:06:32:13 2>/dev/null > $headset_file &
        fi
    fi

    echo
}

function listen() {
    pkill pactl
    LANG=en_US pactl subscribe 2>/dev/null | while read -r event ; do
        need_refresh=$(echo "$event" | grep -e "on card" -e "on sink" -e "on server")
        [ "$need_refresh" ] && $0 output
    done
    exec $0 listen
}

case "$1" in
    volume-up) pactl set-sink-volume "${SELECTED_SINK}" "${VOLUME_UP}%" ;;
    volume-down) pactl set-sink-volume "${SELECTED_SINK}" "${VOLUME_DOWN}%" ;;
    toggle-mute)
        case $MUTED in
            yes) pactl set-sink-mute "${SELECTED_SINK}" "no" ;;
            no) pactl set-sink-mute "${SELECTED_SINK}" "yes" ;;
        esac
        ;;
    output) output ;;
    listen) output ; listen ;;
esac
