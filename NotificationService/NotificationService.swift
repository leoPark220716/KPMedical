//
//  NotificationService.swift
//  NotificationService
//
//  Created by Junsung Park on 5/24/24.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            // 사용자 설정을 읽어와서 알림을 표시할지 숨길지 결정
            let userDefaults = UserDefaults(suiteName: "group.com.kph.kpmedicalwallet")
            let isCounselingNotificationEnabled = userDefaults?.bool(forKey: "counselingNotification") ?? false
            let infoRequestNotification = userDefaults?.bool(forKey: "infoRequestNotification") ?? false
            let movementNotification = userDefaults?.bool(forKey: "movementNotification") ?? false

            let userInfo = bestAttemptContent.userInfo
            let msgType = extractMsgType(from: userInfo)
            var showNotification = false

            switch msgType {
            case "4":
                showNotification = isCounselingNotificationEnabled
            case "6":
                showNotification = infoRequestNotification
            default:
                showNotification = movementNotification
            }

            if showNotification {
                // 알림을 표시
                contentHandler(bestAttemptContent)
            } else {
                // 알림을 숨김
                bestAttemptContent.title = ""
                bestAttemptContent.body = ""
                bestAttemptContent.sound = nil
                bestAttemptContent.badge = nil
                contentHandler(bestAttemptContent)
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    }

    private func extractMsgType(from userInfo: [AnyHashable: Any]) -> String {
        if let chat = userInfo["chat"] as? [String: Any] {
            return extractMsgTypeField(from: chat)
        } else if let chatString = userInfo["chat"] as? String,
                  let chatData = chatString.data(using: .utf8) {
            return decodeMsgType(chatData)
        } else {
            print("Chat data is not in the expected format or missing.")
            return ""
        }
    }

    private func extractMsgTypeField(from chat: [String: Any]) -> String {
        if let msg_type = chat["msg_type"] as? Int {
            return String(msg_type)
        } else {
            return ""
        }
    }

    private func decodeMsgType(_ data: Data) -> String {
        do {
            if let chatDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let msg_type = chatDict["msg_type"] as? Int {
                return String(msg_type)
            } else {
                return "Failed to decode msg_type."
            }
        } catch {
            return "Error decoding chat JSON for msg_type: \(error)"
        }
    }
}
