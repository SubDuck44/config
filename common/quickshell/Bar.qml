pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import Quickshell.Services.Mpris

Scope {
	id: root

	property string power_cap
	property string cpu_load
	property string mem_used
	property int last_cpu_work
	property int last_cpu_total
	property int cur_cpu_work
	property int cur_cpu_total
	property string now_playing
	property bool is_playing

	component BarItem: Rectangle {
		property bool ready
		property string text
		color: "#282828"
		height: parent.parent.height
		width: childrenRect.width + 20
		border.width: 3
		clip: true

		Text {
			id: tex
			font.pointSize: 12
			anchors.centerIn: parent
			font.family: "Iosevka NF"
			color: "#fabd2f"
			visible: true
			text: parent.text
		}

		Behavior on width {
			SequentialAnimation {
				PropertyAnimation {
					properties: "width"
					easing.type: Easing.OutQuad
				}
			}
		}
	}

	Variants {
		model: Quickshell.screens
		PanelWindow {
			color: "#00000000"
			required property var modelData
			screen: modelData
			anchors {
				top: true
				left: true
				right: true
			}
			implicitHeight: 30

			Row {
				id: bar_row
				BarItem {
					border.color: "#83a598"
					text: " " + Qt.formatDateTime(clock.date, "hh:mm:ss")
				}
				BarItem {
					border.color: "#d3869b"
					text: "  " + Qt.formatDateTime(clock.date, "yyyy-MM-dd ddd")
				}
				BarItem {
					border.color: "#fbf1c7"
					text: "  " + root.cpu_load
				}
				BarItem {
					border.color: "#d3869b"
					text: "  " + root.mem_used
				}
				BarItem {
					border.color: "#83a598"
					visible: root.power_cap.length > 0
					text: "󰂄 " + root.power_cap
				}
				BarItem {
					border.color: "#fe8019"
					width: root.is_playing ? childrenRect.width + 20 : 0
					color: "#282828"
					text: "Now playing: " + root.now_playing
				}
			}

			Rectangle {
				id: active_indicator
				color: "#282828"
				border.color: "#b8bb26"
				border.width: 3
				height: parent.height
				width: parent.width - bar_row.width
				anchors.left: bar_row.right
				Text {
					anchors.centerIn: parent
					color: "#fabd2f"
					font.family: "Iosevka NF"
					font.pointSize: 12
					text: Hyprland.activeToplevel.title.length > 50 ? Hyprland.activeToplevel.title.slice(0, 50) + "..." : Hyprland.activeToplevel.title
				}
			}
		}
	}

	Process {
		id: powerGetter
		command: ["cat", "/sys/class/power_supply/BAT1/capacity"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: {
				root.power_cap = this.text;
				powerGetter.running = false;
			}
		}
	}

	Process {
		id: cpuGetter
		command: ["sh", "-c", "head -1 /proc/stat"]
		running: true
		stdout: SplitParser {
			onRead: data => {
				root.last_cpu_work = root.cur_cpu_work;
				root.last_cpu_total = root.cur_cpu_total;

				var values = data.split(" ");
				root.cur_cpu_work = parseInt(values[2]) + parseInt(values[3]) + parseInt(values[4]);
				root.cur_cpu_total = parseInt(values[2]) + parseInt(values[3]) + parseInt(values[4]) + parseInt(values[5]) + parseInt(values[6]) + parseInt(values[7]) + parseInt(values[8]) + parseInt(values[9]) + parseInt(values[10]) + parseInt(values[11]);

				root.cpu_load = (100 * (root.cur_cpu_work - root.last_cpu_work) / (root.cur_cpu_total - root.last_cpu_total)).toFixed(1);
			}
		}
		Component.onCompleted: running = false
	}

	Process {
		id: memGetter
		command: ["sh", "-c", "free  | sed -n 2p"]
		running: true
		stdout: SplitParser {
			onRead: data => {
				var values = data.split(" ").filter(n => n);
				var used = parseInt(values[2]);
				var total = parseInt(values[1]);
				root.mem_used = (used / 1000000).toFixed(2) + "G/" + (total / 1000000).toFixed(2) + "G";
			}
		}
		Component.onCompleted: running = false
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

			for (let i = 0; i < Mpris.players.values.length; i++) {
				let player = Mpris.players.values[i];
				if (player.trackTitle.length > 0 && player.identity == "MPD") {
					root.now_playing = player.trackTitle;
					root.is_playing = player.isPlaying;
				}
			}
		}
	}
}
