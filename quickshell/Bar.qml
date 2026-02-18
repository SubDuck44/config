import Quickshell
import Quickshell.Io
import QtQuick

Scope {
		id: root
		property string time
		Variants {
				model: Quickshell.screens;
				PanelWindow {
						required property var modelData
						screen: modelData
						aboveWindows: false
						color: "#212121"
						anchors {
								top: true
								left: true
								right: true
						}
						implicitHeight: 30
						Text {
								anchors.centerIn: parent
								text: root.time
						}
				}
		}
		SystemClock {
				id: clock
				precision: SystemClock.Seconds
		}
		Timer {
				interval: 1000
				running: true
				repeat: true
				onTriggered: time = Qt.formatDateTime(clock.date, "hh:mm:ss")
		}
}

