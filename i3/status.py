#!/home/sileht/.i3/venv/bin/python

from i3pystatus import Status

status = Status(standalone=True)

status.register("clock", format="%A %d %b %T")
status.register("weather", format="{current_temp}",
                colorize=True,
                location_code="FRXX0099:1:FR")
status.register("network", interface="wlan0",
                format_up="{essid} {quality:.1f}%",)
status.register("runwatch", name="VPN", path="/var/run/openvpn/redhat.pid")
status.register("load", format="⚙:{avg5}")
status.register("pulseaudio", format="♪ {volume}",)
status.register("battery",
                format=("{status}{consumption:.2f}W "
                        "{percentage:.2f}% "
                        #"{percentage_design:.2f}% "
                        "{remaining:%E%hh:%Mm}"),
                alert=True, alert_percentage=5,
                status={"DIS": "↓", "CHR": "↑", "FULL": "="},
                not_present_text="",
                )

#status.register("mpd",
#                format="{title}{status}{album}",
#                status={
#                    "pause": "▷",
#                    "play": "▶",
#                    "stop": "◾",
#                },)

status.run()
