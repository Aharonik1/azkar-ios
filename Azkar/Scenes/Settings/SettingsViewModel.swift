//
//  SettingsViewModel.swift
//  Azkar
//
//  Created by Abdurahim Jauzee on 04.05.2020.
//  Copyright © 2020 Al Jawziyya. All rights reserved.
//

import SwiftUI
import Combine
import UIKit
import UserNotifications

final class SettingsViewModel: ObservableObject {

    private let notificationsCenter = UNUserNotificationCenter.current()
    private let morningNotificationId = "morning.notification"
    private let eveningNotificationId = "evening.notification"

    var canChangeIcon: Bool {
        return !UIDevice.current.isIpad
    }

    private let formatter: DateFormatter

    @Published var preferences: Preferences
    @Published var morningTime: String
    @Published var eveningTime: String

    func getDatesRange(fromHour hour: Int, hours: Int) -> [Date] {
        let now = DateComponents(calendar: Calendar.current, hour: hour, minute: 0).date ?? Date()
        return (1...(hours * 2)).reduce(into: [now]) { (dates, multiplier) in
            let duration = DateComponents(calendar: Calendar.current, minute: multiplier * 30)
            let newDate = Calendar.current.date(byAdding: duration, to: now) ?? now
            dates.append(newDate)
        }
    }

    var morningDateItems: [String] {
        return getDatesRange(fromHour: 2, hours: 11).compactMap(formatter.string)
    }

    var eveningDateItems: [String] {
        return getDatesRange(fromHour: 14, hours: 10).compactMap(formatter.string)
    }

    private var cancellabels = Set<AnyCancellable>()

    init(preferences: Preferences) {
        self.preferences = preferences

        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        self.formatter = formatter
        morningTime = formatter.string(from: preferences.morningNotificationTime)
        eveningTime = formatter.string(from: preferences.eveningNotificationTime)

        preferences.$appIcon
            .dropFirst(1)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { icon in
                UIApplication.shared.setAlternateIconName(icon.iconName)
            })
            .store(in: &cancellabels)

        $morningTime
            .dropFirst()
            .map { [unowned self] time in
                self.formatter.date(from: time) ?? defaultMorningNotificationTime
            }
            .assign(to: \.morningNotificationTime, on: preferences)
            .store(in: &cancellabels)

        $eveningTime
            .dropFirst()
            .map { [unowned self] time in
                self.formatter.date(from: time) ?? defaultEveningNotificationTime
            }
            .assign(to: \.eveningNotificationTime, on: preferences)
            .store(in: &cancellabels)

        Publishers.CombineLatest3(
                preferences.$enableNotifications.dropFirst(),
                preferences.$morningNotificationTime.dropFirst(),
                preferences.$eveningNotificationTime.dropFirst()
            )
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] (enabled, morning, evening) in
                self.removeScheduledNotifications()
                guard enabled else {
                    return
                }
                self.scheduleNotifications()
            })
            .store(in: &cancellabels)
    }

    private func removeScheduledNotifications() {
        notificationsCenter.removeDeliveredNotifications(withIdentifiers: [morningNotificationId, eveningNotificationId])
    }

    private func scheduleNotifications() {
        let morningRequest = notifiationRequest(id: morningNotificationId, date: preferences.morningNotificationTime, title: "Утренние азкары 🌅")
        let eveningRequest = notifiationRequest(id: eveningNotificationId, date: preferences.eveningNotificationTime, title: "Вечерние азкары 🌄")

        notificationsCenter.add(morningRequest, withCompletionHandler: nil)
        notificationsCenter.add(eveningRequest, withCompletionHandler: nil)
    }

    private func notifiationRequest(id: String, date: Date, title: String) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default

        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: date), repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        return request
    }

}
