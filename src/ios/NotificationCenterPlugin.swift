import Foundation;

@objc(NotificationCenterPlugin) class NotificationCenterPlugin : CDVPlugin {
    dynamic var allNotificationsObserver: AnyObject? = nil;
    dynamic var addedObservers = [String: AnyObject]();
    
    func addObserver(_ command: CDVInvokedUrlCommand) {
        let notificationCenter = NotificationCenter.default;
        let notificationName = command.arguments[0] as! String;
        
        if(notificationName == "all" && allNotificationsObserver == nil){
            allNotificationsObserver = notificationCenter.addObserver(forName: nil, object: nil, queue: nil) { [weak self] notification -> Void  in
                self?.didReceiveNotification(notification, command: command);
            };
        }
        
        if(notificationName != "all"){
            let observer = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: notificationName), object: nil, queue: nil) { [weak self] notification -> Void in
                self?.didReceiveNotification(notification, command: command);
            };
            addedObservers[notificationName] = observer;
        }
        
    }
    
    func postNotification(_ command: CDVInvokedUrlCommand) {
        let notificationCenter = NotificationCenter.default;
        let notificationName = command.arguments[0] as! String;
        
        var userInfo:[AnyHashable : Any] = [AnyHashable : Any]()
        
        if command.arguments.count > 1 {
            if (command.arguments[1] is [AnyHashable : Any]) {
                userInfo = command.arguments[1] as! [AnyHashable : Any]
            }
            
        }
        
        
        print(command.arguments)
        
        if !notificationName.isEmpty {
            //[AnyHashable : Any]?
            notificationCenter.post(name: NSNotification.Name(rawValue: notificationName),
                                    object: nil,
                                    userInfo: userInfo)
        }
        
        
    }
    
    func removeObserver(_ command: CDVInvokedUrlCommand) {
        let notificationCenter = NotificationCenter.default;
        let notificationName = command.arguments[0] as! String;
        
        if(notificationName == "all"){
            if(allNotificationsObserver != nil){
                notificationCenter.removeObserver(allNotificationsObserver!);
                allNotificationsObserver = nil;
            }
            
            if(addedObservers.count != 0){
                for(_,observer) in addedObservers{
                    NotificationCenter.default.removeObserver(observer);
                }
                
                addedObservers.removeAll();
            }
        }
        
        if(notificationName != "all"){
            if(addedObservers[notificationName] != nil){
                notificationCenter.removeObserver(addedObservers[notificationName]!, name: NSNotification.Name(rawValue: notificationName), object: nil);
                addedObservers.removeValue(forKey: notificationName);
            }
        }
    }
    
    fileprivate func didReceiveNotification (_ notification: Notification, command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: notification.userInfo);
        pluginResult?.setKeepCallbackAs(true);
        commandDelegate!.send(pluginResult, callbackId:command.callbackId);
    }
}
