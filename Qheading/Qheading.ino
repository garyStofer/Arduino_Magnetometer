#include <imu.h>

#include <LSM303DLH.h>
#include <LiquidCrystal.h>
#include <Wire.h>
#include <math.h>



// define the compass class
LSM303DLH compass;
// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(2, 3, 4, 5, 6, 7);
vector acc,mag;
float attitude,head,bank;

void setup() 
{
   // set up the LCD's number of columns and rows: 
  lcd.begin(20, 4);
  lcd.print("Init");  
  
  Serial.begin(38400);
  Wire.begin();
  compass.enable();    // setiing up for 50hz acc data rate 30 Hz mag data rate, +-2G acc range 
  pinMode(13, OUTPUT); digitalWrite(13, LOW);   // set the LED off 
  IMU_Init(  );
  compass.m_max.x = +372; compass.m_max.y = +571; compass.m_max.z = 462;
  compass.m_min.x = -719; compass.m_min.y = -517; compass.m_min.z = -466; 
  
  compass.a_max.x = +1060; compass.a_max.y = +1000; compass.a_max.z = 1074;
  compass.a_min.x = -1015; compass.a_min.y = -1060; compass.a_min.z = -1014; 

}

// Num_Samp has to be divisble by 2
#define Num_Samp 24
void loop() {
  
  int heading;
  quat Q_estimate; 
  float dt = 0.5;   // the delat time for the IMU_Update
  float magnitude;  // The magnitude of the accelerometer vector -- If this strays from 1.0 We are dealing with dynamic acceleration of the device and we can't use 
                    // the Acc data for anything as it's not pointing to earth anymore
  int i;

  
  vector_clear(&acc);
  vector_clear(&mag);
  
  for( i = 0; i<Num_Samp; i++)
  {
    compass.read_acc(false);
    vector_sum (&acc, &compass.a);
   
   if (i%2 == 0)  // magnetometer has 30 hz data rate -- read only every other time 
   {
      compass.read_mag(false);
      vector_sum (&mag, &compass.m);
   }
   delay(20);    // 20 ms interval == 50 hz update rate on the acc
  }

  //digitalWrite(13,HIGH);   // set the LED on 
           
  magnitude = vector_normalize(&acc)/i;   // we need the aboslute vector size for dyn accel detection
  vector_normalize(&mag);
 
  heading = compass.heading(magnitude,&acc,&mag);
  IMU_Update(&Q_estimate,dt );
   
  Serial.print(" Q_estimate w:");Serial.print(Q_estimate.w);
  Serial.print(" x:");Serial.print(Q_estimate.x);
  Serial.print(" y:");Serial.print(Q_estimate.y);
  Serial.print(" z:");Serial.print(Q_estimate.z);
  
  Quat_ToEuler(&Q_estimate, &head, &bank, &attitude);
  Serial.print(" head:");Serial.print(head);
  Serial.print(" P:");Serial.print(attitude);
  Serial.print(" R:");Serial.print(bank);
  
  // The heading from the compass reading and the heading from the  Quaternion should be identical

  Serial.println("");
  lcd.setCursor(0, 0);
  lcd.print("Heading:");
  lcd.setCursor(0, 1);
  
  // if the accelerometer reports a dynamic acceleartion ( i.e not 1G total) then we invalidate the result 
  
  if (heading < 0 )
    lcd.print("---");
  else
     lcd.print(heading);
  lcd.print("   ");

  delay(50);
  
  digitalWrite(13, LOW);   // set the LED off

 
 
}

