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

    property bool isLandscape: root.width>root.height


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

    Item {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: 5


        RowLayout {
            id:headerRow
            spacing: 5
            height: helpButton.height + 10
            width: parent.width

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



        Item {
            id: controlsRow
            anchors.top: headerRow.bottom
            width: parent.width
            height: onButton.implicitHeight // Or Flow immeditately?

            Rectangle {anchors.fill: parent; color: "darkblue"}


//            Layout.fillWidth: true
//            Layout.preferredHeight: onButton.implicitHeight
//            Layout.fillHeight: true

            Flow {
                spacing: 10
                anchors.fill: parent
                //Layout.fillWidth: true
                //Layout.preferredHeight: onButton.implicitHeight
                //Layout.fillHeight: true
                //scale: 0.8

                Label {
                    height: parent.height
                    text:qsTr("All: ");
                    verticalAlignment: Qt.AlignVCenter
                }

                Button {

                    id: onButton
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
        }


        Item {
            id: harmonicsArea

            width: isLandscape ? parent.width - controlArea.width: parent.width // or maybe anchor changes in states.
            anchors.top: controlsRow.bottom
            anchors.bottom: isLandscape ? parent.bottom : controlArea.top
//            Layout.fillHeight: true
//            Layout.preferredHeight: mainColumn.height*0.6
//            Layout.fillWidth: true



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

            width: parent.width
            anchors.bottom: parent.bottom
            //anchors.top: isLandscape ? harmonicsArea.bottom :  harmonicsArea.bottom
            height: Math.max(volumeColumn.height, optionsFlow.height)
            //anchors.left: isLandscape ? harmonicsArea.right : parent.left
//            Layout.fillWidth: true
//            Layout.preferredHeight: optionsFlow.height + 40
//            Layout.minimumHeight: volumeDial.height + volumeLabel.height
//            Layout.fillHeight: true

            Rectangle {anchors.fill: parent; color: "darkgreen"}


            // TODO: move volume down and other controls above it. Start bottom up.
            states: State {
                        name: "landscape"; when: isLandscape

                        PropertyChanges {
                            target: controlArea
                            width:  tuningRow.width + 6
                        }

                        AnchorChanges {
                            target: controlArea
                            anchors.right: parent.right
                            anchors.top: harmonicsArea.top

                        }

                        PropertyChanges {
                            target: volumeColumn
                            //anchors.horizontalCenter: controlArea.horizontalCenter
                            width: parent.width
                        }


                        PropertyChanges {
                            target: optionsFlow
                            anchors.left: controlArea.left
                            anchors.top: volumeColumn.bottom
                            anchors.topMargin: 20
                        }

                        PropertyChanges {
                            target: harmonicsArea
                            width: parent.width - controlArea.width
                        }

                    }


            ColumnLayout {
                id: volumeColumn

                anchors.topMargin: 5


                Dial {
                    id: volumeDial

//                    Layout.preferredHeight:  isLandscape ? noteComboBox.implicitHeight : implicitHeight
//                    Layout.preferredWidth: Layout.preferredHeight
                    Layout.alignment: Qt.AlignHCenter

                    from: 0.0
                    to: 1.0
                    stepSize: 0.01
                    value: 0.6

                    onValueChanged: {
                        //console.log("Volume: ", value)
                        csound.setChannel("volume", value)
                    }

                    //Rectangle {anchors.fill: parent; color: "darkcyan"}

                }

                Label {
                    id: volumeLabel
                    horizontalAlignment: Text.AlignHCenter
                    Layout.topMargin: 5
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Volume")

                    //Rectangle {anchors.fill: parent; color: "darkmagenta"}

                }
            }


            Flow {
                id: optionsFlow
                spacing: 10
                anchors.left: volumeColumn.right
                anchors.right: parent.right
                anchors.top: parent.top
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
                    id: tuningRow

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

                RowLayout {
                    spacing: 5

                    Label { text: qsTr("Move"); Layout.alignment: Qt.AlignVCenter}

                    CheckBox {
                        id: moveCheckBox

                        onCheckedChanged: {
                            csound.setChannel("move", checked ? 1 : 0);
                        }
                    }


                }

            }

        }


    }
}
