#!/usr/bin/python3
# -*- coding: utf-8 -*-
# flake8: noqa: E501
"""i3pystatus configuration."""

import fnmatch
import os
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

status.register("text", text=" | ")
status.register("clock", format="%a %b %d, %H:%M")
status.register("text", text=" | ")

SINKS = {
    "alsa_output.pci-????_??_??.?.analog-stereo": "🔊 built-in/analog",
    "alsa_output.pci-????_??_??.?.hdmi-stereo": "🔊 built-in/hdmi",
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
    on_leftclick="sound-controller",
    on_middleclick="pavucontrol -t 1",
    vertical_bar_width=1,
    color_muted="#333333",
    format=CustomFormat("{icon} {volume}% ({label})", get_sink_options),
)


@i3pystatus.get_module
def add_bose_battery_glyph(self):
    glyphs = "ﴐﴆﴇﴈﴉﴊﴋﴌﴍﴎﴅ"
    glyphs = ""
    try:
        level = int(self.output["full_text"])
    except ValueError:
        self.output["full_text"] = ""
        return
    pos = int(level * len(glyphs) / 100)
    self.output["full_text"] = glyphs[pos] + " " + self.output["full_text"] + "%"


status.register(
    "shell",
    ignore_empty_stdout=True,
    command="based-connect -b 4C:87:5D:06:32:13",
    on_change=add_bose_battery_glyph,
)

status.register("text", text=" | ")

status.register("dpms", format="冷", format_disabled="冷", color_disabled="#333333")

status.register(
    "battery",
    interval=60,
    # alert=True,
    alert_percentage=10,
    full_color="#FFFFFF",
    charging_color="#FFFFFF",
    critical_level_percentage=5,
    format="{status}{glyph} {percentage:1.0f}% {consumption:1.0f}w {remaining:%E%hh%M}",
    status={"DIS": "", "CHR": "", "FULL": ""},
    glyphs="",
    not_present_text="",
)


status.register("text", text=" | ")

status.register("redshift")

status.register("text", text=" | ")

for interface in os.listdir("/sys/class/net/"):
    if interface.startswith("wl"):
        status.register(
            "network",
            interface=interface,
            format_up=" {bytes_recv}KB/s",
            recv_limit="10000",
            start_color="#FFFFFF",
        )

status.register("text", text="  |  ")


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
    start_color="#FFFFFF",
)
status.run()
