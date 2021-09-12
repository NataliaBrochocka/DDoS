from PySide2.QtCore import QCoreApplication, Qt
from PySide2.QtWidgets import QApplication

from customMainWindow import DDoSMainWindow
from http.server import HTTPServer
from basic_http_server import SimpleHTTPRequestHandler


import threading


def main():

    QCoreApplication.setAttribute(Qt.AA_ShareOpenGLContexts)
    app = QApplication([])
    window = DDoSMainWindow()

    # ------- HTTP SERVER (collect info from VMs) -------
    http_server = HTTPServer(('192.168.27.1', 8080), SimpleHTTPRequestHandler)
    http_server_thread = threading.Thread(target=http_server.serve_forever, daemon=True)
    http_server_thread.start()
    app.aboutToQuit.connect(lambda: http_server.shutdown())
    # --------------- end of HTTP SERVER ---------------

    # --------------- CONNECTIONS ---------------
    http_server.RequestHandlerClass.signals.message.connect(window.update_vm_info)
    # -------------------------------------------

    app.exec_()


if __name__ == '__main__':
    main()
