import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore

Window { // or maybe ApplicationWindow & header?
    id: root
    width: 480
    height: 640
    visible: true
    color: Material.background
    title: qsTr("Harmonics Practice")


    Connections {
            target: Application
            function onAboutToQuit() {
                console.log("Bye!")
                csound.stop();
            }
        }

    // see more on controlling Material: https://doc.qt.io/qt-6/qtquickcontrols-material.html#material-theme-attached-prop


    function setBaseNote() {
        const pitch = ( parseInt(octaveComboBox.currentText)+4 + noteComboBox.currentIndex/100).toFixed(2)
        console.log("New pitch: ", pitch);
        csound.compileOrc(`gkBaseFreq init cpspch(${pitch})`);
    }

    Settings {
        property alias note: noteComboBox.currentIndex
        property alias octave: octaveComboBox.currentIndex
        property alias volume: volumeDial.value
        property alias tuning: tuningSpinBox.value


    }

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: 5

        RowLayout {
            id:headerRow
            spacing: 5

            Label {
                text: root.title; font.bold: true; font.pointSize: 14
            }

            Item {Layout.fillWidth: true}    // spacer

            ToolButton {
                id: helpButton
                Layout.alignment: Qt.AlignRight
                text: "?"
                onClicked: helpDialog.open()
            }

        }

        MessageDialog {
            id: helpDialog
            buttons: MessageDialog.Ok

            text: qsTr(`HarmonicsPractice

                       ... is ...

                       Built using Csound sound engine and Qt framework<br>
                       <br>
                       (c) Tarmo Johannes
                        `)

            onButtonClicked: function (button, role) { // does not close on Android otherwise
                switch (button) {
                case MessageDialog.Ok:
                    helpDialog.close()
                }
            }
        }

        Flow {
            spacing: 10
            Layout.fillWidth: true
            scale: 0.8

            Label {
                text:qsTr("All: ");
                verticalAlignment: Qt.AlignVCenter
            }

            Button {
                text: qsTr("ON");

                onClicked:  {
                    console.log("Count:", harmonicsRepeater.count );

                    for (let i=0; i<harmonicsRepeater.count; i++ ) {
                        harmonicsRepeater.itemAt(i).level = 0.6
                    }
                }
            }

            Button {
                text: qsTr("OFF");

                onClicked:  {
                    for (let i=0; i<harmonicsRepeater.count; i++ ) {
                        harmonicsRepeater.itemAt(i).level = 0
                    }
                }
            }

            Button {
                text: qsTr("Auto");
                checkable: true


                onCheckedChanged:  {

                    for (let i=0; i<harmonicsRepeater.count; i++ ) {
                        harmonicsRepeater.itemAt(i).autoLevel = checked
                    }
                }
            }

            Button {
                text: qsTr("Bumps");
                checkable: true

                onCheckedChanged:  {
                    console.log("Checked", checked)
                    for (let i=0; i<harmonicsRepeater.count; i++ ) {
                        harmonicsRepeater.itemAt(i).bumps = checked
                    }
                }
            }

        }

        Item {
            id: harmonicsArea

            Layout.fillHeight: true
            Layout.preferredHeight: mainColumn.height*0.6
            Layout.fillWidth: true

            Rectangle {
                anchors.fill: parent
                color: "#292a36"
            }

            Row {

                anchors.fill: parent

                Repeater {
                    id: harmonicsRepeater
                    model: 16

                    HarmonicBox {
                        required property int index
                        width: harmonicsArea.width/16
                        height: parent.height
                        harmonicNumber: index+1
                    }
                }

            }



        }

        Item {
            id: controlArea
            Layout.fillWidth: true
            Layout.preferredHeight: optionsFlow.height + 40
            Layout.minimumHeight: volumeDial.height + volumeLabel.height
            Layout.fillHeight: true

            ColumnLayout {
                id: volumeColumn

                //height: parent. height

                Dial {
                    id: volumeDial

                    //Layout.preferredWidth: 30
                    //Layout.preferredHeight: 30

                    from: 0.0
                    to: 1.0
                    stepSize: 0.01
                    value: 0.6

                    onValueChanged: {
                        //console.log("Volume: ", value)
                        csound.setChannel("volume", value)
                    }
                }

                Label {
                    id: volumeLabel
                    horizontalAlignment: Text.AlignTop
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Volume")
                }
            }


            Flow {
                id: optionsFlow
                spacing: 10
                anchors.left: volumeColumn.right
                anchors.right: parent.right
                anchors.leftMargin: 10

                RowLayout {
                    spacing: 5

                    Label {
                        text: qsTr("Fundamental:");
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ComboBox {
                        id: noteComboBox
                        Layout.preferredWidth: 80
                        currentIndex: 0

                        model: ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "Bb", "B" ]

                        onCurrentValueChanged: {
                            console.log("Chose: ", currentText, currentIndex)
                            setBaseNote()
                        }
                    }

                }

                RowLayout {
                    spacing: 5

                    Label { text: qsTr("Octave"); Layout.alignment: Qt.AlignVCenter;}

                    ComboBox {
                        id: octaveComboBox
                        Layout.preferredWidth: 80
                        currentIndex: 2

                        model: ["0", "1", "2", "3", "4" ]

                        onCurrentValueChanged: {
                            console.log("Chose: ", currentIndex)
                            setBaseNote()
                        }
                    }
                }

                RowLayout {
                    spacing: 5

                    Label { text: qsTr("Tuning"); Layout.alignment: Qt.AlignVCenter}

                    SpinBox {
                        id: tuningSpinBox

                        from: 400
                        to: 500
                        value: 442
                        stepSize: 1
                        editable: true

                        onValueChanged:  {
                            console.log("Tuning: ", value)
                            csound.setChannel("a4", value)
                        }
                    }

                }

            }

        }


    }
}
