Enum MsgType
{
    Error = 0
    Warning = 1
    Information = 2
    Ok = 3
    Custom = 4
}


Class MessageObject{
    [MsgType] $Type;
    [string] $Header;
    [string] $Content;
    [string] $HTMLCode

    $Custom = [PSCustomObject]@{
        HCaption        = ""
        HCaptionColor   = ""
        HHeaderColor    = ""
    }

    $HCaption = @{
        'Error'         = "ERROR!!!"
        'Warning'       = "Warning!!!"
        'Information'   = "Information!"
        'Ok'            = "Ok!"
    }
    $HCaptionColor = @{
        'Error'         = "#ed7d31"
        'Warning'       = "#ffc000"
        'Information'   = "#5b9bd5"
        'Ok'            = "#6fac52"
    }

    $HHeaderColor = @{
        'Error'         = "#fbe4d5"
        'Warning'       = "#fff2cc"
        'Information'   = "#deeaf6"
        'Ok'            = "#e2efda"
    }

     MessageObject([MsgType] $TypeIn, [string]$HeaderIn, [string]$ContentIn) {
        $this.Type          = $TypeIn;
        $this.Header        = $HeaderIn;
        $this.Content       = $ContentIn;
        $this.HTMLCode      = $this.BuildHTML()
    }

    MessageObject(
                    [MsgType]   $TypeIn, 
                    [string]    $HeaderIn, 
                    [string]    $ContentIn, 
                    [string]    $Caption,
                    [string]    $CaptionColor,
                    [string]    $HeaderColor) {
        $this.Type = $TypeIn;
        $this.Header = $HeaderIn;
        $this.Content = $ContentIn;
        $this.HCaption.Add("Custom", $Caption)
        $this.HCaptionColor.Add("Custom", $CaptionColor)
        $this.HHeaderColor.Add("Custom", $HeaderColor)
        $this.HTMLCode = $this.BuildHTML()
    }

    [string]GetContrastColor([string]$BaseColor){
        [string]$Result = "white"

            $HEXColor = $BaseColor.Replace("#", "0x")
            #[int]$InvertColor = "0x"+[Convert]::ToString((0xFFFFFF - $HEXColor), 16)
            [int]$InvertColor = 0xFFFFFF - $HEXColor

            if ($InvertColor -le 0x888888){
                $Result = "black"
            }
        #return $InvertColor
        return $Result
    }

    [string]BuildHTML() {
        $Result = $null

        $CaptionColor = $this.HCaptionColor.($this.Type.ToString())
        $HeaderColor = $this.HHeaderColor.($this.Type.ToString())
        
        $TextCaptionColor = $this.GetContrastColor($CaptionColor)
        $TextHeaderColor = $this.GetContrastColor($HeaderColor)
        
        $Result = 
            "<table border=1 cellspacing=0 cellpadding=6 style='border: .5px solid $CaptionColor; font-family: Arial; margin:5px'>
            <tr style='background-color: $CaptionColor'>
            <td style='text-align: center'>
                <span style='color: $TextCaptionColor'>
                    <b>$($this.HCaption.($this.Type.ToString()))</b>
                </span>
            </td>
            </tr>
            <tr style='background-color: $HeaderColor'>
                <td>
                    <span style='color: $TextHeaderColor'>
                        $($this.Header)
                    </span>
                </td>
            </tr>
            <tr>
            <td>
                $($this.Content)
            </td>
            </tr>
            </table>"
        return $Result
    }
	
}



#-=-=-=-=-=-=-=-=-Examle-=-=-=-=-=-=-=-=-
[string]$PTargetUserName = "user"
[datetime]$PPasswordLastSet = Get-Date
$PAccountExpires = "-"

$Content =  "TargetUserName: <b>" + $PTargetUserName + 
            "</b> <br/> PasswordLastSet: <b>" + $PPasswordLastSet.ToString() +
            "</b> <br/> AccountExpires: <b>" + $PAccountExpires + "</b>" 


                       
foreach ($Item in [MsgType].GetEnumNames()){
    [MessageObject]$MsgBox = $null

    If ($Item -eq [MsgType]::Custom){
        $MsgBox = [MessageObject]::new([MsgType]::Custom, 
            "This is a Greate header of message", 
            $Content, 
            "My awesome custom Caption!!!", 
            "#4F5950",
            "#58734C")
    }
    else {
        $MsgBox = [MessageObject]::new($Item, "This is a Greate header of message", $Content)
    }
    
    Write-Host $MsgBox.HTMLCode
    
}