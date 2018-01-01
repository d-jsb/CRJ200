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
		return ["horizon","rollpointer","rollpointer2","asi.tape","vmo.tape","lowspeed.tape","predict.up","predict.down","iasref.text","iasref.bug","compass","vsi.needle","vsi.text","qnh.text","halfbank","alt.tape","alt.1000","preselected.meter","ind.meter","metricalt","radioalt.text","radioalt.tape","radioalt.number","radioalt","dh.text","dh.flag","ADF1.flag","ADF1.needle","ADF2.flag","ADF2.needle","FMS","FMS.text","FMS.crs.text","FMS.dst.text","FMS.name.text","FMS.needle","FMS.deviation","marker","marker.text","marker.box","mda.flag","mda.text","selected_heading","selected_heading2","selected_heading.text","preselected.1000","preselected.100","lat.act","vert.act","ap.flag","vert.arm","lat.arm"];
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
		var speed_selected=getprop("/controls/autoflight/speed-select") or 0;
		me["iasref.text"].setText(sprintf("%d", speed_selected));
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
		var sh=getprop("/controls/autoflight/heading-select") or 0;
		if(sh>mgh){
			var shdiff=mgh-sh;
		}else{
			mgh=mgh-360;
			var shdiff=mgh-sh;
		}
		if(shdiff<138 and shdiff>-138){
			me["selected_heading"].show();
			me["selected_heading"].setRotation(sh*DC);
			me["selected_heading2"].hide();
		}else{
			me["selected_heading"].hide();
			me["selected_heading2"].show();
			me["selected_heading2"].setRotation(sh*DC);
		}
		
		me["selected_heading.text"].setText(sprintf("%3d",sh));
		
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
		var altitude=getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0;
		me["alt.tape"].setTranslation(0,math.mod(altitude,1000)*1.22);
		me["alt.1000"].setText(sprintf("%2d", math.floor(altitude/1000)));
		me["qnh.text"].setText(sprintf("%d", getprop("/instrumentation/altimeter/setting-hpa") or 0));
		var metric=getprop("/instrumentation/use-metric-altitude") or 0;
		var preselected_alt=getprop("/controls/autoflight/altitude-select") or 0;
		if(metric==1){
			me["metricalt"].show();
			me["preselected.meter"].setText(sprintf("%5d", preselected_alt*FT2M));
			me["ind.meter"].setText(sprintf("%5d", (getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0)*FT2M));
		}else{
			me["metricalt"].hide();
		}
		
		#Radio Altimeter
		var radioalt=getprop("/position/gear-agl-ft") or 0;
		var radioaltbar=getprop("/instrumentation/pfd[0]/radio-altitude-ft") or 0;
		var dh=getprop("/instrumentation/adc/reference/dh") or 0;
		var wow1=getprop("/gear/gear[1]/wow") or 0;
		if(radioalt<2500 and wow1==0){
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
		#MDA
		var mda=getprop("/instrumentation/adc/reference/mda") or 0;
		me["mda.text"].setText(sprintf("%4d", mda));
		if(wow1==0 and altitude<mda){
			me["mda.flag"].show();
		}else{
			me["mda.flag"].hide();
		}
		
		#Autopilot
		#AP Flag
		if((getprop("/autopilot/internal/autoflight-engaged") or 0)==1){
			me["ap.flag"].show();
		}else{
			me["ap.flag"].hide();
		}
		#Lateral modes
		var latmode=getprop("/autopilot/annunciators/lat-capture") or "";
		#var navmode=getprop("/controls/autoflight/nav-source") or 99;
		#if(latmode==1){
		#	me["lat.act"].setText("HDG");
		#}else if(latmode==2){
		#	me["lat.act"].setText("LNAV");
		#}else if(latmode==3){
		#	if(navmode==0){
		#		me["lat.act"].setText("LOC1");
		#	}else if(navmode==1){
		#		me["lat.act"].setText("LOC2");
		#	}else{
		#		me["lat.act"].setText("INVLD");
		#	}
		#}
		me["lat.act"].setText(latmode);
		#ALTS annun
		var vertarmed=getprop("/autopilot/annunciators/vert-armed") or 0;
		if(vertarmed==1){
			me["vert.arm"].setText("ALTS");
		}else{
			me["vert.arm"].setText("");
		}
		#LAT armed
		var latarmed=getprop("/autopilot/annunciators/lat-armed") or 0;
		var nav0hasgs=getprop("/instrumentation/nav[0]/has-gs") or 0;
		var nav1hasgs=getprop("/instrumentation/nav[1]/has-gs") or 0;
		if(latarmed=="VOR1" and nav0hasgs){
			me["lat.arm"].setText("LOC1");
		}else if(latarmed=="VOR1" and !nav0hasgs){
			me["lat.arm"].setText("VOR1");
		}else if(latarmed=="VOR2" and nav1hasgs){
			me["lat.arm"].setText("LOC2");
		}else if(latarmed=="VOR2" and !nav1hasgs){
			me["lat.arm"].setText("VOR2");
		}else{
			me["lat.arm"].setText("");
		}
		
		#Vert modes
		var vertmode=getprop("/autopilot/annunciators/vert-capture") or "";
		#if(vertmode==1){
		#	me["vert.act"].setText("ALT");
		#}else if(vertmode==2){
		#	me["vert.act"].setText("V/S");
		#}else if(vertmode==4){
		#	#me["vert.act"].setText(sprint("%3d","IAS "~speed_selected));
		#}
		me["vert.act"].setText(vertmode);
		
		if((getprop("/controls/autoflight/half-bank") or 0)==1){
			me["halfbank"].show();
		}else{
			me["halfbank"].hide();
		}
		
		me["preselected.1000"].setText(sprintf("%2d",math.floor(preselected_alt/1000)));
		me["preselected.100"].setText(sprintf("%03d",math.mod(preselected_alt, 1000)));
		
		#ADF
		#Flags
		var ADF1_inrange=getprop("/instrumentation/adf[0]/in-range") or 0;
		var ADF2_inrange=getprop("/instrumentation/adf[1]/in-range") or 0;
		if(ADF1_inrange){
			me["ADF1.flag"].show();
			me["ADF1.needle"].show();
			me["ADF1.needle"].setRotation((getprop("/instrumentation/adf[0]/indicated-bearing-deg") or 0)*-DC);
		}else{
			me["ADF1.flag"].hide();
			me["ADF1.needle"].hide();
		}
		if(ADF2_inrange){
			me["ADF2.flag"].show();
			me["ADF2.needle"].show();
			me["ADF2.needle"].setRotation((getprop("/instrumentation/adf[1]/indicated-bearing-deg") or 0)*-DC);
		}else{
			me["ADF2.flag"].hide();
			me["ADF2.needle"].hide();
		}
		
		#FMS 1/2, NAV 1/2
		if((getprop("/controls/autoflight/nav-source") or 0)==2){
			me["FMS"].show();
			me["FMS.needle"].show();
			me["FMS.text"].setText("FMS1");
			me["FMS.crs.text"].setText(sprintf("%03d",getprop("autopilot/route-manager/wp[0]/bearing-deg")  or 0));
			me["FMS.dst.text"].setText(sprintf("%3.1f",getprop("autopilot/route-manager/wp[0]/dist") or 0));
			me["FMS.name.text"].setText(getprop("autopilot/route-manager/wp[0]/id") or "");
			me["FMS.needle"].setRotation((getprop("autopilot/route-manager/wp[0]/bearing-deg") or 0)*DC);
			me["FMS.deviation"].setTranslation((getprop("/autopilot/route-manager/deviation-deg") or 0)*32.5,0);
		}else if((getprop("/controls/autoflight/nav-source") or 0)==1){
			me["FMS"].show();
			me["FMS.needle"].show();
			me["FMS.text"].setText("NAV2");
			me["FMS.crs.text"].setText(sprintf("%03d",getprop("instrumentation/nav[1]/radials/selected-deg")  or "XX"));
			me["FMS.dst.text"].setText(sprintf("%3.1f",getprop("instrumentation/nav[1]/distance-nm") or "XX"));
			me["FMS.name.text"].setText(getprop("instrumentation/nav[1]/nav-id") or "");
			me["FMS.needle"].setRotation((getprop("instrumentation/nav[1]/radials/selected-deg") or 0)*DC);
			me["FMS.deviation"].setTranslation((getprop("/instrumentation/nav[1]/heading-needle-deflection-norm") or 0)*130,0);
		}else if((getprop("/controls/autoflight/nav-source") or 0)==0){
			me["FMS"].show();
			me["FMS.needle"].show();
			me["FMS.text"].setText("NAV1");
			me["FMS.crs.text"].setText(sprintf("%03d",getprop("instrumentation/nav[0]/radials/selected-deg")  or "XX"));
			me["FMS.dst.text"].setText(sprintf("%3.1f",getprop("instrumentation/nav[0]/distance-nm") or "XX"));
			me["FMS.name.text"].setText(getprop("instrumentation/nav[0]/nav-id") or "");
			me["FMS.needle"].setRotation((getprop("instrumentation/nav[0]/radials/selected-deg") or 0)*DC);
			me["FMS.deviation"].setTranslation((getprop("/instrumentation/nav[0]/heading-needle-deflection-norm") or 0)*130,0);
		}else{
			me["FMS"].hide();
			me["FMS.needle"].hide();
		}
		
		#Marker beacon
		var om=getprop("/instrumentation/marker-beacon/outer") or 0;
		var mm=getprop("/instrumentation/marker-beacon/middle") or 0;
		var im=getprop("/instrumentation/marker-beacon/inner") or 0;
		if(om==1){
			me["marker"].show();
			me["marker.text"].setText("OM");
			me["marker.box"].setColorFill(0,0,0,0);
			me["marker.text"].setColor(1,1,1);
		}else if(mm==1){
			me["marker"].show();
			me["marker.text"].setText("MM");
			me["marker.box"].setColorFill(0,0,0,0);
			me["marker.text"].setColor(1,1,1);
		}else if(im==1){
			me["marker"].show();
			me["marker.text"].setText("IM");
			me["marker.box"].setColorFill(1,1,1,1);
			me["marker.text"].setColor(0,0,0);
		}else{
			me["marker"].hide();
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
	
