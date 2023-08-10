//
//  calendar.swift
//  calendar
//
//  Created by Derrick on 2023/8/9.
//

import WidgetKit
import SwiftUI
struct CalendarModel: Identifiable{
    var id: Int
    var title:String
    var start_time:String
    var end_time:String
}
struct Provider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "com.terra.wecyn")
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        print(userDefaults?.object(forKey: "token"))
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let datas:[CalendarModel] = [
        CalendarModel(id: 1, title: "Event 1", start_time: "09:00", end_time: "09:39"),
        CalendarModel(id: 2, title: "Event 2", start_time: "13:00", end_time: "13:39"),
        CalendarModel(id: 3, title: "Event 3", start_time: "14:00", end_time: "15:39")
    ]
}

struct calendarEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family // 尺寸环境变量
    var body: some View {
        switch family {
        case .systemSmall:
            SmallCalendar(entry: entry, data:nil)
        case .systemMedium:
            MediumCalendar(entry: entry)
        default:
            SmallCalendar(entry: entry, data:nil)
        }
        
    }
    
    
}

struct MediumCalendar: View {
    var entry: Provider.Entry
    var body: some View {
        HStack {
            VStack(alignment: .leading, content: {

                Text(formatDate(format: "EEE", date: entry.date))
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                Text(formatDate(format: "MMM dd", date: entry.date))
                    .font(.system(size: 22))
                    .foregroundColor(.black)
                if entry.datas.count != 0 { Spacer() }
            })
            if entry.datas.count == 0 {
                Text("No schedule today")
                    .padding(16)
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            } else {
                VStack {
                    ForEach(entry.datas) {
                        CalendarItemView(data: $0)
                    }
                }.padding()
                Spacer()
            }
           
        }.padding()
    }
}

struct SmallCalendar: View {
    
    var entry: Provider.Entry
    var data: CalendarModel?
    var body: some View {
        VStack(alignment: .leading, content: {
            Text(formatDate(format: "EEE", date: entry.date))
                .font(.system(size: 14))
                .foregroundColor(.blue)
            Text(formatDate(format: "MMM dd", date: entry.date))
                .font(.system(size: 22))
                .foregroundColor(.black)
            if let data = data {
                CalendarItemView(data: data)
            }else {
                Text("No schedule today")
                    .padding(16)
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            
        }).padding()
        
        
    }
}

struct CalendarItemView: View {
    var data:CalendarModel
    var body: some View {
        HStack {
            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                .fill(.red)
                .frame(width: 6, height: 40, alignment: .top)
            VStack(alignment: .leading) {
                Text(data.title)
                HStack {
                    Text(data.start_time)
                    Text("-")
                    Text(data.end_time)
                } .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            
        }
    }
}

func formatDate(format:String,date:Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}

struct calendar: Widget {
    let kind: String = "calendar"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            calendarEntryView(entry: entry)
        }
        .configurationDisplayName("Schedule")
        .description("Quick view of upcoming events.")
        .supportedFamilies([.systemSmall,.systemMedium])
    }
}

struct calendar_Previews: PreviewProvider {
    static var previews: some View {
        calendarEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
