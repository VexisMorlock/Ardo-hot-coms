![Ardo-hot-coms](https://user-images.githubusercontent.com/50764330/141024594-e7e76aba-2ec8-4e97-9a3a-ca5f582bf86e.png)
<br />
[![GitHub license](https://img.shields.io/github/license/VexisMorlock/Ardo-hot-coms)](https://github.com/VexisMorlock/Ardo-hot-coms/blob/main/LICENSE)
[![self](https://img.shields.io/badge/Ardo--hot--coms-0.401-purple)](https://github.com/VexisMorlock/Ardo-hot-coms)
[![arduino](https://img.shields.io/badge/Arduino--uno-rev--3-purple)](https://store.arduino.cc/products/arduino-uno-rev3)
[![arduino](https://img.shields.io/badge/Arduino--uno-rev--3-purple)](https://store.arduino.cc/products/arduino-uno-rev3)
[![ahk](https://img.shields.io/badge/AutoHotKey-v1.1.33.1-9cf)](https://www.autohotkey.com/)



This is a script I put together so that I could use AHK to talk to my Arduino Uno over coms, to run an I2C LCD. There is already a project out there for comunicating over coms, but it only worked for a preset value in HEX. I updated it with a ascii to hex converter and added all the necessary bits to make it work over COMs.

It took me forever to get this to work but I have combined a few existing projects to get this to work properly. I understand that It could use a lot of cleanup work, but It works for now.

AHK coms script:
https://autohotkey.com/board/topic/26231-serial-com-port-console-script/page-2

AHK hex converter:
https://autohotkey.com/board/topic/29293-closed-collection-of-beautiful-one-liner-codes/page-2#entry187995

Arduino i2c lcd:
https://bitbucket.org/celem/sainsmart-i2c-lcd/src/3adf8e0d2443/sainlcdtest.ino
