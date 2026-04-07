import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland

Scope {
	id: root
	property string power_cap
	property string cpu_load
	property string mem_used
	property int last_cpu_work
	property int last_cpu_total
	property int cur_cpu_work
	property int cur_cpu_total
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
			Rectangle {
				width: parent.width
				height: parent.height
				gradient: Gradient {
					orientation: Gradient.Horizontal
					GradientStop { position: 0.0; color: "#000000" }
					GradientStop { position: (bar_row.childrenRect.width / width) + 0.2; color: "#282828" }
					GradientStop { position: 1.0; color: "#282828" }
				}
			}
			Row {
				id: bar_row
				spacing: 5
				component BarItem: Rectangle {
					color: "#3c3836"
					implicitHeight: Math.max(childrenRect.height, parent.parent.height)
					implicitWidth: childrenRect.width + 20
					radius: 10
					border.width: 3
				}
				component BarItemText: Text {
					font.pointSize: 12
					anchors.centerIn: parent
					font.family: "Iosevka NF"
					color: "#fabd2f"
				}
				BarItem {
					border.color: "#5bcefa"
					BarItemText {
						text: " " + Qt.formatDateTime(clock.date, "hh:mm:ss")
					}
				}
				BarItem {
					border.color: "#f5a9b8"
					BarItemText {
						text: "  " + Qt.formatDateTime(clock.date, "yyyy-MM-dd")
					}
				}
				BarItem {
					border.color: "#ffffff"
					BarItemText {
						text: "󰂄 " + root.power_cap
					}
				}
				BarItem {
					border.color: "#f5a9b8"
					BarItemText {
						text: "  " + cpu_load
					}
				}
				BarItem {
					border.color: "#5bcefa"
					BarItemText {
text: "  " + mem_used
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
		command: ["sh", "-c", "head -1 /proc/stat"]
		running: true
		stdout: SplitParser {
			onRead: data => {
				last_cpu_work = cur_cpu_work;
				last_cpu_total = cur_cpu_total;

				var values = data.split(" ");
				cur_cpu_work = parseInt(values[2]) + parseInt(values[3]) + parseInt(values[4]);
				cur_cpu_total = parseInt(values[2]) + parseInt(values[3]) + parseInt(values[4]) + parseInt(values[5]) + parseInt(values[6]) + parseInt(values[7]) + parseInt(values[8]) + parseInt(values[9]) + parseInt(values[10]) + parseInt(values[11]);

				cpu_load = (100*(cur_cpu_work - last_cpu_work) / (cur_cpu_total - last_cpu_total)).toFixed(1);
			}
		}
		Component.onCompleted: running = false
	}
	Process {
		id: memGetter
		command: ["sh", "-c", "free -L"]
		running: true
		stdout: SplitParser {
			onRead: data => {
				var values = data.split(" ").filter(n => n)
				var used = parseInt(values[5])
				var total = parseInt(values[1]) + parseInt(values[3]) + parseInt(values[5]) + parseInt(values[7])
				mem_used = (used / 1000000).toFixed(2) + "G /" + (total / 1000000).toFixed(2) + "G"
			}
		}
		Component.onCompleted: running = false;
	}
	SystemClock {
		id: clock
		precision: SystemClock.Seconds
	}
	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: {
			powerGetter.running = true;
			cpuGetter.running = true;
			memGetter.running = true;
		}
	}
}

