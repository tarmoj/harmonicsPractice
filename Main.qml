import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore

ApplicationWindow {
    id: root
    width: 480
    height: 640
    visible: true
    color: Material.background
    title: qsTr("Harmonics Practice")

    property bool isLandscape: root.width>root.height

    signal setChannel(channel: string, value: double)
    signal readScore(scoreLine: string)
    signal compileOrc(code: string)
    signal requestChannel(channel: string)
    signal newChannelValue(channel: string, value: double)

    onNewChannelValue: {
        if (channel[0]==="h") {
            const channelNumber = parseInt(channel.slice(1));
            if (channelNumber>=1 && channelNumber<=16) {
                harmonicsRepeater.itemAt(channelNumber-1).level = Math.min(value,1.0);
            }


        }

    }


    Connections {
            target: Application
            function onAboutToQuit() {
                console.log("Bye!")
                csound.stop(); // this must probably stay straight call not via signal-slot
            }
        }

    // see more on controlling Material: https://doc.qt.io/qt-6/qtquickcontrols-material.html#material-theme-attached-prop


    function setBaseNote() {
        const pitch = ( parseInt(octaveComboBox.currentText)+4 + noteComboBox.currentIndex/100).toFixed(2)
        console.log("New pitch: ", pitch);
         compileOrc(`gkBaseFreq init cpspch(${pitch})`);
    }

    Settings {
        property alias note: noteComboBox.currentIndex
        property alias octave: octaveComboBox.currentIndex
        property alias volume: volumeDial.value
        property alias tuning: tuningSpinBox.value


    }

    header: ToolBar {
        id: headerRow

        Material.background: "transparent"

        Label {
            id: titleLabel
            text: root.title; font.bold: true; font.pointSize: 14
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
        }

        ToolButton {
            id: menuButton
            //height: titleLabel.height
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/images/more.png"
            onClicked: drawer.opened ? drawer.close() : drawer.open()
        }
    }

    MessageDialog { // maybe replace with normal Dialog later
        id: helpDialog
        buttons: MessageDialog.Ok

        text: qsTr(`HarmonicsPractice

is an app for practicing harmonics on brass, wind or any other instruments.
Or you can play whatever on top of the harmonics.
Choose the base note and pull the sliders to set relative volume of the harmonics.

A -  automatic fluctuation of the harmonics
B -  "Bumps" - occasional attacks in  the sound
Move - make the harmonics move between speakers

Built using Csound sound engine and Qt framework

(c) Tarmo Johannes trmjhnns@gmail.com`)

        onButtonClicked: function (button, role) { // does not close on Android otherwise
            switch (button) {
            case MessageDialog.Ok:
                helpDialog.close()
            }
        }
    }



    Drawer {
           id: drawer
           width: tuningRow.width + 40
           height: root.height - headerRow.height
           y: headerRow.height
           property int marginLeft: 20

           background: Rectangle {anchors.fill:parent; color: Material.backgroundColor.lighter()}


           ColumnLayout {
               anchors.fill: parent
               spacing: 5



               ComboBox {
                   id: languageComboBox
                   enabled: false

                   Layout.leftMargin: drawer.marginLeft

                   model: ["EST", "EN"]

                   onActivated: console.log("Laguage: ", currentText)

               }



               RowLayout {
                   spacing: 5
                   id: tuningRow

                   Layout.leftMargin: drawer.marginLeft

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
                            setChannel("a4", value)
                       }
                   }

               }

               MenuItem {
                   text: qsTr("Info")
                   onTriggered: {
                       drawer.close()
                       helpDialog.open()
                   }

               }

               MenuItem {
                text: qsTr("Buy me a coffee")
                onTriggered: Qt.openUrlExternally("https://ko-fi.com/tarmojohannes")
               }

               Item {Layout.fillHeight: true}


           }


       }

    Item {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: 5

        Item {
            id: buttonsRow
            //anchors.top: headerRow.bottom
            width: parent.width
            height: Math.max(onButton.implicitHeight, buttonFlow.height)


            Flow {
                id: buttonFlow
                spacing: 10
                width: parent.width



                Label {
                    height: onButton.height
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

                    //TODO: switch out also  all AUTO
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

                Item { Layout.fillWidth: true }

            }
        }


        Item {
            id: harmonicsArea

            width:  parent.width
            anchors.top: buttonsRow.bottom
            anchors.bottom: isLandscape ? parent.bottom : controlArea.top


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
            height: Math.max(volumeColumn.height, optionsFlow.height)


            states: State {
                        name: "landscape"; when: isLandscape

                        PropertyChanges {
                            target: controlArea
                            width:  tuningRow.width + 12
                        }

                        AnchorChanges {
                            target: controlArea
                            anchors.right: parent.right
                        }

                        PropertyChanges {
                            target: volumeColumn
                            width: parent.width
                            anchors.bottom: parent.bottom
                        }


                        PropertyChanges {
                            target: optionsFlow
                            anchors.left: controlArea.left
                            anchors.bottom: volumeColumn.top
                            anchors.bottomMargin: 20
                        }

                        PropertyChanges {
                            target: harmonicsArea
                            width: parent.width - controlArea.width
                        }

                    }


            ColumnLayout {
                id: volumeColumn

                anchors.topMargin: 5
                //anchors.top: parent.top
                anchors.bottom: parent.bottom



                Dial {
                    id: volumeDial

                    Layout.alignment: Qt.AlignHCenter

                    from: 0.0
                    to: 1.0
                    stepSize: 0.01
                    value: 0.6

                    onValueChanged: {
                        //console.log("Volume: ", value)
                         setChannel("volume", value)
                    }

                    //Rectangle {anchors.fill: parent; color: "darkcyan"}

                }

                Label {
                    id: volumeLabel
                    horizontalAlignment: Text.AlignHCenter
                    Layout.topMargin: 5
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Volume")
                }
            }


            Flow {
                id: optionsFlow
                spacing: 10
                anchors.left: volumeColumn.right
                anchors.right: parent.right
                //anchors.top: parent.top
                anchors.bottom: parent.bottom

                anchors.bottomMargin: 5


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

                        model: ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B" ]

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

                    Label { text: qsTr("Move"); Layout.alignment: Qt.AlignVCenter}

                    CheckBox {
                        id: moveCheckBox

                        onCheckedChanged: {
                             setChannel("move", checked ? 1 : 0);
                        }
                    }

                }

            }

        }


    }
}
