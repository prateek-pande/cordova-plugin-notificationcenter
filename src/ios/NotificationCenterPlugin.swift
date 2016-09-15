import Foundation;

@objc(NotificationCenterPlugin) class NotificationCenterPlugin : CDVPlugin {
    dynamic var allNotificationsObserver: AnyObject? = nil;
    dynamic var addedObservers = [String: AnyObject]();

    func addObserver(command: CDVInvokedUrlCommand) {
        let notificationCenter = NSNotificationCenter.defaultCenter();
        let notificationName = command.arguments[0] as! String;

        if(notificationName == "all" && allNotificationsObserver == nil){
            allNotificationsObserver = notificationCenter.addObserverForName(nil, object: nil, queue: nil) { [weak self] notification -> Void  in
                self?.didReceiveNotification(notification, command: command);
            };
        }

        if(notificationName != "all"){
            let observer = notificationCenter.addObserverForName(notificationName, object: nil, queue: nil) { [weak self] notification -> Void in
                self?.didReceiveNotification(notification, command: command);
            };
            addedObservers[notificationName] = observer;
        }

    }

    func removeObserver(command: CDVInvokedUrlCommand) {
        let notificationCenter = NSNotificationCenter.defaultCenter();
        let notificationName = command.arguments[0] as! String;

        if(notificationName == "all"){
            if(allNotificationsObserver != nil){
                notificationCenter.removeObserver(allNotificationsObserver!);
                allNotificationsObserver = nil;
            }

            if(addedObservers.count != 0){
                for(_,observer) in addedObservers{
                    NSNotificationCenter.defaultCenter().removeObserver(observer);
                }

                addedObservers.removeAll();
            }
        }

        if(notificationName != "all"){
            if(addedObservers[notificationName] != nil){
                notificationCenter.removeObserver(addedObservers[notificationName]!, name: notificationName, object: nil);
                addedObservers.removeValueForKey(notificationName);
            }
        }
    }

    private func didReceiveNotification (notification: NSNotification, command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsDictionary: notification.userInfo);
        pluginResult.setKeepCallbackAsBool(true);
        commandDelegate!.sendPluginResult(pluginResult, callbackId:command.callbackId);
    }
}
