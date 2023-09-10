import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material


Item {
    property bool checked: false
    property alias text: label.text

    width: label.implicitWidth + 8 // Adjust the width based on text size
    height: label.implicitHeight + 4 // Adjust the height based on text size

    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        color:  "transparent"
        radius: width/4

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                checked = !checked;
            }


            onEntered: {
                background.color = Material.backgroundColor.lighter(); // Change background color when hovered
            }

            onExited: {
                background.color = "transparent" // Restore transparent background when not hovered
            }
        }

        Label {
            id: label
            anchors.centerIn: parent
            text: "A"
            font.bold: true
            color: enabled ? ( checked ? Material.accentColor : Material.primaryTextColor ) : Material.secondaryTextColor.darker()
        }
    }
}
