/*
Nombre: Lucas Fuentes
EJercicio: ENTREGA FINAL

Historia: Jurassic Rescue - Juego interactivo

  Misión: Atrapa a los dinosaurios que escaparon de Jurassic Park antes de que sea demasiado tarde.

  Cómo jugar:
  - Avanza por la historia y dispara con el mouse para capturar dinosaurios.
  - Tienes 2 vidas y tiempo limitado en cada etapa.
  - Si fallas un disparo, pierdes una vida. Si atrapas todos, salvas el parque.
*/


import processing.sound.*;

PImage fondo, escenaInicio, escenaClimax, escenaFinal;
SoundFile tema, sonidoAtrapado, sonidoFallo;

int estado = 0; // 0: inicio, 1: historia, 2: juego, 3: éxito, 4: falla
int escena = 0;
int tiempoInicio;
int tiempoLimite = 20;

Dinosaurio[] dinos;
int dinosRestantes;

ArrayList<Disparo> disparos;

int etapa = 1;
int maxEtapas = 3;
int vidas = 2;
boolean huboCapturaEnEtapa = false;

// ------------------- SETUP -------------------
void setup() {
  size(800, 600);

  fondo = loadImage("fondo.jpg");
  escenaInicio = loadImage("inicio.png");
  escenaClimax = loadImage("climax.png");
  escenaFinal = loadImage("final.png");

  tema = new SoundFile(this, "jurassic_theme.mp3");
  sonidoAtrapado = new SoundFile(this, "atrapado.wav");
  sonidoFallo = new SoundFile(this, "fallo.wav");

  tema.loop();

  disparos = new ArrayList<Disparo>();
  iniciarEtapa(etapa);

  textFont(createFont("Arial", 16));
  textLeading(22);
}

// ------------------- DRAW -------------------
void draw() {
  background(255);
  image(fondo, 0, 0, width, height);

  switch (estado) {
    case 0: pantallaInicio(); break;
    case 1: pantallaHistoria(); break;
    case 2: pantallaJuego(); break;
    case 3: pantallaFinal(true); break;
    case 4: pantallaFinal(false); break;
  }
}

void iniciarEtapa(int nivel) {
  int cantidad = (nivel < maxEtapas) ? 1 : 3;
  dinos = new Dinosaurio[cantidad];
  for (int i = 0; i < cantidad; i++) {
    dinos[i] = new Dinosaurio(nivel);
  }
  disparos.clear();
  dinosRestantes = cantidad;
  huboCapturaEnEtapa = false;
  tiempoInicio = millis();
}

// ------------------- PANTALLAS -------------------
void pantallaInicio() {
  fill(0, 180); rect(0, 0, width, height);
  fill(255); textAlign(CENTER, CENTER);
  textSize(22);
  text("¡Bienvenido a Jurassic Park!", width / 2, height / 3);
  textSize(18);
  text("Haz clic para disparar y atrapar a los dinosaurios", width / 2, height / 2);
}

void pantallaHistoria() {
  if (escena == 0) image(escenaInicio, 0, 0, width, height);
  else if (escena == 1) image(escenaClimax, 0, 0, width, height);
  else if (escena == 2) image(escenaFinal, 0, 0, width, height);
  mostrarTextoNarrativo();
}

void pantallaJuego() {
  // Mostrar dinosaurios
  for (Dinosaurio d : dinos) {
    if (!d.capturado) d.mostrar();
  }

  // Mostrar y mover disparos
  for (int i = disparos.size() - 1; i >= 0; i--) {
    Disparo dis = disparos.get(i);
    dis.mover();
    dis.mostrar();

    boolean acierto = false;
    for (Dinosaurio d : dinos) {
      if (!d.capturado && dis.toca(d)) {
        d.capturado = true;
        dinosRestantes--;
        huboCapturaEnEtapa = true;
        sonidoAtrapado.play();
        acierto = true;
        break;
      }
    }

    if (acierto || dis.fueraDePantalla()) {
      disparos.remove(i);
      if (!acierto) sonidoFallo.play();
    }
  }

  int tiempo = (millis() - tiempoInicio) / 1000;
  int restante = tiempoLimite - tiempo;

  fill(0);
  text("Etapa " + etapa + "/" + maxEtapas + " | Vidas: " + vidas + " | Tiempo: " + restante + "s", 20, 20);

  if (dinosRestantes == 0) {
    delay(800);
    etapa++;
    if (etapa > maxEtapas) {
      estado = 3; // éxito
    } else {
      iniciarEtapa(etapa);
    }
  }

  if (restante <= 0) {
    if (!huboCapturaEnEtapa) {
      vidas--;
      sonidoFallo.play();
    }
    if (vidas < 0) {
      estado = 4;
    } else {
      iniciarEtapa(etapa);
    }
  }
}

void pantallaFinal(boolean exito) {
  fill(0, 180);
  rect(0, 0, width, height);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(24);
  if (exito) {
    text("¡Has salvado Jurassic Park!", width / 2, height / 2 - 30);
  } else {
    text("Has perdido... los dinosaurios escaparon.", width / 2, height / 2 - 30);
  }
  textSize(16);
  text("Presiona 'R' para reiniciar", width / 2, height / 2 + 30);
}

// ------------------- INPUT -------------------
void keyPressed() {
  if (estado == 0) estado = 1;
  else if (estado == 1 && escena < 2) escena++;
  else if (estado == 1 && escena == 2) {
    estado = 2;
    etapa = 1;
    vidas = 2;
    iniciarEtapa(etapa);
  } else if ((estado == 3 || estado == 4) && key == 'r') {
    estado = 0;
    escena = 0;
    etapa = 1;
    vidas = 2;
    iniciarEtapa(etapa);
  }
}

void mousePressed() {
  if (estado == 2) {
    disparos.add(new Disparo(mouseX, mouseY));
  }
}

// ------------------- NARRATIVA -------------------
void mostrarTextoNarrativo() {
  String texto = "";
  if (escena == 0) {
    texto = "Año 1993. John Hammond invita a científicos y visitantes a Isla Nublar, donde ha creado un parque con dinosaurios reales.\n\nPresiona una tecla para continuar.";
  } else if (escena == 1) {
    texto = "Una tormenta tropical azota la isla. El sistema colapsa y los dinosaurios escapan.\n\nPresiona una tecla para continuar.";
  } else if (escena == 2) {
    texto = "Dispara para atrapar a los dinosaurios. Si fallas dos veces, perderás.\n\nPresiona una tecla para iniciar la misión.";
  }

  fill(0, 180);
  rect(20, height - 180, width - 40, 160);
  fill(255);
  textAlign(LEFT, TOP);
  textSize(16);
  text(texto, 30, height - 160, width - 60, 140);
}

// ------------------- CLASES -------------------
class Dinosaurio {
  float x, y, r, vx, vy;
  PImage imagen;
  boolean capturado = false;

  Dinosaurio(int nivel) {
    r = 40 - (nivel * 5);
    x = random(r, width - r);
    y = random(r, height - r);
    vx = random(2 + nivel, 4 + nivel);
    vy = random(2 + nivel, 4 + nivel);
    imagen = loadImage("dino" + nivel + ".png");
    imagen.resize(int(r * 2), int(r * 2));
  }

  void mover() {
    x += vx;
    y += vy;
    if (x < r || x > width - r) vx *= -1;
    if (y < r || y > height - r) vy *= -1;
  }

  void mostrar() {
    if (!capturado) {
      image(imagen, x - r, y - r);
      mover();
    }
  }
}

class Disparo {
  float x, y, velocidad;

  Disparo(float objetivoX, float objetivoY) {
    this.x = width / 2;
    this.y = height;
    velocidad = 10;
  }

  void mover() {
    y -= velocidad;
  }

  void mostrar() {
    fill(255, 0, 0);
    noStroke();
    ellipse(x, y, 10, 10);
  }

  boolean fueraDePantalla() {
    return y < 0;
  }

  boolean toca(Dinosaurio d) {
    return dist(x, y, d.x, d.y) < d.r;
  }
}
