#Requires -Version 4.0
#Requires -RunAsAdministrator

<#
.Synopsis
   Script para definir o tipo de sincronismo em servidores remotos
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
. TO THINK
  A origem da vida não pode ter ocorrido por meio de um processo gradual, mas instantâneo [pois] toda máquina precisa ter um número correto de partes para funcionar...Até mesmo a bactéria requer milhares de genes
  para executar para executarem as funções necessárias à vida...A espécie mais simples de bactéria, Clamídia e Rickéttsia [que são] tão pequenas quanto possível para ainda serem um ser vivo..requerem milhões de partes 
  atômicas...Todas as inúmeras macromoléculas necessárias para a vida são construídas a partir de átomos...compostos de partes ainda menores...e a única discussão é sobre como inúmeroas milhões de partes funcionalmente integradas são necessárias...
  De maneira muito simples, a vida depende de um arranjo complexo de três classes de moléculas: DNA, que armazena o planejamento completo; RNA, que transporta uma cópia da informação contida no DNA para a estação de montagem de proteína; e as proteínas,
  que compõe tudo desde os ribossomos até as enzimas.
  Além disso, chaperonas e muitas outras ferramentas de montagem são necessárias para garantir que a proteína será corretamente montada. Todas estas partes são necessárias e precisam existir como uma unidade propriamente montada e integrada...
  As partes não poderiam evoluir separadamente e não poderiam existir independentemente por muito tempo, pois elas se decomporiam no ambiente sem proteção...
  Por este motivo, somente uma criação instantânea de todas as partes necessárias de uma unidade em funcionamento poderia produzir vida.
  Nenhum dispositivo convincente já foi apresentado que refute esta conclusão é há muita evidência em favor da exigência de uma criação instantânea...Uma célula só pode vir através de uma célula em funcionamento e não pode ser construída de maneira fragmentada...
  Para existir como organismo vivo, o corpo humano precisa ter sido criado completo. 1

  1. Bergman, In Six Days, 15-21

.AUTHOR
  Juliano Alves de Brito Ribeiro (jaribeiro@uoldiveo.com or julianoalvesbr@live.com or https://github.com/julianoabr)
.VERSION
  0.4
.ENVIRONMENT
  PROD
#>

Clear-Host

$shortDate = (Get-date -Format "ddMMyyyy").ToString()

#Function to Send Mail
function Send-PoshMail
{
    [CmdletBinding()]
    [Alias('spsmail')]
    Param
    (
        [parameter(
               Mandatory=$true,
               HelpMessage='Activates the e-mail sending feature ($true/$false). The default value is "$false"',
               Position=0)]
               [System.Boolean]$sendMail = $True,
       
        [parameter(
                Mandatory=$false,
                HelpMessage='SMTP Server Address (Like IP address, hostname or FQDN)',
                Position=1)]
                [System.String]$smtpServer = "yoursmtpserver.yourdomain.com",

        [parameter(
                Mandatory=$false,
                HelpMessage='SMTP Server port number (Default 25)',
                Position=2)]
                [ValidateSet(25,587,465,2525)]
                [int]$smtpPort = "25",
        [parameter(
                Mandatory=$false,
                HelpMessage='Sender e-mail address',
                Position=3)]
                [System.String]$mailFrom = "powershellrobot@yourdomain.com",

        [parameter(
                Mandatory=$false,
                HelpMessage='Recipient e-mail address',
                Position=4)]
               [System.Array]$mailTo = ("yourteam@yourdomain.com"),
                 
                 
        [parameter(
                Mandatory=$false,
                HelpMessage='Copied e-mail address',
                Position=5)]
               [System.Array]$mailCC = "yourboss@yourdomain.com" ,
                      
        [parameter(
                Mandatory=$false,
                HelpMessage='Subject of E-mail',
                Position=6)]
                [System.String]$mailSubject = "[DOMAIN-MASTER] Login Logoff Specific Account",

        [parameter(
                Mandatory=$false,
                HelpMessage='If Body of e-mail is HTML',
                Position=7)]
                [System.Boolean]$htmlBody=$false,

        
        [parameter(
                Mandatory=$false,
                HelpMessage='Body of E-mail',
                Position=8)]
                [System.String]$mailMsgBody,
        
        [parameter(
                Mandatory=$false,
                HelpMessage='Mail Priority',
                Position=9)]
                [ValidateSet('High','Low','Normal')]
                [System.String]$mailPriority = 'Normal',
                      
        [parameter(
                Mandatory=$false,
                HelpMessage='Encoding Language',
                Position=10)]
                [ValidateSet('ASCII','UTF8','UTF7','UTF32','Unicode','BigEndianUnicode','Default','OEM')]
                [System.String]$mailEncoding = 'UTF8',
        
        [parameter(
                Mandatory=$false,
                HelpMessage='Attachments',
                Position=11)]
                [System.String[]]$mailAttachments 

    )

#VERIFY SEND MAIL
if ($SendMail){
        
    if ($htmlBody){
    
        Send-MailMessage -SmtpServer $SmtpServer -Port $smtpPort -From $mailFrom -To $mailTo -Cc $mailCC -Subject $mailSubject -BodyAsHtml $mailMsgBody -Attachments $mailAttachments -Priority $mailPriority -Encoding $mailEncoding
    
    
    }#end of if HTML BODY
    else{
    
         Send-MailMessage -SmtpServer $SmtpServer -Port $SmtpPort -From $MailFrom -To $MailTo -Cc $MailCC -Subject $MailSubject -Body $MailMsgBody -Attachments $mailAttachments -Priority $MailPriority -Encoding $MailEncoding
    
    
    }#end of Else Not Send HTML BODY
    

}#end of IF
else{


   Write-Host "Send E-mail is defined to: $SendMail. So I will not send =D" -ForegroundColor White -BackgroundColor DarkGreen

}#end of Else
    

}#End of Function

#Get Current Location to Run Script
$Script_Parent = Split-Path -Parent $MyInvocation.MyCommand.Definition

$script_Resume = $Script_Parent + "\Report\Login-$shortDate-ResumeReport.txt"

$script_File = $Script_Parent + "\Report\Login-$shortDate-Report.txt"

if (Test-Path "$Script_Parent\Report"){

    Write-Host "Directory to Generate File Already Exists" -ForegroundColor Green

} 
else{

    Write-Host "Directory to Generate File Doesn't Exists" -ForegroundColor White -BackgroundColor Red

    New-Item -Path "$Script_Parent\" -ItemType Directory -Name 'Report' -Force -Verbose 
    
}

#GET HYPER-V SERVERS 
$hostHyperVList = @()

$hostHyperVList = Get-ADComputer -Filter {dnshostname -like "*prefix-server-name*"} | Select-Object -ExpandProperty Name | Sort-Object

$specificMachines = @()

$specificMachines = ('server1','server2','server3','server4')

$finalHostList = @()

$finalHostList += $hostHyperVList

$finalHostList += $specificMachines

[int]$hoursToSearch = -24

$trimDate = (Get-date).AddHours($hoursToSearch)

$userList = @()

$userList = 'liarUser1','liarUser2', 'liarUser666'

[System.String]$logToSearch = 'Security'

#https://docs.microsoft.com/pt-br/windows/security/threat-protection/auditing/event-4624
$eventToSearch = '4624'

$foundEvents = @()

#Get Event Log
foreach ($finalHost in $FinalHostList)
{
    
    foreach ($userToSearch in $userList)
    {
        
        $foundEvents = Get-EventLog -LogName $logToSearch -ComputerName $finalHost -ErrorAction SilentlyContinue | Where-Object -FilterScript {$PSItem.EventID -eq $eventToSearch -and $PSItem.TimeGenerated -ge $trimDate -and $PSItem.ReplacementStrings[5] -eq $userToSearch} 
    
        $numberOfEVents = $foundEvents.count

        Write-Output "Server: $finalHost. I found $numberOfEvents Events of ID: $eventToSearch of User: $userToSearch" | Out-File -FilePath $script_Resume -Append

        $foundEvents | Format-List * | Out-File -FilePath $script_File -Append

        Write-Output "`n" | Out-File -FilePath $script_File -Append
        

    }#end of Foreach UserList

  

}#end ForEach Server


$MsgBody = "Login Logoff Events. View Compressed Attachment"

Set-location "$Script_Parent\Report"

#Get Login Events and Compress
Get-ChildItem -File -Include *.txt -Depth 1 | Where-Object -FilterScript {$_.Name -like "*$shortDate*" -and $PSItem.Name -like '*Login*'} | Compress-Archive -DestinationPath "$script_Parent\Report\LoginReport-$shortDate.zip" -CompressionLevel Optimal -Verbose

Start-Sleep -Seconds 5 -Verbose

#Delete Txt Files
Get-ChildItem -File -Include *.txt -Depth 1 | Where-Object -FilterScript {$_.Name -like "*$shortDate*" -and $PSItem.Name -like '*Login*'} | Remove-Item -Force -Verbose

$fileLocation = "$Script_Parent\Report"

$tmpAttachs = @()

$tmpAttachs = Get-ChildItem -File -Include *.zip -Depth 1 | Where-Object -FilterScript {$_.Name -like "*$shortDate*"} | Select-Object -ExpandProperty FullName


Send-PoshMail -sendMail $true -htmlBody $false -mailMsgBody $msgBody -mailAttachments $tmpAttachs

