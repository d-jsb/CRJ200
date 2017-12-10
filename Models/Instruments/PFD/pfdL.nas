# CRJ200 PFD by D-ECHO
#     based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)


var PFD_pfd = nil;
var page = "pfd";
setprop("instrumentation/pfd[0]/page", "pfd");

setprop("/test", 1);
var DC=0.01744;
var FT2M=0.3048;

var canvas_PFD_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {'font-mapper': font_mapper});

		var svg_keys = me.getKeys();
		 
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var svg_keys = me.getKeys();
			foreach (var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var clip_el = canvas_group.getElementById(key ~ "_clip");
			if (clip_el != nil) {
				clip_el.setVisible(0);
				var tran_rect = clip_el.getTransformedBounds();
				var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
				tran_rect[1], # 0 ys
				tran_rect[2], # 1 xe
				tran_rect[3], # 2 ye
				tran_rect[0]); #3 xs
				#   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
				me[key].set("clip", clip_rect);
				me[key].set("clip-frame", canvas.Element.PARENT);
			}
			}
		}
		
		me.h_trans = me["horizon"].createTransform();
		me.h_rot = me["horizon"].createTransform();

		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		#PFD is powered by the DC 1 Bus
		if (getprop("/systems/DC/outputs/eicas-disp")>22) {
			page = getprop("instrumentation/pfd[0]/page");
			if (page == "pfd") {
				PFD_pfd.page.show();
			}
		} else {
			PFD_pfd.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
};

var canvas_PFD_pfd = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_PFD_pfd , canvas_PFD_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["horizon","rollpointer","rollpointer2","asi.tape","vmo.tape","lowspeed.tape","predict.up","predict.down","iasref.text","iasref.bug","compass","vsi.needle","vsi.text","qnh.text","halfbank","alt.tape","alt.1000","preselected.meter","ind.meter","metricalt","radioalt.text","radioalt.tape","radioalt.number","radioalt","dh.text","dh.flag"];
	},
	update: func() {
		
		#AI		
		var pitch = getprop("instrumentation/pfd[0]/pitch") or 0;
		var roll =  getprop("orientation/roll-deg") or 0;
		var x=math.sin(-3.14/180*roll)*pitch*10.6;
		var y=math.cos(-3.14/180*roll)*pitch*10.6;
		
		me.h_trans.setTranslation(0,pitch);
		me.h_rot.setRotation(-roll*DC,me["horizon"].getCenter());
		
		me["rollpointer"].setRotation(roll*(-DC));
		me["rollpointer2"].setTranslation(math.round(getprop("/instrumentation/slip-skid-ball/indicated-slip-skid") or 0)*5, 0);
		
		#ASI
		var asi=getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") or 0;
		me["asi.tape"].setTranslation(0,asi*6.55);
		var vmo=getprop("/instrumentation/pfd[0]/vmo") or 0;
		me["vmo.tape"].setTranslation(0,vmo*(-6.55));
		if(getprop("/gear/gear[1]/wow")==0){
			me["lowspeed.tape"].show();
			me["lowspeed.tape"].setTranslation(0,-120*6.55);
		}else{
			me["lowspeed.tape"].hide();
		}
		var predict=getprop("/instrumentation/pfd[0]/asi-predict-diff-damped") or 0;
		if(predict>0){
			me["predict.up"].show();
			if(predict<39){
				me["predict.up"].setTranslation(0,-predict*6.55);
			}else{
				me["predict.up"].setTranslation(0,-39*6.55);
			}
			me["predict.down"].hide();
		}else if(predict<0){
			me["predict.up"].hide();
			me["predict.down"].show();
			if(predict>-39){
				me["predict.down"].setTranslation(0,-predict*6.55);
			}else{
				me["predict.down"].setTranslation(0,39*6.55);
			}
		}else{
			me["predict.up"].hide();
			me["predict.down"].hide();
		}
		me["iasref.text"].setText(sprintf("%d", getprop("/controls/autoflight/speed-select") or 0));
		var ias_ref_diff=getprop("/instrumentation/pfd[0]/ias-ref-diff") or 0;
		if(ias_ref_diff>-40 and ias_ref_diff<40){
			me["iasref.bug"].setTranslation(0,-ias_ref_diff*6.55);
		}else if(ias_ref_diff>40){
			me["iasref.bug"].setTranslation(0,-40*6.55);
		}else if(ias_ref_diff<-40){
			me["iasref.bug"].setTranslation(0,40*6.55);
		}
		
		
		#Compass
		var mgh=getprop("/orientation/heading-deg") or 0;
		me["compass"].setRotation(mgh*(-DC));
		
		#VSI
		var vsi=getprop("/instrumentation/pfd[0]/vsi") or 0;
		me["vsi.needle"].setRotation(vsi*DC);
		var vsi_value=getprop("/instrumentation/vertical-speed-indicator/indicated-speed-fpm") or 0;
		if(vsi<1000 and vsi>-1000){
			me["vsi.text"].setText(sprintf("%.1f", vsi_value/1000));
		}else{
			me["vsi.text"].setText(sprintf("%2d", vsi_value/1000));
		}
		
		#Altimeter
		me["alt.tape"].setTranslation(0,math.mod((getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0),1000)*1.22);
		me["alt.1000"].setText(sprintf("%2d", math.floor((getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0)/1000)));
		me["qnh.text"].setText(sprintf("%d", getprop("/instrumentation/altimeter/setting-hpa") or 0));
		var metric=getprop("/instrumentation/use-metric-altitude") or 0;
		if(metric==1){
			me["metricalt"].show();
			me["preselected.meter"].setText(sprintf("%5d", (getprop("/it-autoflight/input/alt") or 0)*FT2M));
			me["ind.meter"].setText(sprintf("%5d", (getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0)*FT2M));
		}else{
			me["metricalt"].hide();
		}
		
		#Radio Altimeter
		var radioalt=getprop("/position/gear-agl-ft") or 0;
		var radioaltbar=getprop("/instrumentation/pfd[0]/radio-altitude-ft") or 0;
		var dh=getprop("/instrumentation/adc/reference/dh") or 0;
		if(radioalt<2500){
			me["radioalt"].show();
			if(radioalt<1225){
				me["radioalt.tape"].show();
				me["radioalt.tape"].setTranslation(0,radioaltbar*0.934);
			}else{
				me["radioalt.tape"].hide();
			}
			me["radioalt.number"].setText(sprintf("%4d",radioalt));
			if(radioalt<dh){
				me["radioalt.text"].setColor(1,1,0);
				me["dh.flag"].show();
			}else{
				me["radioalt.text"].setColor(0,1,0);
				me["dh.flag"].hide();
			}
		}else{
			me["radioalt"].hide();
		}
		#Decision Height
		me["dh.text"].setText(sprintf("%3d", dh));
		
		
		#Autopilot
		
		if((getprop("/controls/autoflight/half-bank") or 0)==1){
			me["halfbank"].show();
		}else{
			me["halfbank"].hide();
		}
		
		settimer(func me.update(), 0.02);
		
	},
};

setlistener("sim/signals/fdm-initialized", func {
	PFD_display = canvas.new({
		"name": "EICAS",
		"size": [1024, 1280],
		"view": [1024, 1280],
		"mipmapping": 1
	});
	PFD_display.addPlacement({"node": "PFDScreenL"});
	
	var groupPfd = PFD_display.createGroup();

	PFD_pfd = canvas_PFD_pfd.new(groupPfd, "Aircraft/CRJ200/Models/Instruments/PFD/PFD.svg");



	PFD_pfd.update();
	
	canvas_PFD_base.update();
});

var showPFDL = func {
	var dlg = canvas.Window.new([512, 640], "dialog").set("resize", 1);
	dlg.setCanvas(PFD_display);
}
	
