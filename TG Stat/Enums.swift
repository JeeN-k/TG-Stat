//
//  Enums.swift
//  TG Stat
//
//  Created by user on 18.03.2023.
//

import Foundation


enum Stats: Int, CustomStringConvertible, CaseIterable {
    case senders = 1, weekDays, months, words
    
    var description: String {
        get {
            switch self {
            case .senders:
                return "Senders"
            case .weekDays:
                return "Week days"
            case .months:
                return "Months"
            case .words:
                return "Words"
            }
        }
    }
}

enum WeekDays: Int, CustomStringConvertible, CaseIterable
{
    var description: String {
        switch self {
        case .MONDAY:
            return "Понедельник"
        case .TUESDAY:
            return "Вторник"
        case .WEDNESDAY:
            return "Среда"
        case .THURSDAY:
            return "Четверг"
        case .FRIDAY:
            return "Пятница"
        case .SATURDAY:
            return "Суббота"
        case .SUNDAY:
            return "Воскресенье"
        }
    }
    case SUNDAY = 1, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY
}

enum Months: Int, CustomStringConvertible, CaseIterable
{
    var description: String {
        switch self {
        case .JANUARY:
            return "Январь"
        case .FEBRUARY:
            return "Февраль"
        case .MARCH:
            return "Март"
        case .APRIL:
            return "Апрель"
        case .MAY:
            return "Май"
        case .JUNE:
            return "Июнь"
        case .JULY:
            return "Июль"
        case .AUGUST:
            return "Август"
        case .SEPTEMBER:
            return "Сентябрь"
        case .OCTOBER:
            return "Октябрь"
        case .NOVEMBER:
            return "Ноябрь"
        case .DECEMBER:
            return "Декабрь"
        }
    }
    case JANUARY = 1, FEBRUARY, MARCH, APRIL, MAY, JUNE, JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER
}
