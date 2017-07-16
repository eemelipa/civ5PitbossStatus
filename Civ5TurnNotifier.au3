#include <FileConstants.au3>
#include <Date.au3>
#include <ScreenCapture.au3>
#include <Inet.au3>

HotKeySet("{ESC}","EndProgram")

; Score screen
$topscore=307
$leftscore=1102
$botscore=517
$rightscore=1342

; Timer
$toptimer=568
$lefttimer=628
$bottimer=694
$righttimer=737

; Turn indicator coords
$p1coord="520,670"
$p2coord="585,670"
$p3coord="650,670"
$p4coord="715,670"
$p5coord="780,670"
$p6coord="845,670"
$p7coord="910,670"

$p8coord="455,735"
$p9coord="520,735"
$p10coord="585,735"

Local $aCoords[10] = [$p1coord, $p2coord, $p3coord, $p4coord, $p5coord, $p6coord, $p7coord, $p8coord, $p9coord, $p10coord]

; player names
Local $aNames[10] = ["Player 1", "Player 2", "Player 3", "Player 4", "Player 5", "Player 6", "Player 7", "Player 8", "Player 9", "Player 10"]


; website directory which is synced to host
$baseDir="C:\Users\Me\Documents\Path\Where\To\Website\Base\"
$awsS3Bucket="s3://myurlifIhaveone.com/ --region eu-central-1"

; ------------ These don't need modification by default ------------------
; parameters for resolving who has played turn and who has not
Local Const $totalLoopCount = 120
Local Const $hasntPlayedChanges = 60

; pixel colors
Local $aColors[UBound($aCoords)]

; counter for deciding who has ended turn and who has not
Local $aCounter[UBound($aCoords)]

; last change
Local $aPreviousStatus[UBound($aCoords)]
Local $aPreviousStatusChange[UBound($aCoords)]
For $i = 0 To UBound($aPreviousStatusChange) - 1
   $aPreviousStatus[$i] = -1
   $aPreviousStatusChange[$i] = "?"
Next

$loopCounter = 0
$currentDate = _NowDate()
While True

   $loopCounter = $loopCounter + 1
   $writeContent = ""

   ; loop through each player and see if color has changed since previous loop
   For $i = 0 To UBound($aCoords) - 1
	  $color = PixelGetColor(StringLeft($aCoords[$i],3), StringRight($aCoords[$i], 3))

	  If Not $aColors[$i] Then
		 $aColors[$i] = $color
	  EndIf

	  If Not $aCounter[$i] Then
		 $aCounter[$i] = 0
	  EndIf

	  If $aColors[$i] <> $color Then
		 $aColors[$i] = $color

		 $aCounter[$i] = $aCounter[$i] + 1 ; increment counter => color changed for this player
	  EndIf

	  ; if counting loops done
	  If $loopCounter >= $totalLoopCount Then

		 ; if enough color changes
		 If $aCounter[$i] >= $hasntPlayedChanges Then
			; resolve last status change
			If $aPreviousStatus[$i] = 0 Then ; has to be resolved some other way
			   $aPreviousStatusChange[$i] = _NowDate() & " " & _NowTime()
			EndIf

			; update NAMES content
			$writeContent = $writeContent & $aNames[$i] & @CRLF

			$aPreviousStatus[$i] = 1
		 Else
			If $aPreviousStatus[$i] = 1 Then
			   $aPreviousStatusChange[$i] = _NowDate() & " " & _NowTime()
			EndIf

			$aPreviousStatus[$i] = 0
		 EndIf
		 $aCounter[$i] = 0
	  EndIf

   Next

   ; reset counter and write
   If $loopCounter >= $totalLoopCount Then
	  $loopCounter = 0
	  $writeContent = $writeContent & "Updated: " & _NowDate() & " " & _NowTime() & @CRLF
	  $writeContent = $writeContent & "steam://run/8930/q/%2Bconnect%20" & _GetIP()
	  WriteToFile($writeContent)
	  takeScreenCaptures()
	  UploadToAWS()
   EndIf

   Sleep(1000)

WEnd


; ====== WRITE TO FILE =======
Func WriteToFile(ByRef $string)
    ; Create a constant variable in Local scope of the filepath that will be read/written to.
    Local Const $sFilePath = $baseDir & "\civ5.txt"

    ; Open the file for writing (overwrite the file) and store the handle to a variable.
    Local $hFileOpen = FileOpen($sFilePath, $FO_OVERWRITE)
    If $hFileOpen = -1 Then
        Return False
    EndIf

    ; Write data to the file using the handle returned by FileOpen.
    FileWriteLine($hFileOpen, $string)

    ; Flush the file to disk.
    FileFlush($hFileOpen)

    ; Close the handle returned by FileOpen.
    FileClose($hFileOpen)
EndFunc   ;==>WriteToFile

Func takeScreenCaptures()
   _ScreenCapture_Capture($baseDir & "score.jpg", $leftscore, $topscore, $rightscore, $botscore, False)
   _ScreenCapture_Capture($baseDir & "timer.jpg", $lefttimer, $toptimer, $righttimer, $bottimer, False)
EndFunc

Func UploadToAWS()
   ; Sync only the pics and the text
   RunWait(@ComSpec & ' /c aws s3 cp ' & $baseDir & ' ' & $awsS3Bucket & ' --recursive --exclude "*" --include "score.jpg" --include "timer.jpg" --include "civ5.txt"')
EndFunc


; ================= END ========================
Func EndProgram()
   Exit 0
EndFunc