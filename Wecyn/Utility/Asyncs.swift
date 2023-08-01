//
//  Asyncs.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/31.
//

import Foundation

struct Asyncs {
    public typealias Task = () -> Void

    public static func async(task: @escaping Task) {
        //传入全局任务
        _async(task: task)
    }

    public static func async(task: @escaping Task,mainTask: @escaping Task) {
        //传入全局任务，主队列任务
        _async(task: task, mainTask: mainTask)
    }

    private static func _async(task: @escaping Task,mainTask: Task? = nil) {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.global().async(execute: item)

        //可选项绑定
        if let main = mainTask {
            //item⾥⾯的任务完成之后，再到主队列执⾏
            item.notify(queue: DispatchQueue.main, execute: main)
        }
    }
}
