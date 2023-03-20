//
//  StatsViewModel.swift
//  TG Stat
//
//  Created by user on 18.03.2023.
//

import Foundation
import Charts

class StatsViewModel {
    var viewInput: StatsViewControllerInputProtocol?
    var selectedStat: Stats = .senders
    var messages: [MessageModel] = []
    
    func processWithData(data: Data) {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let group = try jsonDecoder.decode(GroupModel.self, from: data)
            messages = group.messages
            viewInput?.showSegmentedControl()
            Task {
               await makeBarStats()
            }
        } catch DecodingError.dataCorrupted(let context) {
            print(context)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
    }
    
    func makeStats() async {
        if selectedStat == .words {
            await makeBubbleStats()
        } else {
            await makeBarStats()
        }
    }
    
    func makeBarStats() async {
        let totalMessages = await getTotalMessages()
        var entries = [BarChartDataEntry]()
        var x = 0
        totalMessages.forEach { (key, value) in
            let entry = BarChartDataEntry(x: Double(x), y: Double(value))
            entries.append(entry)
            x += 1
        }
        
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = ChartColorTemplates.colorful()
        let data = BarChartData(dataSet: dataSet)
        DispatchQueue.main.async {
            self.viewInput?.didPreparedData(with: data,
                                       names: totalMessages.map { $0.0.trunc(length: 10) },
                                       count: totalMessages.count)
        }
    }
    
    func makeBubbleStats() async {
        let totalWords = await getTotalMessages()

        DispatchQueue.main.async {
            self.viewInput?.didPreparedData(with: totalWords, names: [])
        }
    }
    
    private func getCountByMonths() async -> [(String, Int)] {
        let groupedMessages = Dictionary(grouping: messages, by: { getMonth($0.date) })
        let sortedMonths = Months.allCases.sorted(by: { $0.rawValue < $1.rawValue })
        
        return sortedMonths.map { month in
            (month.description, groupedMessages[month]?.count ?? 0)
        }
    }
    
    private func getCountByWeekDay() async -> [(String, Int)] {
        let groupedMessages = Dictionary(grouping: messages, by: { getDayOfWeek($0.date) })
        let sortedDays = WeekDays.allCases.sorted(by: { $0.rawValue < $1.rawValue })

        return sortedDays.map { day in
            (day.description, groupedMessages[day]?.count ?? 0)
        }
    }
    
    private func getCountBySender() async -> [(String, Int)] {
        var names: Set<String> = []
        var result: [String: Int] = [:]

        for message in messages {
            if let name = message.from {
                names.insert(name)
            }
        }

        for name in names {
            let count = messages.filter { $0.from == name }.count
            result[name] = count
        }

        return Array(result).sorted(by: { $0.0 < $1.0 })
    }
    
    private func getTopWords(messages: [MessageModel], count: Int) async -> [(String, Int)] {
        var wordCount: [String: Int] = [:]

        for message in messages {
            for textEntity in message.textEntities {
                let words = textEntity.text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
                for word in words {
                    if word.count > 2 {
                        if let count = wordCount[word] {
                            wordCount[word] = count + 1
                        } else {
                            wordCount[word] = 1
                        }
                    }
                }
            }
        }

        let sortedWordCount = wordCount.sorted { $0.value > $1.value }
        let topWords = sortedWordCount.prefix(count).map { ($0.key, $0.value) }
        return topWords
    }
    
    private func getDayOfWeek(_ date: String) -> WeekDays? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let todayDate = formatter.date(from: date) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return WeekDays(rawValue: weekDay)
    }
    
    private func getTotalMessages() async -> [(String, Int)]{
        switch selectedStat {
        case .senders:
            return  await getCountBySender()
        case .weekDays:
            return  await getCountByWeekDay()
        case .months:
            return await getCountByMonths()
        case .words:
            return await getTopWords(messages: messages, count: 100)
        }
    }
    
    private func getMonth(_ date: String) -> Months? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let todayDate = formatter.date(from: date) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let month = myCalendar.component(.month, from: todayDate)
        return Months(rawValue: month)
    }
}
