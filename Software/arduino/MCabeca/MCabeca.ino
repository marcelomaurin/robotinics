/*
Criado por Marcelo Maurin Martins
Controle do segundo módulo do robotinics
Modulo Cabeca
22/11/2013
//Responsábilidade:
Gerenciar o laser e as luzes do robotinics

Comunicação diretamente com o arduino mega através de tx e rx ttl

*/
#include <SoftwareSerial.h>
#include <Servo.h>
#include <Ultrasonic.h>     //Carrega a biblioteca Ultrasonic

//SoftwareSerial mySerial(10, 11); // RX, TX - COMUNICAÇAO SERIAL ENTRE OS DOIS ARDUINOS
 //Este meio apesar de existir nao é utilizado
 //A comunicacao hoje é feita diretamente atravéz do raspberry

#define PINO_TRIGGER  13 //Define o pino do Arduino a ser utilizado com o pino Trigger do sensor
#define PINO_ECHO     2 //Define o pino do Arduino a ser utilizado com o pino Echo do sensor

Ultrasonic ultrasonic(PINO_TRIGGER, PINO_ECHO); //Inicializa o sensor ultrasonico

char FVersao[10] = "1.2";

//Partes 8 e 12
int pinCabecaX = 8;
int pinCabecaY = 12;
int pinLaser = 3; //ok
int pinOlhos = 7; //ok
int pinCLedAzul = 6; //ok
int pinCLedVerde = 9;
int pinCLedVermelho = 4; //ok
//int pinMov = 3;
//2,5,13??????
//int pinMovR = 13;

int pos = 0;    // variable to store the servo position 



int firstSensor = 0;    // first analog sensor
int secondSensor = 0;   // second analog sensor
int thirdSensor = 0;    // digital sensor
char inByte = 0;         // incoming serial byte

int contcor = 0;       //contador de cor da cabeca 
int contpasso = 0;
//faz variar a cor da cabeca funcao varialuz


Servo CabecaX;  // create servo object to control a servo 
Servo CabecaY;  // create servo object to control a servo 

String Buffer;

int cmCabeca;

void setup()
{
  Start_Serial();
  Start_Servo();
  Start_Olhos();
  Start_Cores();
  Start_Laser();
  Buffer = "";
  //TesteMovimento();

  //Serial.println("$>");
  Prompt();
}

void Prompt()
{
  //mySerial.println("$>");
  Serial.println("$>");
}
  


void Start_Cores()
{
   pinMode(pinCLedAzul, OUTPUT);  
   pinMode(pinCLedVerde, OUTPUT);  
   pinMode(pinCLedVermelho, OUTPUT);  

}

void Start_Olhos()
{
 pinMode(pinOlhos, OUTPUT);  
 
}

void Versao()
{
  Serial.println("ROBOTINICS Arduino Driver");
  Serial.println("Criado por Marcelo Maurin Martins");
  Serial.println("Robotinics Driver Cabeca");
  Serial.print("Versão");
  Serial.println(FVersao); 

}


void Start_Serial()
{
    // start serial port at 9600 bps:
  Serial.begin(57600);
  
  // set the data rate for the SoftwareSerial port
  //mySerial.begin(9600);
  Versao();
}



void Start_Laser()
{
  pinMode(pinLaser,OUTPUT);
 
  
}

void Start_Servo()
{
  CabecaX.attach(pinCabecaX);  // attaches the servo on pin 9 to the servo object  
  CabecaY.attach(pinCabecaY);  // attaches the servo on pin 9 to the servo object  
  CabecaX.write(90);
  CabecaY.write(0);
  

}

void LedCabecaAzul(bool flag)
{
   digitalWrite(pinCLedAzul,(flag==true)?HIGH:LOW );   
}

void LedCabecaVerde(bool flag)
{
   digitalWrite(pinCLedVerde,(flag==true)?HIGH:LOW );   
}

void LedCabecaVermelho(bool flag)
{
   digitalWrite(pinCLedVermelho,(flag==true)?HIGH:LOW );   
}

void LedOlhos(bool flag)
{
 digitalWrite(pinOlhos,(flag==true)?HIGH:LOW);  
}

void VariaLuz()
{
  contpasso++;
  if (contpasso > 200)
  {
     contcor++;
     if((contcor & 16)==1)
     {
         LedCabecaAzul(false);
         LedCabecaVerde(false);
         LedCabecaVermelho(false);
         LedOlhos(true);
     }
     else
     {
         LedOlhos(false);
         LedCabecaAzul((contcor & 2)?true:false);
         LedCabecaVerde((contcor & 4)?true:false);
         LedCabecaVermelho((contcor & 8)?true:false);

     }
     contpasso = 0;
  }

  
}


//Posiciona o laser na posicao
void Point(int y, int x)
{
      /*Serial.print("Posicionando x:");
      Serial.print(x);
      Serial.print(",");
      Serial.println(y);
      */
      CabecaY.write(y);
      CabecaX.write(x);
}

//Varre area com laser
void SCANNING()
{
  Serial.println("Iniciando Varredura");
  LaserON();
  for (int x=0;x<=180;x=x+5)
  {     
      Point(x,0);
      delay(400);
      Point(x,180);  
      delay(400); 
  }

  Point(90,0);
  LaserOFF();
}


void TesteMovimento()
{
   Serial.println("Iniciando teste de movimento");
   for(int cont=0;cont<=5;cont++)
   {
     //Olhos(not digitalRead(pinOlhos));
      LedOlhos(digitalRead(pinOlhos==HIGH));
     //digitalWrite(pinCLedAzul,HIGH ); 
     LedCabecaAzul(true);
      delay(150);
     //digitalWrite(pinCLedVerde,HIGH ); 
     LedCabecaVerde(true);
     delay(150);
     //digitalWrite(pinCLedVermelho,HIGH ); 
     LedCabecaVermelho(true);
     delay(150);
     delay(150);
     //digitalWrite(pinCLedAzul,HIGH ); 
     LedCabecaAzul(true);
     delay(150);
     //digitalWrite(pinCLedVerde,LOW ); 
     LedCabecaVerde(false);
     delay(150);
     //digitalWrite(pinCLedVermelho,HIGH ); 
     LedCabecaVermelho(true);
     delay(150);
     delay(150);
     //digitalWrite(pinCLedAzul,LOW ); 
     LedCabecaAzul(false);
     delay(150);
     //digitalWrite(pinCLedVerde,HIGH ); 
     LedCabecaVerde(true);
     delay(150);
     //digitalWrite(pinCLedVermelho,HIGH ); 
     LedCabecaVermelho(true);
     delay(150);
      delay(150);
     //digitalWrite(pinCLedAzul,HIGH); 
     LedCabecaAzul(true);
     delay(150);
     //digitalWrite(pinCLedVerde,HIGH ); 
     LedCabecaVerde(true);
     delay(150);
     //digitalWrite(pinCLedVermelho,LOW ); 
     LedCabecaVermelho(false);
     delay(150);
     //digitalWrite(pinCLedAzul,LOW ); 
     LedCabecaAzul(false);
     delay(150);
     //digitalWrite(pinCLedVerde,LOW ); 
     LedCabecaVerde(false);
     delay(150);
     //digitalWrite(pinCLedVermelho,LOW ); 
     LedCabecaVermelho(false);
     delay(150);
   }

  
  for(int cont=0;cont<=5;cont++)
 {
   //digitalWrite(pinOlhos,HIGH); 
   LedOlhos(true);
   delay(150);
   //digitalWrite(pinOlhos,LOW);
   LedOlhos(false);
   delay(150);
 }
  
  LaserON();
  //digitalWrite(pinLaser,HIGH);
  
  SCANNING();  //Varre area com laser
  LaserOFF();
  //digitalWrite(pinLaser,LOW);  
}





//Acende ou apaga a luz dos olhos
void Olhos(int Luz)
{
   digitalWrite(pinOlhos,Luz); 
}

void Le_Ultrasom(int Imprime)
{
  float cmMsec, inMsec;
  float cmMsec1, inMsec1;
  float cmMsec2, inMsec2;
  float cmMsec3, inMsec3;

  long microsec = ultrasonic.timing();  //Le os dados do sensor, com o tempo de retorno do sinal
  cmMsec1 = ultrasonic.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  inMsec1 = ultrasonic.convert(microsec, Ultrasonic::IN); //Calcula a distancia em polegadas
  
  microsec = ultrasonic.timing();  //Le os dados do sensor, com o tempo de retorno do sinal
  cmMsec2 = ultrasonic.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  inMsec2 = ultrasonic.convert(microsec, Ultrasonic::IN); //Calcula a distancia em polegadas  
  
   microsec = ultrasonic.timing();  //Le os dados do sensor, com o tempo de retorno do sinal
  cmMsec3 = ultrasonic.convert(microsec, Ultrasonic::CM); //Calcula a distancia em centimetros
  inMsec3 = ultrasonic.convert(microsec, Ultrasonic::IN); //Calcula a distancia em polegadas  
  
  microsec = ultrasonic.timing();  //Le os dados do sensor, com o tempo de retorno do sinal
  cmMsec = (cmMsec1 + cmMsec2 + cmMsec3) /3;
  inMsec = (inMsec1 + inMsec2 + inMsec3) /3;

  
  cmCabeca = cmMsec;
  if(Imprime==1)
  {
    Serial.print("Cent: ");
    Serial.print(cmMsec);
    Serial.print(", Pol. : ");
    Serial.println(inMsec); 
  }
  if(Imprime==2)
  {
    if(cmMsec<10)
    {
      Serial.print("Colisao eminente Cent: ");
      Serial.print(cmMsec);
      Serial.print(", Pol. : ");
      Serial.println(inMsec); 
      Prompt();
    }
  }
}


void ExecCMD(String pBuffer)
{
  Serial.print("Comando:");
  Serial.println(pBuffer);
  bool flgRum = false;
  if(pBuffer.indexOf("ULTRA")>=0)
  {
    //lcd.clear();
    Le_Ultrasom(1);
    flgRum = true;
    //Serial.print("ULTRA");
  }

  if(pBuffer.indexOf("MAN")>=0)
  {
    //lcd.clear();
    Help();
    flgRum = true;
    //Serial.println("CORR");
  }  

  //TesteMovimento
  if(pBuffer.indexOf("TESTE")>=0)
  {
    //lcd.clear();
    TesteMovimento();
    flgRum = true;
    //Serial.println("CORR");
  }  
  
  //Liga laser
  if(pBuffer.indexOf("LASERON")>=0)
  {
    //lcd.clear();
    //TesteMovimento();
    LaserON();
    flgRum = true;
    //Serial.println("CORR");
  }  
  
  //Liga laser
  if(pBuffer.indexOf("VER")>=0)
  {
    //lcd.clear();
    //TesteMovimento();
    Versao();
    flgRum = true;
    //Serial.println("CORR");
  }  

  
  if(pBuffer.indexOf("POINT:")>=0)
  {
    int virgula = pBuffer.indexOf(',');
    String sx = String(pBuffer.substring(7,virgula-1));
    String sy = String(pBuffer.substring(virgula+1));
    
    //Falta passar valor
    int x= 0;
    int y = 0;
    Point(x,y);
    
    flgRum = true;
    //Serial.print("MSG1:");
  }

  //Desliga laser
  if(pBuffer.indexOf("LASEROFF")>=0)
  {
    //lcd.clear();
    //TesteMovimento();
    LaserOFF();
    flgRum = true;
    //Serial.println("CORR");
  }  


  //Varre Area
  if(pBuffer.indexOf("SCANNING")>=0)
  {
    //lcd.clear();
    //TesteMovimento();
    SCANNING();
    flgRum = true;
    //Serial.println("CORR");
  }    
  
  if (flgRum==false)
  {
    Serial.println("Comando não reconhecido");
  }
  Prompt();
  //Serial.println("$>");
  Buffer = ""; 
}



void Help()
{
  Serial.println("MAN - Manual de comandos"); 
  Serial.println("ULTRA - Ultrasom"); 
  Serial.println("VER - Versao do MCabeca");
  Serial.println("LASERON - Liga laser");
  Serial.println("LASEROFF - Desliga laser");
  Serial.println("SCANNING - Varre area com laser");
  Serial.println("POINT - Aponta laser posicao POINT=x,y");
  Serial.println("TESTE - Teste de Movimento"); 

}


/*
void Le_Arduino()
{
  // if we get a valid byte, read analog ins:
  if (mySerial.available() > 0) {
    // get incoming byte:
    inByte = mySerial.read();
    if (inByte != '\n')
    {
      Buffer += inByte;
    }
    else
    {
      ExecCMD(Buffer);
      //mySerial.println("$>");
      Prompt();
      Buffer = ""; 
    }

  }
}
*/

//Realiza Leituras de dispositivos
void Leituras()
{
  Le_Ultrasom(2);
  Serial_Read();
  //Le_Arduino();
  //Le_gas();
  //Le_corr();
  
}

void LaserON()
{
  digitalWrite(pinLaser,HIGH);
}

void LaserOFF()
{
 digitalWrite(pinLaser,LOW); 
}

void loop()
{
  Leituras();
  VariaLuz();
 
}




void Serial_Read()
{  
 // if we get a valid byte, read analog ins:
  if (Serial.available() > 0) {
    // get incoming byte:
    inByte = Serial.read();
    if (inByte != '\n')
    {
      Buffer = Buffer + inByte;
      //sprintf(Buffer,"%s%c",Buffer,inByte);
      //Serial.print(Buffer);
    }
    else
    {
      ExecCMD(Buffer);

    }
  }
  
}

