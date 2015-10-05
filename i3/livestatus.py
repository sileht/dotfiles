from i3pystatus import IntervalModule
from i3pystatus.core.util import internet, require

from urllib.parse import urlparse
import socket

from paramiko import SSHClient, AutoAddPolicy


class Livestatus(IntervalModule):
    """
    This module gets the nagios status via livestatus

    .. rubric:: Available formatters

    """

    interval = 30

    settings = (
        ("url", ("Location of livestatus ("
                 "file:///var/lib/nagios/rw/live, "
                 "ssh://foo@foobar:222/var/lib/nagios/rw/live, "
                 "tcp://foobar:1324"
                 ")")),
        ("query", "Livestatus query"),
        ("separator_format", "Separator between query result"),
        ("item_format", "Format of one result"),
        ("max_items", "Maximun number of items to show"),
        "format",
    )
    url = 'file:///var/lib/nagios/rw/live'
    query = """GET hosts
Filter: state >= 1
Filter: acknowledged = 0
Limit: 1
Columns: name
ColumnHeaders: on

    """

    max_items = None
    separator_format = ", "
    item_format = "{name}"
    format = "{count} hosts: {items}"

    def _read(self, method, initial):
        size = 16384
        data = '*' * size
        reply = initial
        while len(data) == size:
            data = method(size)
            reply += data
        return reply

    def fetch_livestatus_from_socket(self, url_parsed, query):
        if url_parsed.scheme == "tcp":
            try:
                ip = socket.gethostbyname(url_parsed.hostname)
            except socket.gaierror:
                return {'error': 'resolv failure'}
            location = (ip, url_parsed.port)
        else:
            location = url_parsed.path

        s = None
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect(location)
            s.sendall(query.encode('utf-8'))
            reply = self._read(s.recv, b'')
        except socket.error:
            raise Exception('livestatus connection fails')
        finally:
            if s is not None:
                s.close()
        return reply.decode("utf-8")

    def fetch_livestatus_from_ssh(self, url_parsed, query):
        client = SSHClient()
        client.load_system_host_keys()
        client.set_missing_host_key_policy(AutoAddPolicy())
        client.connect(url_parsed.hostname,
                       port=url_parsed.port,
                       username=url_parsed.username,
                       password=url_parsed.password)
        stdin, stdout, stderr = client.exec_command(
            'unixcat %s' % url_parsed.path)
        stdin.write(query)
        reply = self._read(stdout.read, '')
        client.close()
        return reply

    def fetch_livestatus(self, query):
        '''Fetch livestatus report.'''

        url_parsed = urlparse(self.url)

        if url_parsed.scheme in ["tcp", "file"]:
            return self.fetch_livestatus_from_socket(url_parsed, query)
        elif url_parsed.scheme == "ssh":
            return self.fetch_livestatus_from_ssh(url_parsed, query)
        else:
            raise Exception('url scheme not supported')

    def parse_result(self, result):
        result = result.split("\n")
        cols = result[0].split(";")
        parsed = []
        for row in result[1:]:
            if not row.strip():
                continue
            parsed.append(dict(zip(cols, row.split(";"))))
        return parsed

    @require(internet)
    def run(self):
        items = self.parse_result(self.fetch_livestatus(
            self.query.strip() + "\nColumnHeaders: on\n\n"))

        if self.max_items:
            items_subset = items[:self.max_items]
        else:
            items_subset = items
        items_formatted = self.separator_format.join(
            [self.item_format.format(**r) for r in items_subset])
        if not items:
            items_formatted = "n/a"
        elif self.max_items and items_subset != items:
            items_formatted += ", ..."
        self.output = {"full_text": self.format.format(
            count=len(items), items=items_formatted)}
