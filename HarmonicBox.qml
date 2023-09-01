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
    property bool autoLevel: false


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

                color: autoLevel ? "aquamarine" : "green"

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
                     setLevel(mouseY)
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
            //Layout.maximumHeight: meterItem.width

            //Layout.fillWidth: true
            text: "A"
            checkable: true
        }

        ToolButton {
            id: bumpsButton

            Layout.maximumWidth: meterItem.width
            //Layout.maximumHeight: meterItem.width
            text: "B"
            checkable: true
        }



    }

}
