/*
** Example Arduino sketch for SainSmart I2C LCD Screen 16x2
** based on https://bitbucket.org/celem/sainsmart-i2c-lcd/src/3adf8e0d2443/sainlcdtest.ino
** by
** Edward Comer
** LICENSE: GNU General Public License, version 3 (GPL-3.0)

** This example uses F Malpartida's NewLiquidCrystal library. Obtain from:
** https://bitbucket.org/fmalpartida/new-liquidcrystal

** Modified - Ian Brennan ianbren at hotmail.com 23-10-2012 to support Tutorial posted to Arduino.cc
** Modified again by: Bettj AHK (Auto hotkey) forums.
** https://autohotkey.com/boards/viewtopic.php?f=6&t=15550

** NOTE: Tested on Arduino Uno whose I2C pins are A4==SDA, A5==SCL

*/
#include <Wire.h>
#include <LCD.h>
#include <LiquidCrystal_I2C.h>

#define I2C_ADDR    0x3F // <<----- Add your address here.  Find it from I2C Scanner
#define BACKLIGHT_PIN     3
#define En_pin  2
#define Rw_pin  1
#define Rs_pin  0
#define D4_pin  4
#define D5_pin  5
#define D6_pin  6
#define D7_pin  7

char sMem[15]{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int n = 1;
int chl = 0;
char ch = 49;
String readString;
String first;
String second;
LiquidCrystal_I2C	lcd(I2C_ADDR,En_pin,Rw_pin,Rs_pin,D4_pin,D5_pin,D6_pin,D7_pin);

void setup()
{
 lcd.begin (16,2); //  <<----- My LCD was 16x2

 
// Switch on the backlight
lcd.setBacklightPin(BACKLIGHT_PIN,POSITIVE);
lcd.setBacklight(HIGH);
lcd.home (); // go home
Serial.begin(9600);

// lcd.print("SainSmartI2C16x2");  
}

void loop()
{
  while (Serial.available()) {
       delay(10);  //small delay to allow input buffer to fill
         
       char c = Serial.read();  //gets one byte from serial buffer
       if (c == ',') {break;}  //breaks out of capture loop to print readstring
       readString += c; } //makes the string readString  
       if(readString!="")lcd.clear();    
        
     if (readString.length() >0) {
       //You will need to change the substring settings in this section to fit your screen. default (16x2)
       /*if (readString.substring(16,16) == " ") {
          
         Serial.println(readString.substring(0,16)); //prints string to serial port out;
         Serial.println(readString.substring(16,32));
         lcd.print(readString.substring(0,16));
         lcd.setCursor (0,1);
         lcd.print(readString.substring(16,32));
         readString="";
         
       }
       else{
         */
        if (readString.length() >16){
        
        first = readString.substring(0,16);
        first = first.substring(0,first.lastIndexOf(' '));
        Serial.println(first);
        second = readString.substring(first.lastIndexOf(' ')+1,32);
        second = second.substring(second.indexOf(' ')+1,32);
        Serial.println(first);
        Serial.println(second);
        lcd.print(first);
          lcd.setCursor (0,1);
        lcd.print(second);
        readString="";
       }
       else{
         Serial.println(readString);
         lcd.print(readString);
         readString="";
       }
     }}
