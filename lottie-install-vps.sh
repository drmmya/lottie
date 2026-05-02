#!/usr/bin/env bash
set -euo pipefail

echo "Installing Lottie Maker V3 safe static version..."
echo "No service will be stopped/restarted."

TMP_HTML="/tmp/lottie_v3_index_$$.html"
cat > "$TMP_HTML" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Fast PNG to Lottie Maker V3</title>
<!-- VERSION-LottieMaker-V3-53 -->
<style>
:root{--bg:#06142f;--panel:#0b1b3b;--line:rgba(255,255,255,.15);--txt:#fff;--muted:#bcd0ff;--green:#1fb34f}
*{box-sizing:border-box}
body{margin:0;background:linear-gradient(180deg,#020717,#06142f);color:var(--txt);font-family:Arial,Helvetica,sans-serif}
.page{max-width:1100px;margin:18px auto;padding:0 12px}
.wrap{display:grid;grid-template-columns:340px 1fr;gap:16px}
.card{background:linear-gradient(180deg,#081a39,#0c2148);border:1px solid var(--line);border-radius:18px;box-shadow:0 10px 30px rgba(0,0,0,.28)}
.side{padding:16px}
h2{margin:0 0 10px;font-size:18px}.sub{font-size:13px;line-height:1.4;margin:0 0 12px;color:#fff}
.field{margin:10px 0}label{display:block;font-size:13px;margin-bottom:6px}
input,select,button{font:inherit}input[type=file],input[type=number],input[type=text]{width:100%;background:#000d2d;color:#fff;border:1px solid var(--line);border-radius:10px;padding:9px 10px}
input[type=range]{width:100%}.grid2{display:grid;grid-template-columns:1fr 1fr;gap:10px}.mini{font-size:12px;color:var(--muted)}
.row{display:flex;gap:8px;align-items:center;flex-wrap:wrap}.row label{margin:0}.row input{width:auto}
.pill{display:inline-block;border-radius:999px;background:rgba(255,255,255,.1);padding:3px 8px;font-size:11px;margin-left:6px}
.animSearch{margin-bottom:8px}
.animList{height:260px;overflow:auto;border:1px solid var(--line);border-radius:12px;padding:8px;background:#061633;display:grid;grid-template-columns:1fr 1fr;gap:7px}
.animBtn{border:1px solid rgba(255,255,255,.14);background:#09214d;color:#fff;border-radius:10px;padding:8px 7px;text-align:left;cursor:pointer;font-size:12px}
.animBtn.active{background:#1d4ed8;border-color:#60a5fa}
.btn{width:100%;border:0;background:var(--green);color:#fff;border-radius:10px;padding:12px;font-weight:700;cursor:pointer;margin-top:8px}.btn:disabled{opacity:.55;cursor:not-allowed}
.status{font-size:13px;min-height:18px;margin-top:12px}.note{font-size:12px;color:var(--muted);line-height:1.45;margin-top:10px}
.preview{padding:14px}.previewBox{height:500px;border:1px solid var(--line);border-radius:18px;padding:12px;background:#0a1734;display:flex;align-items:center;justify-content:center;overflow:hidden}
.stage{position:relative;width:100%;height:100%;border-radius:14px;display:flex;align-items:center;justify-content:center;overflow:hidden}
.placeholder{font-size:22px;font-weight:700}
.sizeBox{position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);display:flex;align-items:center;justify-content:center;transition:none!important}
.animBox{width:100%;height:100%;display:flex;align-items:center;justify-content:center;transform-origin:center center;will-change:transform,opacity;transition:none!important}
#img{display:block;width:100%;height:100%;object-fit:contain;user-select:none;pointer-events:none}
@media(max-width:860px){.wrap{grid-template-columns:1fr}.previewBox{height:430px}.animList{height:300px}}

/* 53 animations */
@keyframes spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}@keyframes spinReverse{from{transform:rotate(0)}to{transform:rotate(-360deg)}}
@keyframes bounce{0%,100%{transform:translateY(0)}25%{transform:translateY(-110px)}50%{transform:translateY(0)}75%{transform:translateY(-55px)}}@keyframes bounceSoft{0%,100%{transform:translateY(0)}50%{transform:translateY(-50px)}}
@keyframes pulse{0%,100%{transform:scale(1)}50%{transform:scale(1.2)}}@keyframes pulseSoft{0%,100%{transform:scale(1)}50%{transform:scale(1.1)}}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-42px)}}@keyframes floatX{0%,100%{transform:translateX(0)}50%{transform:translateX(42px)}}
@keyframes shake{0%,100%{transform:translateX(0)}20%{transform:translateX(-18px)}40%{transform:translateX(18px)}60%{transform:translateX(-12px)}80%{transform:translateX(12px)}}@keyframes shakeSoft{0%,100%{transform:translateX(0)}20%{transform:translateX(-8px)}40%{transform:translateX(8px)}60%{transform:translateX(-6px)}80%{transform:translateX(6px)}}
@keyframes swing{0%,100%{transform:rotate(0)}25%{transform:rotate(12deg)}75%{transform:rotate(-12deg)}}@keyframes swingSoft{0%,100%{transform:rotate(0)}25%{transform:rotate(6deg)}75%{transform:rotate(-6deg)}}
@keyframes wobble{0%,100%{transform:translateX(0) rotate(0)}15%{transform:translateX(-18px) rotate(-5deg)}30%{transform:translateX(14px) rotate(4deg)}45%{transform:translateX(-12px) rotate(-3deg)}60%{transform:translateX(10px) rotate(2deg)}75%{transform:translateX(-6px) rotate(-1deg)}}@keyframes wobbleX{0%,100%{transform:translateX(0)}20%{transform:translateX(-28px)}40%{transform:translateX(22px)}60%{transform:translateX(-16px)}80%{transform:translateX(10px)}}
@keyframes flash{0%,100%{opacity:1}25%{opacity:.2}50%{opacity:1}75%{opacity:.2}}@keyframes blink{0%,45%,100%{opacity:1}50%,95%{opacity:0}}@keyframes fadeInOut{0%,100%{opacity:1}50%{opacity:.35}}
@keyframes zoomInOut{0%,100%{transform:scale(1)}50%{transform:scale(1.3)}}@keyframes zoomIn{0%{transform:scale(.7)}100%{transform:scale(1)}}@keyframes zoomOut{0%{transform:scale(1.3)}100%{transform:scale(1)}}
@keyframes slideUpDown{0%,100%{transform:translateY(55px)}50%{transform:translateY(-55px)}}@keyframes slideLeftRight{0%,100%{transform:translateX(-80px)}50%{transform:translateX(80px)}}
@keyframes roll{0%{transform:translateX(-100px) rotate(0)}100%{transform:translateX(100px) rotate(360deg)}}@keyframes rollReverse{0%{transform:translateX(100px) rotate(0)}100%{transform:translateX(-100px) rotate(-360deg)}}
@keyframes bob{0%,100%{transform:translateY(0)}25%{transform:translateY(-18px)}50%{transform:translateY(0)}75%{transform:translateY(-8px)}}@keyframes hop{0%,100%{transform:translateY(0)}50%{transform:translateY(-130px)}}@keyframes pop{0%{transform:scale(.4)}60%{transform:scale(1.2)}100%{transform:scale(1)}}
@keyframes breathe{0%,100%{transform:scale(1);opacity:1}50%{transform:scale(1.06);opacity:.92}}@keyframes rubberBand{0%,100%{transform:scale(1,1)}30%{transform:scale(1.25,.75)}40%{transform:scale(.75,1.25)}55%{transform:scale(1.15,.85)}75%{transform:scale(.95,1.05)}}
@keyframes jello{0%,100%{transform:none}22%{transform:skewX(-12deg) skewY(-6deg)}33%{transform:skewX(8deg) skewY(4deg)}44%{transform:skewX(-5deg) skewY(-3deg)}55%{transform:skewX(3deg) skewY(2deg)}}@keyframes tada{0%,100%{transform:scale(1)}10%,20%{transform:scale(.95) rotate(-3deg)}30%,50%,70%,90%{transform:scale(1.08) rotate(3deg)}40%,60%,80%{transform:scale(1.08) rotate(-3deg)}}@keyframes heartbeat{0%,100%{transform:scale(1)}14%{transform:scale(1.22)}28%{transform:scale(1)}42%{transform:scale(1.28)}70%{transform:scale(1)}}
@keyframes rotateScale{0%,100%{transform:rotate(0) scale(1)}50%{transform:rotate(180deg) scale(1.22)}}@keyframes pendulum{0%,100%{transform:rotate(20deg)}50%{transform:rotate(-20deg)}}@keyframes drift{0%,100%{transform:translate(0,0)}25%{transform:translate(35px,-25px)}50%{transform:translate(70px,5px)}75%{transform:translate(25px,18px)}}@keyframes wave{0%,100%{transform:translate(0,0)}25%{transform:translate(28px,-18px)}50%{transform:translate(58px,0)}75%{transform:translate(28px,18px)}}
@keyframes skewX{0%,100%{transform:skewX(0)}50%{transform:skewX(14deg)}}@keyframes skewY{0%,100%{transform:skewY(0)}50%{transform:skewY(14deg)}}@keyframes flipX{0%,100%{transform:scaleX(1)}50%{transform:scaleX(-1)}}@keyframes flipY{0%,100%{transform:scaleY(1)}50%{transform:scaleY(-1)}}@keyframes growShrink{0%,100%{transform:scale(.8)}50%{transform:scale(1.2)}}
@keyframes liftDrop{0%,100%{transform:translateY(40px)}50%{transform:translateY(-60px)}}@keyframes bounceRotate{0%,100%{transform:translateY(0) rotate(0)}25%{transform:translateY(-80px) rotate(12deg)}50%{transform:translateY(0) rotate(0)}75%{transform:translateY(-40px) rotate(-12deg)}}@keyframes swingZoom{0%,100%{transform:rotate(0) scale(1)}25%{transform:rotate(10deg) scale(1.1)}75%{transform:rotate(-10deg) scale(.92)}}
@keyframes orbit{0%{transform:translate(70px,0) rotate(0)}25%{transform:translate(0,-70px) rotate(90deg)}50%{transform:translate(-70px,0) rotate(180deg)}75%{transform:translate(0,70px) rotate(270deg)}100%{transform:translate(70px,0) rotate(360deg)}}@keyframes figure8{0%{transform:translate(0,0)}12.5%{transform:translate(32px,-22px)}25%{transform:translate(60px,0)}37.5%{transform:translate(32px,22px)}50%{transform:translate(0,0)}62.5%{transform:translate(-32px,-22px)}75%{transform:translate(-60px,0)}87.5%{transform:translate(-32px,22px)}100%{transform:translate(0,0)}}
@keyframes jellyPulse{0%,100%{transform:scale(1,1)}25%{transform:scale(1.16,.9)}50%{transform:scale(.92,1.12)}75%{transform:scale(1.08,.96)}}@keyframes tremor{0%,100%{transform:translate(0,0)}20%{transform:translate(-3px,2px)}40%{transform:translate(3px,-2px)}60%{transform:translate(-2px,-2px)}80%{transform:translate(2px,2px)}}@keyframes spiral{0%{transform:translate(0,0) scale(.8) rotate(0)}25%{transform:translate(26px,-26px) scale(.9) rotate(90deg)}50%{transform:translate(52px,0) scale(1) rotate(180deg)}75%{transform:translate(26px,26px) scale(1.1) rotate(270deg)}100%{transform:translate(0,0) scale(1.2) rotate(360deg)}}
@keyframes floatRotate{0%,100%{transform:translateY(0) rotate(0)}50%{transform:translateY(-35px) rotate(18deg)}}@keyframes bounceX{0%,100%{transform:translateX(0)}25%{transform:translateX(-110px)}50%{transform:translateX(0)}75%{transform:translateX(55px)}}@keyframes snap{0%{transform:scale(.2);opacity:0}65%{transform:scale(1.18);opacity:1}100%{transform:scale(1);opacity:1}}@keyframes fadeZoom{0%,100%{transform:scale(1);opacity:1}50%{transform:scale(1.25);opacity:.4}}
</style>
</head>
<body>
<div class="page">
  <div class="wrap">
    <div class="card side">
      <h2>Fast PNG to Lottie Maker <span class="pill">V3</span><span class="pill" id="count">53 styles</span></h2>
      <p class="sub">Native dropdown বাদ দেওয়া হয়েছে, তাই আর 10টা option limit হবে না। নিচের list থেকে animation select করুন।</p>
      <div class="field"><label>Upload PNG / JPG / WebP</label><input type="file" id="file" accept="image/png,image/jpeg,image/webp"></div>
      <div class="field">
        <label>Animation styles</label>
        <input class="animSearch" id="search" type="text" placeholder="Search animation, e.g. spin, bounce, zoom">
        <div class="animList" id="animList"></div>
      </div>
      <div class="grid2 field">
        <div><label>Speed</label><input type="range" id="speed" min=".4" max="8" step=".1" value="2"><div class="mini"><span id="speedVal">2.0</span>s</div></div>
        <div><label>Size</label><input type="range" id="size" min="20" max="220" step="1" value="100"><div class="mini"><span id="sizeVal">100</span>%</div></div>
      </div>
      <div class="grid2 field">
        <div><label>Width</label><input type="number" id="w" min="16" max="4000" value="800"></div>
        <div><label>Height</label><input type="number" id="h" min="16" max="4000" value="800"></div>
      </div>
      <div class="field"><label>Background</label><input type="color" id="bg" value="#0a1734"></div>
      <div class="field row"><input type="checkbox" id="transparent" checked><label for="transparent">Transparent background</label></div>
      <div class="field"><label>Image Compress Max Size (px)</label><input type="number" id="compress" min="32" max="2048" value="384"></div>
      <button id="download" class="btn" disabled>Download Lottie JSON</button>
      <div class="status" id="status">Ready. Version V3 loaded.</div>
      <div class="note">Selected: <b id="selectedName">Spin</b><br>Spin animation never uses scale/zoom. Size slider only changes box size.</div>
    </div>
    <div class="card preview">
      <h2>Fast Preview</h2>
      <div class="previewBox">
        <div class="stage" id="stage">
          <div class="placeholder" id="placeholder">Upload image first</div>
          <div class="sizeBox" id="sizeBox" style="display:none;width:200px;height:200px">
            <div class="animBox" id="animBox"><img id="img" alt="preview"></div>
          </div>
        </div>
      </div>
      <div class="note">এখানে size box আর animation box আলাদা, তাই spin select করলে zoom animation add হবে না।</div>
    </div>
  </div>
</div>
<script>
(()=> {
const animations=[
['spin','Spin'],['spinReverse','Spin Reverse'],['bounce','Bounce'],['bounceSoft','Bounce Soft'],['pulse','Pulse'],['pulseSoft','Pulse Soft'],['float','Float'],['floatX','Float X'],['shake','Shake'],['shakeSoft','Shake Soft'],['swing','Swing'],['swingSoft','Swing Soft'],['wobble','Wobble'],['wobbleX','Wobble X'],['flash','Flash'],['blink','Blink'],['fadeInOut','Fade In Out'],['zoomInOut','Zoom In Out'],['zoomIn','Zoom In'],['zoomOut','Zoom Out'],['slideUpDown','Slide Up Down'],['slideLeftRight','Slide Left Right'],['roll','Roll'],['rollReverse','Roll Reverse'],['bob','Bob'],['hop','Hop'],['pop','Pop'],['breathe','Breathe'],['rubberBand','Rubber Band'],['jello','Jello'],['tada','Tada'],['heartbeat','Heartbeat'],['rotateScale','Rotate Scale'],['pendulum','Pendulum'],['drift','Drift'],['wave','Wave'],['skewX','Skew X'],['skewY','Skew Y'],['flipX','Flip X'],['flipY','Flip Y'],['growShrink','Grow Shrink'],['liftDrop','Lift Drop'],['bounceRotate','Bounce Rotate'],['swingZoom','Swing Zoom'],['orbit','Orbit'],['figure8','Figure 8'],['jellyPulse','Jelly Pulse'],['tremor','Tremor'],['spiral','Spiral'],['floatRotate','Float Rotate'],['bounceX','Bounce X'],['snap','Snap'],['fadeZoom','Fade Zoom']
];
const $=id=>document.getElementById(id);
const el={file:$('file'),list:$('animList'),search:$('search'),speed:$('speed'),size:$('size'),w:$('w'),h:$('h'),bg:$('bg'),transparent:$('transparent'),compress:$('compress'),download:$('download'),status:$('status'),stage:$('stage'),placeholder:$('placeholder'),sizeBox:$('sizeBox'),animBox:$('animBox'),img:$('img'),speedVal:$('speedVal'),sizeVal:$('sizeVal'),selectedName:$('selectedName'),count:$('count')};
let state={anim:'spin',animName:'Spin',dataUrl:'',iw:0,ih:0,pw:0,ph:0};
el.count.textContent=animations.length+' styles';

function renderList(){
  const q=el.search.value.trim().toLowerCase();
  el.list.innerHTML='';
  animations.filter(a=>!q||a[1].toLowerCase().includes(q)||a[0].toLowerCase().includes(q)).forEach(([key,name])=>{
    const b=document.createElement('button');b.type='button';b.className='animBtn'+(key===state.anim?' active':'');b.textContent=name;
    b.onclick=()=>{state.anim=key;state.animName=name;el.selectedName.textContent=name;renderList();updatePreview();}
    el.list.appendChild(b);
  });
}
function status(t){el.status.textContent=t}
function bg(){el.stage.style.background=el.transparent.checked?'transparent':el.bg.value}
function fit(){const max=220,iw=state.pw||state.iw||200,ih=state.ph||state.ih||200,r=Math.min(max/iw,max/ih,1);return {w:Math.max(20,Math.round(iw*r)),h:Math.max(20,Math.round(ih*r))}}
const timing={spin:'linear',spinReverse:'linear',roll:'linear',rollReverse:'linear',orbit:'linear',figure8:'linear',wave:'linear',tremor:'linear',spiral:'linear',zoomIn:'ease-out',zoomOut:'ease-in',snap:'ease-out'};
function updatePreview(){
  el.speedVal.textContent=Number(el.speed.value).toFixed(1);el.sizeVal.textContent=el.size.value;bg();
  if(!state.dataUrl){el.placeholder.style.display='block';el.sizeBox.style.display='none';el.download.disabled=true;return}
  el.placeholder.style.display='none';el.sizeBox.style.display='flex';el.download.disabled=false;el.img.src=state.dataUrl;
  const f=fit(),s=Number(el.size.value)/100;
  el.sizeBox.style.width=Math.round(f.w*s)+'px';el.sizeBox.style.height=Math.round(f.h*s)+'px';
  el.animBox.style.animation='none';el.animBox.style.transform='none';void el.animBox.offsetWidth;
  el.animBox.style.animation=`${state.anim} ${Math.max(.1,Number(el.speed.value))}s infinite ${timing[state.anim]||'ease-in-out'}`;
}
async function resizeDataUrl(dataUrl,maxDim){
  return new Promise((res,rej)=>{const im=new Image();im.onload=()=>{let w=im.naturalWidth,h=im.naturalHeight,ow=w,oh=h;if(maxDim>0){const r=Math.min(1,maxDim/Math.max(w,h));w=Math.max(1,Math.round(w*r));h=Math.max(1,Math.round(h*r));}const c=document.createElement('canvas');c.width=w;c.height=h;const x=c.getContext('2d');x.clearRect(0,0,w,h);x.drawImage(im,0,0,w,h);res({dataUrl:c.toDataURL('image/png'),ow,oh,w,h})};im.onerror=rej;im.src=dataUrl})}
el.file.onchange=e=>{const f=e.target.files&&e.target.files[0];if(!f)return;status('Loading image...');const r=new FileReader();r.onload=async()=>{try{const d=await resizeDataUrl(r.result,parseInt(el.compress.value||'384',10));state.dataUrl=d.dataUrl;state.iw=d.ow;state.ih=d.oh;state.pw=d.w;state.ph=d.h;updatePreview();status(`Image ready (${d.w}x${d.h})`)}catch(e){console.error(e);status('Image process failed')}};r.readAsDataURL(f)};
[el.search,el.speed,el.size,el.w,el.h,el.bg,el.transparent,el.compress].forEach(x=>{x.oninput=()=>{if(x===el.search)renderList();else updatePreview()}});

function ease1(){return {i:{x:[.667],y:[1]},o:{x:[.333],y:[0]}}}function ease2(n=3){return {i:{x:Array(n).fill(.667),y:Array(n).fill(1)},o:{x:Array(n).fill(.333),y:Array(n).fill(0)}}}
function k1(v,T){let o=[],L=v.length-1,S=T/L;for(let i=0;i<v.length;i++){let t=Math.round(i*S);if(i<L)o.push(Object.assign({t,s:[v[i]],e:[v[i+1]]},ease1()));else o.push({t,s:[v[i]]})}return o}
function k2(v,T){let o=[],L=v.length-1,S=T/L;for(let i=0;i<v.length;i++){let t=Math.round(i*S),c=[v[i][0],v[i][1],0];if(i<L)o.push(Object.assign({t,s:c,e:[v[i+1][0],v[i+1][1],0]},ease2(3)));else o.push({t,s:c})}return o}
function ks(v,T){let o=[],L=v.length-1,S=T/L;for(let i=0;i<v.length;i++){let t=Math.round(i*S),c=[v[i][0],v[i][1],100];if(i<L)o.push(Object.assign({t,s:c,e:[v[i+1][0],v[i+1][1],100]},ease2(3)));else o.push({t,s:c})}return o}
function motion(name,w,h){
  const T=Math.max(24,Math.round(Number(el.speed.value||2)*60)),cx=w/2,cy=h/2,dx=Math.min(w,h)*.10,dy=Math.min(w,h)*.12;
  const m={o:{a:0,k:100},r:{a:0,k:0},p:{a:0,k:[cx,cy,0]},s:{a:0,k:[100,100,100]}},P=v=>m.p={a:1,k:k2(v,T)},R=v=>m.r={a:1,k:k1(v,T)},O=v=>m.o={a:1,k:k1(v,T)},S=v=>m.s={a:1,k:ks(v,T)};
  switch(name){
    case'spin':R([0,360]);break;case'spinReverse':R([0,-360]);break;case'bounce':P([[cx,cy],[cx,cy-dy*2],[cx,cy],[cx,cy-dy],[cx,cy]]);break;case'bounceSoft':P([[cx,cy],[cx,cy-dy],[cx,cy]]);break;case'pulse':S([[100,100],[120,120],[100,100]]);break;case'pulseSoft':S([[100,100],[110,110],[100,100]]);break;case'float':P([[cx,cy],[cx,cy-dy],[cx,cy]]);break;case'floatX':P([[cx,cy],[cx+dx,cy],[cx,cy]]);break;case'shake':P([[cx,cy],[cx-18,cy],[cx+18,cy],[cx-12,cy],[cx+12,cy],[cx,cy]]);break;case'shakeSoft':P([[cx,cy],[cx-8,cy],[cx+8,cy],[cx-6,cy],[cx+6,cy],[cx,cy]]);break;case'swing':R([0,12,0,-12,0]);break;case'swingSoft':R([0,6,0,-6,0]);break;case'wobble':P([[cx,cy],[cx-18,cy],[cx+14,cy],[cx-12,cy],[cx+10,cy],[cx,cy]]);R([0,-5,4,-3,2,0]);break;case'wobbleX':P([[cx,cy],[cx-28,cy],[cx+22,cy],[cx-16,cy],[cx+10,cy],[cx,cy]]);break;case'flash':O([100,20,100,20,100]);break;case'blink':O([100,0,100]);break;case'fadeInOut':O([100,35,100]);break;case'zoomInOut':S([[100,100],[130,130],[100,100]]);break;case'zoomIn':S([[70,70],[100,100]]);break;case'zoomOut':S([[130,130],[100,100]]);break;case'slideUpDown':P([[cx,cy+dy],[cx,cy-dy],[cx,cy+dy]]);break;case'slideLeftRight':P([[cx-dx*2,cy],[cx+dx*2,cy],[cx-dx*2,cy]]);break;case'roll':P([[cx-dx*2,cy],[cx+dx*2,cy]]);R([0,360]);break;case'rollReverse':P([[cx+dx*2,cy],[cx-dx*2,cy]]);R([0,-360]);break;case'bob':P([[cx,cy],[cx,cy-18],[cx,cy],[cx,cy-8],[cx,cy]]);break;case'hop':P([[cx,cy],[cx,cy-dy*2.4],[cx,cy]]);break;case'pop':S([[40,40],[120,120],[100,100]]);break;case'breathe':S([[100,100],[106,106],[100,100]]);O([100,92,100]);break;case'rubberBand':S([[100,100],[125,75],[75,125],[115,85],[100,100]]);break;case'jello':R([0,-8,6,-4,3,0]);S([[100,100],[108,96],[96,104],[104,98],[100,100]]);break;case'tada':R([0,-3,3,-3,3,0]);S([[100,100],[95,95],[108,108],[108,108],[108,108],[100,100]]);break;case'heartbeat':S([[100,100],[122,122],[100,100],[128,128],[100,100]]);break;case'rotateScale':R([0,180,360]);S([[100,100],[122,122],[100,100]]);break;case'pendulum':R([20,-20,20]);break;case'drift':P([[cx,cy],[cx+35,cy-25],[cx+70,cy+5],[cx+25,cy+18],[cx,cy]]);break;case'wave':P([[cx,cy],[cx+28,cy-18],[cx+58,cy],[cx+28,cy+18],[cx,cy]]);break;case'skewX':S([[100,100],[120,100],[100,100]]);break;case'skewY':S([[100,100],[100,120],[100,100]]);break;case'flipX':S([[100,100],[-100,100],[100,100]]);break;case'flipY':S([[100,100],[100,-100],[100,100]]);break;case'growShrink':S([[80,80],[120,120],[80,80]]);break;case'liftDrop':P([[cx,cy+40],[cx,cy-60],[cx,cy+40]]);break;case'bounceRotate':P([[cx,cy],[cx,cy-80],[cx,cy],[cx,cy-40],[cx,cy]]);R([0,12,0,-12,0]);break;case'swingZoom':R([0,10,0,-10,0]);S([[100,100],[110,110],[100,100],[92,92],[100,100]]);break;case'orbit':P([[cx+70,cy],[cx,cy-70],[cx-70,cy],[cx,cy+70],[cx+70,cy]]);R([0,90,180,270,360]);break;case'figure8':P([[cx,cy],[cx+32,cy-22],[cx+60,cy],[cx+32,cy+22],[cx,cy],[cx-32,cy-22],[cx-60,cy],[cx-32,cy+22],[cx,cy]]);break;case'jellyPulse':S([[100,100],[116,90],[92,112],[108,96],[100,100]]);break;case'tremor':P([[cx,cy],[cx-3,cy+2],[cx+3,cy-2],[cx-2,cy-2],[cx+2,cy+2],[cx,cy]]);break;case'spiral':P([[cx,cy],[cx+26,cy-26],[cx+52,cy],[cx+26,cy+26],[cx,cy]]);R([0,90,180,270,360]);S([[80,80],[90,90],[100,100],[110,110],[120,120]]);break;case'floatRotate':P([[cx,cy],[cx,cy-35],[cx,cy]]);R([0,18,0]);break;case'bounceX':P([[cx,cy],[cx-dx*2.2,cy],[cx,cy],[cx+dx,cy],[cx,cy]]);break;case'snap':S([[20,20],[118,118],[100,100]]);O([0,100,100]);break;case'fadeZoom':S([[100,100],[125,125],[100,100]]);O([100,40,100]);break;default:R([0,360])
  }
  return {T,m}
}
function build(){
 if(!state.dataUrl)throw Error('No image selected');
 const w=Math.max(16,parseInt(el.w.value||800,10)),h=Math.max(16,parseInt(el.h.value||800,10)),iw=state.pw||state.iw||200,ih=state.ph||state.ih||200,scale=Math.max(.1,Number(el.size.value||100)/100),mo=motion(state.anim,w,h),m=mo.m,T=mo.T;
 if(m.s.a===0)m.s.k=[m.s.k[0]*scale,m.s.k[1]*scale,100];else m.s.k=m.s.k.map(k=>k.e?{...k,s:[k.s[0]*scale,k.s[1]*scale,100],e:[k.e[0]*scale,k.e[1]*scale,100]}:{...k,s:[k.s[0]*scale,k.s[1]*scale,100]});
 let layers=[];
 if(!el.transparent.checked){const c=el.bg.value,r=parseInt(c.slice(1,3),16)/255,g=parseInt(c.slice(3,5),16)/255,b=parseInt(c.slice(5,7),16)/255;layers.push({ddd:0,ind:1,ty:1,nm:'Background',sr:1,ks:{o:{a:0,k:100},r:{a:0,k:0},p:{a:0,k:[w/2,h/2,0]},a:{a:0,k:[0,0,0]},s:{a:0,k:[100,100,100]}},shapes:[{ty:'rc',d:1,s:{a:0,k:[w,h]},p:{a:0,k:[0,0]},r:{a:0,k:0},nm:'Rect'},{ty:'fl',c:{a:0,k:[r,g,b,1]},o:{a:0,k:100},r:1,nm:'Fill'},{ty:'tr',p:{a:0,k:[0,0]},a:{a:0,k:[0,0]},s:{a:0,k:[100,100]},r:{a:0,k:0},o:{a:0,k:100},sk:{a:0,k:0},sa:{a:0,k:0}}],ip:0,op:T,st:0,bm:0})}
 layers.push({ddd:0,ind:layers.length+1,ty:2,nm:'Image Layer',refId:'image_0',sr:1,ks:{o:m.o,r:m.r,p:m.p,a:{a:0,k:[iw/2,ih/2,0]},s:m.s},ip:0,op:T,st:0,bm:0});
 return {v:'5.7.15',fr:60,ip:0,op:T,w,h,nm:'PNG to Lottie Export V3',ddd:0,assets:[{id:'image_0',w:iw,h:ih,u:'',p:state.dataUrl,e:1}],layers,meta:{generator:'LottieMaker-V3-53',animation:state.anim,animationName:state.animName,sizePercent:Number(el.size.value),speedSeconds:Number(el.speed.value)}}
}
el.download.onclick=()=>{try{const data=JSON.stringify(build(),null,2),blob=new Blob([data],{type:'application/json'}),url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download='lottie_'+state.anim+'.json';document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);status('Downloaded lottie_'+state.anim+'.json')}catch(e){status('Download failed: '+e.message)}};
renderList();updatePreview();
})();
</script>
</body>
</html>
HTML

declare -A ROOTS
ROOTS["/var/www/html"]=1

# Add Apache DocumentRoot paths
if [ -d /etc/apache2 ]; then
  while read -r root; do
    [ -n "$root" ] || continue
    root="${root%/}"
    # Skip variables such as APACHE_LOG_DIR
    case "$root" in *'$'* ) continue ;; esac
    ROOTS["$root"]=1
  done < <(grep -RhoE '^[[:space:]]*DocumentRoot[[:space:]]+[^ #]+' /etc/apache2/sites-enabled /etc/apache2/sites-available 2>/dev/null | awk '{print $2}' | tr -d '"' | sort -u || true)

  # Add Apache Alias /lottie target paths
  while read -r alias_path; do
    [ -n "$alias_path" ] || continue
    alias_path="${alias_path%/}"
    case "$alias_path" in *'$'* ) continue ;; esac
    mkdir -p "$alias_path"
    if [ -f "$alias_path/index.html" ]; then
      cp -a "$alias_path/index.html" "$alias_path/index.html.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    cp "$TMP_HTML" "$alias_path/index.html"
    chmod 644 "$alias_path/index.html"
    echo "Installed alias path: $alias_path/index.html"
  done < <(grep -RhoE '^[[:space:]]*Alias[[:space:]]+/lottie/?[[:space:]]+[^ #]+' /etc/apache2 2>/dev/null | awk '{print $3}' | tr -d '"' | sort -u || true)
fi

for root in "${!ROOTS[@]}"; do
  [ -n "$root" ] || continue
  mkdir -p "$root/lottie" "$root/lottie-v3"
  if [ -f "$root/lottie/index.html" ]; then
    cp -a "$root/lottie/index.html" "$root/lottie/index.html.backup.$(date +%Y%m%d_%H%M%S)"
  fi
  cp "$TMP_HTML" "$root/lottie/index.html"
  cp "$TMP_HTML" "$root/lottie-v3/index.html"
  chmod 755 "$root/lottie" "$root/lottie-v3"
  chmod 644 "$root/lottie/index.html" "$root/lottie-v3/index.html"
  echo "Installed: $root/lottie/index.html"
  echo "Installed: $root/lottie-v3/index.html"
done

rm -f "$TMP_HTML"

echo ""
echo "Done. Services untouched."
echo "Try these:"
echo "  http://YOUR_SERVER_IP/lottie/?v=v3-53"
echo "  http://YOUR_SERVER_IP/lottie-v3/?v=v3-53"
echo ""
echo "Server check:"
echo "  curl -s http://127.0.0.1/lottie/?v=v3-53 | grep VERSION-LottieMaker-V3-53"
echo "  curl -s http://127.0.0.1/lottie-v3/?v=v3-53 | grep VERSION-LottieMaker-V3-53"
