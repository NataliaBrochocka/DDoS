from PySide2.QtCore import *

from http.server import HTTPServer, BaseHTTPRequestHandler
from io import BytesIO


class SimpleHTTPRequestHandlerSignals(QObject):
    message = Signal(bytes)


class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):

    signals = SimpleHTTPRequestHandlerSignals()

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Hello, world!')

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        self.send_response(200)
        self.end_headers()
        response = BytesIO()
        response.write(b'This is POST request. ')
        response.write(b'Received: ')
        response.write(body)
        self.signals.message.emit(body)
        self.wfile.write(response.getvalue())


if __name__ == '__main__':
    httpd = HTTPServer(('192.168.27.1', 8080), SimpleHTTPRequestHandler)
    httpd.serve_forever()
