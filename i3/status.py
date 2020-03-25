#!/usr/bin/python3
# -*- coding: utf-8 -*-
# flake8: noqa: E501
"""i3pystatus configuration."""

import i3pystatus
import pulsectl

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
status.register("dpms", format="DPMS", format_disabled="DPMS", color_disabled="#333333")
status.register("text", text="|")

status.register("clock", format="%a %b %d, %H:%M")
status.register("text", text="|")


status.register(
    "network",
    interface="wlp1s0",
    format_up="NET: {bytes_recv}KB/s",
    start_color="#FFFFFF",
)
status.register(
    "cpu_usage_graph",
    graph_width=5,
    format="CPU: {usage:02}% {cpu_graph}",
    dynamic_color=True,
)
status.register("mem_bar", format="{used_mem_bar}", multi_colors=True)
status.register(
    "mem", format="MEM: {used_mem}/{total_mem}GiB", divisor=1024 ** 3, color="#FFFFFF"
)
status.register("text", text="|")

# status.register("redshift")
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
status.register("text", text="|")
status.register("window_title")
status.run()
