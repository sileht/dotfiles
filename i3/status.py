#!/home/sileht/.i3/venv/bin/python
# -*- coding: utf-8 -*-

from i3pystatus.mail import imap
from i3pystatus import Status
# from i3pystatus.updates import aptget
# from i3pystatus.weather import weathercom

status = Status(standalone=True)
status.register("clock", format="%a %b %d, %H:%M")

status.register("pulseaudio",
                on_leftclick="change_sink",
                sink="alsa_output.pci-0000_00_1b.0.analog-stereo",
                color_muted="#AAAAAA",
                format="🔊: {volume}{selected}")
status.register("pulseaudio",
                on_leftclick="change_sink",
                sink="alsa_output.usb-06f8_USB_Audio-00.analog-stereo",
                color_muted="#AAAAAA",
                format="🎧: {volume}{selected}")
#status.register("xkblayout", layouts=["fr", "us"])
status.register("temp")
status.register("cpu_usage_graph", graph_width=5)
status.register("battery", interval=60, alert_percentage=3,
                # {bar}",
                format="{status}{remaining:%E%hh:%Mm} {consumption}W",
                alert=True,
                status={"DIS": "↓", "CHR": "↑", "FULL": "="},
                not_present_text="")
status.register("mail",
                hide_if_null=False,
                backends=[imap.IMAP(host="mx1.sileht.net")],
                format_plural="{unread} new emails",
                on_leftclick="chromium https://m.sileht.net/")
# status.register("google_calendar",
#                credential_path="/home/sileht/.gcalcli_oauth",
#                format="{summary} ({start_time})",
#                on_leftclick="chromium {htmlLink}",
#                skip_recurring=False)
status.register("shell", command="/home/sileht/.i3/vpn-chk.sh",
                hints={"markup": "pango"},
                on_leftclick="zsh -i -c 'vpnrh'",
                on_rightclick="zsh -i -c 'novpn'")

# status.register("keyboard_locks", format="{caps}{num}",
#                 caps_on="↑", caps_off="_",
#                 num_on="❿", num_off="_")
# status.register("spotify")
# status.register("updates",
#                format="Updates: {count}",
#                format_no_updates="No updates",
#                backends=[aptget.AptGet()])
# status.register("weather", format="{icon} {current_temp}°",
#                colorize=True, backend=weathercom.Weathercom(
#                    location_code="FRXX0099:1:FR"))


status.run()
