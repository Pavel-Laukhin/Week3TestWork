//
//  BruteForceOperation.swift
//  Week3TestWork
//
//  Created by Павел on 13.08.2020.
//  Copyright © 2020 E-legion. All rights reserved.
//

import UIKit

class BruteForceOperation: Operation {
    
    /// Номер потока
    let thread: Int
    
    /// Число потоков
    let threadsCount: Int
    
    /// Cтрока, содержащая допустимые символы
    let availableCharacters: String
    
    /// Введенный пароль, который собираемся искать
    let inputPassword: String
    
    /// Очередь типа OperationQueue
    let queue: OperationQueue
    
    var result: String?
    
    init(thread: Int, threadsCount: Int, availableCharacters: String, inputPassword: String, queue: OperationQueue) {
        self.thread = thread
        self.threadsCount = threadsCount
        self.availableCharacters = availableCharacters
        self.inputPassword = inputPassword
        self.queue = queue
    }
    
    override func main() {
        
        /// Массив из допустимых символов
        var charactersArray = [String]()
        for i in availableCharacters {
            charactersArray.append(String(i))
        }
        
        /// Текущий массив индексов. Сначала присваиваем последнему элементу текущего массива индексов его начальное значение, зависящее от номера текущего потока:
        var currentIndexArray = [0, 0, 0, thread]
        
        /// Максимальный индекс. Может быть не больше числа элементов в массиве символов.
        let maxIndexValue = charactersArray.count - 1
        
        /// Флажок, определяющий, когда остановиться циклу While
        var isCheckedAll = false
        
        /// Номер итерации. Для дебаггинга.
        var iteration = 0
        
        // Основной цикл, который проверяет текущий пароль с искомым. Прерывается, если пароль найден или если все комбинации символов перепробованы.
        while true && !isCancelled {
            
            // Формируем строку проверки пароля из элементов массива символов.
            let currentPass = charactersArray[currentIndexArray[0]] + charactersArray[currentIndexArray[1]] + charactersArray[currentIndexArray[2]] + charactersArray[currentIndexArray[3]]
            
            // Выходим из цикла если пароль найден, или, если дошли до конца массива индексов.
            if inputPassword == currentPass {
                
                // для дебаггинга
                //print("\(currentIndexArray)   поток \(thread + 1) - итерация \(iteration)")
                //print("\(currentPass)   поток \(thread + 1) - итерация \(iteration)")
                print("I found! Password is \"\(currentPass)\"    поток \(thread + 1) - итерация \(iteration)")
                
                result = currentPass
                queue.cancelAllOperations()
                
                // для дебаггинга
                print("---------------All canceled in thread \(thread + 1)")
                
                break
            } else {
                if isCheckedAll {
                    
                    // для дебаггинга
                    print("Всё проверено, пароль не найден in thread \(thread + 1).")
                    
                    break
                }
                
                // для дебаггинга
                //print("\(currentIndexArray)   поток \(thread + 1) - итерация \(iteration)")
                //print("\(currentPass)   поток \(thread + 1) - итерация \(iteration)")
                iteration += 1
                
                // Если пароль не найден, то происходит увеличение индекса. Для этого в цикле, начиная с последнего элемента осуществляется проверка текущего значения. Если оно меньше максимального значения (61), то индекс просто увеличивается на 1.
                // Например было [0, 0, 0, 5] а станет [0, 0, 0, 6]. Если же мы уже проверили последний индекс, например [0, 0, 0, 61], то нужно сбросить его в 0, а "старший" индекс увеличить на 1. При этом далее в цикле проверяется переполение "старшего" индекса тем же алгоритмом.
                // Таким образом [0, 0, 0, 61] станет [0, 0, 1, 0]. И поиск продолжится дальше:  [0, 0, 1, 1],  [0, 0, 1, 2],  [0, 0, 1, 3] и т.д.
                for index in (0 ..< currentIndexArray.count).reversed() {
                    
                    let newValue = currentIndexArray[index] + threadsCount
                    let isLastItemInArray = index == currentIndexArray.count - 1
                    let isFirstIntemInArray = index == 0
                    
                    // Проверка значения текущего элемента массива.
                    // Когда значение текущего элемента массива равно или больше максимально допустимого, то возможны два варианта:
                    //      Если это последний элемент массива, то его значение становится равным разнице между его новым значением и максимально допустимым, то есть становится равным тому, что сверх максимально возможного и наш цикл for переключается на следующий индекс (из-за "continue"). После чего следующий элемент массива просто увеличивается на 1 (ниже, в условии if).
                    //      Если это индекс первого элемента, то наш цикл For прекращается, isCheckedAll становится true, и соответственно цикл While тоже прекращается, так как все варианты перебраны, и пароль не найден.
                    //      Если это индекс всех остальных элементов кроме первго и последнего, то значение по данному индексу просто обнуляется и цикл переключается на следующий индекс, который дальше (ниже) увеличится на 1.
                    guard currentIndexArray[index] < maxIndexValue else {
                        if isLastItemInArray {
                            currentIndexArray[index] = newValue - maxIndexValue - 1
                            continue
                        } else if isFirstIntemInArray {
                            isCheckedAll = true
                            break
                        } else {
                            currentIndexArray[index] = 0
                            continue
                        }
                    }
                    
                    // Если индекс соответствует последнему элементу массива, то индекс становится равным либо новому значению, либо величине, превыщающей максимально возможное значение. Если это не последний элемент массива, то его индекс просто увеличивается на единицу.
                    if isLastItemInArray {
                        
                        if newValue <= maxIndexValue {
                            currentIndexArray[index] = newValue
                            break
                        } else {
                            currentIndexArray[index] = newValue - maxIndexValue - 1
                            continue
                        }
                    } else {
                        currentIndexArray[index] += 1
                        break
                    }
                }
            }
        }
    }
    
}
