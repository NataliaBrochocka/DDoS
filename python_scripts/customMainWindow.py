from PySide2.QtWidgets import *
from PySide2.QtCore import *
from PySide2.QtUiTools import QUiLoader

import json

MAX_TILES_IN_ROW = 4


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

        # store all tiles with VMs status
        self.tiles = {}
        self.tile_iterator = 0
        # -----------------
        # self.ui.group_homing.setEnabled(True)

    def update_vm_info(self, message):
        message = json.loads(message)

        for record in message['metrics']:
            machine_name = record['tags']['host']
            if machine_name in self.tiles:
                # update machine record

                if record['name'] == "cpu":
                    self.tiles[machine_name].label_cpu_value.setText(f"{record['fields']['usage_active']:.2f} %")
                elif record['name'] == "disk":
                    self.tiles[machine_name].label_disk_value.setText(f"{record['fields']['used_percent']:.2f} %")
                elif record['name'] == "mem":
                    self.tiles[machine_name].label_swap_value.setText(f"{record['fields']['swap_total']} B")
                elif record['name'] == "net" and record['tags']['interface'] == "enp0s3":

                    prev_b_recv = int(self.tiles[machine_name].label_recv_value.text())
                    b_recv = int(record['fields']['bytes_recv'])
                    self.tiles[machine_name].label_recv_value.setText(f"{b_recv - prev_b_recv}")

                    prev_b_sent = int(self.tiles[machine_name].label_sent_value.text())
                    b_sent = int(record['fields']['bytes_sent'])
                    self.tiles[machine_name].label_sent_value.setText(f"{b_sent-prev_b_sent}")
            else:
                # create new tile with machine name and add to GUI
                new_tile = create_tile(machine_name)
                self.ui.VM_tiles.addWidget(new_tile,
                                           int(self.tile_iterator/MAX_TILES_IN_ROW),
                                           self.tile_iterator % MAX_TILES_IN_ROW)
                self.tile_iterator = self.tile_iterator + 1
                self.tiles[machine_name] = new_tile


def create_tile(name):

    designer_file = QFile("tile.ui")
    designer_file.open(QFile.ReadOnly)
    loader = QUiLoader()

    tile = loader.load(designer_file)
    designer_file.close()

    tile.label_vm_name.setText(name)
    return tile
