#!/home/sileht/.i3/venv/bin/python

from i3pystatus import Status
from i3pystatus.mail import imap
from i3pystatus.weather import weathercom
from i3pystatus.updates import aptget

status = Status(standalone=True)
status.register("online",
                format_online="●",
                format_offline="●",
                color="#00ff00",
                color_offline="#ff0000")
status.register("clock", format="%a %b %d, %H:%M")
status.register("keyboard_locks", format="{caps}{num}",
                caps_on="↑", caps_off="_",
                num_on="❿", num_off="_")
status.register("xkblayout", layouts=["fr", "en"])
#status.register("spotify")
status.register("updates",
                format = "Updates: {count}",
                format_no_updates = "No updates",
                backends=[aptget.AptGet()])
status.register("weather", format="{current_temp}°",
                colorize=True, backend=weathercom.Weathercom(
                    location_code="FRXX0099:1:FR"))
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
status.register("shell", command="/home/sileht/.i3/vpn-chk.sh",
                hints={"markup": "pango"})
status.run()
