import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: meterItem
    width: 20
    height: 400

    property int harmonicNumber: 1
    property double level: 0
    property string levelChannel: "h"+harmonicNumber
    property alias autoLevel: autoModeButton.checked
    property alias bumps: bumpsButton.checked


    Timer {
        id: getChannelTimer
        interval: 10
        repeat:true

        onTriggered: {
            const value = csound.getChannel(levelChannel) // does not work on Android...
            //console.log("getChannel in qml: ", value)
            meterItem.level = Math.min(value,1.0);
        }
    }

    onLevelChanged: {
        if (!autoLevel) {
            csound.setChannel(levelChannel, level)
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        //spacing: 5

        Rectangle {
            id: meterRect
            color: "black"
            border.color: "#970505"
            border.width: 1

            Layout.fillHeight: true
            Layout.fillWidth: true


            Rectangle {
                id: levelRect
                width: parent.width - 2*parent.border.width
                height: (parent.height - 2*parent.border.width) * level

                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.border.width
                anchors.leftMargin: parent.border.width

                color: autoLevel ? "darkmagenta" : "green"
                gradient: Gradient {
                    GradientStop {
                        position: 0.00;
                        color: levelRect.color.lighter(1+level);
                    }
                    GradientStop {
                        position: 1.00;
                        color: levelRect.color.darker(4);
                    }
                }

                Behavior on height {
                    NumberAnimation { duration: 20 }
                }
            }

            MouseArea {
                 anchors.fill: parent

                 function setLevel(y) {
                     let newLevel =    (meterRect.height-y)/ meterRect.height
                     if (newLevel<0 ) newLevel = 0;
                     if (newLevel>1 ) newLevel = 1;
                     //console.log("y, relative: ", y, newLevel)
                     levelRect.height = meterRect.height * newLevel
                     meterItem.level = newLevel
                 }

                 onMouseYChanged: {
                     if (!autoLevel && mouseY>0) {
                        setLevel(mouseY) 
                     }
                 }
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            color: "yellow"
            text: harmonicNumber
        }

        LabelButton {
            id: autoModeButton
            Layout.alignment: Qt.AlignHCenter

            text: "A"
            //checkable: true

            onCheckedChanged: {
                if (!checked && bumpsButton.checked) { // bumps out when auto is out
                    bumpsButton.checked = false
                }
                csound.setChannel("auto"+harmonicNumber, checked ? 1 : 0)

                if (checked) {
                    getChannelTimer.start()
                } else {
                    getChannelTimer.stop()
                }
            }
        }

        LabelButton {
            id: bumpsButton
            Layout.alignment: Qt.AlignHCenter


            enabled: autoModeButton.checked

            text: "B"

            onCheckedChanged: {
                csound.setChannel("bumps"+harmonicNumber, checked ? 1 : 0)
            }

        }



    }

}
