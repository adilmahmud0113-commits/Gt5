<!DOCTYPE html>
<html lang="bn">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>Mini City 3D</title>
<style>
*{box-sizing:border-box}
body{margin:0;overflow:hidden;background:#87ceeb;font-family:Arial,sans-serif}
canvas{display:block}
#info{
 position:fixed;top:12px;left:12px;z-index:2;
 color:white;background:#0009;padding:10px 14px;
 border-radius:12px;font-size:14px;line-height:1.6;
}
#controls{
 position:fixed;bottom:22px;left:20px;z-index:3;
 display:grid;grid-template-columns:60px 60px 60px;gap:6px;
}
button{
 width:60px;height:60px;border:0;border-radius:15px;
 background:#0009;color:white;font-size:24px;
 touch-action:none;
}
#up{grid-column:2}
#left{grid-column:1;grid-row:2}
#down{grid-column:2;grid-row:2}
#right{grid-column:3;grid-row:2}
#carBtn{
 position:fixed;bottom:35px;right:20px;
 width:100px;height:55px;font-size:15px;z-index:3;
}
#missionBtn{
 position:fixed;top:115px;left:12px;
 width:120px;height:45px;font-size:14px;z-index:3;
}
</style>
</head>
<body>

<div id="info">🏙️ MINI CITY 3D<br>🚶 গাড়ির কাছে যাও</div>

<div id="controls">
  <button id="up">▲</button>
  <button id="left">◀</button>
  <button id="down">▼</button>
  <button id="right">▶</button>
</div>

<button id="carBtn">🚗 ENTER</button>
<button id="missionBtn">🎯 MISSION</button>

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

scene.add(new THREE.HemisphereLight(0xffffff, 0x777777, 2));

const sun = new THREE.DirectionalLight(0xffffff, 2);
sun.position.set(10, 20, 10);
scene.add(sun);

function box(w,h,d,color,x,y,z){
  const mesh = new THREE.Mesh(
    new THREE.BoxGeometry(w,h,d),
    new THREE.MeshStandardMaterial({color})
  );
  mesh.position.set(x,y,z);
  scene.add(mesh);
  return mesh;
}

// Ground
box(200,0.05,200,0x4c9a52,0,-0.03,0);

// Roads
box(200,0.05,12,0x444444,0,0.03,0);
box(12,0.05,200,0x444444,0,0.04,0);

// Houses
for(let x=-60;x<=60;x+=30){
  for(let z=-60;z<=60;z+=30){
    if(Math.abs(x)<15 || Math.abs(z)<15) continue;
    box(12,10,12,0xd98b5f,x,5,z);
    box(14,2,14,0x8b4513,x,11,z);
  }
}

// NPC
function createNPC(x,z,color){
  const npc = new THREE.Group();

  const body = new THREE.Mesh(
    new THREE.BoxGeometry(1.2,2,0.8),
    new THREE.MeshStandardMaterial({color})
  );
  body.position.y=1.5;
  npc.add(body);

  const head = new THREE.Mesh(
    new THREE.SphereGeometry(0.45,16,16),
    new THREE.MeshStandardMaterial({color:0xffcc99})
  );
  head.position.y=2.8;
  npc.add(head);

  npc.position.set(x,0,z);
  scene.add(npc);
  return npc;
}

createNPC(-8,5,0x22c55e);
createNPC(8,-5,0xf59e0b);
createNPC(-8,-8,0xa855f7);

// Shop
box(8,6,8,0x3b82f6,25,3,25);
box(8.5,1,8.5,0x1e3a8a,25,6.5,25);

// Player
const player = new THREE.Group();

const body = new THREE.Mesh(
  new THREE.BoxGeometry(1.2,2,0.8),
  new THREE.MeshStandardMaterial({color:0x2563eb})
);
body.position.y=1.5;
player.add(body);

const head = new THREE.Mesh(
  new THREE.SphereGeometry(0.45,16,16),
  new THREE.MeshStandardMaterial({color:0xffcc99})
);
head.position.y=2.8;
player.add(head);

player.position.set(0,0,8);
scene.add(player);

// Car
const car = new THREE.Group();

const carBody = new THREE.Mesh(
  new THREE.BoxGeometry(3,1,5),
  new THREE.MeshStandardMaterial({color:0xdc2626})
);
carBody.position.y=0.8;
car.add(carBody);

const roof = new THREE.Mesh(
  new THREE.BoxGeometry(2.4,0.8,2.5),
  new THREE.MeshStandardMaterial({color:0x222222})
);
roof.position.y=1.6;
car.add(roof);

const wheels = [];

function createWheel(x,z){
  const wheel = new THREE.Mesh(
    new THREE.CylinderGeometry(0.45,0.45,0.3,16),
    new THREE.MeshStandardMaterial({color:0x111111})
  );
  wheel.rotation.z=Math.PI/2;
  wheel.position.set(x,0.45,z);
  car.add(wheel);
  wheels.push(wheel);
}

createWheel(-1.3,-1.5);
createWheel(1.3,-1.5);
createWheel(-1.3,1.5);
createWheel(1.3,1.5);

car.position.set(8,0,8);
scene.add(car);

// Traffic cars
const trafficCars = [];

function createTrafficCar(x,z,color){
  const traffic = new THREE.Mesh(
    new THREE.BoxGeometry(2,1,4),
    new THREE.MeshStandardMaterial({color})
  );
  traffic.position.set(x,0.6,z);
  scene.add(traffic);
  trafficCars.push(traffic);
}

createTrafficCar(-30,0,0x2563eb);
createTrafficCar(30,0,0xf59e0b);
createTrafficCar(0,-30,0x22c55e);

// Game state
const keys = {};
let driving = false;
let mission = 0;
let missionComplete = false;

function hold(id,key){
  const btn=document.getElementById(id);

  btn.addEventListener("pointerdown",e=>{
    e.preventDefault();
    keys[key]=true;
  });

  btn.addEventListener("pointerup",()=>keys[key]=false);
  btn.addEventListener("pointercancel",()=>keys[key]=false);
  btn.addEventListener("pointerleave",()=>keys[key]=false);
}

hold("up","up");
hold("down","down");
hold("left","left");
hold("right","right");

// Enter / Exit car
document.getElementById("carBtn").addEventListener("click",()=>{
  const distance=player.position.distanceTo(car.position);

  if(!driving && distance<4){
    driving=true;
    document.getElementById("carBtn").textContent="🚶 EXIT";
    document.getElementById("info").innerHTML=
      "🚗 তুমি গাড়িতে উঠেছো!<br>🎮 গাড়ি চালাও";
  }
  else if(driving){
    driving=false;
    player.position.set(car.position.x+3,0,car.position.z);
    document.getElementById("carBtn").textContent="🚗 ENTER";
    document.getElementById("info").innerHTML=
      "🚶 তুমি গাড়ি থেকে নেমেছো!";
  }
  else{
    document.getElementById("info").innerHTML=
      "🚗 গাড়ির কাছে যাও!";
  }
});

// Mission button
document.getElementById("missionBtn").addEventListener("click",()=>{
  if(mission===0){
    mission=1;
    document.getElementById("info").innerHTML=
      "🎯 MISSION 1<br>🚗 গাড়ির কাছে যাও";
  }
  else if(mission===1 && driving){
    mission=2;
    document.getElementById("info").innerHTML=
      "🎯 MISSION 2<br>🏪 দোকানে যাও";
  }
  else if(mission===2){
    document.getElementById("info").innerHTML=
      "🏪 দোকানে যাও এবং মিশন শেষ করো!";
  }
});

// Update
function update(){
  const speed=driving?0.15:0.08;
  const target=driving?car:player;

  if(keys.up) target.position.z-=speed;
  if(keys.down) target.position.z+=speed;
  if(keys.left) target.position.x-=speed;
  if(keys.right) target.position.x+=speed;

  // Wheel rotation
  if(driving){
    wheels.forEach(wheel=>{
      wheel.rotation.x+=0.15;
    });
  }

  // Mission 1
  if(mission===0 && !missionComplete){
    const distance=player.position.distanceTo(car.position);

    if(distance<4){
      missionComplete=true;
      document.getElementById("info").innerHTML=
        "🏆 MISSION COMPLETE!<br>🎯 MISSION চাপো";
    }
  }

  // Mission 2
  if(mission===2 && driving){
    const distance=car.position.distanceTo(
      new THREE.Vector3(25,0,25)
    );

    if(distance<5){
      mission=3;
      document.getElementById("info").innerHTML=
        "🏆 MISSION COMPLETE!<br>🎉 তুমি দোকানে পৌঁছেছো!";
    }
  }

  // Traffic movement
  trafficCars.forEach((traffic,i)=>{
    traffic.position.x+=0.03+i*0.01;

    if(traffic.position.x>100){
      traffic.position.x=-100;
    }
  });

  // Camera follow
  camera.position.lerp(
    new THREE.Vector3(
      target.position.x,
      target.position.y+6,
      target.position.z+12
    ),
    0.06
  );

  camera.lookAt(
    target.position.x,
    target.position.y+1,
    target.position.z
  );
}

function animate(){
  requestAnimationFrame(animate);
  update();
  renderer.render(scene,camera);
}

animate();

addEventListener("resize",()=>{
  camera.aspect=innerWidth/innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(innerWidth,innerHeight);
});
</script>
</body>
</html>

