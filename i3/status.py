#!/usr/bin/python3
# -*- coding: utf-8 -*-

from i3pystatus import Status

status = Status()
status.register("text", text="")
status.register("shell",
                command="bose_bluetooth_profile",
                ignore_empty_stdout=True,
                on_leftclick="bose_bluetooth_profile switch")
# Billy
status.register("pulseaudio",
                on_leftclick="change_sink",
                on_middleclick="pavucontrol -t 1",
                vertical_bar_width=1,
                sink="alsa_output.pci-0000_00_1f.3.analog-stereo",
                color_muted="#AAAAAA",
                format="🔊: {volume}{selected}")

# Bob
status.register("pulseaudio",
                on_leftclick="change_sink",
                on_middleclick="pavucontrol -t 1",
                vertical_bar_width=1,
                sink="alsa_output.pci-0000_00_1b.0.analog-stereo",
                color_muted="#AAAAAA",
                format="🔊: {volume}{selected}")

# USB UGREEN
status.register("pulseaudio",
                on_leftclick="change_sink",
                on_middleclick="pavucontrol -t 1",
                vertical_bar_width=1,
                sink=("alsa_output.usb-C-Media_Electronics_Inc._USB_Advanced_"
                      "Audio_Device-00.analog-stereo"),
                color_muted="#AAAAAA",
                format="🎧: {volume}{selected}")

# Bose
status.register("pulseaudio",
                on_leftclick="change_sink",
                on_middleclick="pavucontrol -t 1",
                vertical_bar_width=1,
                sink="bluez_sink.4C_87_5D_06_32_13.headset_head_unit",
                color_muted="#AAAAAA",
                format="🎧: {volume}{selected}")

status.register("pulseaudio",
                on_leftclick="change_sink",
                on_middleclick="pavucontrol -t 1",
                vertical_bar_width=1,
                sink="bluez_sink.4C_87_5D_06_32_13.a2dp_sink",
                color_muted="#AAAAAA",
                format="🎧: {volume}{selected}")

# Bar de son
status.register("pulseaudio",
                on_leftclick="change_sink",
                on_middleclick="pavucontrol -t 1",
                vertical_bar_width=1,
                sink="bluez_sink.14_BB_6E_7A_E0_86.a2dp_sink",
                color_muted="#AAAAAA",
                format="📻: {volume}{selected}")
status.register("clock", format="%a %b %d, %H:%M")
# status.register("text", text="---------------", color="#333333")
status.register("cpu_usage_graph", graph_width=5)
status.register("mem_bar")
# status.register("redshift")
status.register("dpms", format="🔳", format_disabled="🔲")
status.register("battery", interval=60, alert_percentage=3,
                format="{status}{remaining:%E%hh:%Mm} {consumption}W",
                alert=True,
                status={"DIS": "↓", "CHR": "↑", "FULL": "="},
                not_present_text="")
status.register("text", text="---------------", color="#333333")
status.register("window_title")
status.run()
