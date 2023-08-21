//
//  calendar.swift
//  calendar
//
//  Created by Derrick on 2023/8/9.
//

import WidgetKit
import SwiftUI

struct EventColor {
    static var allColor:[String] {
        return ["13A5D6","136ED6","0943B2","5451E1","692BB7","C33A7C","EA6A6A","2F9A94","6FC23C","F2AF02","C27502","888888"]
    }
    static var defaultColor: String = "13A5D6"
}


struct CalendarModel: Identifiable,Codable {
    var id: Int = 0
    var title:String = ""
    var start_time:String = ""
    var end_time:String = ""
    var color:Int = 0
    
    var start_date:Date? {
        return formatString(format: "dd-MM-yyyy HH:ss", dateStr: start_time)
    }
    var end_date:Date? {
        return formatString(format: "dd-MM-yyyy HH:ss", dateStr: end_time)
    }
    var distance:TimeInterval  {
        guard let start = start_date else { return 0 }
        return start.distance(to: Date())
    }
}


struct Provider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.widget.calendar")
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),datas: [CalendarModel(id: 1, title: "New Event", start_time: "09:00", end_time: "09:39")])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),datas:[CalendarModel(id: 1, title: "New Event", start_time: "09:00", end_time: "09:39")])
        completion(entry)
    }
  
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
      
        let currentDate = Date()
              //设定1小时更新一次数据
        let updateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        getCalendarDatas { datas in
            let entry = Entry(date: currentDate, datas: datas)
            let timeline = Timeline(entries: [entry], policy: .after(updateDate))
            completion(timeline)
        }
    }
    
    func getCalendarDatas(complete:@escaping ([CalendarModel])->()) {
        guard let id = userDefaults?.object(forKey: "userId"),let token = userDefaults?.object(forKey: "token") as? String,let baseurl = userDefaults?.object(forKey: "baseUrl") as? String else {
            complete([])
            return
        }

        let date = formatDate(format: "dd-MM-yyyy", date: Date())
        let url: URL = URL(string: baseurl + "/api/schedule/searchList/?current_user_id=\(id)&end_date=\(date)&start_date=\(date)")!
                
        var request: URLRequest = URLRequest(url: url)
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let configration = URLSessionConfiguration.default
        let session =  URLSession(configuration: configration)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
                    if error == nil {
                        do {
                            let result: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                            print(result)
                            DispatchQueue.main.async {
                                guard let data = result["data"] as? [[String:Any]] else {
                                    complete([])
                                    return
                                }
                                let result = data.map({
                                    mapDictionaryToModel($0)
                                })
                                complete(result)
                            }
                        }catch{
                            
                        }
                  }
        }
                
        //5、启动任务
        task.resume()
    }
    
    func mapDictionaryToModel(_ dict:[String:Any]) -> CalendarModel {
        var model = CalendarModel()
        model.id = dict["id"] as? Int ?? 0
        model.title = dict["title"] as? String ?? ""
        model.start_time = dict["start_time"] as? String ?? ""
        model.end_time = dict["end_time"] as? String ?? ""
        model.color = dict["color"] as? Int ?? 0
        return model
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let datas:[CalendarModel]
}

struct calendarEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family // 尺寸环境变量
    var body: some View {
        switch family {
        case .systemSmall:
            SmallCalendar(entry: entry, data:entry.datas.sorted(by: { $0.distance < $1.distance }).first)
        case .systemMedium:
            MediumCalendar(entry: entry)
        default:
            LargeCalendarView(entry: entry)
        }
        
    }
    
    
}

// 最多5条数据
struct LargeCalendarView: View {
    var entry: Provider.Entry
    var body: some View {
        VStack {
            HStack {
                CalendarDateView(entry: entry)
                Spacer()
                Link(destination: URL(string: "wecyn://addNewEvent")!) {
                    Image("plus")
                }
               
            }
            if entry.datas.count == 0 {
                Text("No schedule today")
                    .padding(8)
                    .foregroundColor(Color("placeholderColor"))
                    .font(.system(size: 12))
                
            } else {
                VStack(alignment:.leading) {
                    ForEach(entry.datas) {
                        CalendarItemView(data: $0)
                    }
                }
                   
            }
            Spacer()
        }.padding()
    }
}

struct MediumCalendar: View {
    var entry: Provider.Entry
    var body: some View {
        HStack {
            CalendarDateView(entry: entry)
            if entry.datas.count == 0 {
                Text("No schedule today")
                    .padding(8)
                    .foregroundColor(Color("placeholderColor"))
                    .font(.system(size: 12))
            } else {
                VStack(alignment:.leading) {
                    ForEach(entry.datas) {
                        CalendarItemView(data: $0)
                    }
                    Spacer()
                }.padding(.leading,16)
                    .padding(.trailing,16)
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
            CalendarDateView(entry: entry)
            if let data = data {
                CalendarItemView(data: data)
            }else {
                Text("No schedule today")
                    .padding(8)
                    .foregroundColor(Color("placeholderColor"))
                    .font(.system(size: 12))
            }
            
        }).padding(12)
        
        
    }
}

struct CalendarItemView: View {
    var data:CalendarModel
    var body: some View {
        Link(destination: URL(string: "wecyn://checkEventDetail/?id=\(data.id)")!) {
            HStack {
                RoundedRectangle(cornerSize: CGSize(width: 2, height: 2))
                    .foregroundColor(Color(uiColor: UIColor.hexStringColor(hexString: EventColor.allColor[data.color])))
                    .frame(width: 4, height: 32, alignment: .top)
                VStack(alignment: .leading) {
                    Text(data.title)
                    HStack {
                        Text(data.start_time.split(separator: " ").last ?? "")
                        Text("-")
                        Text(data.end_time.split(separator: " ").last ?? "")
                    } .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
                Spacer()
            }
        }
        
    }
}

struct CalendarDateView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    var body: some View {
        VStack(alignment: .leading, content: {
            HStack(alignment:.lastTextBaseline) {
                Text(formatDate(format: "dd", date: entry.date))
                    .font(.system(size: 26))
                    .foregroundColor(Color("monthColor"))
                Text(formatDate(format: "/ MMM", date: entry.date))
                    .font(.system(size: 12))
                    .foregroundColor(Color("monthColor"))
            }
            HStack {
                Text(formatDate(format: "yyyy", date: entry.date))
                    .font(.system(size: 12))
                    .foregroundColor(Color("monthColor"))
                Text(formatDate(format: "EEE", date: entry.date))
                    .font(.system(size: 12))
                    .foregroundColor(Color("monthColor"))
                
            }
            
            if family == .systemMedium {
                
                if entry.datas.count != 0 { Spacer() }
            }
            
        })
    }
}

func formatDate(format:String,date:Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}
func formatString(format:String,dateStr:String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: dateStr)
}

struct calendar: Widget {
    let kind: String = "calendar"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            calendarEntryView(entry: entry)
        }
        .configurationDisplayName("Schedule")
        .description("Quick view of upcoming events.")
        .supportedFamilies([.systemSmall,.systemMedium,.systemLarge])
    }
}

struct calendar_Previews: PreviewProvider {
    static var previews: some View {
        calendarEntryView(entry: SimpleEntry(date: Date(),datas: [CalendarModel(id: 1, title: "Event 1", start_time: "09:00", end_time: "09:39"),CalendarModel(id: 2, title: "Event 1", start_time: "09:00", end_time: "09:39"),CalendarModel(id: 3, title: "Event 1", start_time: "09:00", end_time: "09:39"),CalendarModel(id: 4, title: "your appointment is booked", start_time: "09:00", end_time: "09:39")]))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
//        calendarEntryView(entry: SimpleEntry(date: Date(),datas: [CalendarModel(id: 1, title: "Event 1", start_time: "09:00", end_time: "09:39")]))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension UIColor {
    static func color(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    // MARK: 2.2、十六进制字符串设置颜色(方法)
    static func hexStringColor(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        let newColor = hexStringToColorRGB(hexString: hexString)
        guard let r = newColor.r, let g = newColor.g, let b = newColor.b else {
            assert(false, "颜色值有误")
            return .white
        }
        return color(r: r, g: g, b: b, alpha: alpha)
    }
    static func hexStringToColorRGB(hexString: String) -> (r: CGFloat?, g: CGFloat?, b: CGFloat?) {
        // 1、判断字符串的长度是否符合
        guard hexString.count >= 6 else {
            return (nil, nil, nil)
        }
        // 2、将字符串转成大写
        var tempHex = hexString.uppercased()
        // 检查字符串是否拥有特定前缀
        // hasPrefix(prefix: String)
        // 检查字符串是否拥有特定后缀。
        // hasSuffix(suffix: String)
        // 3、判断开头： 0x/#/##
        if tempHex.hasPrefix("0x") || tempHex.hasPrefix("0X") || tempHex.hasPrefix("##") {
            tempHex = String(tempHex[tempHex.index(tempHex.startIndex, offsetBy: 2)..<tempHex.endIndex])
        }
        if tempHex.hasPrefix("#") {
            tempHex = String(tempHex[tempHex.index(tempHex.startIndex, offsetBy: 1)..<tempHex.endIndex])
        }
        // 4、分别取出 RGB
        // FF --> 255
        var range = NSRange(location: 0, length: 2)
        let rHex = (tempHex as NSString).substring(with: range)
        range.location = 2
        let gHex = (tempHex as NSString).substring(with: range)
        range.location = 4
        let bHex = (tempHex as NSString).substring(with: range)
        // 5、将十六进制转成 255 的数字
        var r: UInt32 = 0, g: UInt32 = 0, b: UInt32 = 0
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        return (r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
    }
}
