AscToHex(str) {
  Return str="" ? "":Chr((Asc(str)>>4)+48) Chr((x:=Asc(str)&15)+(x>9 ? 55:48)) AscToHex(SubStr(str,2))
}

F4::
InputBox, asciiMessage, "what do you want", What...?
rawHex= % AscToHex(asciiMessage)
hexLngth:= % StrLen(rawHex)/2
hexLngth:=Floor(hexLngth)
bMessage=""
cMessage=""
MsgBox, Begin COM Test

;########################################################################
;###### User Variables (Change these to match you needs) ################
;########################################################################
COM_Port     = COM3
COM_Baud     = 9600
COM_Parity   = N
COM_Data     = 8
COM_Stop     = 1

;########################################################################
;###### Script Variables (Don't touch these) ############################
;########################################################################
COM_Settings = %COM_Port%:baud=%COM_Baud% parity=%COM_Parity% data=%COM_Data% stop=%COM_Stop% dtr=Off

;########################################################################
;###### Main Routine ####################################################
;########################################################################
Initialize_COM(COM_Settings) 

;NL = New Line

while, hexLngth>A_Index-1{
	iniwrite, % SubStr(rawHex,A_Index*2-1,2), temp.ini,simple,%A_Index%
	iniread, tMessage,temp.ini,simple,%A_Index%
	iniwrite, `, 0x%tMessage%, temp.ini,character,%A_Index%
	iniread, jMessage, temp.ini,character,%A_Index%
	fileAppend, %jMessage%, temp.txt
}
FileRead, Message, temp.txt
Message= % SubStr(message,3)
filedelete, temp.txt
;            &   NL   NL    O    8    (    )   NL   NL    %
;Message =0x26,0x0A,0x0A,0x4F,0x38,0x28,0x29,0x0A,0x0A,0x25
Write_to_COM(Message)


Close_COM(COM_FileHandle) 
Return


;########################################################################
;###### Subroutines (You don't really need to look below this line) #####
;########################################################################

;########################################################################
;###### Initialize COM Subroutine (Don't touch this routine) ############
;########################################################################
Initialize_COM(COM_Settings)
{
  Global COM_FileHandle

  ;###### Build COM DCB ######
  ;Creates the structure that contains the COM Port number, baud rate,...
  VarSetCapacity(DCB, 28)
  BCD_Result := DllCall("BuildCommDCB"
       ,"str" , COM_Settings ;lpDef
       ,"UInt", &DCB)        ;lpDCB
  If (BCD_Result <> 1)
  {
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll BuildCommDCB, BCD_Result=%BCD_Result% `nThe Script Will Now Exit.
    Exit
  }

  ;###### Extract/Format the COM Port Number ######
  ;7/23/08 Thanks krisky68 for finding/solving the bug in which COM Ports greater than 9 didn't work.
  StringSplit, COM_Port_Temp, COM_Settings, `: 
  COM_Port_Temp1_Len := StrLen(COM_Port_Temp1)  ;For COM Ports > 9 \\.\ needs to prepended to the COM Port name.
  If (COM_Port_Temp1_Len > 4)                   ;So the valid names are
    COM_Port = \\.\%COM_Port_Temp1%             ; ... COM8  COM9   \\.\COM10  \\.\COM11  \\.\COM12 and so on...
  Else                                          ;
    COM_Port = %COM_Port_Temp1%
  ;MsgBox, COM_Port=%COM_Port% 

  ;###### Create COM File ######
  ;Creates the COM Port File Handle
  ;StringLeft, COM_Port, COM_Settings, 4  ; 7/23/08 This line is replaced by the "Extract/Format the COM Port Number" section above.
  COM_FileHandle := DllCall("CreateFile"
       ,"Str" , COM_Port     ;File Name         
       ,"UInt", 0xC0000000   ;Desired Access
       ,"UInt", 3            ;Safe Mode
       ,"UInt", 0            ;Security Attributes
       ,"UInt", 3            ;Creation Disposition
       ,"UInt", 0            ;Flags And Attributes
       ,"UInt", 0            ;Template File
       ,"Cdecl Int")
  If (COM_FileHandle < 1)
  {
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll CreateFile, COM_FileHandle=%COM_FileHandle% `nThe Script Will Now Exit.
    Exit
  }

  ;###### Set COM State ######
  ;Sets the COM Port number, baud rate,...
  SCS_Result := DllCall("SetCommState"
       ,"UInt", COM_FileHandle ;File Handle
       ,"UInt", &DCB)          ;Pointer to DCB structure
  If (SCS_Result <> 1)
  {
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCS_Result=%SCS_Result% `nThe Script Will Now Exit.
    Close_COM(COM_FileHandle)
    Exit
  }

  ;###### Create the SetCommTimeouts Structure ######
  ReadIntervalTimeout        = 0xffffffff
  ReadTotalTimeoutMultiplier = 0x00000000
  ReadTotalTimeoutConstant   = 0x00000000
  WriteTotalTimeoutMultiplier= 0x00000000
  WriteTotalTimeoutConstant  = 0x00000000

  VarSetCapacity(Data, 20, 0) ; 5 * sizeof(DWORD)
  NumPut(ReadIntervalTimeout,         Data,  0, "UInt")
  NumPut(ReadTotalTimeoutMultiplier,  Data,  4, "UInt")
  NumPut(ReadTotalTimeoutConstant,    Data,  8, "UInt")
  NumPut(WriteTotalTimeoutMultiplier, Data, 12, "UInt")
  NumPut(WriteTotalTimeoutConstant,   Data, 16, "UInt")

  ;###### Set the COM Timeouts ######
  SCT_result := DllCall("SetCommTimeouts"
     ,"UInt", COM_FileHandle ;File Handle
     ,"UInt", &Data)         ;Pointer to the data structure
  If (SCT_result <> 1)
  {
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll SetCommState, SCT_result=%SCT_result% `nThe Script Will Now Exit.
    Close_COM(COM_FileHandle)
    Exit
  }

  Return %COM_FileHandle%
}

;########################################################################
;###### Close COM Subroutine (Don't touch this routine) #################
;########################################################################
Close_COM(COM_FileHandle)
{
  ;###### Close the COM File ######
  CH_result := DllCall("CloseHandle", "UInt", COM_FileHandle)
  If (CH_result <> 1)
    MsgBox, Failed Dll CloseHandle CH_result=%CH_result%

  Return
}

;########################################################################
;###### Write to COM Subroutines (Don't touch this routine) #############
;########################################################################
Write_to_COM(Message)
{
  Global COM_FileHandle
  Global COM_Port

  SetFormat, Integer, DEC

  ;Parse the Message. Byte0 is the number of bytes in the array.
  StringSplit, Byte, Message, `,
  Data_Length := Byte0
  ;msgbox, Data_Length=%Data_Length% b1=%Byte1% b2=%Byte2% b3=%Byte3% b4=%Byte4%

  ;Set the Data buffer size, prefill with 0xFF.
  VarSetCapacity(Data, Byte0, 0xFF)

  ;Write the Message into the Data buffer
  i=1
  Loop %Byte0%
  {
    NumPut(Byte%i%, Data, (i-1) , "UChar")
    ;msgbox, %i%
    i++
  }
  ;msgbox, Data string=%Data%

  ;###### Write the data to the COM Port ######
  WF_Result := DllCall("WriteFile"
       ,"UInt" , COM_FileHandle ;File Handle
       ,"UInt" , &Data          ;Pointer to string to send
       ,"UInt" , Data_Length    ;Data Length
       ,"UInt*", Bytes_Sent     ;Returns pointer to num bytes sent
       ,"Int"  , "NULL")
  If (WF_Result <> 1 or Bytes_Sent <> Data_Length)
    MsgBox, Failed Dll WriteFile to %COM_Port%, result=%WF_Result% `nData Length=%Data_Length% `nBytes_Sent=%Bytes_Sent%
}

;########################################################################
;###### Read from COM Subroutines (Don't touch this routine) ############
;########################################################################
Read_from_COM(Num_Bytes)
{
  Global COM_FileHandle
  Global COM_Port
  Global Bytes_Received
  SetFormat, Integer, HEX

  ;Set the Data buffer size, prefill with 0x55 = ASCII character "U"
  ;VarSetCapacity won't assign anything less than 3 bytes. Meaning: If you
  ;  tell it you want 1 or 2 byte size variable it will give you 3.
  Data_Length  := VarSetCapacity(Data, Num_Bytes, 0x55)
  ;msgbox, Data_Length=%Data_Length%

  ;###### Read the data from the COM Port ######
  ;msgbox, COM_FileHandle=%COM_FileHandle% `nNum_Bytes=%Num_Bytes%
  Read_Result := DllCall("ReadFile"
       ,"UInt" , COM_FileHandle   ; hFile
       ,"Str"  , Data             ; lpBuffer
       ,"Int"  , Num_Bytes        ; nNumberOfBytesToRead
       ,"UInt*", Bytes_Received   ; lpNumberOfBytesReceived
       ,"Int"  , 0)               ; lpOverlapped
  ;MsgBox, Read_Result=%Read_Result% `nBR=%Bytes_Received% ,`nData=%Data%
  If (Read_Result <> 1)
  {
    MsgBox, There is a problem with Serial Port communication. `nFailed Dll ReadFile on %COM_Port%, result=%Read_Result% - The Script Will Now Exit.
    Close_COM(COM_FileHandle)
    Exit
  }

  i = 0
  Data_HEX =
  Loop %Bytes_Received%
  {
    ;First byte into the Rx FIFO ends up at position 0

    Data_HEX_Temp := NumGet(Data, i, "UChar") ;Convert to HEX byte-by-byte
    StringTrimLeft, Data_HEX_Temp, Data_HEX_Temp, 2 ;Remove the 0x (added by the above line) from the front

    ;If there is only 1 character then add the leading "0'
    Length := StrLen(Data_HEX_Temp)
    If (Length =1)
      Data_HEX_Temp = 0%Data_HEX_Temp%

    i++

    ;Put it all together
    Data_HEX := Data_HEX . Data_HEX_Temp
  }
  ;MsgBox, Read_Result=%Read_Result% `nBR=%Bytes_Received% ,`nData_HEX=%Data_HEX%

  SetFormat, Integer, DEC
  Data := Data_HEX

  Return Data

}

;-----Serial-com-----
;https://autohotkey.com/board/topic/26231-serial-com-port-console-script/page-2
;----Hex Converter----
;https://autohotkey.com/board/topic/29293-closed-collection-of-beautiful-one-liner-codes/page-2#entry187995
