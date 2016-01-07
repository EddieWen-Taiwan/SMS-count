//
//  FacebookLogin.swift
//  SMSCount
//
//  Created by Eddie on 1/7/16.
//  Copyright © 2016 Wen. All rights reserved.
//

import Parse

class FacebookLogin {

    func storeInformation( info: AnyObject ) {
        print(info)
        if let FBID = info.objectForKey("id") {
            let fbIdQuery = PFQuery(className: "UserT")
            fbIdQuery.whereKey( "fb_id", equalTo: FBID )
            fbIdQuery.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error: NSError?) -> Void in
                print(objects)
            }
        }
    }

}