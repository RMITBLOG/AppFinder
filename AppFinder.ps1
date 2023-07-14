﻿Add-Type -AssemblyName System.Windows.Forms

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "App Finder"
$form.Width = 400
$form.Height = 400
$form.StartPosition = "CenterScreen"

# Create a menu bar
$mainMenu = New-Object System.Windows.Forms.MainMenu

# Create a "Help" menu
$menuHelp = New-Object System.Windows.Forms.MenuItem
$menuHelp.Text = "Help"

# Create an "About" menu item
$menuAbout = New-Object System.Windows.Forms.MenuItem
$menuAbout.Text = "About"

# Handle the "About" menu item click event
$menuAbout.Add_Click({
    Start-Process "https://www.alexandrumarin.com"
})

# Add the "About" menu item to the "Help" menu
$menuHelp.MenuItems.Add($menuAbout)

# Add the "Help" menu to the main menu
$mainMenu.MenuItems.Add($menuHelp)

# Set the form's menu to the main menu
$form.Menu = $mainMenu

# Create a label and textbox for the application name
$lblAppName = New-Object System.Windows.Forms.Label
$lblAppName.Text = "Application Name:"
$lblAppName.Location = New-Object System.Drawing.Point(20, 20)
$lblAppName.AutoSize = $true

$txtAppName = New-Object System.Windows.Forms.TextBox
$txtAppName.Location = New-Object System.Drawing.Point(150, 20)
$txtAppName.Width = 200

# Create a button for searching
$btnSearch = New-Object System.Windows.Forms.Button
$btnSearch.Text = "Search"
$btnSearch.Location = New-Object System.Drawing.Point(150, 60)

# Create a text box for displaying the output
$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Multiline = $true
$txtOutput.ScrollBars = "Vertical"
$txtOutput.Location = New-Object System.Drawing.Point(20, 100)
$txtOutput.Width = 360
$txtOutput.Height = 240
$txtOutput.ReadOnly = $true

# Define the search function
function Search {
    $targetAppName = $txtAppName.Text

    # Define the registry paths for uninstall information
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    # Create a string builder to store the output
    $output = New-Object System.Text.StringBuilder

    # Loop through each registry path and retrieve the list of subkeys
    foreach ($path in $registryPaths) {
        $uninstallKeys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

        # Skip if the registry path doesn't exist
        if (-not $uninstallKeys) {
            continue
        }

        # Loop through each uninstall key and append the properties of the target application to the output
        foreach ($key in $uninstallKeys) {
            $keyPath = Join-Path -Path $path -ChildPath $key.PSChildName

            $displayName = (Get-ItemProperty -Path $keyPath -Name "DisplayName" -ErrorAction SilentlyContinue).DisplayName
            $uninstallString = (Get-ItemProperty -Path $keyPath -Name "UninstallString" -ErrorAction SilentlyContinue).UninstallString
            $version = (Get-ItemProperty -Path $keyPath -Name "DisplayVersion" -ErrorAction SilentlyContinue).DisplayVersion
            $publisher = (Get-ItemProperty -Path $keyPath -Name "Publisher" -ErrorAction SilentlyContinue).Publisher
            $installLocation = (Get-ItemProperty -Path $keyPath -Name "InstallLocation" -ErrorAction SilentlyContinue).InstallLocation

            if ($displayName -match $targetAppName) {
                $output.AppendLine("DisplayName: $displayName")
                $output.AppendLine("UninstallString: $uninstallString")
                $output.AppendLine("Version: $version")
                $output.AppendLine("Publisher: $publisher")
                $output.AppendLine("InstallLocation: $installLocation")
                $output.AppendLine("---------------------------------------------------")
            }
        }
    }

    # Set the output text in the text box
    $txtOutput.Text = $output.ToString()
}

# Add the search function to the button click event
$btnSearch.Add_Click({ Search })

# Handle the Enter key press event in the text box
$txtAppName.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq "Enter") {
        Search
    }
})

# Add the controls to the form
$form.Controls.Add($lblAppName)
$form.Controls.Add($txtAppName)
$form.Controls.Add($btnSearch)
$form.Controls.Add($txtOutput)

# Show the form
$form.ShowDialog() | Out-Null
