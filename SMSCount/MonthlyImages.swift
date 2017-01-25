//
//  BackImageUpdate.swift
//  SMSCount
//
//  Created by Eddie on 2015/10/9.
//  Copyright © 2015年 Wen. All rights reserved.
//

class MonthlyImages {

    let currentMonth: Int

    let firebaseFileUri = "https://firebasestorage.googleapis.com/v0/b/project-36387647498278200.appspot.com/o/"
    let monthFile = [
        "bkg_01_january.png?alt=media&token=8c3a44af-7fe9-4933-bb3e-a9702a478ba7",
        "bkg_02_february.png?alt=media&token=3245c5bd-1d6f-4d1a-a50c-4ecc2de6815e",
        "bkg_03_march.png?alt=media&token=aec23151-6f10-4958-b78d-134c190bcc3a",
        "bkg_04_april.png?alt=media&token=c7cb3f70-866a-4f04-94fa-dffc8db21020",
        "bkg_05_may.png?alt=media&token=7b57a010-d031-42dc-9403-201e7625ba64",
        "bkg_06_june.png?alt=media&token=1048a9ec-6e30-4805-81af-580627d48949",
        "bkg_07_july.png?alt=media&token=4003523e-679c-4a15-9bb2-7f46083c9071",
        "bkg_08_august.png?alt=media&token=4b209631-ca75-4e54-bad1-8e4aaee1cf9b",
        "bkg_09_september.png?alt=media&token=f1a21d2f-58c0-4f1f-96c2-38b10d54dba2",
        "bkg_10_october.png?alt=media&token=3c3f9d9b-b577-4b56-848c-7d932782507b",
        "bkg_11_november.png?alt=media&token=0e9195c1-014c-48ce-9e47-da38b516b71e",
        "bkg_12_december.png?alt=media&token=c6fbf53b-9c64-4969-be2c-c52a65ffcf02"
    ]

    init(month: String) {
        self.currentMonth = Int(month) ?? 1
    }

    func setBackground( _ background: UIImageView ) {

        guard let monthUrl = URL(string: firebaseFileUri + monthFile[self.currentMonth-1]) else {
            return
        }

        Reachability().getImageFromUrl(monthUrl) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    background.image = UIImage(data: data)
                }
            }
        }

    }

}
