//
//  salary_widgetApp.swift
//  salary-widget
//
//  Created by Airing on 2025/7/19.
//

import SwiftUI

@main
struct salary_widgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusBarItem: NSStatusItem!
    private var popover: NSPopover!
    private var timer: Timer?
    
    @Published var monthlyWage: Double = 10000 {
        didSet { updateStatusBarView() }
    }
    @Published var startTime: String = "10:00" {
        didSet { updateStatusBarView() }
    }
    @Published var offDutyTime: String = "21:00" {
        didSet { updateStatusBarView() }
    }
    @Published var selectedDays: Set<Int> = [1, 2, 3, 4, 5] { // Mon-Fri
        didSet { updateStatusBarView() }
    }
    @Published var selectedCurrency: String = "USD" {
        didSet { updateStatusBarView() }
    }
    
    var currencySymbol: String {
        switch selectedCurrency {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "JPY": return "¥"
        case "CNY": return "¥"
        case "KRW": return "₩"
        case "INR": return "₹"
        case "SGD": return "$"
        default: return "$"
        }
    }
    
    var availableCurrencies: [String] {
        ["USD", "EUR", "GBP", "JPY", "CNY", "KRW", "INR", "SGD"]
    }
    
    var workingDaysThisMonth: Int {
        calculateWorkingDaysInCurrentMonth()
    }
    
    var dailyWage: Double {
        let workingDays = workingDaysThisMonth
        return workingDays > 0 ? monthlyWage / Double(workingDays) : 0
    }
    
    var hourlyWage: Double {
        let workHours = calculateWorkHours()
        return workHours > 0 ? dailyWage / workHours : 0
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        createStatusBarItem()
        createPopover()
        startTimer()
    }
    
    private func createStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            updateStatusBarView()
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    private func createPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: SettingsView().environmentObject(self))
    }
    
    @objc private func togglePopover() {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    private func startTimer() {
        // Update immediately when starting
        updateStatusBarView()
        
        // Then update every 10 seconds for better responsiveness during testing
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            self.updateStatusBarView()
        }
    }
    
    private func updateStatusBarView() {
        guard let button = statusBarItem.button else { return }
        
        let (progress, todayEarnings) = calculateProgress()
        let progressWidth = Int(progress * 60) // 60px progress bar width
        
        // Debug output
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        print("🔄 Status Bar Update at \(formatter.string(from: now))")
        print("   Monthly Wage: \(currencySymbol)\(monthlyWage)")
        print("   Working Days This Month: \(workingDaysThisMonth)")
        print("   Start Time: \(startTime)")
        print("   Off-duty Time: \(offDutyTime)")
        print("   Selected Days: \(selectedDays)")
        print("   Currency: \(selectedCurrency) (\(currencySymbol))")
        print("   Daily Wage: \(currencySymbol)\(dailyWage)")
        print("   Progress: \(String(format: "%.1f", progress * 100))%")
        print("   Today Earnings: \(currencySymbol)\(todayEarnings)")
        print("   Progress Width: \(progressWidth)px")
        
        // Prepare text content
        let progressText = "\(Int(progress * 100))%"
        let earningsText = todayEarnings >= 1000 ? 
            "\(currencySymbol)\(String(format: "%.1fk", todayEarnings / 1000))" : 
            "\(currencySymbol)\(Int(todayEarnings))"
        let combinedText = "\(progressText) \(earningsText)"
        
        // Calculate required width dynamically
        let tempLabel = NSTextField(labelWithString: combinedText)
        tempLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        tempLabel.sizeToFit()
        let textWidth = tempLabel.frame.width
        
        let totalWidth = 8 + 60 + 8 + textWidth + 8 // padding + progress + gap + text + padding
        
        // Create custom view with dynamic width
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: totalWidth, height: 22))
        
        // Progress bar background
        let progressBg = NSView(frame: NSRect(x: 8, y: 8, width: 60, height: 8))
        progressBg.wantsLayer = true
        progressBg.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.4).cgColor
        progressBg.layer?.cornerRadius = 4
        
        // Progress bar fill
        let progressFill = NSView(frame: NSRect(x: 8, y: 8, width: progressWidth, height: 8))
        progressFill.wantsLayer = true
        progressFill.layer?.backgroundColor = NSColor.systemGreen.cgColor
        progressFill.layer?.cornerRadius = 4
        
        // Combined text label (progress % + earnings)
        let combinedLabel = NSTextField(labelWithString: combinedText)
        combinedLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        combinedLabel.textColor = NSColor.labelColor
        combinedLabel.frame = NSRect(x: 8 + 60 + 8, y: 3, width: textWidth, height: 16)
        combinedLabel.alignment = .left
        combinedLabel.isBezeled = false
        combinedLabel.drawsBackground = false
        combinedLabel.isEditable = false
        combinedLabel.isSelectable = false
        
        containerView.addSubview(progressBg)
        containerView.addSubview(progressFill)
        containerView.addSubview(combinedLabel)
        
        button.subviews.forEach { $0.removeFromSuperview() }
        button.addSubview(containerView)
        
        // Set dynamic width for status bar item
        statusBarItem.length = totalWidth
    }
    
    private func calculateProgress() -> (Double, Double) {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        let currentWeekday = weekday == 1 ? 7 : weekday - 1 // Convert to Mon=1, Sun=7
        
        print("   📅 Today is weekday: \(currentWeekday) (1=Mon, 7=Sun)")
        
        // Check if today is a working day
        guard selectedDays.contains(currentWeekday) else {
            print("   ❌ Today is not a working day")
            return (0.0, 0.0)
        }
        
        print("   ✅ Today is a working day")
        
        let startComponents = parseTime(startTime)
        let endComponents = parseTime(offDutyTime)
        
        let startDate = calendar.date(bySettingHour: startComponents.0, minute: startComponents.1, second: 0, of: now) ?? now
        let endDate = calendar.date(bySettingHour: endComponents.0, minute: endComponents.1, second: 0, of: now) ?? now
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        print("   🕐 Work hours: \(formatter.string(from: startDate)) - \(formatter.string(from: endDate))")
        print("   ⏰ Current time: \(formatter.string(from: now))")
        
        let totalWorkMinutes = endDate.timeIntervalSince(startDate) / 60
        print("   ⏱️ Total work minutes: \(totalWorkMinutes)")
        
        if now < startDate {
            print("   🌅 Before work hours")
            return (0.0, 0.0)
        } else if now > endDate {
            print("   🌆 After work hours")
            return (1.0, dailyWage)
        } else {
            let workedMinutes = now.timeIntervalSince(startDate) / 60
            let progress = workedMinutes / totalWorkMinutes
            let earnings = progress * dailyWage
            print("   🏃 Working: \(workedMinutes) minutes of \(totalWorkMinutes)")
            return (progress, earnings)
        }
    }
    
    private func calculateWorkHours() -> Double {
        let startComponents = parseTime(startTime)
        let endComponents = parseTime(offDutyTime)
        
        let startMinutes = startComponents.0 * 60 + startComponents.1
        let endMinutes = endComponents.0 * 60 + endComponents.1
        
        return Double(endMinutes - startMinutes) / 60.0
    }
    
    private func parseTime(_ timeString: String) -> (Int, Int) {
        let components = timeString.split(separator: ":").map { Int($0) ?? 0 }
        return (components.count >= 2 ? components[0] : 0, components.count >= 2 ? components[1] : 0)
    }
    
    private func calculateWorkingDaysInCurrentMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the current month and year
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start,
              let monthEnd = calendar.dateInterval(of: .month, for: now)?.end else {
            return 0
        }
        
        var workingDays = 0
        var currentDate = monthStart
        
        // Iterate through each day of the month
        while currentDate < monthEnd {
            let weekday = calendar.component(.weekday, from: currentDate)
            let currentWeekday = weekday == 1 ? 7 : weekday - 1 // Convert to Mon=1, Sun=7
            
            // Check if this day is in the selected working days
            if selectedDays.contains(currentWeekday) {
                workingDays += 1
            }
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? monthEnd
        }
        
        return workingDays
    }
}
