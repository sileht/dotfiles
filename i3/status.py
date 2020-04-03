#!/usr/bin/python3
# -*- coding: utf-8 -*-
# flake8: noqa: E501
"""i3pystatus configuration."""

import fnmatch
import subprocess

import pulsectl

import i3pystatus


class CustomFormat(str):
    def __new__(cls, string, options_getter):
        o = str.__new__(cls, string)
        o.options_getter = options_getter
        return o

    def format(self, *args, **kwargs):
        kwargs.update(self.options_getter())
        return super().format(*args, **kwargs)


pulse = pulsectl.Pulse("i3pystatus")

status = i3pystatus.Status()

SINKS = {
    "alsa_output.pci-????_??_??.?.analog-stereo": "🔊 built-in",
    "alsa_output.usb-*.analog-stereo": "🎧 usb",
    "bluez_sink.??_??_??_??_??_??.headset_head_unit": "🎧 headset",
    "bluez_sink.??_??_??_??_??_??.a2dp_sink": "🎧 a2dp",
    "bluez_sink.??_??_??_??_??_??.a2dp_sink_aac": "🎧 a2dp/aac",
    "bluez_sink.??_??_??_??_??_??.a2dp_sink_sbc": "🎧 a2dp/sbc",
}  # noqa


def get_sink_options():
    default_sink_name = pulse.server_info().default_sink_name
    for sink_wilcard, label in SINKS.items():
        if fnmatch.fnmatch(default_sink_name, sink_wilcard):
            break
    else:
        label = "🔊 unknown"
    return zip(("icon", "label"), label.split())


status.register(
    "pulseaudio",
    on_leftclick="change_sink",
    on_middleclick="pavucontrol -t 1",
    vertical_bar_width=1,
    color_muted="#333333",
    format=CustomFormat("{icon} {volume}% ({label})", get_sink_options),
)
status.register("dpms", format="冷", format_disabled="冷", color_disabled="#333333")
status.register("text", text="|")

status.register("clock", format="%a %b %d, %H:%M")
status.register("text", text="|")

status.register(
    "network", interface="wlp1s0", format_up=" {bytes_recv}KB/s", start_color="#FFFFFF"
)


@i3pystatus.get_module
def add_mem_glyph(self):
    glyphs = "▁▂▃▄▅▆▇█"
    pos = int(self.data["percent_used_mem"] * len(glyphs) / 100)
    self.output["full_text"] += glyphs[pos]


status.register(
    "mem",
    format=" {percent_used_mem:02.1f}% ",
    divisor=1000000000,
    color="#FFFFFF",
    on_change=add_mem_glyph,
)


def get_cpufreq_mode():
    with open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor") as f:
        return dict(mode=f.read().strip())


def change_cpufreq_mode():
    mode = get_cpufreq_mode()["mode"]
    if mode == "powersave":
        mode = "performance"
    else:
        mode = "powersave"
    subprocess.run(
        f"sudo cpupower frequency-set -g {mode}".split(),
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


status.register(
    "cpu_freq",
    format=CustomFormat("{avgg}Ghz ({mode})", get_cpufreq_mode),
    on_leftclick=change_cpufreq_mode,
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
    alert=True,
    alert_percentage=10,
    critical_level_percentage=5,
    format="{glyph}{status} {consumption:1.0f}w {remaining:%E%hh%M}",
    status={"DIS": "", "CHR": "", "FULL": ""},
    glyphs="",
    not_present_text="",
)
status.register("text", text="|")
status.register("window_title")
status.run()
