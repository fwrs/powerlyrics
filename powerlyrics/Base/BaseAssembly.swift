//
//  BaseAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import ObjectiveC
import Swinject
import UIKit

class Assembly: Swinject.Assembly {
    
    required init() {}
    func assemble(container: Container) {}
    
}

struct ClassInfo: CustomStringConvertible, Equatable {

    let classObject: AnyClass
    
    let className: String
    
    init?(_ classObject: AnyClass?) {
        guard classObject != nil else { return nil }
        
        self.classObject = classObject!
        
        let cName = class_getName(classObject)
        self.className = String(cString: cName)
    }
    
    var superclassInfo: ClassInfo? {
        let superclassObject: AnyClass? = class_getSuperclass(self.classObject)
        return ClassInfo(superclassObject)
    }
    
    var description: String {
        self.className
    }
    
    static func == (lhs: ClassInfo, rhs: ClassInfo) -> Bool {
        lhs.className == rhs.className
    }
}

class Config {
    
    fileprivate static var resolver: Resolver?
    
    static func getResolver() -> Resolver {
        if resolver == nil {
            resolver = makeResolver()
        }
        return resolver!
    }
    
    fileprivate static func makeResolver() -> Resolver {
        let assembler = Assembler(getAllAssembliesInTarget())
        return assembler.resolver
    }
    
    fileprivate static func getAllAssembliesInTarget() -> [Swinject.Assembly] {
        let assemblyClassInfo = ClassInfo(Assembly.self)
        var subclassList: [ClassInfo] = []
        
        var count = UInt32(0)
        let classListPointer = objc_copyClassList(&count)!
        
        let mapped = UnsafeBufferPointer(start: classListPointer, count: Int(count)).compactMap(ClassInfo.init)
        
        for classInfo in mapped {
            if let superclassInfo = classInfo.superclassInfo, superclassInfo == assemblyClassInfo {
                subclassList.append(classInfo)
            }
        }
        
        return subclassList.map { classInfo -> Swinject.Assembly in
            let classObject = classInfo.classObject as! Assembly.Type
            return classObject.init()
        }
    }
    
}

class BaseAssembly: Assembly {
    
    override func assemble(container: Container) {
        container.register(AppDelegate.self) { _ in
            UIApplication.shared.delegate as! AppDelegate
        }.inObjectScope(.container)
        
        container.register(SceneDelegate.self) { _ in
            UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
        }.inObjectScope(.container)
        
        container.register(UIWindow.self) { resolver in
            let window = resolver.resolve(SceneDelegate.self)!.window!
            window.tintColor = .red
            return window
        }.inObjectScope(.container)
    }
    
}
