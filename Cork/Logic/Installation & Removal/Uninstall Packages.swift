//
//  Uninstall Packages.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import SwiftUI

@MainActor
func uninstallSelectedPackage(package: BrewPackage, brewData: BrewDataStorage, appState: AppState) async throws
{
    appState.isShowingUninstallationProgressView = true

    print("Will try to remove package \(package.name)")
    let uninstallCommandOutput = await shell(AppConstants.brewExecutablePath.absoluteString, ["uninstall", package.name])

    print(uninstallCommandOutput.standardError)

    if uninstallCommandOutput.standardError.contains("because it is required by")
    {
        print("Could not uninstall this package because it's a dependency")

        do
        {
            let dependencyNameExtractionRegex: String = "(?<=required by ).*?(?=, which)"

            var dependencyName: String

            dependencyName = String(try regexMatch(from: uninstallCommandOutput.standardError, regex: dependencyNameExtractionRegex))

            appState.offendingDependencyProhibitingUninstallation = dependencyName
            appState.isShowingUninstallationNotPossibleDueToDependencyAlert = true

            print("Name of offending dependency: \(dependencyName)")
        }
        catch let regexError as NSError
        {
            print("Failed to extract dependency name from output: \(regexError)")
            throw RegexError.foundNilRange
        }
    }
    else
    {
        print("Uninstalling can proceed")

        switch package.isCask
        {
        case false:
            DispatchQueue.main.async
            {
                withAnimation
                {
                    brewData.installedFormulae.removeAll(where: { $0.name == package.name })
                }
            }

        case true:
            DispatchQueue.main.async
            {
                withAnimation
                {
                    brewData.installedCasks.removeAll(where: { $0.name == package.name })
                }
            }
        }
    }

    appState.isShowingUninstallationProgressView = false

    print(uninstallCommandOutput)
}
