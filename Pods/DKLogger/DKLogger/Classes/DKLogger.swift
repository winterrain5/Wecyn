/*
 
 Level    Description
 .trace
 Appropriate for messages that contain information only when debugging a program.
 .debug
 Appropriate for messages that contain information normally of use only when debugging a program.
 .info
 Appropriate for informational messages.
 .notice
 Appropriate for conditions that are not error conditions, but that may require special handling.
 .warning
 Appropriate for messages that are not error conditions, but more severe than .notice
 .error
 Appropriate for error conditions.
 .critical
 Appropriate for critical error conditions that usually require immediate attention.
 */
/*
 [2021-03-15 10:53:34] [WARN] [rtc(日志标签)] 具体内容
 WARN/INFO/ERROR/DEBUG
 */
import Foundation
import UIKit

public enum LogLevel:Int,CustomStringConvertible {
    
    case Debug
    case Info
    case Warn
    case Error
    
    public var description: String {
        switch self {
        case .Error:
            return "❎ERROR"
        case .Info:
            return "📪INFO"
        case .Warn:
            return "⚠️WARN"
        case .Debug:
            return "🐎DEBUG"
        }
    }
    
}
open class Logger {
    
    public static var isEnableWriteToFileInDebugMode:Bool = false
    public static var cacheDirectory = NSHomeDirectory() + "/Documents/Logs"
    public static var cacheTxtName = "LogFile"
    
    public static func debug<T>(_ message:T,
                         label:String = "",
                         _ file: String = #file,
                         _ line: Int = #line) {
        innerprint(message, .Debug, label, file, line)
    }
    
    public static func info<T>(_ message:T,
                        label:String = "",
                        _ file: String = #file,
                        _ line: Int = #line) {
        innerprint(message, .Info, label, file, line)
    }
    
    public static func warn<T>(_ message:T,
                        label:String = "",
                        _ file: String = #file,
                        _ line: Int = #line) {
        innerprint(message, .Warn, label, file, line)
    }
    
    public static func error<T>(_ message:T,
                         label:String = "",
                         _ file: String = #file,
                         _ line: Int = #line) {
        innerprint(message, .Error, label, file, line)
    }
    
    private static func innerprint<T>(_ message:T,
                                   _ level:LogLevel,
                                   _ label:String,
                                   _ file: String,
                                   _ line: Int) {
        checkOldFile()
        let fileName = (file as NSString).lastPathComponent
        let date = dateFormater("yyyy-MM-dd HH:mm:ss.sss")
        var output = ""
        if label.isEmpty {
            output = "[\(date)] [\(level.description)] [\(fileName).\(line)] \(message)"
        }else {
            output = "[\(date)] [\(level.description)] [\(fileName).\(line)] [\(label)] \(message)"
        }
        if isEnableWriteToFileInDebugMode {
            writeToFile(output)
        }else {
            if level.rawValue > LogLevel.Debug.rawValue {
                writeToFile(output)
            }
        }
        print(output)
    }
    
    private static func writeToFile(_ logString:String) {
        DispatchQueue.global().async {
            let fileManager = FileManager.default
            do {
                try fileManager.createDirectory(atPath: cacheDirectory,
                                                withIntermediateDirectories: true, attributes: nil)
                let filePath = dateFormater("yyyy.MM.dd").appending("-\(cacheTxtName).txt")
                guard let logURL = URL(string: asNSString(cacheDirectory).appendingPathComponent(filePath)) else { return }
                appendText(fileURL: logURL, string: logString)
            } catch {
                print("failed to crateDirectory: \(error)")
            }
        }
      
    }
    
    private static func appendText(fileURL: URL, string: String) {
        do {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            }
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            let stringToWrite = "\n" + string + "\n"
            
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
            
        } catch let error as NSError {
            print("failed to append: \(error)")
        }
    }

    private static func checkOldFile() {
        let manager = FileManager.default
        do {
            guard let fileArray = manager.subpaths(atPath: cacheDirectory) else { return }
            for file in fileArray{
                let filePath = asNSString(cacheDirectory).appendingPathComponent(file)
                let attributes = try manager.attributesOfItem(atPath: filePath)
                guard let createDate = attributes[FileAttributeKey.creationDate] as? Date else { return }
                let dateSince = daysSince(date: Date(), otherDate: createDate)
                if dateSince > 5 {
                    try manager.removeItem(atPath: cacheDirectory + "/\(file)")
                }
            }
        } catch  {
            print("failed to get attributes of item:\(error)")
        }
        
    }
}

extension Logger {
    private static func dateFormater(_ format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }
    private static func daysSince(date:Date,otherDate:Date) -> Double {
        return date.timeIntervalSince(otherDate)/(3600*24)
    }
    private static func asNSString(_ string:String) -> NSString {
        return (string as NSString)
    }
}

