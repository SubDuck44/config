pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications

Scope {
	id: root
	NotificationServer {
		id: server
		actionsSupported: true
		bodySupported: true
		imageSupported: true
		onNotification: n => {
			n.tracked = true;
		}
	}

	property var cur_att_color

	SequentialAnimation {
		running: true
		loops: Animation.Infinite

		PropertyAction {
			targets: root
			property: "cur_att_color"
			value: "#fe8019"
		}

		PauseAnimation {
			duration: 500
		}

		PropertyAction {
			targets: root
			property: "cur_att_color"
			value: "#fb4934"
		}

		PauseAnimation {
			duration: 500
		}
	}

	component AttentionMarker: Text {
		id: attention
		property int interval: 500
		text: " +++ ATTENTION +++ "

		font.pointSize: 12
		font.family: "Iosevka NF"

		color: root.cur_att_color
	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: panel

			WlrLayershell.layer: WlrLayer.Overlay
			exclusiveZone: ExclusionMode.Ignore

			required property var modelData
			property var hyprlandMonitor: Hyprland.monitorFor(screen)

			screen: modelData

			anchors {
				bottom: true
				left: true
				right: true
			}

			aboveWindows: true
			visible: false

			color: "#00000000"

			height: 30
			width: 1920

			Repeater {
				id: repeater

				model: server.trackedNotifications

				property Rectangle lastRec

				Rectangle {
					id: rect

					required property var modelData
					property var dur

					width: childrenRect.width
					height: panel.height
					anchors.verticalCenter: parent.verticalCenter

					color: "#282828"
					radius: 8
					border.color: rect.modelData.urgency == NotificationUrgency.Critical ? root.cur_att_color : "#d3869b"
					border.width: 3
					clip: true

					function calculateDuration(from, to, speed) {
						var distance = Math.abs(to - from);
						return distance / speed; // result is in milliseconds
					}

					Component.onCompleted: {
						if (repeater.lastRec) {
							rect.x = Math.max(repeater.lastRec.x + repeater.lastRec.width + 10, panel.width);
						} else {
							rect.x = panel.width;
						}
						rect.dur = calculateDuration(rect.x, -rect.width, 0.1);
						repeater.lastRec = rect;
						panel.visible = true;
					}

					SequentialAnimation {
						running: true
						alwaysRunToEnd: true

						NumberAnimation {
							target: rect
							properties: "x"
							from: rect.x
							to: -rect.width
							duration: rect.dur
						}

						onFinished: {
							rect.modelData.expire();
							if (server.trackedNotifications.values.length <= 0) {
								panel.visible = false;
							}
						}
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							rect.modelData.expire();
							if (server.trackedNotifications.values.length <= 0) {
								panel.visible = false;
							}
						}
					}

					Row {
						anchors.verticalCenter: parent.verticalCenter

						AttentionMarker {}

						Text {
							id: message
							property var message_width: width
							anchors.verticalCenter: parent.verticalCenter

							text: rect.modelData.summary + ": " + rect.modelData.body

							font.pointSize: 12
							font.family: "Iosevka NF"

							color: "#fabd2f"
						}

						Image {
							source: "notif.opus"
						}

						AttentionMarker {}
					}
				}
			}
		}
	}
}
