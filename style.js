<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mini Open World 3D</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; overflow: hidden; background: #87ceeb; font-family: Arial; }
  canvas { display: block; }
  #info {
    position: fixed; top: 12px; left: 12px;
    color: white; background: #0008; padding: 10px;
    border-radius: 10px; z-index: 2;
  }
  #controls {
    position: fixed; bottom: 20px; left: 20px;
    display: grid; grid-template-columns: 60px 60px 60px;
    gap: 6px; z-index: 3;
  }
  button {
    width: 60px; height: 60px; border: 0; border-radius: 14px;
    background: #0009; color: white; font-size: 24px;
    touch-action: none;
  }
  #up { grid-column: 2; }
  #left { grid-column: 1; grid-row: 2; }
  #down { grid-column: 2; grid-row: 2; }
  #right { grid-column: 3; grid-row: 2; }
  #carBtn {
    position: fixed; bottom: 35px; right: 20px;
    width: 90px; height: 55px; font-size: 15px;
  }
</style>
</head>
<body>

<div id="info">🏙️ Mini Open World 3D<br>🚶 Walk around the city</div>

<div id="controls">
  <button id="up">▲</button>
  <button id="left">◀</button>
  <button id="down">▼</button>
  <button id="right">▶</button>
</div>

<button id="carBtn">🚗 CAR</button>

<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"></script>
<script>
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x87ceeb);

const camera = new THREE.PerspectiveCamera(
  70, innerWidth / innerHeight, 0.1, 1000
);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(innerWidth, innerHeight);
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
document.body.appendChild(renderer.domElement);

const clock = new THREE.Clock();

// Light
scene.add(new THREE.HemisphereLight(0xffffff, 0x777777, 2));

const sun = new THREE.DirectionalLight(0xffffff, 2);
sun.position.set(10, 20, 10);
scene.add(sun);

// Ground
const ground = new THREE.Mesh(
  new THREE.PlaneGeometry(200, 200),
  new THREE.MeshStandardMaterial({ color: 0x4c9a52 })
);
ground.rotation.x = -Math.PI / 2;
scene.add(ground);

// Road
function box(w, h, d, color, x, y, z) {
  const mesh = new THREE.Mesh(
    new THREE.BoxGeometry(w, h, d),
    new THREE.MeshStandardMaterial({ color })
  );
  mesh.position.set(x, y, z);
  scene.add(mesh);
  return mesh;
}

box(200, 0.05, 12, 0x444444, 0, 0.03, 0);
box(12, 0.05, 200, 0x444444, 0, 0.04, 0);

// Houses
for (let x = -60; x <= 60; x += 30) {
  for (let z = -60; z <= 60; z += 30) {
    if (Math.abs(x) < 15 || Math.abs(z) < 15) continue;

    box(12, 10, 12, 0xd98b5f, x, 5, z);
    box(14, 2, 14, 0x8b4513, x, 11, z);
  }
}

// Trees
for (let i = 0; i < 30; i++) {
  const x = (Math.random() - 0.5) * 150;
  const z = (Math.random() - 0.5) * 150;

  if (Math.abs(x) < 20 || Math.abs(z) < 20) continue;

  const trunk = new THREE.Mesh(
    new THREE.CylinderGeometry(0.5, 0.7, 4),
    new THREE.MeshStandardMaterial({ color: 0x6b4226 })
  );
  trunk.position.set(x, 2, z);
  scene.add(trunk);

  const leaves = new THREE.Mesh(
    new THREE.SphereGeometry(3, 12, 12),
    new THREE.MeshStandardMaterial({ color: 0x228b22 })
  );
  leaves.position.set(x, 6, z);
  scene.add(leaves);
}

// Player
const player = new THREE.Group();

const body = new THREE.Mesh(
  new THREE.BoxGeometry(1.2, 2, 0.8),
  new THREE.MeshStandardMaterial({ color: 0x2563eb })
);
body.position.y = 1.5;
player.add(body);

const head = new THREE.Mesh(
  new THREE.SphereGeometry(0.45, 16, 16),
  new THREE.MeshStandardMaterial({ color: 0xffcc99 })
);
head.position.y = 2.8;
player.add(head);

player.position.set(0, 0, 8);
scene.add(player);

// Car
const car = new THREE.Group();

const carBody = new THREE.Mesh(
  new THREE.BoxGeometry(3, 1, 5),
  new THREE.MeshStandardMaterial({ color: 0xdc2626 })
);
carBody.position.y = 0.8;
car.add(carBody);

const roof = new THREE.Mesh(
  new THREE.BoxGeometry(2.4, 0.8, 2.5),
  new THREE.MeshStandardMaterial({ color: 0x222222 })
);
roof.position.y = 1.6;
car.add(roof);

car.position.set(8, 0, 8);
scene.add(car);

// Controls
const keys = {};
let driving = false;

function hold(id, key) {
  const btn = document.getElementById(id);
  btn.addEventListener("pointerdown", e => {
    e.preventDefault();
    keys[key] = true;
  });
  btn.addEventListener("pointerup", () => keys[key] = false);
  btn.addEventListener("pointercancel", () => keys[key] = false);
  btn.addEventListener("pointerleave", () => keys[key] = false);
}

hold("up", "up");
hold("down", "down");
hold("left", "left");
hold("right", "right");

document.getElementById("carBtn").addEventListener("click", () => {
  driving = !driving;
  document.getElementById("carBtn").textContent =
    driving ? "🚶 EXIT" : "🚗 CAR";
});

// Movement
function update() {
  const speed = driving ? 0.12 : 0.08;
  const target = driving ? car : player;

  if (keys.up) target.position.z -= speed;
  if (keys.down) target.position.z += speed;
  if (keys.left) target.position.x -= speed;
  if (keys.right) target.position.x += speed;

  // Camera follows
  camera.position.lerp(
    new THREE.Vector3(
      target.position.x,
      target.position.y + 7,
      target.position.z + 10
    ),
    0.08
  );

  camera.lookAt(
    target.position.x,
    target.position.y + 1,
    target.position.z
  );
}

function animate() {
  requestAnimationFrame(animate);
  update();
  renderer.render(scene, camera);
}

animate();

addEventListener("resize", () => {
  camera.aspect = innerWidth / innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(innerWidth, innerHeight);
});
</script>
</body>
</html>
      
