from PySide2.QtWidgets import *
from PySide2.QtCore import *
from PySide2.QtGui import *
from PySide2.QtUiTools import QUiLoader


class DDoSMainWindowSignals(QObject):
    # custom object to store custom signals
    pass


class DDoSMainWindow(QMainWindow):
    # Custom QMainWindow Object to override UI and add some extra func.
    def __init__(self):
        QMainWindow.__init__(self)

        self.signals = DDoSMainWindowSignals()

        # Load UI and show
        designer_file = QFile("interface.ui")
        designer_file.open(QFile.ReadOnly)
        loader = QUiLoader()

        self.ui = loader.load(designer_file)
        designer_file.close()

        grid_layout = QGridLayout()
        grid_layout.addWidget(self.ui, column=0, row=0)
        self.ui.setLayout(grid_layout)

        self.ui.show()

        for i in range(4):
            for j in range(5):
                self.ui.VM_tiles.addWidget(create_tile(f"VM {i} {j}"), i, j)

        # -----------------
        # self.ui.group_homing.setEnabled(True)


def create_tile(name):

    designer_file = QFile("tile.ui")
    designer_file.open(QFile.ReadOnly)
    loader = QUiLoader()

    tile = loader.load(designer_file)
    designer_file.close()

    tile.label_vm_name.setText(name)
    return tile
