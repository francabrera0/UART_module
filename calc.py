import sys
import serial
from PySide6.QtWidgets import QApplication, QWidget, QVBoxLayout, QLineEdit, QPushButton, QLabel, QComboBox
from PySide6.QtCore import Qt

PORT = '/dev/ttyUSB1'
BAUDRATE = 19200

OPERATIONS = {
    'ADD': 0x20,
    'SUB': 0x22,
    'AND': 0x24,
    'OR' : 0x25,
    'XOR' : 0x26,
    'NOR' : 0x27,
    'SRA': 0x03,
    'SRL': 0x02
}

class CalculatorApp(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Calculadora Uart-Alu')
        self.layout = QVBoxLayout()

        self.operand1_input = QLineEdit()
        self.operand2_input = QLineEdit()

        self.operation_selector = QComboBox()
        self.operation_selector.addItems(OPERATIONS.keys())

        self.result_display = QLineEdit()
        self.result_display.setReadOnly(True)

        self.calculate_button = QPushButton('Calcular')
        self.calculate_button.clicked.connect(self.send_serial_data)

        self.layout.addWidget(QLabel('Operando 1 (Hex):'))
        self.layout.addWidget(self.operand1_input)
        self.layout.addWidget(QLabel('Operando 2 (Hex):'))
        self.layout.addWidget(self.operand2_input)
        self.layout.addWidget(QLabel('Seleccione la Operación:'))
        self.layout.addWidget(self.operation_selector)
        self.layout.addWidget(self.calculate_button)
        self.layout.addWidget(QLabel('Resultado:'))
        self.layout.addWidget(self.result_display)

        self.setLayout(self.layout)

        self.serial_port = serial.Serial(PORT, BAUDRATE, timeout=1)

    def calculate_crc(self, data):
        return data ^ 0xFF

    def send_serial_data(self):
        operand1 = int(self.operand1_input.text(), 16)
        operand2 = int(self.operand2_input.text(), 16)
        operation_index = self.operation_selector.currentIndex()
        selected_operation = list(OPERATIONS.values())[operation_index]

        crc = self.calculate_crc(selected_operation ^ operand1 ^ operand2)

        data_to_send = bytes([selected_operation, operand1, operand2, crc])
        self.serial_port.write(data_to_send)

        received_data = self.serial_port.read(2)
        if len(received_data) == 2:
            received_result, received_crc = received_data
            calculated_crc = self.calculate_crc(received_result)
            if received_crc == calculated_crc:
                result = int.from_bytes(bytes([received_result]), byteorder='big')
                self.result_display.setText(hex(result))
            else:
                self.result_display.setText("Error de CRC: Descartando resultado")
        else:
            self.result_display.setText("Error de recepción: No se recibieron los datos correctamente")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = CalculatorApp()
    window.show()
    sys.exit(app.exec())
