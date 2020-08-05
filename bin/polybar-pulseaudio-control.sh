#!/usr/bin/env bash

#
#import fnmatch
#import sys
#
#import pulsectl
#
#SINKS = {
#      "alsa_output.pci-????_??_??.?.analog-stereo": "🔊 built-in/analog",
#      "alsa_output.pci-????_??_??.?.hdmi-stereo": "🔊 built-in/hdmi",
#      "alsa_output.usb-*.analog-stereo": "🎧 usb",
#      "bluez_sink.??_??_??_??_??_??.headset_head_unit": "🎧 headset",
#      "bluez_sink.??_??_??_??_??_??.a2dp_sink": "🎧 a2dp",
#      "bluez_sink.??_??_??_??_??_??.a2dp_sink_aac": "🎧 a2dp/aac",
#      "bluez_sink.??_??_??_??_??_??.a2dp_sink_sbc": "🎧 a2dp/sbc",
#} # noqa
#
#pulse = pulsectl.Pulse("polybar")
#
#print(dir(pulse.server_info()))
#def get_sink_options():
#  default_sink_name = pulse.server_info().default_sink_name
#  for sink_wilcard, label in SINKS.items():
#      if fnmatch.fnmatch(default_sink_name, sink_wilcard):
#          break
#  else:
#      label = "🔊 unknown"
#  return zip(("icon", "label"), label.split())
#
#
#
#sys.exit(0)
#

mode=$1
shift
source ~/.zinit/plugins/marioortizmanero---polybar-pulseaudio-control/pulseaudio-control.bash

declare -A SINK_NICKNAMES
SINK_NICKNAMES[alsa_output.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo]="🎧 (usb)"
SINK_NICKNAMES[alsa_output.pci-0000_00_1f.3.analog-stereo]="🔊 (built-in/analog)"
SINK_NICKNAMES[alsa_output.pci-0000_00_1f.3.hdmi-stereo]="🔊 (built-in/hdmi)"
SINK_NICKNAMES[bluez_sink.4C_87_5D_06_32_13.headset_head_unit]="🎧 (headset)"
SINK_NICKNAMES[bluez_sink.4C_87_5D_06_32_13.a2dp_sink]="🎧 (a2dp)"
SINK_NICKNAMES[bluez_sink.4C_87_5D_06_32_13.a2dp_sink_aac]="🎧 (a2dp/aac)"
SINK_NICKNAMES[bluez_sink.4C_87_5D_06_32_13.a2dp_sink_sbc]="🎧 (a2dp/sbc)"


MAX_VOL=130  # Maximum volume
MUTED_ICON=""
NOTIFICATIONS="no"
#VOLUME_ICONS=("🕨 " "🕩 " "🕪 " "🕪 ")
#VOLUME_ICONS=(" " "" " " " ")

SINK_ICON=""

case "$mode" in
    up)
        volUp
        ;;
    down)
        volDown
        ;;
    togmute)
        volMute toggle
        ;;
    mute)
        volMute mute
        ;;
    unmute)
        volMute unmute
        ;;
    sync)
        volSync
        ;;
    listen)
        pkill pactl
        listen
        ;;
    next-sink)
        nextSink
        ;;
    output)
        output
        ;;
    *)
        usage
        ;;
esac
