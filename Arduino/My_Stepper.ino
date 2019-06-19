// https://github.com/MAWoodMain/BYJ48-Stepper/tree/master

// define the stepper driver pins
#define IN1  8
#define IN2  9
#define IN3  10
#define IN4  11

// define how many cycles to a full rotation
#define CYCLES_PER_ROTATION 512

const byte numChars = 32;
char receivedChars[numChars];
boolean newData = false;

void setup() 
{
  pinMode(IN1, OUTPUT); 
  pinMode(IN2, OUTPUT); 
  pinMode(IN3, OUTPUT); 
  pinMode(IN4, OUTPUT); 
  
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  Serial.println("<Arduino is ready>");
}

void loop() 
{
  recvWithStartEndMarkers();
  showNewData();
}

void recvWithStartEndMarkers() {
    static boolean recvInProgress = false;
    static byte ndx = 0;
    char startMarker = '<';
    char endMarker = '>';
    char rc;
 
    while (Serial.available() > 0 && newData == false) {
        rc = Serial.read();

        if (recvInProgress == true) {
            if (rc != endMarker) {
                receivedChars[ndx] = rc;
                ndx++;
                if (ndx >= numChars) {
                    ndx = numChars - 1;
                }
            }
            else {
                receivedChars[ndx] = '\0'; // terminate the string
                recvInProgress = false;
                ndx = 0;
                newData = true;
            }
        }

        else if (rc == startMarker) {
            recvInProgress = true;
        }
    }
}

void showNewData() {
    if (newData == true) {
        Serial.print("This just in ... ");
        Serial.println(receivedChars);
        newData = false;

        float rotationAmount = atof(receivedChars);
        turns(rotationAmount);
    }
}

void turns(float rotations)
{
  // if the rotation count is -ve then it is CCW
  Serial.println();
  Serial.print("Turning : ");
  Serial.print(rotations);
  Serial.println(" rotations");
  bool clockwise = rotations > 0;
  Serial.print("Clockwise = ");
  Serial.println(clockwise);
  // calculate how many cycles the stepper will have to make
  int cycles = rotations * CYCLES_PER_ROTATION;
  // force the cycle count to be positive
  cycles = abs(cycles);
  Serial.print("That is ");
  Serial.print(cycles);
  Serial.print(" Cycles ");
  // only move if the user specifed an actual movement
  if(rotations != 0)
  {
    if (clockwise)
    {
      Serial.println("Clockwise");
      // for each cycle
      for (int x=0; x<cycles; x++)
      {
        // for each phase
        for(int y=0; y<8; y++)
        {
          // go to phase y
          phaseSelect(y);
          // pause so the stepper has time to react
          delay(1);
        }
      }
    } else {
      Serial.println("Counter Clockwise");
      // for each cycle
      for (int x=0; x<cycles; x++)
      {
        // for each phase (backwards for CCW rotation)
        for(int y=7; y>=0; y--)
        {
          // go to phase y
          phaseSelect(y);
          // pause so the stepper has time to react
          delay(1);
        }
      }
    }
  }
  // go to the default state (all poles off) when finished
  phaseSelect(8);
  Serial.println("Done");
}

void phaseSelect(int phase)
{
  switch(phase){
     case 0:
       digitalWrite(IN1, LOW); 
       digitalWrite(IN2, LOW);
       digitalWrite(IN3, LOW);
       digitalWrite(IN4, HIGH);
       break; 
     case 1:
       digitalWrite(IN1, LOW); 
       digitalWrite(IN2, LOW);
       digitalWrite(IN3, HIGH);
       digitalWrite(IN4, HIGH);
       break; 
     case 2:
       digitalWrite(IN1, LOW); 
       digitalWrite(IN2, LOW);
       digitalWrite(IN3, HIGH);
       digitalWrite(IN4, LOW);
       break; 
     case 3:
       digitalWrite(IN1, LOW); 
       digitalWrite(IN2, HIGH);
       digitalWrite(IN3, HIGH);
       digitalWrite(IN4, LOW);
       break; 
     case 4:
       digitalWrite(IN1, LOW); 
       digitalWrite(IN2, HIGH);
       digitalWrite(IN3, LOW);
       digitalWrite(IN4, LOW);
       break; 
     case 5:
       digitalWrite(IN1, HIGH); 
       digitalWrite(IN2, HIGH);
       digitalWrite(IN3, LOW);
       digitalWrite(IN4, LOW);
       break; 
     case 6:
       digitalWrite(IN1, HIGH); 
       digitalWrite(IN2, LOW);
       digitalWrite(IN3, LOW);
       digitalWrite(IN4, LOW);
       break; 
     case 7:
       digitalWrite(IN1, HIGH); 
       digitalWrite(IN2, LOW);
       digitalWrite(IN3, LOW);
       digitalWrite(IN4, HIGH);
       break; 
     default:
       digitalWrite(IN1, LOW); 
       digitalWrite(IN2, LOW);
       digitalWrite(IN3, LOW);
       digitalWrite(IN4, LOW);
       break; 
  }
}

