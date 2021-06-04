#Date Select Function
Function DateSelect {
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$calendarform = New-Object Windows.Forms.Form -Property @{
    StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
    Size          = New-Object Drawing.Size 243, 230
    Text          = 'Select a Date'
    Topmost       = $true
}

$calendar = New-Object Windows.Forms.MonthCalendar -Property @{
    ShowTodayCircle   = $false
    MaxSelectionCount = 1
}
$calendarform.Controls.Add($calendar)

$calendarOKButton = New-Object Windows.Forms.Button -Property @{
    Location     = New-Object Drawing.Point 38, 165
    Size         = New-Object Drawing.Size 75, 23
    Text         = 'OK'
    DialogResult = [Windows.Forms.DialogResult]::OK
}
$calendarform.AcceptButton = $calenderOKButton
$calendarform.Controls.Add($calendarOKButton)

$calendarCancelButton = New-Object Windows.Forms.Button -Property @{
    Location     = New-Object Drawing.Point 113, 165
    Size         = New-Object Drawing.Size 75, 23
    Text         = 'Cancel'
    DialogResult = [Windows.Forms.DialogResult]::Cancel
}
$calendarform.CancelButton = $calendarCancelButton
$calendarform.Controls.Add($calendarCancelButton)

$calendarresult = $calendarform.ShowDialog()

if ($calendarresult -eq [Windows.Forms.DialogResult]::OK) {
    $date = $calendar.SelectionStart
    Write-Host "Date selected: $($date.ToShortDateString())"
    }
}
DateSelect