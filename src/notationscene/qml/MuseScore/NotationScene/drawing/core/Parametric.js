// SPDX-License-Identifier: GPL-3.0-only
// Native drawing primitives. Independent implementation; no external editor code.
function clone(v){return JSON.parse(JSON.stringify(v));}
function clamp(v,a,b){return Math.max(a,Math.min(b,v));}
function sample(stops,t,key,fallback){
    if(!stops||!stops.length)return fallback;
    var a=stops[0],b=a;
    for(var i=1;i<stops.length;i++){b=stops[i];if(t<=b.t)break;a=b;}
    if(t<=a.t)return a[key];if(t>=b.t)return b[key];
    return a[key]+(b[key]-a[key])*(t-a.t)/Math.max(0.00001,b.t-a.t);
}
// Integer arithmetic below stays within JavaScript's exact integer range and
// is mirrored by the native renderer. Cell identities survive layout changes.
function noiseRandom(column,row,seed){
    seed=Math.floor(Math.abs(Number(seed)||1))%10001;
    var n=((column+1)*73856093+(row+8192)*19349663+seed*83492791)%2147483647;
    if(n<0)n+=2147483647;
    n=(n*48271)%2147483647;
    n=Math.floor(n/256)^(n%65536);
    return ((n*48271)%2147483647)/2147483647;
}
function isNoiseGuide(shape){return !!(shape&&shape.wave&&shape.wave.waveform==="noise"&&shape.wave.guideVersion===1);}
function noiseGuide(shape){
    if(isNoiseGuide(shape))return shape.commands;
    var c=shape.commands,w=shape.wave,a=c.length>1?c[c.length-2]:null,b=c.length?c[c.length-1]:null;
    return [["M",a&&a.length===3?a[1]:w.a.x,a&&a.length===3?a[2]:w.a.y],["L",b&&b.length===3?b[1]:w.b.x,b&&b.length===3?b[2]:w.b.y]];
}
function upgradeNoise(shape){
    if(!shape.wave||shape.wave.waveform!=="noise"||isNoiseGuide(shape))return shape;
    var out=Object.assign({},shape,{wave:Object.assign({},shape.wave,{guideVersion:1}),commands:noiseGuide(shape)});
    delete out.paintRanges;delete out.segmentStyles;return out;
}
function guideTrace(commands){
    var trace=[],last=null,total=0;
    function push(x,y){var p={x:x,y:y};if(trace.length)total+=Math.hypot(x-trace[trace.length-1].x,y-trace[trace.length-1].y);p.distance=total;trace.push(p);}
    commands.forEach(function(c){
        if(c[0]==="M"||c[0]==="L"){push(c[1],c[2]);last={x:c[1],y:c[2]};}
        else if(c[0]==="C"&&last){
            var a=last,steps=24;
            for(var i=1;i<=steps;i++){var t=i/steps,u=1-t;push(u*u*u*a.x+3*u*u*t*c[1]+3*u*t*t*c[3]+t*t*t*c[5],u*u*u*a.y+3*u*u*t*c[2]+3*u*t*t*c[4]+t*t*t*c[6]);}
            last={x:c[5],y:c[6]};
        }
    });return trace;
}
function guidePoint(trace,distance){
    if(trace.length<2)return {x:trace.length?trace[0].x:0,y:trace.length?trace[0].y:0,ux:1,uy:0};
    var lo=1,hi=trace.length-1;
    while(lo<hi){var mid=(lo+hi)>>1;if(trace[mid].distance<distance)lo=mid+1;else hi=mid;}
    var a=trace[lo-1],b=trace[lo],span=b.distance-a.distance,t=span>0?clamp((distance-a.distance)/span,0,1):0,dx=b.x-a.x,dy=b.y-a.y,n=Math.hypot(dx,dy)||1;
    return {x:a.x+dx*t,y:a.y+dy*t,ux:dx/n,uy:dy/n};
}
function noiseCommands(w,diameter,guide){
    var trace=guideTrace(guide||[["M",w.a.x,w.a.y],["L",w.b.x,w.b.y]]),length=trace.length?trace[trace.length-1].distance:0,result=[];
    if(length<0.001){var origin=guidePoint(trace,0);return [["M",origin.x,origin.y],["M",origin.x,origin.y]];}
    var density=clamp(w.density===undefined?25:w.density,1,100);
    diameter=Math.max(0.001,diameter||1);
    function point(x,y){var p=guidePoint(trace,x);return {x:p.x-p.uy*y,y:p.y+p.ux*y};}
    function push(op,x,y){var p=point(x,y);result.push([op,p.x,p.y]);}
    if(density>=100){
        // A filled envelope avoids generating millions of overlapping dots.
        var positions=trace.map(function(p){return p.distance;}).concat(w.stops.map(function(s){return length*s.t;})).sort(function(a,b){return a-b;});
        positions=positions.filter(function(p,i){return !i||Math.abs(p-positions[i-1])>0.000001;});
        positions.forEach(function(p,i){push(i?"L":"M",p,sample(w.stops,p/length,"amplitude",20));});
        positions.slice().reverse().forEach(function(p){push("L",p,-sample(w.stops,p/length,"amplitude",20));});
        result.push(["Z"]);
    } else {
        var pitch=Math.max(0.001,diameter*0.75),columns=Math.ceil(length/pitch);
        var columnStep=Math.max(1,Math.ceil(columns/1024)),columnCount=Math.ceil(columns/columnStep);
        for(var column=0;column<columns;column+=columnStep){
            var centre=Math.min(length,(column+0.5)*pitch),t=centre/length;
            var amplitude=clamp(sample(w.stops,t,"amplitude",20),0,1000000);
            var spacing=Math.max(diameter*0.7,sample(w.stops,t,"period",8),0.001);
            var rows=Math.ceil(amplitude/spacing),rowStep=Math.max(1,Math.ceil((2*rows+1)/Math.max(1,Math.floor(8192/columnCount))));
            for(var row=-rows;row<=rows;row+=rowStep){
                if(noiseRandom(column,row,w.seed)>=density/100)continue;
                var x=(column+0.1+0.8*noiseRandom(column,row,(w.seed||1)+1))*pitch;
                var y=rows===0?0:(row+0.8*(noiseRandom(column,row,(w.seed||1)+2)-0.5))*spacing;
                if(x>length||Math.abs(y)>amplitude)continue;
                push("M",x,y);push("L",x+0.001,y);
            }
        }
        if(!result.length){push("M",length/2,0);push("L",length/2+0.001,0);}
    }
    var a=guidePoint(trace,0),b=guidePoint(trace,length);
    result.push(["M",a.x,a.y],["M",b.x,b.y]);
    return result;
}
var noiseRenderCache=[];
function renderNoise(shape){
    if(!isNoiseGuide(shape)||shape.noiseRendered)return shape;
    for(var i=0;i<noiseRenderCache.length;i++){
        var saved=noiseRenderCache[i];
        if(saved.guide===shape.commands&&saved.wave===shape.wave&&saved.width===shape.style.width)
            return Object.assign({},shape,{commands:saved.commands,paintRanges:undefined,noiseRendered:true});
    }
    var commands=noiseCommands(shape.wave,shape.style.width,shape.commands);
    noiseRenderCache.push({guide:shape.commands,wave:shape.wave,width:shape.style.width,commands:commands});
    var weight=noiseRenderCache.reduce(function(n,c){return n+c.commands.length;},0);
    while(noiseRenderCache.length>1&&(noiseRenderCache.length>16||weight>100000))weight-=noiseRenderCache.shift().commands.length;
    return Object.assign({},shape,{commands:commands,paintRanges:undefined,noiseRendered:true});
}
function noiseStyle(w,style){
    if(!w||w.waveform!=="noise")return style;
    var out=Object.assign({},style,{fill:w.density>=100?style.stroke:"none",lineCap:"round",linePattern:"solid"});
    delete out.nib;delete out.fillGradient;
    if(w.density>=100&&style.strokeGradient)out.fillGradient=style.strokeGradient;
    return out;
}
function waveCommands(w,diameter){
    if(w.waveform==="noise")return noiseCommands(w,diameter);
    var dx=w.b.x-w.a.x,dy=w.b.y-w.a.y,length=Math.hypot(dx,dy);
    if(length<0.001)return [["M",w.a.x,w.a.y]];
    var ux=dx/length,uy=dy/length,minPeriod=Math.max(2,Math.min.apply(null,w.stops.map(function(s){return s.period;})));
    var count=Math.max(16,Math.min(4096,Math.ceil(length/minPeriod*24))),phase=(w.phase||0)*Math.PI/180,result=[];
    for(var i=0;i<=count;i++){
        var t=i/count,amp=sample(w.stops,t,"amplitude",20),period=Math.max(2,sample(w.stops,t,"period",40));
        if(i)phase+=2*Math.PI*(length/count)/period;
        var value=w.waveform==="zigzag"?2/Math.PI*Math.asin(Math.sin(phase)):Math.sin(phase);
        var y=amp*value;
        result.push([i?"L":"M",w.a.x+dx*t-uy*y,w.a.y+dy*t+ux*y]);
    }
    result.push(["M",w.a.x,w.a.y],["M",w.b.x,w.b.y]);return result;
}
function create(kind,a,b,style,options){
    options=options||{};
    if(kind==="wave"||kind==="noise"){
        var spacing=kind==="noise"?(options.verticalSpacing===undefined?8:options.verticalSpacing):(options.period||40);
        var w={a:clone(a),b:clone(b),waveform:kind==="noise"?"noise":options.waveform||"sine",phase:0,layoutMode:kind==="noise"?"continue":options.layoutMode||"continue",stops:[{t:0,amplitude:options.amplitude===undefined?20:options.amplitude,period:spacing},{t:0.5,amplitude:options.amplitude===undefined?20:options.amplitude,period:spacing},{t:1,amplitude:options.amplitude===undefined?20:options.amplitude,period:spacing}]};
        if(kind==="noise"){w.guideVersion=1;w.density=options.density===undefined?25:options.density;w.seed=options.seed===undefined?Math.floor(Math.random()*10000)+1:options.seed;}
        return {kind:kind,wave:w,commands:kind==="noise"?[["M",a.x,a.y],["L",b.x,b.y]]:waveCommands(w,style.width),style:clone(style)};
    }
    var x=Math.min(a.x,b.x),y=Math.min(a.y,b.y),width=Math.abs(b.x-a.x),height=Math.abs(b.y-a.y),cx=x+width/2,cy=y+height/2,c=[],sides=clamp(Math.round(options.sides||5),3,24),points=[];
    if(kind==="rounded-rectangle"){
        var r=Math.min(width,height)*clamp(options.roundness===undefined?0.2:options.roundness,0,0.5),k=0.5522847498;
        c=[["M",x+r,y],["L",x+width-r,y],["C",x+width-r+k*r,y,x+width,y+r-k*r,x+width,y+r],["L",x+width,y+height-r],["C",x+width,y+height-r+k*r,x+width-r+k*r,y+height,x+width-r,y+height],["L",x+r,y+height],["C",x+r-k*r,y+height,x,y+height-r+k*r,x,y+height-r],["L",x,y+r],["C",x,y+r-k*r,x+r-k*r,y,x+r,y],["Z"]];
    } else {
        if(kind==="diamond")points=[[cx,y],[x+width,cy],[cx,y+height],[x,cy]];
        else if(kind==="cross")points=[[x+width/3,y],[x+2*width/3,y],[x+2*width/3,y+height/3],[x+width,y+height/3],[x+width,y+2*height/3],[x+2*width/3,y+2*height/3],[x+2*width/3,y+height],[x+width/3,y+height],[x+width/3,y+2*height/3],[x,y+2*height/3],[x,y+height/3],[x+width/3,y+height/3]];
        else for(var i=0,n=kind==="star"?sides*2:sides;i<n;i++){
            var angle=-Math.PI/2+2*Math.PI*i/n,ratio=kind==="star"&&i%2?clamp(options.innerRatio||0.4,0.05,0.95):1;
            points.push([cx+width/2*Math.cos(angle)*ratio,cy+height/2*Math.sin(angle)*ratio]);
        }
        c=points.map(function(p,i){return [i?"L":"M",p[0],p[1]];});c.push(["Z"]);
    }
    return {kind:kind,parametric:{frame:{a:clone(a),b:clone(b)},matrix:[1,0,0,1,0,0],sides:sides,innerRatio:options.innerRatio||0.4,roundness:options.roundness===undefined?0.2:options.roundness},commands:c,style:clone(style)};
}
function rebuild(shape,options){
    var box=shape.commands.reduce(function(b,c){for(var i=1;i<c.length;i+=2){b.x=Math.min(b.x,c[i]);b.y=Math.min(b.y,c[i+1]);b.right=Math.max(b.right,c[i]);b.bottom=Math.max(b.bottom,c[i+1]);}return b;},{x:Infinity,y:Infinity,right:-Infinity,bottom:-Infinity});
    var frame=shape.parametric.frame||{a:{x:box.x,y:box.y},b:{x:box.right,y:box.bottom}},m=shape.parametric.matrix||[1,0,0,1,0,0],made=create(shape.kind,frame.a,frame.b,shape.style,options);
    made.commands=made.commands.map(function(c){var out=c.slice();for(var i=1;i<c.length;i+=2){out[i]=m[0]*c[i]+m[2]*c[i+1]+m[4];out[i+1]=m[1]*c[i]+m[3]*c[i+1]+m[5];}return out;});
    made.parametric.matrix=clone(m);return Object.assign({},shape,{commands:made.commands,parametric:made.parametric});
}
function handles(shape,scale){
    if(!shape)return [];
    if(shape.parametric){
        var box=shape.commands.reduce(function(b,c){for(var i=1;i<c.length;i+=2){b.x=Math.min(b.x,c[i]);b.y=Math.min(b.y,c[i+1]);b.right=Math.max(b.right,c[i]);b.bottom=Math.max(b.bottom,c[i+1]);}return b;},{x:Infinity,y:Infinity,right:-Infinity,bottom:-Infinity});
        var role=shape.kind==="rounded-rectangle"?"corners":"sides",out=[];
        if(["polygon","star","rounded-rectangle"].indexOf(shape.kind)>=0)out.push({role:role,x:box.right+20/scale,y:box.y,color:"#a75aee"});
        if(shape.kind==="star")out.push({role:"inner-radius",x:box.right+20/scale,y:box.bottom,color:"#17bfa1"});return out;
    }
    if(!shape.wave)return [];
    var w=shape.wave,dx=w.b.x-w.a.x,dy=w.b.y-w.a.y,length=Math.hypot(dx,dy)||1,ux=dx/length,uy=dy/length,gap=18/Math.max(0.02,scale),result=[];
    var trace=isNoiseGuide(shape)?guideTrace(shape.commands):null;
    if(trace&&!trace.length)return [];
    w.stops.forEach(function(s,i){
        var p=trace?guidePoint(trace,s.t*trace[trace.length-1].distance):{x:w.a.x+dx*s.t,y:w.a.y+dy*s.t,ux:ux,uy:uy},x=p.x,y=p.y;
        result.push({role:w.waveform==="noise"?"noise-spread":"wave-amplitude",index:i,x:x-p.uy*s.amplitude,y:y+p.ux*s.amplitude,color:"#a75aee"});
        result.push(w.waveform==="noise"?{role:"noise-spacing",index:i,x:x+p.ux*gap+p.uy*s.period,y:y+p.uy*gap-p.ux*s.period,color:"#17bfa1"}:{role:"wave-period",index:i,x:x+ux*s.period/2+uy*gap,y:y+uy*s.period/2-ux*gap,color:"#17bfa1"});
    });return result;
}
function adjust(shape,handle,dx,dy,scale){
    if(shape.parametric){var p=clone(shape.parametric),pixels=dx*(scale||1);if(handle.role==="corners")p.roundness=clamp(p.roundness+pixels/200,0,0.5);else if(handle.role==="inner-radius")p.innerRatio=clamp(p.innerRatio+pixels/200,0.05,0.95);else p.sides=clamp(p.sides+Math.round(pixels/12),3,24);return rebuild(shape,p);}
    var out=Object.assign({},shape,{wave:clone(shape.wave)}),w=out.wave,s=w.stops[handle.index],vx=w.b.x-w.a.x,vy=w.b.y-w.a.y,length=Math.hypot(vx,vy)||1,ux=vx/length,uy=vy/length;
    if(isNoiseGuide(shape)){var trace=guideTrace(shape.commands);if(!trace.length)return shape;var p=guidePoint(trace,s.t*trace[trace.length-1].distance);length=trace[trace.length-1].distance||1;ux=p.ux;uy=p.uy;}
    if(handle.role==="noise-spacing")s.period=Math.max(0.1,s.period+dx*uy-dy*ux);
    else if(handle.role==="wave-period")s.period=Math.max(2,s.period+2*(dx*ux+dy*uy));
    else {s.amplitude=Math.max(0,s.amplitude-dx*uy+dy*ux);if(handle.index>0&&handle.index<w.stops.length-1)s.t=clamp(s.t+(dx*ux+dy*uy)/length,w.stops[handle.index-1].t+0.01,w.stops[handle.index+1].t-0.01);}
    out.commands=isNoiseGuide(shape)?shape.commands:waveCommands(w,out.style.width);return out;
}
function transform(w,m){
    var out=clone(w),map=function(p){return {x:m[0]*p.x+m[2]*p.y+m[4],y:m[1]*p.x+m[3]*p.y+m[5]};},dx=w.b.x-w.a.x,dy=w.b.y-w.a.y,length=Math.hypot(dx,dy)||1;
    out.a=map(w.a);out.b=map(w.b);
    var along=Math.hypot(out.b.x-out.a.x,out.b.y-out.a.y)/length,normal=Math.hypot(m[0]*(-dy/length)+m[2]*(dx/length),m[1]*(-dy/length)+m[3]*(dx/length));
    out.stops.forEach(function(s){s.amplitude*=normal;s.period*=w.waveform==="noise"?normal:along;});return out;
}
