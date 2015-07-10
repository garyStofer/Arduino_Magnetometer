#include <util/twi.h>
#include <LiquidCrystal.h>
#include <Wire.h>
#include <LSM303DLH.h>
#define AVG_CNT 80

LSM303DLH compass;
vector mag_max, mag_min, acc_max, acc_min, acc_avg, mag_avg;
LiquidCrystal lcd(2, 3, 4, 5, 6, 7);		// assigne pins 


void setup() {
	Serial.begin(38400);
	Wire.begin();
	lcd.begin(20, 4);
	lcd.print("Calib.");  
	compass.enable();
	pinMode(13, OUTPUT);  
	vector_clear( &acc_avg);
	vector_clear( &mag_avg);
	vector_clear( &mag_min);
	vector_clear( &mag_max);
	vector_clear( &acc_min);
	vector_clear( &acc_max);
	Serial.print("Hello");
}

void loop() 
{
	int i;
		
	for ( i=0 ; i <AVG_CNT; i++)
	{
		compass.read();
		vector_sum( &acc_avg, &compass.a);
		vector_sum( &mag_avg, &compass.m);
	}
	
	vector_scale( &acc_avg, i);
	vector_scale( &mag_avg, i);
	

        // Acc min and max
        if (acc_avg.x > acc_max.x )
          acc_max.x = acc_avg.x;
        
        if (acc_avg.y > acc_max.y )
          acc_max.y = acc_avg.y;      
        
        if (acc_avg.z > acc_max.z )
          acc_max.z = acc_avg.z; 
        
        if (acc_avg.x < acc_min.x )
          acc_min.x = acc_avg.x; 
        
        if (acc_avg.y < acc_min.y )
          acc_min.y = acc_avg.y;  
        
        if (acc_avg.z < acc_min.z )
          acc_min.z = acc_avg.z;   
          
        // magnetometer min and max
        if (mag_avg.x > mag_max.x )
          mag_max.x = mag_avg.x;
        
        if (mag_avg.y > mag_max.y )
          mag_max.y = mag_avg.y;      
        
        if (mag_avg.z > mag_max.z )
          mag_max.z = mag_avg.z; 
        
        if (mag_avg.x < mag_min.x )
          mag_min.x = mag_avg.x; 
        
        if (mag_avg.y < mag_min.y )
          mag_min.y = mag_avg.y;  
        
        if (mag_avg.z < mag_min.z )
          mag_min.z = mag_avg.z;           


	digitalWrite(13, HIGH);   // set the LED on
#ifdef CAL_ACC
	Serial.print("\nAcc "); 
	Serial.print("X: ");Serial.print(acc_min.x);Serial.print(", "); Serial.print(acc_max.x);
	Serial.print(", Y: ");Serial.print(acc_min.y);Serial.print(", "); Serial.print(acc_max.y);
	Serial.print(", Z: ");Serial.print(acc_min.z);Serial.print(", "); Serial.print(acc_max.z);

       lcd.setCursor(0, 1); lcd.print("Acc X: ");
       lcd.print(acc_avg.x);  lcd.print("   ");
       lcd.setCursor(0, 2); lcd.print("Acc Y: ");
       lcd.print(acc_avg.y);  lcd.print("   ");
       lcd.setCursor(0, 3); lcd.print("Acc Z: ");
       lcd.print(acc_avg.z);  lcd.print("   ");
#else
	Serial.print("\nMag ");  
	Serial.print("X: "); Serial.print(mag_min.x); Serial.print(", "); Serial.print(mag_max.x);
	Serial.print(", Y: ");Serial.print(mag_min.y);Serial.print(", "); Serial.print(mag_max.y);
	Serial.print(", Z: ");Serial.print(mag_min.z);Serial.print(", "); Serial.print(mag_max.z);
       
       lcd.setCursor(0, 1); lcd.print("mag X: ");
       lcd.print(mag_avg.x);  lcd.print("   ");
       lcd.setCursor(0, 2); lcd.print("mag Y: ");
       lcd.print(mag_avg.y);  lcd.print("   ");
       lcd.setCursor(0, 3); lcd.print("mag Z: ");
       lcd.print(mag_avg.z);  lcd.print("   ");
#endif	
      digitalWrite(13, LOW);   
   

        delay(10);
}

