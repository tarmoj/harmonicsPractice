import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Window { // or maybe ApplicationWindow & header?
    id: root
    width: 640
    height: 480
    visible: true
    color: Material.background
    title: qsTr("Harmonics Practice")

    Material.theme: Material.Dark
    Material.primary: "yellow"

    // see more on controlling Material: https://doc.qt.io/qt-6/qtquickcontrols-material.html#material-theme-attached-prop

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: 5

        RowLayout {
            id:headerRow
            spacing: 5
            //Layout.fillWidth: true

            Label {text: root.title; font.bold: true; font.pointSize: 14}

            Item {Layout.fillWidth: true}    // spacer

            RoundButton {
                id: helpButton
                Layout.alignment: Qt.AlignRight
                text: qsTr("Help")
            }

        }

        Item {
            id: harmonicsArea

            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                anchors.fill: parent
                color: "darkgrey"
            }

        }

        Item {
            id: controlArea
            Layout.fillWidth: true
            Layout.preferredHeight: 120

            ColumnLayout {
                id: volumeColumn

                height: parent. height

                Dial {
                    id: volumeDial
                    from: 0.0
                    to: 1.0
                    stepSize: 0.01

                    onValueChanged: {
                        console.log("Volume: ", value)
                    }
                }

                Label {
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Volume")

                }

            }


            Flow {
                spacing: 10
                anchors.left: volumeColumn.right
                anchors.right: parent.right
                height: parent.height
                //columns: 4

                Row {
                    spacing: 5

                    Label { text: qsTr("Fundamental:")}

                    ComboBox {
                        id: noteComboBox
                        width: 60

                        model: ["C", "C#", "D" ]

                        onAccepted: {
                            console.log("Chose: ", currentText)
                        }
                    }

                }

                Row {
                    spacing: 5

                    Label { text: qsTr("Octave")}

                    ComboBox {
                        id: octaveComboBox
                        width: 60

                        model: ["0", "1", "2", "3", "4" ]

                        onAccepted: {
                            console.log("Chose: ", currentIndex)
                        }
                    }
                }

                Row {
                    spacing: 5

                    Label { text: qsTr("Tuning")}

                    SpinBox {
                        id: tuningSpinBox

                        from: 400
                        to: 500
                        value: 442
                        stepSize: 1

                        onValueChanged:  {
                            console.log("Tuning: ", value)
                        }
                    }

                }

            }

        }


    }
}
