#!/usr/bin/python3
# -*- coding: utf-8 -*-
# flake8: noqa: E501
"""i3pystatus configuration."""

import fnmatch

import pulsectl

import i3pystatus

pulse = pulsectl.Pulse("i3pystatus")

status = i3pystatus.Status()

SINKS = {
    "alsa_output.pci-????_??_??.?.analog-stereo": "🔊 (built-in)",
    "alsa_output.usb-*.analog-stereo": "🎧 (usb)",
    "bluez_sink.??_??_??_??_??_??.headset_head_unit": "🎧 (headset)",
    "bluez_sink.??_??_??_??_??_??.a2dp_sink": "🎧 (a2dp)",
    "bluez_sink.??_??_??_??_??_??.a2dp_sink_aac": "🎧 (a2dp/aac)",
    "bluez_sink.??_??_??_??_??_??.a2dp_sink_sbc": "🎧 (a2dp/sbc)",
}  # noqa


class SinkFormat:
    @staticmethod
    def format(*args, **kwargs):
        default_sink_name = pulse.server_info().default_sink_name
        for sink_wilcard, label in SINKS.items():
            if fnmatch.fnmatch(default_sink_name, sink_wilcard):
                break
        else:
            label = "🔊 (unknown)"
        output_format = "%s: {volume}%%" % label
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
