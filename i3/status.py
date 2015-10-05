#!/home/sileht/.i3/venv/bin/python

from i3pystatus import Status

status = Status(standalone=True)
status.register("clock", format="%a %b %d, %H:%M")
status.register("weather", format="{current_temp}",
                colorize=True,
                location_code="FRXX0099:1:FR")
status.register("battery",
                format="{status}{remaining:%E%hh:%Mm}",
                alert=True, alert_percentage=5,
                status={"DIS": "↓", "CHR": "↑", "FULL": "="},
                not_present_text="",
                )
status.register("shell", command="/home/sileht/.i3/vpn-chk.sh",
                hints={"markup": "pango"})


status.register("livestatus",
                web_url="https://nagios.tetaneutral.net/check_mk/index.py?start_url=view.py%3Fselection%3D28fa9e16-bac7-40ad-b72c-18731527457d%26hst2%3D%26hst1%3D%26hst0%3Don%26is_service_acknowledged%3D0%26host_tag_2_op%3D%26st0%3D%26st1%3Don%26host_tag_2_grp%3D%26st3%3Don%26hdst2%3Don%26st2%3Don%26hstp%3Don%26neg_opthost_group%3D%26is_in_downtime%3D0%26host_tag_0_op%3D%26host_tag_2_val%3D%26host_tag_0_grp%3D%26host_tag_0_val%3D%26service_regex%3D%26host_tag_1_op%3D%26hdstp%3Don%26host_tag_1_grp%3D%26is_summary_host%3D0%26opthost_group%3Dall_without_tsf%26view_name%3Dsvcproblems%26stp%3D%26hdst3%3Don%26hdst0%3Don%26hdst1%3Don%26host_tag_1_val%3D%26is_service_in_notification_period%3D-1",  # noqa
                url="tcp://localhost:6557",
                format="S: {items}",
                max_items=5,
                item_format=("<span color=\"{state_color}\">"
                             "{host_name}: {description}</span>"),
                query="""
GET services
Filter: last_hard_state > 0
Filter: acknowledged = 0
Filter: description !~~ ^(Check_MK inventory|PING)
Filter: host_name !~~ ^(tsf-|pingall)
Columns: host_name description state
""")
status.register("livestatus",
                web_url="https://nagios.tetaneutral.net/check_mk/index.py?start_url=%2Fcheck_mk%2Fview.py%3Fselection%3D7a41bc3b-6d91-4cef-8cb4-0de99da1db26%26is_host_scheduled_downtime_depth%3D0%26hstp%3D%26is_host_acknowledged%3D0%26hst2%3Don%26hst1%3Don%26hst0%3D%26is_summary_host%3D0%26opthost_group%3Dall_without_tsf%26view_name%3Dhostproblems%26neg_opthost_group%3D%26is_host_in_notification_period%3D-1%26host_regex%3D",  # noqa
                url="tcp://localhost:6557",
                max_items=5,
                format="H: {items}",
                item_format=("<span color=\"{state_color}\">"
                             "{name}</span>"),
                query="""
GET hosts
Filter: last_hard_state > 0
Filter: acknowledged = 0
Filter: name !~~ ^(tsf-|pingall)
Columns: name state
""")


status.run()
