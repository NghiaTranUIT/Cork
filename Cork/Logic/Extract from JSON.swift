//
//  Extract from JSON.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

enum WhatToExtract: String
{
    case description = "desc"
    case homepage
    case tap = "tap"
    case version
}

func extractPackageInfo(rawJSON: String, whatToExtract: WhatToExtract) throws -> String
{
    let regex = "(?<=\(whatToExtract.rawValue)\": \").*?(?=\")"

    return try regexMatch(from: rawJSON, regex: regex)
}
