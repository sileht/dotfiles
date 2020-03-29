#!/usr/bin/python3
# -*- coding: utf-8 -*-
# flake8: noqa: E501
"""i3pystatus configuration."""

import pulsectl

import i3pystatus

pulse = pulsectl.Pulse("i3pystatus")

status = i3pystatus.Status()

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
    color_muted="#333333",
    format=SinkFormat,
)
status.register("dpms", format="冷", format_disabled="冷", color_disabled="#333333")
status.register("text", text="|")

status.register("clock", format="%a %b %d, %H:%M")
status.register("text", text="|")

status.register(
    "network", interface="wlp1s0", format_up=" {bytes_recv}KB/s", start_color="#FFFFFF"
)


@i3pystatus.get_module
def add_battery_glyph(self):
    glyphs = "▁▂▃▄▅▆▇█"
    pos = int(self.data["percent_used_mem"] * len(glyphs) / 100)
    self.output["full_text"] += glyphs[pos]


status.register(
    "mem",
    format=" {percent_used_mem:02.1f}% ",
    divisor=1000000000,
    color="#FFFFFF",
    on_change=add_battery_glyph,
)

status.register(
    "cpu_usage_graph",
    graph_width=5,
    format="﬙ {usage:02}% {cpu_graph}",
    dynamic_color=True,
)

status.register(
    "battery",
    interval=60,
    alert_percentage=3,
    format="{glyph}{status} {remaining:%E%hh%M}/{consumption:1.0f}w",
    alert=True,
    status={"DIS": "↓", "CHR": "↑", "FULL": ""},
    glyphs="",
    not_present_text="",
)
status.register("text", text="|")
status.register("window_title")
status.run()
