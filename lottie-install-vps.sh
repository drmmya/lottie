#!/usr/bin/env bash
set -e

APP_DIR="/var/www/html/lottie"
BACKUP_DIR="/var/www/html/lottie_backup_$(date +%Y%m%d_%H%M%S)"

need_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root: sudo bash $0"
    exit 1
  fi
}

install_nginx() {
  if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y nginx curl
    systemctl enable nginx
    systemctl restart nginx
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y nginx curl
    systemctl enable nginx
    systemctl restart nginx
  elif command -v yum >/dev/null 2>&1; then
    yum install -y epel-release || true
    yum install -y nginx curl
    systemctl enable nginx
    systemctl restart nginx
  else
    echo "Unsupported OS package manager. Install nginx manually, then re-run."
    exit 1
  fi
}

write_index() {
  mkdir -p "$APP_DIR"

  if [ -f "$APP_DIR/index.html" ]; then
    mkdir -p "$BACKUP_DIR"
    cp -a "$APP_DIR/." "$BACKUP_DIR/"
    echo "Backup saved to: $BACKUP_DIR"
  fi

  cat > "$APP_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Fast PNG to Lottie Maker</title>
<style>
  :root{
    --bg:#030d22;
    --panel:#091934;
    --panel2:#0b1d3f;
    --line:rgba(255,255,255,.14);
    --text:#f6f8ff;
    --muted:#bed0ff;
    --accent:#22c55e;
    --accent2:#1d4ed8;
  }
  *{box-sizing:border-box}
  body{
    margin:0;
    font-family:Arial,Helvetica,sans-serif;
    color:var(--text);
    background:linear-gradient(180deg,#010615 0%,#03102a 100%);
  }
  .page{
    max-width:1020px;
    margin:20px auto;
    padding:0 12px;
  }
  .wrap{
    display:grid;
    grid-template-columns:320px 1fr;
    gap:16px;
    align-items:stretch;
  }
  .panel{
    background:linear-gradient(180deg,var(--panel),var(--panel2));
    border:1px solid var(--line);
    border-radius:18px;
    box-shadow:0 10px 30px rgba(0,0,0,.25);
  }
  .sidebar{padding:16px}
  h1,h2,h3,p{margin:0}
  h2{font-size:18px;font-weight:700;margin-bottom:10px}
  .sub{font-size:14px;line-height:1.4;color:#fff;margin-bottom:14px}
  .field{margin:10px 0}
  label{display:block;font-size:14px;margin-bottom:6px}
  input[type="file"], select, input[type="number"], input[type="text"]{
    width:100%;
    background:#000c2c;
    color:#fff;
    border:1px solid rgba(255,255,255,.14);
    border-radius:10px;
    padding:10px 12px;
    outline:none;
  }
  input[type="number"]{height:32px;padding:6px 10px}
  input[type="range"]{width:100%}
  .grid2{display:grid;grid-template-columns:1fr 1fr;gap:12px}
  .inline{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
  .inline input[type="checkbox"]{margin:0}
  .btn{
    width:100%;
    border:0;
    cursor:pointer;
    border-radius:10px;
    background:#1eb34b;
    color:#fff;
    font-weight:700;
    padding:12px 14px;
    margin-top:8px;
  }
  .btn:disabled{opacity:.55;cursor:not-allowed}
  .status{
    margin-top:14px;
    font-size:13px;
    color:#fff;
    min-height:18px;
  }
  .preview{padding:14px}
  .preview h2{margin-bottom:14px}
  .previewShell{
    border:1px solid rgba(255,255,255,.18);
    border-radius:18px;
    height:480px;
    padding:12px;
    background:
      linear-gradient(180deg, rgba(255,255,255,.02), rgba(255,255,255,.01)),
      linear-gradient(135deg, rgba(255,255,255,.05) 25%, transparent 25%) 0 0/18px 18px,
      linear-gradient(225deg, rgba(255,255,255,.05) 25%, transparent 25%) 0 0/18px 18px,
      linear-gradient(315deg, rgba(255,255,255,.05) 25%, transparent 25%) 0 0/18px 18px,
      linear-gradient(45deg, rgba(255,255,255,.05) 25%, transparent 25%) 0 0/18px 18px,
      #0a1734;
    display:flex;
    align-items:center;
    justify-content:center;
    overflow:hidden;
    position:relative;
  }
  .previewStage{
    width:100%;
    height:100%;
    position:relative;
    border-radius:14px;
    overflow:hidden;
    display:flex;
    align-items:center;
    justify-content:center;
  }
  .placeholder{
    color:#fff;
    font-weight:700;
    font-size:22px;
    text-align:center;
    opacity:.96;
    pointer-events:none;
  }
  .animShell{
    position:absolute;
    left:50%;
    top:50%;
    transform:translate(-50%,-50%);
    display:flex;
    align-items:center;
    justify-content:center;
    pointer-events:none;
  }
  .animTarget{
    display:flex;
    align-items:center;
    justify-content:center;
    transform-origin:center center;
    will-change:transform,opacity;
  }
  #previewImg{
    display:block;
    width:100%;
    height:100%;
    object-fit:contain;
    pointer-events:none;
    user-select:none;
  }
  .mini{font-size:12px;color:var(--muted)}
  .summary{margin-top:10px;font-size:12px;color:var(--muted);line-height:1.4}
  .pill{display:inline-block;font-size:11px;background:rgba(255,255,255,.1);padding:3px 8px;border-radius:999px;margin-left:6px}
  @media (max-width:860px){
    .wrap{grid-template-columns:1fr}
    .previewShell{height:420px}
  }

  @keyframes spin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}
  @keyframes spinReverse{from{transform:rotate(0deg)}to{transform:rotate(-360deg)}}
  @keyframes bounce{0%,100%{transform:translateY(0)}25%{transform:translateY(-110px)}50%{transform:translateY(0)}75%{transform:translateY(-55px)}}
  @keyframes bounceSoft{0%,100%{transform:translateY(0)}50%{transform:translateY(-50px)}}
  @keyframes pulse{0%,100%{transform:scale(1)}50%{transform:scale(1.2)}}
  @keyframes pulseSoft{0%,100%{transform:scale(1)}50%{transform:scale(1.1)}}
  @keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-42px)}}
  @keyframes floatX{0%,100%{transform:translateX(0)}50%{transform:translateX(42px)}}
  @keyframes shake{0%,100%{transform:translateX(0)}20%{transform:translateX(-18px)}40%{transform:translateX(18px)}60%{transform:translateX(-12px)}80%{transform:translateX(12px)}}
  @keyframes shakeSoft{0%,100%{transform:translateX(0)}20%{transform:translateX(-8px)}40%{transform:translateX(8px)}60%{transform:translateX(-6px)}80%{transform:translateX(6px)}}
  @keyframes swing{0%,100%{transform:rotate(0)}25%{transform:rotate(12deg)}75%{transform:rotate(-12deg)}}
  @keyframes swingSoft{0%,100%{transform:rotate(0)}25%{transform:rotate(6deg)}75%{transform:rotate(-6deg)}}
  @keyframes wobble{0%,100%{transform:translateX(0) rotate(0)}15%{transform:translateX(-18px) rotate(-5deg)}30%{transform:translateX(14px) rotate(4deg)}45%{transform:translateX(-12px) rotate(-3deg)}60%{transform:translateX(10px) rotate(2deg)}75%{transform:translateX(-6px) rotate(-1deg)}}
  @keyframes wobbleX{0%,100%{transform:translateX(0)}20%{transform:translateX(-28px)}40%{transform:translateX(22px)}60%{transform:translateX(-16px)}80%{transform:translateX(10px)}}
  @keyframes flash{0%,100%{opacity:1}25%{opacity:.2}50%{opacity:1}75%{opacity:.2}}
  @keyframes blink{0%,45%,100%{opacity:1}50%,95%{opacity:0}}
  @keyframes fadeInOut{0%,100%{opacity:1}50%{opacity:.35}}
  @keyframes zoomInOut{0%,100%{transform:scale(1)}50%{transform:scale(1.3)}}
  @keyframes zoomIn{0%{transform:scale(.7)}100%{transform:scale(1)}}
  @keyframes zoomOut{0%{transform:scale(1.3)}100%{transform:scale(1)}}
  @keyframes slideUpDown{0%,100%{transform:translateY(55px)}50%{transform:translateY(-55px)}}
  @keyframes slideLeftRight{0%,100%{transform:translateX(-80px)}50%{transform:translateX(80px)}}
  @keyframes roll{0%{transform:translateX(-100px) rotate(0deg)}100%{transform:translateX(100px) rotate(360deg)}}
  @keyframes rollReverse{0%{transform:translateX(100px) rotate(0deg)}100%{transform:translateX(-100px) rotate(-360deg)}}
  @keyframes bob{0%,100%{transform:translateY(0)}25%{transform:translateY(-18px)}50%{transform:translateY(0)}75%{transform:translateY(-8px)}}
  @keyframes hop{0%,100%{transform:translateY(0)}50%{transform:translateY(-130px)}}
  @keyframes pop{0%{transform:scale(.4)}60%{transform:scale(1.2)}100%{transform:scale(1)}}
  @keyframes breathe{0%,100%{transform:scale(1);opacity:1}50%{transform:scale(1.06);opacity:.92}}
  @keyframes rubberBand{0%,100%{transform:scale(1,1)}30%{transform:scale(1.25,.75)}40%{transform:scale(.75,1.25)}55%{transform:scale(1.15,.85)}75%{transform:scale(.95,1.05)}}
  @keyframes jello{0%,100%{transform:none}22%{transform:skewX(-12deg) skewY(-6deg)}33%{transform:skewX(8deg) skewY(4deg)}44%{transform:skewX(-5deg) skewY(-3deg)}55%{transform:skewX(3deg) skewY(2deg)}}
  @keyframes tada{0%,100%{transform:scale(1)}10%,20%{transform:scale(.95) rotate(-3deg)}30%,50%,70%,90%{transform:scale(1.08) rotate(3deg)}40%,60%,80%{transform:scale(1.08) rotate(-3deg)}}
  @keyframes heartbeat{0%,100%{transform:scale(1)}14%{transform:scale(1.22)}28%{transform:scale(1)}42%{transform:scale(1.28)}70%{transform:scale(1)}}
  @keyframes rotateScale{0%,100%{transform:rotate(0) scale(1)}50%{transform:rotate(180deg) scale(1.22)}}
  @keyframes pendulum{0%,100%{transform:rotate(20deg)}50%{transform:rotate(-20deg)}}
  @keyframes drift{0%,100%{transform:translate(0,0)}25%{transform:translate(35px,-25px)}50%{transform:translate(70px,5px)}75%{transform:translate(25px,18px)}}
  @keyframes wave{0%,100%{transform:translate(0,0)}25%{transform:translate(28px,-18px)}50%{transform:translate(58px,0)}75%{transform:translate(28px,18px)}}
  @keyframes skewX{0%,100%{transform:skewX(0)}50%{transform:skewX(14deg)}}
  @keyframes skewY{0%,100%{transform:skewY(0)}50%{transform:skewY(14deg)}}
  @keyframes flipX{0%,100%{transform:scaleX(1)}50%{transform:scaleX(-1)}}
  @keyframes flipY{0%,100%{transform:scaleY(1)}50%{transform:scaleY(-1)}}
  @keyframes growShrink{0%,100%{transform:scale(.8)}50%{transform:scale(1.2)}}
  @keyframes liftDrop{0%,100%{transform:translateY(40px)}50%{transform:translateY(-60px)}}
  @keyframes bounceRotate{0%,100%{transform:translateY(0) rotate(0)}25%{transform:translateY(-80px) rotate(12deg)}50%{transform:translateY(0) rotate(0)}75%{transform:translateY(-40px) rotate(-12deg)}}
  @keyframes swingZoom{0%,100%{transform:rotate(0) scale(1)}25%{transform:rotate(10deg) scale(1.1)}75%{transform:rotate(-10deg) scale(.92)}}
  @keyframes orbit{0%{transform:translate(70px,0) rotate(0)}25%{transform:translate(0,-70px) rotate(90deg)}50%{transform:translate(-70px,0) rotate(180deg)}75%{transform:translate(0,70px) rotate(270deg)}100%{transform:translate(70px,0) rotate(360deg)}}
  @keyframes figure8{0%{transform:translate(0,0)}12.5%{transform:translate(32px,-22px)}25%{transform:translate(60px,0)}37.5%{transform:translate(32px,22px)}50%{transform:translate(0,0)}62.5%{transform:translate(-32px,-22px)}75%{transform:translate(-60px,0)}87.5%{transform:translate(-32px,22px)}100%{transform:translate(0,0)}}
  @keyframes jellyPulse{0%,100%{transform:scale(1,1)}25%{transform:scale(1.16,.9)}50%{transform:scale(.92,1.12)}75%{transform:scale(1.08,.96)}}
  @keyframes tremor{0%,100%{transform:translate(0,0)}20%{transform:translate(-3px,2px)}40%{transform:translate(3px,-2px)}60%{transform:translate(-2px,-2px)}80%{transform:translate(2px,2px)}}
  @keyframes spiral{0%{transform:translate(0,0) scale(.8) rotate(0)}25%{transform:translate(26px,-26px) scale(.9) rotate(90deg)}50%{transform:translate(52px,0) scale(1) rotate(180deg)}75%{transform:translate(26px,26px) scale(1.1) rotate(270deg)}100%{transform:translate(0,0) scale(1.2) rotate(360deg)}}
  @keyframes floatRotate{0%,100%{transform:translateY(0) rotate(0)}50%{transform:translateY(-35px) rotate(18deg)}}
  @keyframes bounceX{0%,100%{transform:translateX(0)}25%{transform:translateX(-110px)}50%{transform:translateX(0)}75%{transform:translateX(55px)}}
  @keyframes snap{0%{transform:scale(.2);opacity:0}65%{transform:scale(1.18);opacity:1}100%{transform:scale(1);opacity:1}}
  @keyframes fadeZoom{0%,100%{transform:scale(1);opacity:1}50%{transform:scale(1.25);opacity:.4}}
</style>
</head>
<body>
<div class="page">
  <div class="wrap">
    <div class="panel sidebar">
      <h2>Fast PNG to Lottie Maker</h2>
      <p class="sub">Preview এখন CSS দিয়ে fast হবে। Download করলে browser-এই Lottie JSON বানাবে। <span class="pill" id="styleCount">0 styles</span></p>

      <div class="field">
        <label for="file">Upload PNG / JPG / WebP</label>
        <input type="file" id="file" accept="image/png,image/jpeg,image/webp" />
      </div>

      <div class="field">
        <label for="anim">Animation</label>
        <select id="anim"></select>
      </div>

      <div class="grid2 field">
        <div>
          <label for="speed">Speed (seconds)</label>
          <input type="range" id="speed" min="0.4" max="8" step="0.1" value="2">
          <div class="mini"><span id="speedVal">2.0</span>s / cycle</div>
        </div>
        <div>
          <label for="size">Size</label>
          <input type="range" id="size" min="20" max="220" step="1" value="100">
          <div class="mini"><span id="sizeVal">100</span>%</div>
        </div>
      </div>

      <div class="grid2 field">
        <div>
          <label for="width">Width</label>
          <input type="number" id="width" min="16" max="4000" value="800">
        </div>
        <div>
          <label for="height">Height</label>
          <input type="number" id="height" min="16" max="4000" value="800">
        </div>
      </div>

      <div class="field">
        <label for="bg">Background</label>
        <input type="color" id="bg" value="#0a1734">
      </div>

      <div class="field inline">
        <input type="checkbox" id="transparent" checked>
        <label for="transparent" style="margin:0">Transparent background</label>
      </div>

      <div class="field">
        <label for="compressPx">Image Compress Max Size (px)</label>
        <input type="number" id="compressPx" min="32" max="2048" value="384">
      </div>

      <button class="btn" id="downloadBtn" disabled>Download Lottie JSON</button>
      <div class="status" id="status">Ready</div>
      <div class="summary">
        Fix included:<br>
        1) size বড় করলেও spin only spin করবে, auto-zoom bug থাকবে না<br>
        2) এখানে 40+ animation style আছে এবং dropdown-এ full list show করবে
      </div>
    </div>

    <div class="panel preview">
      <h2>Fast Preview</h2>
      <div class="previewShell" id="previewShell">
        <div class="previewStage" id="previewStage">
          <div class="placeholder" id="placeholder">Upload image first</div>
          <div class="animShell" id="animShell" style="display:none; width:200px; height:200px;">
            <div class="animTarget" id="animTarget" style="width:100%;height:100%;">
              <img id="previewImg" alt="preview">
            </div>
          </div>
        </div>
      </div>
      <div class="summary">Preview আলাদা wrapper ব্যবহার করে, তাই size slider আর animation transform একে অন্যকে overwrite করবে না।</div>
    </div>
  </div>
</div>

<script>
(() => {
  const animations = [
    ['spin','Spin'],['spinReverse','Spin Reverse'],['bounce','Bounce'],['bounceSoft','Bounce Soft'],['pulse','Pulse'],['pulseSoft','Pulse Soft'],
    ['float','Float'],['floatX','Float X'],['shake','Shake'],['shakeSoft','Shake Soft'],['swing','Swing'],['swingSoft','Swing Soft'],
    ['wobble','Wobble'],['wobbleX','Wobble X'],['flash','Flash'],['blink','Blink'],['fadeInOut','Fade In Out'],['zoomInOut','Zoom In Out'],
    ['zoomIn','Zoom In'],['zoomOut','Zoom Out'],['slideUpDown','Slide Up Down'],['slideLeftRight','Slide Left Right'],['roll','Roll'],['rollReverse','Roll Reverse'],
    ['bob','Bob'],['hop','Hop'],['pop','Pop'],['breathe','Breathe'],['rubberBand','Rubber Band'],['jello','Jello'],['tada','Tada'],['heartbeat','Heartbeat'],
    ['rotateScale','Rotate Scale'],['pendulum','Pendulum'],['drift','Drift'],['wave','Wave'],['skewX','Skew X'],['skewY','Skew Y'],['flipX','Flip X'],['flipY','Flip Y'],
    ['growShrink','Grow Shrink'],['liftDrop','Lift Drop'],['bounceRotate','Bounce Rotate'],['swingZoom','Swing Zoom'],['orbit','Orbit'],['figure8','Figure 8'],
    ['jellyPulse','Jelly Pulse'],['tremor','Tremor'],['spiral','Spiral'],['floatRotate','Float Rotate'],['bounceX','Bounce X'],['snap','Snap'],['fadeZoom','Fade Zoom']
  ];

  const $ = (id) => document.getElementById(id);
  const fileEl = $('file');
  const animEl = $('anim');
  const speedEl = $('speed');
  const sizeEl = $('size');
  const widthEl = $('width');
  const heightEl = $('height');
  const bgEl = $('bg');
  const transparentEl = $('transparent');
  const compressEl = $('compressPx');
  const downloadBtn = $('downloadBtn');
  const statusEl = $('status');
  const previewStage = $('previewStage');
  const previewShell = $('previewShell');
  const placeholder = $('placeholder');
  const animShell = $('animShell');
  const animTarget = $('animTarget');
  const previewImg = $('previewImg');
  const speedVal = $('speedVal');
  const sizeVal = $('sizeVal');
  const styleCount = $('styleCount');

  let state = {
    originalDataUrl: '',
    dataUrl: '',
    imageWidth: 0,
    imageHeight: 0,
    processedWidth: 0,
    processedHeight: 0,
  };

  animEl.innerHTML = animations.map(([v,n]) => `<option value="${v}">${n}</option>`).join('');
  styleCount.textContent = `${animations.length} styles`;

  const timingMap = {
    bounce:'ease-in-out', bounceSoft:'ease-in-out', pulse:'ease-in-out', pulseSoft:'ease-in-out', float:'ease-in-out', floatX:'ease-in-out',
    swing:'ease-in-out', swingSoft:'ease-in-out', wobble:'ease-in-out', wobbleX:'ease-in-out', fadeInOut:'ease-in-out', zoomInOut:'ease-in-out',
    zoomIn:'ease-out', zoomOut:'ease-in', bob:'ease-in-out', hop:'ease-in-out', pop:'ease-out', breathe:'ease-in-out', rubberBand:'ease-in-out',
    jello:'ease-in-out', tada:'ease-in-out', heartbeat:'ease-in-out', rotateScale:'ease-in-out', pendulum:'ease-in-out', drift:'ease-in-out',
    wave:'linear', skewX:'ease-in-out', skewY:'ease-in-out', flipX:'ease-in-out', flipY:'ease-in-out', growShrink:'ease-in-out', liftDrop:'ease-in-out',
    bounceRotate:'ease-in-out', swingZoom:'ease-in-out', orbit:'linear', figure8:'linear', jellyPulse:'ease-in-out', tremor:'linear', spiral:'linear',
    floatRotate:'ease-in-out', bounceX:'ease-in-out', snap:'ease-out', fadeZoom:'ease-in-out'
  };

  function setStatus(msg) { statusEl.textContent = msg; }

  function updatePreviewBackground() {
    previewStage.style.background = transparentEl.checked ? 'transparent' : bgEl.value;
  }

  function fitBaseSize() {
    if (!state.dataUrl) return {w:200,h:200};
    const maxBox = 220;
    const iw = state.processedWidth || state.imageWidth || 200;
    const ih = state.processedHeight || state.imageHeight || 200;
    const ratio = Math.min(maxBox / iw, maxBox / ih, 1);
    return { w: Math.max(20, Math.round(iw * ratio)), h: Math.max(20, Math.round(ih * ratio)) };
  }

  function updatePreview() {
    speedVal.textContent = Number(speedEl.value).toFixed(1);
    sizeVal.textContent = sizeEl.value;
    updatePreviewBackground();

    if (!state.dataUrl) {
      placeholder.style.display = 'block';
      animShell.style.display = 'none';
      downloadBtn.disabled = true;
      return;
    }

    placeholder.style.display = 'none';
    animShell.style.display = 'flex';
    downloadBtn.disabled = false;

    const base = fitBaseSize();
    const scale = Number(sizeEl.value) / 100;
    animShell.style.width = Math.max(12, Math.round(base.w * scale)) + 'px';
    animShell.style.height = Math.max(12, Math.round(base.h * scale)) + 'px';

    previewImg.src = state.dataUrl;
    const anim = animEl.value;
    const duration = Math.max(0.1, Number(speedEl.value));
    animTarget.style.animation = 'none';
    void animTarget.offsetWidth;
    animTarget.style.animation = `${anim} ${duration}s infinite ${timingMap[anim] || 'linear'}`;
  }

  function resizeDataUrl(dataUrl, maxDim) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        let w = img.naturalWidth;
        let h = img.naturalHeight;
        const originalW = w;
        const originalH = h;
        if (maxDim > 0) {
          const ratio = Math.min(1, maxDim / Math.max(w, h));
          w = Math.max(1, Math.round(w * ratio));
          h = Math.max(1, Math.round(h * ratio));
        }
        const canvas = document.createElement('canvas');
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');
        ctx.clearRect(0,0,w,h);
        ctx.drawImage(img, 0, 0, w, h);
        resolve({ dataUrl: canvas.toDataURL('image/png'), originalW, originalH, w, h });
      };
      img.onerror = reject;
      img.src = dataUrl;
    });
  }

  fileEl.addEventListener('change', async (e) => {
    const file = e.target.files && e.target.files[0];
    if (!file) return;
    setStatus('Loading image...');
    try {
      const reader = new FileReader();
      reader.onload = async () => {
        try {
          const originalDataUrl = reader.result;
          const compressed = await resizeDataUrl(originalDataUrl, parseInt(compressEl.value || '384', 10));
          state.originalDataUrl = originalDataUrl;
          state.dataUrl = compressed.dataUrl;
          state.imageWidth = compressed.originalW;
          state.imageHeight = compressed.originalH;
          state.processedWidth = compressed.w;
          state.processedHeight = compressed.h;
          updatePreview();
          setStatus(`Image ready (${compressed.w}x${compressed.h})`);
        } catch (err) {
          console.error(err);
          setStatus('Image process failed');
        }
      };
      reader.readAsDataURL(file);
    } catch (err) {
      console.error(err);
      setStatus('Image load failed');
    }
  });

  [animEl, speedEl, sizeEl, widthEl, heightEl, bgEl, transparentEl, compressEl].forEach(el => {
    el.addEventListener('input', updatePreview);
    el.addEventListener('change', updatePreview);
  });

  function ease1(){ return {i:{x:[0.667],y:[1]},o:{x:[0.333],y:[0]}}; }
  function ease2(n=3){ return {i:{x:new Array(n).fill(0.667),y:new Array(n).fill(1)},o:{x:new Array(n).fill(0.333),y:new Array(n).fill(0)}}; }

  function kf1(values, total) {
    const out=[];
    const last=values.length-1;
    const step = total / last;
    for (let i=0;i<values.length;i++) {
      const t = Math.round(i * step);
      if (i < last) out.push(Object.assign({t, s:[values[i]], e:[values[i+1]]}, ease1()));
      else out.push({t, s:[values[i]]});
    }
    return out;
  }

  function kf2(values, total) {
    const out=[];
    const last=values.length-1;
    const step = total / last;
    for (let i=0;i<values.length;i++) {
      const t = Math.round(i * step);
      const current = [values[i][0], values[i][1], 0];
      if (i < last) {
        const next = [values[i+1][0], values[i+1][1], 0];
        out.push(Object.assign({t, s:current, e:next}, ease2(3)));
      } else out.push({t, s:current});
    }
    return out;
  }

  function kfS(values, total) {
    const out=[];
    const last=values.length-1;
    const step = total / last;
    for (let i=0;i<values.length;i++) {
      const t = Math.round(i * step);
      const current = [values[i][0], values[i][1], 100];
      if (i < last) {
        const next = [values[i+1][0], values[i+1][1], 100];
        out.push(Object.assign({t, s:current, e:next}, ease2(3)));
      } else out.push({t, s:current});
    }
    return out;
  }

  function cycleFrames() {
    return Math.max(24, Math.round(Number(speedEl.value || 2) * 60));
  }

  function exportMotion(name, w, h) {
    const total = cycleFrames();
    const cx = Math.round(w / 2);
    const cy = Math.round(h / 2);
    const dx = Math.round(Math.min(w, h) * 0.10) || 40;
    const dy = Math.round(Math.min(w, h) * 0.12) || 48;
    const motion = {
      o:{a:0,k:100},
      r:{a:0,k:0},
      p:{a:0,k:[cx,cy,0]},
      s:{a:0,k:[100,100,100]}
    };
    const setPos = vals => motion.p = {a:1,k:kf2(vals,total)};
    const setRot = vals => motion.r = {a:1,k:kf1(vals,total)};
    const setOpa = vals => motion.o = {a:1,k:kf1(vals,total)};
    const setSca = vals => motion.s = {a:1,k:kfS(vals,total)};

    switch(name){
      case 'spin': setRot([0,360]); break;
      case 'spinReverse': setRot([0,-360]); break;
      case 'bounce': setPos([[cx,cy],[cx,cy-dy*2],[cx,cy],[cx,cy-dy],[cx,cy]]); break;
      case 'bounceSoft': setPos([[cx,cy],[cx,cy-dy],[cx,cy]]); break;
      case 'pulse': setSca([[100,100],[120,120],[100,100]]); break;
      case 'pulseSoft': setSca([[100,100],[110,110],[100,100]]); break;
      case 'float': setPos([[cx,cy],[cx,cy-dy],[cx,cy]]); break;
      case 'floatX': setPos([[cx,cy],[cx+dx,cy],[cx,cy]]); break;
      case 'shake': setPos([[cx,cy],[cx-18,cy],[cx+18,cy],[cx-12,cy],[cx+12,cy],[cx,cy]]); break;
      case 'shakeSoft': setPos([[cx,cy],[cx-8,cy],[cx+8,cy],[cx-6,cy],[cx+6,cy],[cx,cy]]); break;
      case 'swing': setRot([0,12,0,-12,0]); break;
      case 'swingSoft': setRot([0,6,0,-6,0]); break;
      case 'wobble': setPos([[cx,cy],[cx-18,cy],[cx+14,cy],[cx-12,cy],[cx+10,cy],[cx,cy]]); motion.r = {a:1,k:kf1([0,-5,4,-3,2,0], total)}; break;
      case 'wobbleX': setPos([[cx,cy],[cx-28,cy],[cx+22,cy],[cx-16,cy],[cx+10,cy],[cx,cy]]); break;
      case 'flash': setOpa([100,20,100,20,100]); break;
      case 'blink': setOpa([100,0,100]); break;
      case 'fadeInOut': setOpa([100,35,100]); break;
      case 'zoomInOut': setSca([[100,100],[130,130],[100,100]]); break;
      case 'zoomIn': setSca([[70,70],[100,100]]); break;
      case 'zoomOut': setSca([[130,130],[100,100]]); break;
      case 'slideUpDown': setPos([[cx,cy+dy],[cx,cy-dy],[cx,cy+dy]]); break;
      case 'slideLeftRight': setPos([[cx-dx*2,cy],[cx+dx*2,cy],[cx-dx*2,cy]]); break;
      case 'roll': setPos([[cx-dx*2,cy],[cx+dx*2,cy]]); setRot([0,360]); break;
      case 'rollReverse': setPos([[cx+dx*2,cy],[cx-dx*2,cy]]); setRot([0,-360]); break;
      case 'bob': setPos([[cx,cy],[cx,cy-18],[cx,cy],[cx,cy-8],[cx,cy]]); break;
      case 'hop': setPos([[cx,cy],[cx,cy-dy*2.4],[cx,cy]]); break;
      case 'pop': setSca([[40,40],[120,120],[100,100]]); break;
      case 'breathe': setSca([[100,100],[106,106],[100,100]]); motion.o = {a:1,k:kf1([100,92,100], total)}; break;
      case 'rubberBand': setSca([[100,100],[125,75],[75,125],[115,85],[100,100]]); break;
      case 'jello': setRot([0,-8,6,-4,3,0]); setSca([[100,100],[108,96],[96,104],[104,98],[100,100]]); break;
      case 'tada': setRot([0,-3,3,-3,3,0]); setSca([[100,100],[95,95],[108,108],[108,108],[108,108],[100,100]]); break;
      case 'heartbeat': setSca([[100,100],[122,122],[100,100],[128,128],[100,100]]); break;
      case 'rotateScale': setRot([0,180,360]); setSca([[100,100],[122,122],[100,100]]); break;
      case 'pendulum': setRot([20,-20,20]); break;
      case 'drift': setPos([[cx,cy],[cx+35,cy-25],[cx+70,cy+5],[cx+25,cy+18],[cx,cy]]); break;
      case 'wave': setPos([[cx,cy],[cx+28,cy-18],[cx+58,cy],[cx+28,cy+18],[cx,cy]]); break;
      case 'skewX': setSca([[100,100],[120,100],[100,100]]); break;
      case 'skewY': setSca([[100,100],[100,120],[100,100]]); break;
      case 'flipX': setSca([[100,100],[-100,100],[100,100]]); break;
      case 'flipY': setSca([[100,100],[100,-100],[100,100]]); break;
      case 'growShrink': setSca([[80,80],[120,120],[80,80]]); break;
      case 'liftDrop': setPos([[cx,cy+40],[cx,cy-60],[cx,cy+40]]); break;
      case 'bounceRotate': setPos([[cx,cy],[cx,cy-80],[cx,cy],[cx,cy-40],[cx,cy]]); setRot([0,12,0,-12,0]); break;
      case 'swingZoom': setRot([0,10,0,-10,0]); setSca([[100,100],[110,110],[100,100],[92,92],[100,100]]); break;
      case 'orbit': setPos([[cx+70,cy],[cx,cy-70],[cx-70,cy],[cx,cy+70],[cx+70,cy]]); setRot([0,90,180,270,360]); break;
      case 'figure8': setPos([[cx,cy],[cx+32,cy-22],[cx+60,cy],[cx+32,cy+22],[cx,cy],[cx-32,cy-22],[cx-60,cy],[cx-32,cy+22],[cx,cy]]); break;
      case 'jellyPulse': setSca([[100,100],[116,90],[92,112],[108,96],[100,100]]); break;
      case 'tremor': setPos([[cx,cy],[cx-3,cy+2],[cx+3,cy-2],[cx-2,cy-2],[cx+2,cy+2],[cx,cy]]); break;
      case 'spiral': setPos([[cx,cy],[cx+26,cy-26],[cx+52,cy],[cx+26,cy+26],[cx,cy]]); setRot([0,90,180,270,360]); setSca([[80,80],[90,90],[100,100],[110,110],[120,120]]); break;
      case 'floatRotate': setPos([[cx,cy],[cx,cy-35],[cx,cy]]); setRot([0,18,0]); break;
      case 'bounceX': setPos([[cx,cy],[cx-dx*2.2,cy],[cx,cy],[cx+dx,cy],[cx,cy]]); break;
      case 'snap': setSca([[20,20],[118,118],[100,100]]); setOpa([0,100,100]); break;
      case 'fadeZoom': setSca([[100,100],[125,125],[100,100]]); setOpa([100,40,100]); break;
      default: setRot([0,360]);
    }
    return { total, motion };
  }

  function dataUrlToBase64(dataUrl) {
    return dataUrl.split(',')[1] || '';
  }

  function buildLottieJson() {
    if (!state.dataUrl) throw new Error('No image selected');
    const w = Math.max(16, parseInt(widthEl.value || '800', 10));
    const h = Math.max(16, parseInt(heightEl.value || '800', 10));
    const imgW = state.processedWidth || state.imageWidth || 200;
    const imgH = state.processedHeight || state.imageHeight || 200;
    const bgColor = transparentEl.checked ? null : bgEl.value;
    const sizeFactor = Math.max(0.1, Number(sizeEl.value || '100') / 100);
    const { total, motion } = exportMotion(animEl.value, w, h);
    if (motion.s.a === 0) {
      motion.s.k = [motion.s.k[0] * sizeFactor, motion.s.k[1] * sizeFactor, 100];
    } else {
      motion.s.k = motion.s.k.map((kf, idx) => {
        if (idx === motion.s.k.length - 1 && kf.s) return { ...kf, s:[kf.s[0]*sizeFactor, kf.s[1]*sizeFactor, 100] };
        if (kf.s && kf.e) return { ...kf, s:[kf.s[0]*sizeFactor, kf.s[1]*sizeFactor, 100], e:[kf.e[0]*sizeFactor, kf.e[1]*sizeFactor, 100] };
        return kf;
      });
    }

    const base64 = dataUrlToBase64(state.dataUrl);
    const layers = [];
    if (bgColor) {
      const r = parseInt(bgColor.slice(1,3),16)/255;
      const g = parseInt(bgColor.slice(3,5),16)/255;
      const b = parseInt(bgColor.slice(5,7),16)/255;
      layers.push({
        ddd:0, ind:1, ty:1, nm:'Background', sr:1,
        ks:{o:{a:0,k:100}, r:{a:0,k:0}, p:{a:0,k:[w/2,h/2,0]}, a:{a:0,k:[0,0,0]}, s:{a:0,k:[100,100,100]}},
        shapes:[
          {ty:'rc', d:1, s:{a:0,k:[w,h]}, p:{a:0,k:[0,0]}, r:{a:0,k:0}, nm:'Rect'},
          {ty:'fl', c:{a:0,k:[r,g,b,1]}, o:{a:0,k:100}, r:1, nm:'Fill'},
          {ty:'tr', p:{a:0,k:[0,0]}, a:{a:0,k:[0,0]}, s:{a:0,k:[100,100]}, r:{a:0,k:0}, o:{a:0,k:100}, sk:{a:0,k:0}, sa:{a:0,k:0}}
        ],
        ip:0, op:total, st:0, bm:0
      });
    }

    const imageLayerInd = layers.length + 1;
    layers.push({
      ddd:0,
      ind:imageLayerInd,
      ty:2,
      nm:'Image Layer',
      refId:'image_0',
      sr:1,
      ks:{
        o:motion.o,
        r:motion.r,
        p:motion.p,
        a:{a:0,k:[imgW/2,imgH/2,0]},
        s:motion.s
      },
      ip:0,
      op:total,
      st:0,
      bm:0
    });

    return {
      v:'5.7.15',
      fr:60,
      ip:0,
      op:total,
      w,
      h,
      nm:'PNG to Lottie Export',
      ddd:0,
      assets:[{
        id:'image_0',
        w:imgW,
        h:imgH,
        u:'',
        p:'data:image/png;base64,' + base64,
        e:1
      }],
      layers,
      meta:{
        generator:'Fast PNG to Lottie Maker',
        animation:animEl.value,
        transparent:transparentEl.checked,
        speedSeconds:Number(speedEl.value),
        sizePercent:Number(sizeEl.value)
      }
    };
  }

  function downloadJson(data, filename) {
    const blob = new Blob([JSON.stringify(data, null, 2)], {type:'application/json'});
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  downloadBtn.addEventListener('click', () => {
    try {
      const json = buildLottieJson();
      const safeName = (animEl.value || 'animation').replace(/[^a-z0-9_-]/gi,'_');
      downloadJson(json, `lottie_${safeName}.json`);
      setStatus(`Downloaded: lottie_${safeName}.json`);
    } catch (err) {
      console.error(err);
      setStatus('Download failed: ' + err.message);
    }
  });

  updatePreview();
})();
</script>
</body>
</html>
HTML
}

post_message() {
  echo ""
  echo "==========================================="
  echo "Lottie maker installed successfully"
  echo "Path: $APP_DIR"
  echo "URL : http://YOUR_SERVER_IP/lottie/"
  echo "==========================================="
  echo ""
}

need_root
install_nginx
write_index
systemctl restart nginx || true
post_message
