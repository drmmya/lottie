#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/html/lottie"
INDEX_FILE="$APP_DIR/index.html"

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Please run as root: sudo bash install-lottie-maker.sh"
  exit 1
fi

echo "==> Installing PNG to Lottie Maker..."

# Install and enable a web server when possible.
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y nginx
  systemctl enable nginx >/dev/null 2>&1 || true
  systemctl restart nginx >/dev/null 2>&1 || true
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y nginx
  systemctl enable nginx >/dev/null 2>&1 || true
  systemctl restart nginx >/dev/null 2>&1 || true
elif command -v yum >/dev/null 2>&1; then
  yum install -y nginx
  systemctl enable nginx >/dev/null 2>&1 || true
  systemctl restart nginx >/dev/null 2>&1 || true
else
  echo "No supported package manager found. I will only create the files."
fi

mkdir -p "$APP_DIR"

if [ -f "$INDEX_FILE" ]; then
  BACKUP_FILE="$INDEX_FILE.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$INDEX_FILE" "$BACKUP_FILE"
  echo "Backup created: $BACKUP_FILE"
fi

cat > "$INDEX_FILE" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Fast PNG to Lottie Maker</title>
<style>
  :root{
    --bg:#020617; --panel:#111827; --panel2:#0f172a; --border:#334155;
    --text:#fff; --muted:#cbd5e1; --accent:#0ea5e9; --green:#16a34a;
  }
  *{box-sizing:border-box}
  body{
    margin:0; min-height:100vh; background:var(--bg); color:var(--text);
    font-family:Arial,Helvetica,sans-serif; font-size:14px;
  }
  .wrap{max-width:980px; margin:20px auto; padding:0 10px; display:grid; grid-template-columns:304px 1fr; gap:16px}
  .card{background:var(--panel); border:1px solid var(--border); border-radius:18px; padding:16px; box-shadow:0 12px 35px rgba(0,0,0,.25)}
  h1,h2{margin:12px 0 16px; font-size:21px; line-height:1.15}
  h2{font-size:20px}
  p{margin:0 0 12px; color:#fff; line-height:1.35; font-weight:700}
  label{display:block; margin:10px 0 6px; font-weight:700}
  input,select,button{width:100%; border-radius:9px; border:1px solid var(--border); background:#020617; color:#fff; padding:10px; font-weight:700}
  input[type=file]{padding:8px}
  input[type=range]{accent-color:var(--accent); padding:0; height:22px}
  input[type=color]{height:36px; padding:3px}
  input[type=checkbox]{width:auto; vertical-align:middle; accent-color:var(--accent)}
  button{background:var(--green); border:none; margin-top:12px; cursor:pointer}
  button:disabled{background:#475569; cursor:not-allowed; opacity:.75}
  .row{display:grid; grid-template-columns:1fr 1fr; gap:8px}
  .mini{font-size:12px; color:var(--muted); margin-top:5px; min-height:16px}
  .checkrow{display:flex; align-items:center; gap:7px; margin:12px 0 4px; font-weight:700; line-height:1.3}
  .checkrow input{flex:0 0 auto}
  .status{margin-top:14px; font-weight:700}
  .stage{
    height:483px; display:flex; align-items:center; justify-content:center; overflow:hidden;
    border:1px dashed #475569; border-radius:18px; position:relative;
    background-color:#1e293b;
    background-image:linear-gradient(45deg,rgba(255,255,255,.06) 25%,transparent 25%),linear-gradient(-45deg,rgba(255,255,255,.06) 25%,transparent 25%),linear-gradient(45deg,transparent 75%,rgba(255,255,255,.06) 75%),linear-gradient(-45deg,transparent 75%,rgba(255,255,255,.06) 75%);
    background-size:24px 24px; background-position:0 0,0 12px,12px -12px,-12px 0;
  }
  .placeholder{font-weight:800; text-align:center}
  #previewImg{max-width:80%; max-height:80%; object-fit:contain; transform-origin:center center; display:none; will-change:transform,opacity,filter}
  .footer-tools{display:grid; grid-template-columns:1fr 1fr; gap:8px}
  .secondary{background:#0ea5e9}
  @media(max-width:820px){.wrap{grid-template-columns:1fr}.stage{height:360px}}

  @keyframes spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}
  @keyframes spinReverse{from{transform:rotate(360deg)}to{transform:rotate(0)}}
  @keyframes bounce{0%,100%{transform:translateY(0)}50%{transform:translateY(-110px)}}
  @keyframes pulse{0%,100%{transform:scale(1)}50%{transform:scale(1.35)}}
  @keyframes fade{0%,100%{opacity:1}50%{opacity:.18}}
  @keyframes shake{0%,100%{transform:translateX(0)}20%{transform:translateX(-38px)}40%{transform:translateX(38px)}60%{transform:translateX(-24px)}80%{transform:translateX(24px)}}
  @keyframes swing{0%,100%{transform:rotate(0)}20%{transform:rotate(22deg)}40%{transform:rotate(-18deg)}60%{transform:rotate(12deg)}80%{transform:rotate(-8deg)}}
  @keyframes wobble{0%,100%{transform:translateX(0) rotate(0)}25%{transform:translateX(-38px) rotate(-8deg)}50%{transform:translateX(28px) rotate(6deg)}75%{transform:translateX(-18px) rotate(-4deg)}}
  @keyframes flipX{0%,100%{transform:rotateX(0)}50%{transform:rotateX(180deg)}}
  @keyframes flipY{0%,100%{transform:rotateY(0)}50%{transform:rotateY(180deg)}}
  @keyframes zoom{0%,100%{transform:scale(.7)}50%{transform:scale(1.45)}}
  @keyframes slideLeft{0%,100%{transform:translateX(150px)}50%{transform:translateX(-150px)}}
  @keyframes slideRight{0%,100%{transform:translateX(-150px)}50%{transform:translateX(150px)}}
  @keyframes slideUp{0%,100%{transform:translateY(130px)}50%{transform:translateY(-130px)}}
  @keyframes slideDown{0%,100%{transform:translateY(-130px)}50%{transform:translateY(130px)}}
  @keyframes orbit{0%{transform:rotate(0) translateX(115px) rotate(0)}100%{transform:rotate(360deg) translateX(115px) rotate(-360deg)}}
  @keyframes heartbeat{0%,100%{transform:scale(1)}15%{transform:scale(1.25)}30%{transform:scale(1)}45%{transform:scale(1.4)}60%{transform:scale(1)}}
  @keyframes rubber{0%,100%{transform:scale(1)}25%{transform:scale(1.35,.72)}50%{transform:scale(.78,1.28)}75%{transform:scale(1.12,.9)}}
  @keyframes tada{0%,100%{transform:scale(1) rotate(0)}15%,35%,55%,75%{transform:scale(1.15) rotate(-12deg)}25%,45%,65%,85%{transform:scale(1.15) rotate(12deg)}}
  @keyframes jello{0%,100%{transform:skewX(0)}25%{transform:skewX(-18deg)}50%{transform:skewX(14deg)}75%{transform:skewX(-8deg)}}
  @keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-45px)}}
  @keyframes pop{0%{transform:scale(.1);opacity:0}45%{transform:scale(1.25);opacity:1}70%{transform:scale(.9)}100%{transform:scale(1);opacity:1}}
  @keyframes blink{0%,48%,100%{opacity:1}50%,70%{opacity:0}}
  @keyframes diagonal{0%,100%{transform:translate(-120px,90px)}50%{transform:translate(120px,-90px)}}
  @keyframes rotateScale{0%,100%{transform:rotate(0) scale(.8)}50%{transform:rotate(180deg) scale(1.45)}}
  @keyframes pendulum{0%,100%{transform:rotate(-35deg)}50%{transform:rotate(35deg)}}
  @keyframes skew{0%,100%{transform:skew(0,0)}50%{transform:skew(22deg,8deg)}}
  @keyframes breathe{0%,100%{transform:scale(1);filter:brightness(1)}50%{transform:scale(1.18);filter:brightness(1.35)}}
  @keyframes blurPulse{0%,100%{filter:blur(0);opacity:1}50%{filter:blur(5px);opacity:.62}}
  @keyframes rotateIn{0%{transform:rotate(-220deg) scale(.15);opacity:0}100%{transform:rotate(0) scale(1);opacity:1}}
  @keyframes roll{0%{transform:translateX(-180px) rotate(-360deg)}100%{transform:translateX(180px) rotate(360deg)}}
  @keyframes wave{0%,100%{transform:rotate(0)}15%{transform:rotate(25deg)}30%{transform:rotate(-15deg)}45%{transform:rotate(18deg)}60%{transform:rotate(-9deg)}}
  @keyframes vanish{0%{transform:scale(1);opacity:1}100%{transform:scale(0);opacity:0}}
  @keyframes drop{0%{transform:translateY(-180px);opacity:0}60%{transform:translateY(25px);opacity:1}80%{transform:translateY(-10px)}100%{transform:translateY(0)}}
  @keyframes rise{0%{transform:translateY(180px);opacity:0}100%{transform:translateY(0);opacity:1}}
  @keyframes leftIn{0%{transform:translateX(-240px);opacity:0}100%{transform:translateX(0);opacity:1}}
  @keyframes rightIn{0%{transform:translateX(240px);opacity:0}100%{transform:translateX(0);opacity:1}}
  @keyframes squeeze{0%,100%{transform:scale(1,1)}50%{transform:scale(1.55,.55)}}
  @keyframes stretch{0%,100%{transform:scale(1,1)}50%{transform:scale(.58,1.55)}}
  @keyframes zigzag{0%,100%{transform:translate(0,0)}25%{transform:translate(90px,-70px)}50%{transform:translate(-90px,-10px)}75%{transform:translate(70px,70px)}}
  @keyframes circleZoom{0%{transform:rotate(0) translateX(70px) scale(.85)}50%{transform:rotate(180deg) translateX(70px) scale(1.35)}100%{transform:rotate(360deg) translateX(70px) scale(.85)}}
  @keyframes flash{0%,50%,100%{opacity:1}25%,75%{opacity:.1}}
  @keyframes rotateBounce{0%,100%{transform:translateY(0) rotate(0)}50%{transform:translateY(-100px) rotate(180deg)}}
</style>
</head>
<body>
  <main class="wrap">
    <section class="card">
      <h1>Fast PNG to Lottie Maker</h1>
      <p>Preview এখন CSS দিয়ে fast হবে। Download করলে Lottie JSON বানাবে।</p>

      <label for="file">Upload PNG</label>
      <input id="file" type="file" accept="image/png,image/webp,image/jpeg" />
      <div class="mini" id="fileInfo"></div>

      <label for="anim">Animation</label>
      <select id="anim"></select>

      <div class="row">
        <div><label for="speed">Speed</label><input type="range" id="speed" min="0.3" max="8" step="0.1" value="2"></div>
        <div><label for="size">Size</label><input type="range" id="size" min="20" max="300" step="1" value="100"></div>
      </div>

      <div class="row">
        <div><label for="width">Width</label><input type="number" id="width" min="64" max="3000" value="800"></div>
        <div><label for="height">Height</label><input type="number" id="height" min="64" max="3000" value="800"></div>
      </div>

      <label for="bg">Background</label>
      <input type="color" id="bg" value="#111827">

      <label class="checkrow"><input type="checkbox" id="transparent" checked> Transparent background</label>

      <label for="compress">Image Compress px</label>
      <input type="number" id="compress" min="64" max="4096" value="384">
      <div class="mini">PNG বড় হলে export file ছোট রাখার জন্য image resize হবে।</div>

      <div class="footer-tools">
        <button id="downloadBtn" disabled>Download Lottie JSON</button>
        <button id="resetBtn" class="secondary" type="button">Reset</button>
      </div>
      <div class="status" id="status">Ready</div>
    </section>

    <section class="card">
      <h2>Fast Preview</h2>
      <div class="stage" id="stage">
        <div class="placeholder" id="placeholder">Upload image first</div>
        <img id="previewImg" alt="preview" />
      </div>
    </section>
  </main>

<script>
'use strict';

const ANIMS = [
  ['none','None'], ['spin','Spin'], ['spinReverse','Spin Reverse'], ['bounce','Bounce'], ['pulse','Pulse'], ['fade','Fade'],
  ['shake','Shake'], ['swing','Swing'], ['wobble','Wobble'], ['flipX','Flip X'], ['flipY','Flip Y'], ['zoom','Zoom In Out'],
  ['slideLeft','Slide Left'], ['slideRight','Slide Right'], ['slideUp','Slide Up'], ['slideDown','Slide Down'], ['orbit','Orbit'],
  ['heartbeat','Heartbeat'], ['rubber','Rubber Band'], ['tada','Tada'], ['jello','Jello'], ['float','Float'], ['pop','Pop'], ['blink','Blink'],
  ['diagonal','Diagonal Move'], ['rotateScale','Rotate Scale'], ['pendulum','Pendulum'], ['skew','Skew'], ['breathe','Breathe'], ['blurPulse','Blur Pulse'],
  ['rotateIn','Rotate In'], ['roll','Roll'], ['wave','Wave'], ['vanish','Vanish'], ['drop','Drop In'], ['rise','Rise In'],
  ['leftIn','Left In'], ['rightIn','Right In'], ['squeeze','Squeeze X'], ['stretch','Stretch Y'], ['zigzag','Zig Zag'], ['circleZoom','Circle Zoom'],
  ['flash','Flash'], ['rotateBounce','Rotate Bounce']
];

const el = id => document.getElementById(id);
const file = el('file'), anim = el('anim'), speed = el('speed'), size = el('size'), width = el('width'), height = el('height'), bg = el('bg'), transparent = el('transparent'), compress = el('compress');
const img = el('previewImg'), stage = el('stage'), placeholder = el('placeholder'), statusEl = el('status'), fileInfo = el('fileInfo'), downloadBtn = el('downloadBtn'), resetBtn = el('resetBtn');

let originalImage = null;
let sourceDataUrl = '';
let imageW = 0, imageH = 0;

ANIMS.forEach(([value,label]) => {
  const o = document.createElement('option'); o.value = value; o.textContent = label; anim.appendChild(o);
});
anim.value = 'spin';

function setStatus(text){ statusEl.textContent = text; }
function num(v, fallback){ const n = parseFloat(v); return Number.isFinite(n) ? n : fallback; }
function clamp(v, min, max){ return Math.min(max, Math.max(min, v)); }
function stageBg(){
  stage.style.backgroundColor = transparent.checked ? '#1e293b' : bg.value;
}

function applyPreview(){
  stageBg();
  const dur = clamp(num(speed.value,2), .3, 8);
  const scale = clamp(num(size.value,100), 20, 300);
  img.style.width = scale + '%';
  img.style.height = 'auto';
  img.style.animation = 'none';
  void img.offsetWidth;
  if (anim.value !== 'none' && sourceDataUrl) {
    img.style.animation = `${anim.value} ${dur}s infinite linear`;
  }
}

async function loadImageData(fileObj){
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onerror = () => reject(new Error('File read failed'));
    r.onload = () => {
      const im = new Image();
      im.onerror = () => reject(new Error('Image load failed'));
      im.onload = () => resolve({im, dataUrl:r.result});
      im.src = r.result;
    };
    r.readAsDataURL(fileObj);
  });
}

function resizeImageToDataUrl(im, maxPx){
  const max = clamp(num(maxPx,384), 64, 4096);
  let w = im.naturalWidth, h = im.naturalHeight;
  const ratio = Math.min(1, max / Math.max(w,h));
  w = Math.round(w * ratio); h = Math.round(h * ratio);
  const c = document.createElement('canvas');
  c.width = w; c.height = h;
  const ctx = c.getContext('2d');
  ctx.clearRect(0,0,w,h);
  ctx.drawImage(im,0,0,w,h);
  return {dataUrl:c.toDataURL('image/png'), w, h};
}

file.addEventListener('change', async e => {
  try{
    const f = e.target.files && e.target.files[0];
    if(!f) return;
    setStatus('Loading image...');
    const loaded = await loadImageData(f);
    originalImage = loaded.im;
    const resized = resizeImageToDataUrl(originalImage, compress.value);
    sourceDataUrl = resized.dataUrl;
    imageW = resized.w; imageH = resized.h;
    img.src = sourceDataUrl;
    img.style.display = 'block';
    placeholder.style.display = 'none';
    downloadBtn.disabled = false;
    fileInfo.textContent = `${f.name} | original ${originalImage.naturalWidth}x${originalImage.naturalHeight} | export ${imageW}x${imageH}`;
    setStatus('Ready');
    applyPreview();
  }catch(err){
    console.error(err); setStatus('Image load error');
  }
});

[anim,speed,size,width,height,bg,transparent,compress].forEach(x => x.addEventListener('input', () => {
  if (originalImage && x === compress) {
    const resized = resizeImageToDataUrl(originalImage, compress.value);
    sourceDataUrl = resized.dataUrl; imageW = resized.w; imageH = resized.h; img.src = sourceDataUrl;
  }
  applyPreview();
}));

resetBtn.addEventListener('click', () => {
  anim.value='spin'; speed.value='2'; size.value='100'; width.value='800'; height.value='800'; bg.value='#111827'; transparent.checked=true; compress.value='384';
  applyPreview(); setStatus('Ready');
});

function hold(v){ return {a:0,k:v}; }
function kf(t, s, e){ return {t, s, e, i:{x:[0.833],y:[1]}, o:{x:[0.167],y:[0]}}; }
function linearKf(t, s, e){ return {t, s, e, i:{x:[1],y:[1]}, o:{x:[0],y:[0]}}; }
function percentScale(base, x=1, y=x){ return [base*x, base*y, 100]; }

function buildAnimationKeys(name, frames, cw, ch, baseScale){
  const cx = cw/2, cy = ch/2;
  const keys = {
    a: hold([imageW/2,imageH/2,0]),
    p: hold([cx,cy,0]),
    s: hold(percentScale(baseScale)),
    r: hold(0),
    o: hold(100)
  };
  const p0=[cx,cy,0], s0=percentScale(baseScale);
  switch(name){
    case 'spin': keys.r = {a:1,k:[linearKf(0,[0],[360]) , {...linearKf(frames,[360],[360]), h:1}]}; break;
    case 'spinReverse': keys.r = {a:1,k:[linearKf(0,[360],[0]), {...linearKf(frames,[0],[0]), h:1}]}; break;
    case 'bounce': keys.p = {a:1,k:[kf(0,p0,[cx,cy-130,0]), kf(frames/2,[cx,cy-130,0],p0), {...kf(frames,p0,p0),h:1}]}; break;
    case 'pulse': keys.s = {a:1,k:[kf(0,s0,percentScale(baseScale,1.35)), kf(frames/2,percentScale(baseScale,1.35),s0), {...kf(frames,s0,s0),h:1}]}; break;
    case 'fade': keys.o = {a:1,k:[kf(0,[100],[15]), kf(frames/2,[15],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'shake': keys.p = {a:1,k:[kf(0,p0,[cx-45,cy,0]), kf(frames*.2,[cx-45,cy,0],[cx+45,cy,0]), kf(frames*.4,[cx+45,cy,0],[cx-28,cy,0]), kf(frames*.6,[cx-28,cy,0],[cx+28,cy,0]), kf(frames*.8,[cx+28,cy,0],p0), {...kf(frames,p0,p0),h:1}]}; break;
    case 'swing': keys.r = {a:1,k:[kf(0,[0],[24]), kf(frames*.2,[24],[-18]), kf(frames*.4,[-18],[12]), kf(frames*.6,[12],[-8]), kf(frames*.8,[-8],[0]), {...kf(frames,[0],[0]),h:1}]}; break;
    case 'wobble': keys.p = {a:1,k:[kf(0,p0,[cx-40,cy,0]), kf(frames*.25,[cx-40,cy,0],[cx+30,cy,0]), kf(frames*.5,[cx+30,cy,0],[cx-20,cy,0]), kf(frames*.75,[cx-20,cy,0],p0), {...kf(frames,p0,p0),h:1}]}; keys.r = {a:1,k:[kf(0,[0],[-8]), kf(frames*.25,[-8],[6]), kf(frames*.5,[6],[-4]), kf(frames*.75,[-4],[0]), {...kf(frames,[0],[0]),h:1}]}; break;
    case 'flipX': keys.s = {a:1,k:[kf(0,s0,percentScale(baseScale,1,-1)), kf(frames/2,percentScale(baseScale,1,-1),s0), {...kf(frames,s0,s0),h:1}]}; break;
    case 'flipY': keys.s = {a:1,k:[kf(0,s0,percentScale(baseScale,-1,1)), kf(frames/2,percentScale(baseScale,-1,1),s0), {...kf(frames,s0,s0),h:1}]}; break;
    case 'zoom': keys.s = {a:1,k:[kf(0,percentScale(baseScale,.7),percentScale(baseScale,1.45)), kf(frames/2,percentScale(baseScale,1.45),percentScale(baseScale,.7)), {...kf(frames,percentScale(baseScale,.7),percentScale(baseScale,.7)),h:1}]}; break;
    case 'slideLeft': keys.p = {a:1,k:[kf(0,[cx+170,cy,0],[cx-170,cy,0]), kf(frames/2,[cx-170,cy,0],[cx+170,cy,0]), {...kf(frames,[cx+170,cy,0],[cx+170,cy,0]),h:1}]}; break;
    case 'slideRight': keys.p = {a:1,k:[kf(0,[cx-170,cy,0],[cx+170,cy,0]), kf(frames/2,[cx+170,cy,0],[cx-170,cy,0]), {...kf(frames,[cx-170,cy,0],[cx-170,cy,0]),h:1}]}; break;
    case 'slideUp': keys.p = {a:1,k:[kf(0,[cx,cy+150,0],[cx,cy-150,0]), kf(frames/2,[cx,cy-150,0],[cx,cy+150,0]), {...kf(frames,[cx,cy+150,0],[cx,cy+150,0]),h:1}]}; break;
    case 'slideDown': keys.p = {a:1,k:[kf(0,[cx,cy-150,0],[cx,cy+150,0]), kf(frames/2,[cx,cy+150,0],[cx,cy-150,0]), {...kf(frames,[cx,cy-150,0],[cx,cy-150,0]),h:1}]}; break;
    case 'orbit': keys.p = {a:1,k:[linearKf(0,[cx+120,cy,0],[cx,cy+120,0]), linearKf(frames*.25,[cx,cy+120,0],[cx-120,cy,0]), linearKf(frames*.5,[cx-120,cy,0],[cx,cy-120,0]), linearKf(frames*.75,[cx,cy-120,0],[cx+120,cy,0]), {...linearKf(frames,[cx+120,cy,0],[cx+120,cy,0]),h:1}]}; keys.r={a:1,k:[linearKf(0,[0],[360]), {...linearKf(frames,[360],[360]),h:1}]}; break;
    case 'heartbeat': keys.s = {a:1,k:[kf(0,s0,percentScale(baseScale,1.25)), kf(frames*.15,percentScale(baseScale,1.25),s0), kf(frames*.3,s0,percentScale(baseScale,1.4)), kf(frames*.45,percentScale(baseScale,1.4),s0), {...kf(frames,s0,s0),h:1}]}; break;
    case 'rubber': keys.s = {a:1,k:[kf(0,s0,percentScale(baseScale,1.35,.72)), kf(frames*.25,percentScale(baseScale,1.35,.72),percentScale(baseScale,.78,1.28)), kf(frames*.5,percentScale(baseScale,.78,1.28),percentScale(baseScale,1.12,.9)), kf(frames*.75,percentScale(baseScale,1.12,.9),s0), {...kf(frames,s0,s0),h:1}]}; break;
    case 'tada': keys.s={a:1,k:[kf(0,s0,percentScale(baseScale,1.15)), kf(frames*.85,percentScale(baseScale,1.15),s0), {...kf(frames,s0,s0),h:1}]}; keys.r={a:1,k:[kf(0,[0],[-12]), kf(frames*.15,[-12],[12]), kf(frames*.3,[12],[-12]), kf(frames*.45,[-12],[12]), kf(frames*.6,[12],[-12]), kf(frames*.75,[-12],[0]), {...kf(frames,[0],[0]),h:1}]}; break;
    case 'jello': keys.sk={a:1,k:[kf(0,[0],[-18]), kf(frames*.25,[-18],[14]), kf(frames*.5,[14],[-8]), kf(frames*.75,[-8],[0]), {...kf(frames,[0],[0]),h:1}]}; keys.sa=hold(0); break;
    case 'float': keys.p={a:1,k:[kf(0,p0,[cx,cy-55,0]), kf(frames/2,[cx,cy-55,0],p0), {...kf(frames,p0,p0),h:1}]}; break;
    case 'pop': keys.s={a:1,k:[kf(0,percentScale(baseScale,.1),percentScale(baseScale,1.25)), kf(frames*.45,percentScale(baseScale,1.25),percentScale(baseScale,.9)), kf(frames*.7,percentScale(baseScale,.9),s0), {...kf(frames,s0,s0),h:1}]}; keys.o={a:1,k:[kf(0,[0],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'blink': keys.o={a:1,k:[kf(0,[100],[100]), kf(frames*.48,[100],[0]), kf(frames*.5,[0],[0]), kf(frames*.7,[0],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'diagonal': keys.p={a:1,k:[kf(0,[cx-135,cy+105,0],[cx+135,cy-105,0]), kf(frames/2,[cx+135,cy-105,0],[cx-135,cy+105,0]), {...kf(frames,[cx-135,cy+105,0],[cx-135,cy+105,0]),h:1}]}; break;
    case 'rotateScale': keys.r={a:1,k:[kf(0,[0],[180]), kf(frames/2,[180],[360]), {...kf(frames,[360],[360]),h:1}]}; keys.s={a:1,k:[kf(0,percentScale(baseScale,.8),percentScale(baseScale,1.45)), kf(frames/2,percentScale(baseScale,1.45),percentScale(baseScale,.8)), {...kf(frames,percentScale(baseScale,.8),percentScale(baseScale,.8)),h:1}]}; break;
    case 'pendulum': keys.r={a:1,k:[kf(0,[-35],[35]), kf(frames/2,[35],[-35]), {...kf(frames,[-35],[-35]),h:1}]}; break;
    case 'skew': keys.sk={a:1,k:[kf(0,[0],[22]), kf(frames/2,[22],[0]), {...kf(frames,[0],[0]),h:1}]}; keys.sa={a:1,k:[kf(0,[0],[8]), kf(frames/2,[8],[0]), {...kf(frames,[0],[0]),h:1}]}; break;
    case 'breathe': keys.s={a:1,k:[kf(0,s0,percentScale(baseScale,1.18)), kf(frames/2,percentScale(baseScale,1.18),s0), {...kf(frames,s0,s0),h:1}]}; break;
    case 'blurPulse': keys.o={a:1,k:[kf(0,[100],[62]), kf(frames/2,[62],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'rotateIn': keys.r={a:1,k:[kf(0,[-220],[0]), {...kf(frames,[0],[0]),h:1}]}; keys.s={a:1,k:[kf(0,percentScale(baseScale,.15),s0), {...kf(frames,s0,s0),h:1}]}; keys.o={a:1,k:[kf(0,[0],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'roll': keys.p={a:1,k:[linearKf(0,[cx-190,cy,0],[cx+190,cy,0]), {...linearKf(frames,[cx+190,cy,0],[cx+190,cy,0]),h:1}]}; keys.r={a:1,k:[linearKf(0,[-360],[360]), {...linearKf(frames,[360],[360]),h:1}]}; break;
    case 'wave': keys.r={a:1,k:[kf(0,[0],[25]), kf(frames*.15,[25],[-15]), kf(frames*.3,[-15],[18]), kf(frames*.45,[18],[-9]), kf(frames*.6,[-9],[0]), {...kf(frames,[0],[0]),h:1}]}; break;
    case 'vanish': keys.s={a:1,k:[kf(0,s0,percentScale(baseScale,0.01)), {...kf(frames,percentScale(baseScale,0.01),percentScale(baseScale,0.01)),h:1}]}; keys.o={a:1,k:[kf(0,[100],[0]), {...kf(frames,[0],[0]),h:1}]}; break;
    case 'drop': keys.p={a:1,k:[kf(0,[cx,cy-190,0],[cx,cy+25,0]), kf(frames*.6,[cx,cy+25,0],[cx,cy-10,0]), kf(frames*.8,[cx,cy-10,0],p0), {...kf(frames,p0,p0),h:1}]}; keys.o={a:1,k:[kf(0,[0],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'rise': keys.p={a:1,k:[kf(0,[cx,cy+190,0],p0), {...kf(frames,p0,p0),h:1}]}; keys.o={a:1,k:[kf(0,[0],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'leftIn': keys.p={a:1,k:[kf(0,[cx-260,cy,0],p0), {...kf(frames,p0,p0),h:1}]}; keys.o={a:1,k:[kf(0,[0],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'rightIn': keys.p={a:1,k:[kf(0,[cx+260,cy,0],p0), {...kf(frames,p0,p0),h:1}]}; keys.o={a:1,k:[kf(0,[0],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'squeeze': keys.s={a:1,k:[kf(0,s0,percentScale(baseScale,1.55,.55)), kf(frames/2,percentScale(baseScale,1.55,.55),s0), {...kf(frames,s0,s0),h:1}]}; break;
    case 'stretch': keys.s={a:1,k:[kf(0,s0,percentScale(baseScale,.58,1.55)), kf(frames/2,percentScale(baseScale,.58,1.55),s0), {...kf(frames,s0,s0),h:1}]}; break;
    case 'zigzag': keys.p={a:1,k:[kf(0,p0,[cx+95,cy-80,0]), kf(frames*.25,[cx+95,cy-80,0],[cx-95,cy-15,0]), kf(frames*.5,[cx-95,cy-15,0],[cx+80,cy+80,0]), kf(frames*.75,[cx+80,cy+80,0],p0), {...kf(frames,p0,p0),h:1}]}; break;
    case 'circleZoom': keys.p={a:1,k:[linearKf(0,[cx+80,cy,0],[cx,cy+80,0]), linearKf(frames*.25,[cx,cy+80,0],[cx-80,cy,0]), linearKf(frames*.5,[cx-80,cy,0],[cx,cy-80,0]), linearKf(frames*.75,[cx,cy-80,0],[cx+80,cy,0]), {...linearKf(frames,[cx+80,cy,0],[cx+80,cy,0]),h:1}]}; keys.s={a:1,k:[kf(0,percentScale(baseScale,.85),percentScale(baseScale,1.35)), kf(frames*.5,percentScale(baseScale,1.35),percentScale(baseScale,.85)), {...kf(frames,percentScale(baseScale,.85),percentScale(baseScale,.85)),h:1}]}; break;
    case 'flash': keys.o={a:1,k:[kf(0,[100],[10]), kf(frames*.25,[10],[100]), kf(frames*.5,[100],[10]), kf(frames*.75,[10],[100]), {...kf(frames,[100],[100]),h:1}]}; break;
    case 'rotateBounce': keys.p={a:1,k:[kf(0,p0,[cx,cy-120,0]), kf(frames/2,[cx,cy-120,0],p0), {...kf(frames,p0,p0),h:1}]}; keys.r={a:1,k:[kf(0,[0],[180]), kf(frames/2,[180],[360]), {...kf(frames,[360],[360]),h:1}]}; break;
    default: break;
  }
  return keys;
}

function buildLottie(){
  const cw = Math.round(clamp(num(width.value,800),64,3000));
  const ch = Math.round(clamp(num(height.value,800),64,3000));
  const fr = 60;
  const seconds = clamp(num(speed.value,2), .3, 8);
  const op = Math.round(fr * seconds);
  const baseScale = clamp(num(size.value,100),20,300) / 100 * Math.min(cw / imageW, ch / imageH) * 100 * .75;
  const ks = buildAnimationKeys(anim.value, op, cw, ch, baseScale);
  const lottie = {
    v:'5.7.4', fr, ip:0, op, w:cw, h:ch, nm:'PNG Animation Maker Export', ddd:0,
    assets:[{id:'image_0', w:imageW, h:imageH, u:'', p:sourceDataUrl, e:1}],
    layers:[{
      ddd:0, ind:1, ty:2, nm:'PNG Image', refId:'image_0', sr:1, ks, ao:0,
      ip:0, op, st:0, bm:0
    }],
    markers:[]
  };
  if (!transparent.checked) {
    lottie.layers.unshift({
      ddd:0, ind:2, ty:1, nm:'Background', sr:1,
      ks:{o:hold(100), r:hold(0), p:hold([cw/2,ch/2,0]), a:hold([cw/2,ch/2,0]), s:hold([100,100,100])},
      ao:0, sw:cw, sh:ch, sc:bg.value, ip:0, op, st:0, bm:0
    });
  }
  return lottie;
}

function downloadJSON(){
  if(!sourceDataUrl){ setStatus('Upload image first'); return; }
  try{
    setStatus('Generating JSON...');
    const json = JSON.stringify(buildLottie());
    const blob = new Blob([json], {type:'application/json'});
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    const cleanName = (anim.value || 'animation').replace(/[^a-z0-9_-]/gi,'_').toLowerCase();
    a.download = `png-${cleanName}-lottie.json`;
    document.body.appendChild(a); a.click(); a.remove();
    setTimeout(() => URL.revokeObjectURL(a.href), 1000);
    setStatus('Downloaded');
  }catch(err){ console.error(err); setStatus('JSON export error'); }
}

downloadBtn.addEventListener('click', downloadJSON);
applyPreview();
</script>
</body>
</html>
HTML

chown -R www-data:www-data "$APP_DIR" 2>/dev/null || chown -R nginx:nginx "$APP_DIR" 2>/dev/null || true
chmod -R 755 "$APP_DIR"

# Open firewall if UFW/firewalld is active.
if command -v ufw >/dev/null 2>&1; then
  ufw allow 80/tcp >/dev/null 2>&1 || true
  ufw allow 443/tcp >/dev/null 2>&1 || true
fi
if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-service=http >/dev/null 2>&1 || true
  firewall-cmd --permanent --add-service=https >/dev/null 2>&1 || true
  firewall-cmd --reload >/dev/null 2>&1 || true
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl restart nginx >/dev/null 2>&1 || true
fi

IP=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
echo ""
echo "Done!"
echo "Folder: $APP_DIR"
echo "Open:   http://${IP:-YOUR_SERVER_IP}/lottie/"
echo ""
echo "If it does not open, check VPS firewall/security group and allow port 80."
