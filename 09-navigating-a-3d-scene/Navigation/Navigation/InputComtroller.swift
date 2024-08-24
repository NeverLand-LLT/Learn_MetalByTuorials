///// Copyright (c) 2023 Kodeco Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import GameController

class InputComtroller {
    static let shared = InputComtroller()
    
    var keysPressed: Set<GCKeyCode> = []
    
    private init() {
        let center = NotificationCenter.default
        center.addObserver(
            forName: .GCKeyboardDidConnect,
            object: nil,
            queue: nil) { notification in
                let keyboard = notification.object as? GCKeyboard
                keyboard?.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
                    if pressed {
                        self.keysPressed.insert(keyCode)
                    } else {
                        self.keysPressed.remove(keyCode)
                    }
                }
            }
        
        // 解决点击会发送嘟嘟声音，
        /*
         仅在 macOS 上，您可以通过处理任何按键并告诉系统在按键时不需要采取操作来中断视图的响应程序链。对于 iPadOS，您不需要执行此操作，因为 iPad 不会发出键盘噪音。、
        注意：您可以在此代码中将键添加到keysPressed，而不是使用观察器。然而，这在 iPadOS 上不起作用，并且 GCKeyCode 比 NSEvent 为您提供的原始键值更容易阅读。
         */
#if os(macOS)
        NSEvent.addLocalMonitorForEvents(
            matching: [.keyUp, .keyDown]) { _ in nil }
#endif
    }
}
