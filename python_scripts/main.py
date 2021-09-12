from PySide2.QtCore import QCoreApplication, Qt
from PySide2.QtWidgets import QApplication

from customMainWindow import DDoSMainWindow


def main():

    QCoreApplication.setAttribute(Qt.AA_ShareOpenGLContexts)
    app = QApplication([])
    window = DDoSMainWindow()
    app.exec_()


if __name__ == '__main__':
    main()
