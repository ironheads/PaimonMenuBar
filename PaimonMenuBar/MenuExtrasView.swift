//
//  MenuView.swift
//  PaimonMenuBar
//
//  Created by Spencer Woo on 2022/3/25.
//

import Defaults
import Foundation
import Kingfisher
import SwiftUI

class RelativeFormatter {
    private let df = DateFormatter()

    init() {
        df.dateStyle = DateFormatter.Style.long
        df.timeStyle = DateFormatter.Style.short
        df.doesRelativeDateFormatting = true
    }

    func string(time: Date) -> String {
        return df.string(from: time)
    }
}

/// Return the formatted time interval in a human-readable string
/// - Parameter timeInterval: A time interval represented in seconds
/// - Returns: A human-readable string representing the time interval
private func formatTimeInterval(timeInterval: String) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: (TimeInterval(timeInterval) ?? TimeInterval("0"))!) ?? ""
}

/// Format a date that is of 'timeInterval' seconds away from now
/// - Parameter timeInterval: The number of seconds away from current time
/// - Returns: A human-readable string describing the future date
private func formatFutureDate(timeInterval: String) -> String {
    let currentTime = Date()
    let futureTime = currentTime.addingTimeInterval((TimeInterval(timeInterval) ?? TimeInterval("0"))!)

    if Calendar.current.isDateInToday(futureTime) {
        return "\(String.localized("Today")) \(futureTime.shortenedFormatted)"
    }
    if Calendar.current.isDateInTomorrow(futureTime) {
        return "\(String.localized("Tomorrow")) \(futureTime.shortenedFormatted)"
    }
    // This should not happen, but just in case.
    return futureTime.defaultFormatted
}

struct MenuExtrasView: View {
    @Default(.lastGameRecord) private var lastGameRecord

    var body: some View {
        VStack(spacing: 8) {
            ResinView(
                currentResin: lastGameRecord.data.current_resin,
                maxResin: lastGameRecord.data.max_resin,
                resinRecoveryTime: lastGameRecord.data.resin_recovery_time,
                fetchAt: lastGameRecord.fetchAt
            )

            ExpeditionView(
                expeditions: lastGameRecord.data.expeditions,
                maxExpeditionNum: lastGameRecord.data.max_expedition_num,
                currentExpeditionNum: lastGameRecord.data.current_expedition_num
            )

            DailyCommissionView(
                finishedTaskNum: lastGameRecord.data.finished_task_num,
                totalTaskNum: lastGameRecord.data.total_task_num
            )

            HomeCoinView(
                currentHomeCoin: lastGameRecord.data.current_home_coin,
                maxHomeCoin: lastGameRecord.data.max_home_coin,
                homeCoinRecoveryTime: lastGameRecord.data.home_coin_recovery_time
            )

            ExtraTaskRewardView(
                remainResinDiscountNum: lastGameRecord.data.remain_resin_discount_num,
                resinDiscountNumLimit: lastGameRecord.data.resin_discount_num_limit,
                isExtraTaskRewardReceived: lastGameRecord.data.is_extra_task_reward_received
            )

            ParametricTransformerView(transformer: lastGameRecord.data.transformer)
        }
        .padding([.horizontal])
        .padding([.vertical], 8)
    }
}

struct ResinView: View {
    let currentResin: Int
    let maxResin: Int
    let resinRecoveryTime: String
    let fetchAt: Date?

    private let formatter = RelativeFormatter()

    var body: some View {
        VStack(spacing: 8) {
            Text((fetchAt != nil) ? "Update: \(formatter.string(time: fetchAt!))" : "Not updated")
                .font(.caption).opacity(0.4)

            HStack(spacing: 4) {
                Image("FragileResin")
                    .resizable()
                    .frame(width: 16, height: 16)
                Text("Current Resin")
                    .font(.subheadline)
                    .opacity(0.6)
                Spacer()
            }

            Text("\(currentResin)/\(maxResin)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(.largeTitle, design: .monospaced).bold())

            HStack {
                Label("Fully replenished", systemImage: "moon.circle")
                Spacer()
                Text(formatTimeInterval(timeInterval: resinRecoveryTime))
                    .font(.system(.body, design: .monospaced).bold())
            }
            HStack {
                Label("ETA", systemImage: "clock")
                Spacer()
                Text(formatFutureDate(timeInterval: resinRecoveryTime))
                    .font(.system(.body, design: .monospaced).bold())
            }
            Divider()
        }
    }
}

struct ExpeditionView: View {
    let expeditions: [Expeditions]
    let maxExpeditionNum: Int
    let currentExpeditionNum: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Expeditions \(currentExpeditionNum)/\(maxExpeditionNum)")
                    .font(.subheadline)
                    .opacity(0.6)
                Spacer()
            }

            ForEach(expeditions, id: \.self) { expedition in
                ExpeditionItemView(
                    status: expedition.status, avatar: expedition.avatar_side_icon,
                    remainedTime: expedition.remained_time
                )
            }

            Divider()
        }
    }
}

struct ExpeditionItemView: View {
    let status: String
    let avatar: String
    let remainedTime: String

    var body: some View {
        HStack {
            KFImage.url(URL(string: avatar))
                .resizable()
                .placeholder { Color.gray.opacity(0.3) }
                .clipShape(Circle())
                .overlay(Circle().stroke(status == "Finished" ? Color.green : Color.gray))
                .frame(width: 20, height: 20)
            Text(status == "Finished" ? String.localized("Complete") : String.localized("Exploring"))
            Spacer()
            Text(formatTimeInterval(timeInterval: remainedTime))
                .font(.system(.body, design: .monospaced).bold())
        }
    }
}

struct DailyCommissionView: View {
    let finishedTaskNum: Int
    let totalTaskNum: Int

    var body: some View {
        HStack {
            Image("Commision")
                .resizable()
                .frame(width: 20, height: 20, alignment: .leading)
            Text("Daily commissions")
            Spacer()
            Text("\(finishedTaskNum)/\(totalTaskNum)")
                .font(.system(.body, design: .monospaced).bold())
        }
    }
}

struct HomeCoinView: View {
    let currentHomeCoin: Int
    let maxHomeCoin: Int
    let homeCoinRecoveryTime: String

    var body: some View {
        HStack {
            Image("JarOfRiches")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20, alignment: .center)
            Text("Realm currency")
            Spacer()
            Text("\(currentHomeCoin)/\(maxHomeCoin)")
                .font(.system(.body, design: .monospaced).bold())
        }
    }
}

struct ExtraTaskRewardView: View {
    let remainResinDiscountNum: Int
    let resinDiscountNumLimit: Int
    let isExtraTaskRewardReceived: Bool

    var body: some View {
        HStack {
            Image("Domain")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20, alignment: .center)
            Text("Weekly bosses")
            Spacer()
            Text("\(remainResinDiscountNum)/\(resinDiscountNumLimit)")
                .font(.system(.body, design: .monospaced).bold())
        }
    }
}

struct ParametricTransformerView: View {
    let transformer: Transformer

    func formatRecoveryTime(recoveryTime: RecoveryTime) -> String {
        if recoveryTime.reached {
            return "✔"
        } else {
            return recoveryTime.Day != 0 ? "\(recoveryTime.Day)\(String.localized("d"))" :
                recoveryTime.Hour != 0 ? "\(recoveryTime.Hour)\(String.localized("h"))"
                : "\(recoveryTime.Minute)\(String.localized("m"))"
        }
    }

    var body: some View {
        HStack {
            Image("ParametricTransformer")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20, alignment: .center)
            Text("Parametric Transformer")
            Spacer()
            if transformer.obtained {
                Text(formatRecoveryTime(recoveryTime: transformer.recovery_time))
                    .font(.system(.body, design: .monospaced).bold())
            } else {
                Text("🚫")
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuExtrasView()
            .frame(width: 280.0)
            .frame(height: 430.0)
    }
}
