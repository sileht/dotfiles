#!/home/sileht/.i3/venv/bin/python

from i3pystatus import Status

status = Status(standalone=True)
status.register("pulseaudio", format="{volume_bar}♪",
                multi_colors=True,
                vertical_bar_width=1)
status.register("clock", format="%a %b %d, %H:%m")
status.register("weather", format="{current_temp}",
                colorize=True,
                location_code="FRXX0099:1:FR")
status.register("battery",
                format="{status}{remaining:%E%hh:%Mm} {bar} ",
                alert=True, alert_percentage=5,
                status={"DIS": "↓", "CHR": "↑", "FULL": "="},
                not_present_text="",
                )
status.register("shell", command="/home/sileht/.i3/vpn-chk.sh")
status.run()
