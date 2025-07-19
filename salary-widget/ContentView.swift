//
//  ContentView.swift
//  salary-widget
//
//  Created by Airing on 2025/7/19.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text("Settings")
                    .font(.title)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    // 薪资设置
                    SalarySettingsSection(appDelegate: appDelegate)
                    
                    // 工作时间设置
                    WorkingTimeSection(appDelegate: appDelegate)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 400)
        .frame(maxHeight: 450)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct SalarySettingsSection: View {
    @ObservedObject var appDelegate: AppDelegate
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "薪资设置")
            
            VStack(spacing: 12) {
                SettingRow(title: "月薪资", value: "\(Int(appDelegate.monthlyWage))(元)") {
                    TextField("", value: $appDelegate.monthlyWage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
                
                SettingRow(title: "本月工作天数", value: "\(appDelegate.workingDaysThisMonth)天") {
                    Text("\(appDelegate.workingDaysThisMonth)天")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
}


struct WorkingTimeSection: View {
    @ObservedObject var appDelegate: AppDelegate
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Working Time Settings")
            
            VStack(spacing: 12) {
                SettingRow(title: "Starting Time", value: appDelegate.startTime) {
                    TextField("", text: $appDelegate.startTime)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                }
                
                SettingRow(title: "Off-duty Time", value: appDelegate.offDutyTime) {
                    TextField("", text: $appDelegate.offDutyTime)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Weekdays")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    ForEach(Array(zip(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], 1...7)), id: \.1) { day, index in
                        DayButton(
                            title: day,
                            isSelected: appDelegate.selectedDays.contains(index),
                            action: {
                                if appDelegate.selectedDays.contains(index) {
                                    appDelegate.selectedDays.remove(index)
                                } else {
                                    appDelegate.selectedDays.insert(index)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SettingRow<Content: View>: View {
    let title: String
    let value: String
    let content: () -> Content
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct DayButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 35, height: 25)
                .background(isSelected ? Color.green : Color.gray.opacity(0.2))
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppDelegate())
}
