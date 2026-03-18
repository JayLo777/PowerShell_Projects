#This script will pull your Microsoft Learning Transcript. 
# you will need to use your share link from MS learn.
$TranscriptLink = "https://learn.microsoft.com/en-us/users/jayarloiselle-1091/transcript/dz309sy0lzqn1qk"
#This will open the transcript in your default web browser.
Start-Process $TranscriptLink

#Save the results as a CSV file. You can specify the path and filename as needed.

$TranscriptData = Invoke-WebRequest -Uri $TranscriptLink -UseBasicParsing | Select-Object -ExpandProperty Content
Get-Content .\transcriptReview.csv