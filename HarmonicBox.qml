import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: meterItem
    width: 20
    height: 400

    property int harmonicNumber: 1
    property double level: 0.6
    property alias autoLevel: autoModeButton.checked
    property alias bumps: bumpsButton.checked


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
                     const newLevel = (meterRect.height-y)/ meterRect.height
                     //console.log("y, relative: ", y, newLevel)
                     levelRect.height = meterRect.height * newLevel
                     meterItem.level = newLevel
                     //csound.setChannel(....)
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

        ToolButton {
            id: autoModeButton
            Layout.maximumWidth: meterItem.width

            text: "A"
            checkable: true

            onCheckedChanged: {
                if (!checked && bumpsButton.checked) { // bumps out when auto is out
                    bumpsButton.checked = false
                }
            }
        }

        ToolButton {
            id: bumpsButton
            Layout.maximumWidth: meterItem.width
            //Layout.maximumHeight: meterItem.width
            checkable: true
            enabled: autoModeButton.checked

            text: "B"

        }



    }

}
