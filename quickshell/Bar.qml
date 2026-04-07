import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland

Scope {
	id: root
	property string power_cap
	property string cpu_load
	Variants {
		model: Quickshell.screens;
		PanelWindow {
			color: "#282828"
			required property var modelData
			screen: modelData
			anchors {
				top: true
				left: true
				right: true
			}
			implicitHeight: 30
			Row {
				spacing: 5
				component BarItem: Rectangle {
					color: "#3c3836"
					implicitHeight: Math.max(childrenRect.height, parent.parent.height)
					implicitWidth: childrenRect.width + 20
					radius: 10
				}
				component BarItemText: Text {
					font.pointSize: 12
					anchors.centerIn: parent
					font.family: "Iosevka NF"
					color: "#fabd2f"
				}
				BarItem {
					BarItemText {
						text: " " + Qt.formatDateTime(clock.date, "hh:mm:ss")
					}
				}
				BarItem {
					BarItemText {
						text: "  " + Qt.formatDateTime(clock.date, "yyyy-MM-dd")
					}
				}
				BarItem {
					BarItemText {
						text: "󰂄 " + root.power_cap
					}
				}
			}
			Text {
				anchors.centerIn: parent
				color: "#a89984"
				font.family: "Iosevka NF"
				font.pointSize: 12
				text: Hyprland.activeToplevel.title
			}
		}
	}
	Process {
		id: powerGetter
		command: ["cat", "/sys/class/power_supply/BAT1/capacity"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: {root.power_cap = this.text; powerGetter.running = false;}
		}
	}
	Process {
		id: cpuGetter
		command: [""]
		running: true
		stdout: StdioCollector {
			onStreamFinished: {root.cpu_load = this.text; cpuGetter.running = false;}
		}
	}
	SystemClock {
		id: clock
		precision: SystemClock.Seconds
	}
	Timer {
		interval: 500
		running: true
		repeat: true
		onTriggered: {
			powerGetter.running = true;
		}
	}
}

