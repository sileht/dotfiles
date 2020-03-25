#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""i3pystatus configuration."""

import pulsectl

import i3pystatus

pulse = pulsectl.Pulse("i3pystatus")

status = i3pystatus.Status()
status.register("text", text="")

SINKS = {
    "alsa_output.pci-0000_00_1f.3.analog-stereo": "🔊 (built-in)",  # billy/trudy
    "alsa_output.pci-0000_00_1b.0.analog-stereo": "🔊 (built-in)",  # bob
    "alsa_output.usb-C-Media_Electronics_Inc."
    "_USB_Advanced_Audio_Device-00.analog-stereo": "🎧 (usb)",
    "bluez_sink.4C_87_5D_06_32_13.headset_head_unit": "🎧 (headset)",
    "bluez_sink.4C_87_5D_06_32_13.a2dp_sink": "🎧 (a2dp)",
    "bluez_sink.4C_87_5D_06_32_13.a2dp_sink_aac": "🎧 (a2dp/aac)",
    "bluez_sink.4C_87_5D_06_32_13.a2dp_sink_sbc": "🎧 (a2dp/sbc)",
}  # noqa


class SinkFormat:
    @staticmethod
    def format(*args, **kwargs):
        default_name = SINKS.get(pulse.server_info().default_sink_name)
        output_format = "%s: {volume}{selected}" % default_name
        return output_format.format(*args, **kwargs)


status.register(
    "pulseaudio",
    on_leftclick="change_sink",
    on_middleclick="pavucontrol -t 1",
    vertical_bar_width=1,
    color_muted="#AAAAAA",
    format=SinkFormat,
)


status.register("clock", format="%a %b %d, %H:%M")
# status.register("text", text="---------------", color="#333333")
status.register("cpu_usage_graph", graph_width=5)
status.register("mem_bar")
# status.register("redshift")
status.register("dpms", format="🔳: on", format_disabled="🔳: off")
status.register(
    "battery",
    interval=60,
    alert_percentage=3,
    format=(
        "{percentage:.0f}% {glyph} "
        "{status}{remaining:%E%hh:%Mm} "
        "{consumption}W"  # noqa
    ),
    alert=True,
    status={"DIS": "↓", "CHR": "↑", "FULL": "="},
    not_present_text="",
)
# status.register("text", text="---------------", color="#333333")
status.register("window_title")
status.run()
