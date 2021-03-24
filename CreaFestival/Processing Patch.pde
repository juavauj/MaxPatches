import processing.serial.*;

Serial myPort; 
int sensorValue; 

int dim = 1200;   // las dimensiones donde se construye la imagen en el eje X

int num = 1200;   // las dimensiones donde se construye la imagen en el eje Y

int time = 600000;     // el tiempo que se demora construyendo la imágen


Disc[] discs;


int maxpal = 512;

int numpal = 0;

color[] goodcolor = new color[maxpal]; // ESTA ES LA VARIABLE DE COLOR 1

//color[] goodcolor2 = new color[maxpal]; // ESTA ES AL VARIABLE COLORES


// MAIN

boolean desierto=false; // estado desierto

boolean azul=false;   // estado páramo

boolean manglar=false;  // estado manglar




void setup() { // donde se establecen las reglas del sistema

  size(1200,1200,P3D); // el tamaño de la pantalla

  takecolor("azul.gif"); // acá se cargan las imágenes, las imágenes deben ir en la carpeta del código

  background (159, 213, 209); //  este es el fondo del paramo

  background(134, 137, 93); // el fondo del manglar

  background(0); // negro, fondo inicial

  frameRate(30); //esta es la velocidad en la que se construye el código

  String portName = Serial.list()[1];
  myPort = new Serial(this, portName,115200);

  discs = new Disc[num]; // es el nombre que le asignamos a los constructores


  // arrange linearly //  de donde salen las formas, es aleatorio - como se construyen las imágenes

  for (int i=0;i<num;i++) {

    float x = random(dim*8);

    float y = random(dim);

    float fy = 0;

    float fx = random(-1.2,1.2);

    float r = 5+random(600); // tamaño de la forma - posibilidad para el sensor

    discs[i] = new Disc(i,x,y,fx,fy,r);

  }

}


void draw() { // acá dibuja 

if (desierto) {

   background(0);//Fondo desierto

      }
      
  if (azul) {

   background(134,137,93);//Fondo  paramo

      }  
   
if (manglar) {

   background(159,213,209);//Fondo manglar

      }  

  for (int c=0;c<num;c++) {

    discs[c].move();

    discs[c].render();

  }

 

  time++;

}




// OBJECTS

class Disc {

  // index identifier

  int id;

  // position

  float x,y;

  // radius

  float r;

  // destination radius

  float dr;

  // velocity

  float vx,vy;


  // sand painters

  int numsands = 3;

  SandPainter[] sands = new SandPainter[numsands];


  Disc(int Id, float X, float Y, float Vx, float Vy, float R) {

    // construct

    id=Id;

    x=X;

    y=Y;

    vx=Vx;

    vy=Vy;

    r=0;

    dr=R;

    

    // create sand painters

    for (int n=0;n<numsands;n++) {

      sands[n] = new SandPainter();

    }

  }


  void reset(int Id, float X, float Y, float Vx, float Vy, float R) {

    // construct

    id=Id;

    x=X;

    y=Y;

    vx=Vx;

    vy=Vy;

    r=0;

    dr=R;

  }


  void draw() {

    stroke(0,50);

    noFill();

    ellipse(x,y,r,r);

  }


  void render() { //rendewrizacion 

    // find intersecting points with all ascending discs

    for (int n=id+1;n<num;n++) {

      // find distance to other disc

      float dx = discs[n].x-x;

      float dy = discs[n].y-y;

      float d = sqrt(dx*dx+dy*dy);

      // intersection test

      if (d<(discs[n].r+r)) {

        // complete containment test

        if (d>abs(discs[n].r-r)) {

          // find solutions

          float a = (r*r - discs[n].r*discs[n].r + d*d ) / (2*d);

          

          float p2x = x + a*(discs[n].x - x)/d;

          float p2y = y + a*(discs[n].y - y)/d;

          

          float h = sqrt(r*r - a*a);

          

          float p3ax = p2x + h*(discs[n].y - y)/d;

          float p3ay = p2y - h*(discs[n].x - x)/d;

          

          float p3bx = p2x - h*(discs[n].y - y)/d;

          float p3by = p2y + h*(discs[n].x - x)/d;

          

          for (int s=0;s<numsands;s++) {

            sands[s].render(p3ax,p3ay,p3bx,p3by);

          }

        }

      }

    }

  }


  void move() {

    // add velocity to position

    x+=vx;

    y+=vy;

    // grow to destination radius

    if (r<dr) {
        if (myPort.available() > 1) { 
         sensorValue = myPort.read();        
          r+= (sensorValue - 4);
      }
   }



    // bound check

    if (x+r<0) x+=dim*4+r+r;

    if (x-r>dim*4) x-=dim*4+r+r;

    if (y+r<0) y+=dim+r+r;

    if (y-r>dim) y-=dim+r+r;

  }

}



class SandPainter {


  float p;

  color c;

  float g;



  SandPainter() {


    p = random(1.0);

    c = somecolor();

    g = random(0.01,0.1);


  }


  void render(float x, float y, float ox, float oy) {

    // draw painting sweeps


    g+=random(-0.050,0.050);

    float maxg = 0.22;

    if (g<-maxg) g=-maxg;

    if (g>maxg) g=maxg;

    p+=random(-0.050,0.050);

    if (p<0) p=0;

    if (p>1.0) p=1.0;


    float w = g/10.0;

    for (int i=0;i<11;i++) {

      float a = 0.1-i/110;

      stroke(red(c),green(c),blue(c),256*a);

    // stroke(red(h),green(h),blue(h),256*a);


      point(ox+(x-ox)*sin(p + sin(i*w)),oy+(y-oy)*sin(p + sin(i*w)));

      point(ox+(x-ox)*sin(p - sin(i*w)),oy+(y-oy)*sin(p - sin(i*w)));

    }

  }

}




// COLORING ROUTINES ----------------------------------------------------------------


color somecolor() {

  // pick some random good color

  return goodcolor[int(random(numpal))];

}


void takecolor(String fn) {

  PImage b;

  b = loadImage(fn);

  image(b,0,0);


  for (int x=0;x<b.width;x++){

    for (int y=0;y<b.height;y++) {

      color c = get(x,y);

      boolean exists = false;

      for (int n=0;n<numpal;n++) {

        if (c==goodcolor[n]) {

          exists = true;

          break;

        }

      }

      if (!exists) {

        // add color to pal

        if (numpal<maxpal) {

          goodcolor[numpal] = c;

          numpal++;

        }

      }

    }

  }

}
void keyPressed() {

  if (key=='a')desierto=!desierto;

  if (key=='s')azul=!azul;

  if (key=='d')manglar=!manglar;

  }
