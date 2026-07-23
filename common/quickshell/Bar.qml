pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import Quickshell.Services.Mpris

Scope {
	id: root

	property bool is_playing
	property string cpu_load
	property string mem_load
	property string bat_load
	property string now_playing

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
			wrapMode: Text.NoWrap
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
					text: "  " + root.mem_load
				}
				BarItem {
					id: power_indicator
					border.color: "#83a598"
					visible: parseInt(root.bat_load) > 0
					text: "󰂄 " + root.bat_load

					SequentialAnimation {
						running: parseInt(root.bat_load) < 15
						alwaysRunToEnd: true
						loops: Animation.Infinite

						PropertyAnimation {
							target: power_indicator
							properties: "color"
							to: "#fb4934"
							easing: Easing.InOutQuad
							duration: 500
						}
						PropertyAnimation {
							target: power_indicator
							properties: "color"
							to: "#282828"
							easing: Easing.InOutQuad
							duration: 500
						}
					}
				}
				Rectangle {
					border.color: "#a89984"
					border.width: 3
					color: "#282828"

					height: parent.height
					width: childrenRect.width + 12

					Behavior on width {
						SequentialAnimation {
							PropertyAnimation {
								properties: "width"
								easing.type: Easing.OutQuad
							}
						}
					}

					Row {
						width: childrenRect.width
						height: parent.height
						anchors.centerIn: parent

						Repeater {
							model: Hyprland.workspaces.values
							anchors.centerIn: parent

							Rectangle {
								required property int index

								width: childrenRect.width + 10
								height: parent.height - 6
								anchors.verticalCenter: parent.verticalCenter

								color: "#282828"

								Text {
									anchors.centerIn: parent

									text: Hyprland.workspaces.values[parent.index].name
									font.family: "Iosevka NF"
									font.pointSize: 12
									color: "#fabd2f"

									Text {
										anchors.centerIn: parent
										text: "[ ]"
										font.family: "Iosevka NF"
										font.pointSize: 12
										color: "#fabd2f"
										rotation: 90

										visible: Hyprland.focusedWorkspace.name == Hyprland.workspaces.values[parent.parent.index].name
									}
								}
							}
						}
					}
				}
				BarItem {
					border.color: "#fe8019"
					width: root.is_playing ? childrenRect.width + 20 : 0
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

	SystemClock {
		id: clock
		precision: SystemClock.Seconds
	}

	Process {
		id: dataGetter
		command: ["bar-info"]
		running: true
		stdout: SplitParser {
			onRead: data => {
				var values = data.split("\t");

				root.cpu_load = values[0];
				root.mem_load = values[1];
				root.bat_load = values[2];
			}
		}
	}

	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: {
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
