#!/usr/bin/env python

from urlparse import parse_qs
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from gntp import notifier

class IrssiListener(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.getheader('Content-Length'))
        args = parse_qs(self.rfile.read(length))
        for k,v in args.iteritems():
            args[k] = v[0]
        growler.alert(**args)

class IrssiGrowler:
    def __init__(self):
        self.growl = notifier.GrowlNotifier(
            applicationName = "Irssi Growl Tunnel",
            notifications = [ "Channel Messages",
                "Highlights", "Private Messages" ],
            defaultNotifications = [ "Highlights", "Private Messages" ]
        )
        self.growl.register()

    def alert(self, title, message, alertType="Highlights", sticky=False):
        self.growl.notify(
            noteType = alertType,
            title = title,
            description = message,
            icon = "./irssi-icon.png",
            sticky = sticky,
            priority = 1
        )

if __name__ == '__main__':
    growler = IrssiGrowler()
    server = HTTPServer(('localhost', 55573), IrssiListener)
    server.serve_forever()