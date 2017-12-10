# CRJ200 EICAS by D-ECHO
#     based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#######################################
# Copyright (c) A3XX Development Team #
#######################################

var EICAS_primary = nil;
var EICAS_status = nil;
var EICAS_electrical = nil;
var EICAS_fuel = nil;
var EICAS_hydraulics = nil;
var EICAS_doors = nil;
var EICAS_fctl = nil;
var EICAS_ecs = nil;
var page = "electrical";
setprop("instrumentation/eicas[1]/page", "electrical");
setprop("/systems/electrical/extra/apu-load", 0);
setprop("/systems/electrical/extra/apu-volts", 0);
setprop("/systems/electrical/extra/apu-hz", 0);
setprop("/systems/pneumatic/bleedapu", 0);
setprop("/engines/engine[0]/oil-psi-actual", 0);
setprop("/engines/engine[1]/oil-psi-actual", 0);
setprop("/environment/temperature-degc", 0);
setprop("/FMGC/internal/gw", 0);
setprop("/controls/flight/spoiler-l1-failed", 0);
setprop("/controls/flight/spoiler-l2-failed", 0);
setprop("/controls/flight/spoiler-l3-failed", 0);
setprop("/controls/flight/spoiler-l4-failed", 0);
setprop("/controls/flight/spoiler-l5-failed", 0);
setprop("/controls/flight/spoiler-r1-failed", 0);
setprop("/controls/flight/spoiler-r2-failed", 0);
setprop("/controls/flight/spoiler-r3-failed", 0);
setprop("/controls/flight/spoiler-r4-failed", 0);
setprop("/controls/flight/spoiler-r5-failed", 0);
setprop("/canvas-test", 1);
setprop("/engines/engine/rpm", 0);
setprop("/engines/engine[1]/rpm", 0);
setprop("/engines/engine/rpm2", 0);
setprop("/engines/engine[1]/rpm2", 0);
setprop("/engines/engine[0]/fuel-flow_pph", 0);
setprop("/engines/engine[1]/fuel-flow_pph", 0);
setprop("/engines/engine[0]/itt-norm", 0);
setprop("/engines/engine[1]/itt-norm", 0);
setprop("/engines/apu/egt-degc", 0);
setprop("/controls/flight/aileron-trim", 0);
setprop("/controls/flight/elevator-trim", 0);
setprop("/controls/flight/rudder-trim", 0);
setprop("/test", 1);

var canvas_EICAS_base = {
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

		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		#EICAS is powered by the DC 1 Bus
		if (getprop("/systems/DC/outputs/eicas-disp")>22) {
			page = getprop("instrumentation/eicas[1]/page");
			if (page == "primary") {
				EICAS_primary.page.show();
				EICAS_status.page.hide();
				EICAS_electrical.page.hide();
				EICAS_fuel.page.hide();
				EICAS_hydraulics.page.hide();
				EICAS_doors.page.hide();
				EICAS_fctl.page.hide();
				EICAS_ecs.page.hide();
			} else if(page=="status") {
				EICAS_primary.page.hide();
				EICAS_status.page.show();
				EICAS_electrical.page.hide();
				EICAS_fuel.page.hide();
				EICAS_hydraulics.page.hide();
				EICAS_doors.page.hide();
				EICAS_fctl.page.hide();
				EICAS_ecs.page.hide();
			} else if(page=="electrical") {
				EICAS_primary.page.hide();
				EICAS_status.page.hide();
				EICAS_electrical.page.show();
				EICAS_fuel.page.hide();
				EICAS_hydraulics.page.hide();
				EICAS_doors.page.hide();
				EICAS_fctl.page.hide();
				EICAS_ecs.page.hide();
			} else if(page=="fuel") {
				EICAS_primary.page.hide();
				EICAS_status.page.hide();
				EICAS_electrical.page.hide();
				EICAS_fuel.page.show();
				EICAS_hydraulics.page.hide();
				EICAS_doors.page.hide();
				EICAS_fctl.page.hide();
				EICAS_ecs.page.hide();
			} else if(page=="hydraulics") {
				EICAS_primary.page.hide();
				EICAS_status.page.hide();
				EICAS_electrical.page.hide();
				EICAS_fuel.page.hide();
				EICAS_hydraulics.page.show();
				EICAS_doors.page.hide();
				EICAS_fctl.page.hide();
				EICAS_ecs.page.hide();
			} else if(page=="doors") {
				EICAS_primary.page.hide();
				EICAS_status.page.hide();
				EICAS_electrical.page.hide();
				EICAS_fuel.page.hide();
				EICAS_hydraulics.page.hide();
				EICAS_doors.page.show();
				EICAS_fctl.page.hide();
				EICAS_ecs.page.hide();
			} else if(page=="fctl") {
				EICAS_primary.page.hide();
				EICAS_status.page.hide();
				EICAS_electrical.page.hide();
				EICAS_fuel.page.hide();
				EICAS_hydraulics.page.hide();
				EICAS_doors.page.hide();
				EICAS_fctl.page.show();
				EICAS_ecs.page.hide();
			} else if(page=="ecs") {
				EICAS_primary.page.hide();
				EICAS_status.page.hide();
				EICAS_electrical.page.hide();
				EICAS_fuel.page.hide();
				EICAS_hydraulics.page.hide();
				EICAS_doors.page.hide();
				EICAS_fctl.page.hide();
				EICAS_ecs.page.show();
			} else {
				EICAS_primary.page.hide();
				EICAS_status.page.hide();
				EICAS_electrical.page.hide();
				EICAS_fuel.page.hide();
				EICAS_hydraulics.page.hide();
				EICAS_doors.page.hide();
				EICAS_fctl.page.hide();
				EICAS_ecs.page.hide();
			}
		} else {
			EICAS_primary.page.hide();
			EICAS_status.page.hide();
			EICAS_electrical.page.hide();
			EICAS_fuel.page.hide();
			EICAS_hydraulics.page.hide();
			EICAS_doors.page.hide();
			EICAS_fctl.page.hide();
			EICAS_ecs.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
};

var canvas_EICAS_primary = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EICAS_primary , canvas_EICAS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["LeftN1","RightN1","LeftN1Needle","RightN1Needle","LeftGearText","LeftGearBox","FrontGearText","FrontGearBox","RightGearText","RightGearBox","FlapsDeg","flaps.bar","FuelQtyLeft","FuelQtyCenter","FuelQtyRight","FuelQtyTotal","FuelFlowLeft","FuelFlowRight","OilPressLeft","OilPressRight","LeftITT","LeftITTNeedle","RightITT","RightITTNeedle","LeftN2","LeftN2Needle","RightN2","RightN2Needle","message1","message2","message3","message4","message5","message6","message7","message8","message9","message10","message11","message12","reverse.left","reverse.right"];
	},
	update: func() {
	
		#N1
		me["LeftN1"].setText(sprintf("%2.1f", getprop("/engines/engine/rpm")));
		me["RightN1"].setText(sprintf("%2.1f", getprop("/engines/engine[1]/rpm")));
		me["LeftN1Needle"].setRotation(getprop("/engines/engine/rpm")*0.0375);
		me["RightN1Needle"].setRotation(getprop("/engines/engine[1]/rpm")*0.0375);
		
		#Engine Reverser
		rev_pos0=getprop("sim/multiplay/generic/float[4]") or 0; #/engines/engine[0]/reverser-pos-norm
		rev_pos1=getprop("sim/multiplay/generic/float[5]") or 0; #/engines/engine[1]/reverser-pos-norm
		if(rev_pos0>0){
			me["reverse.left"].show();
			if(rev_pos0==1){
				me["reverse.left"].setColor(0,1,0);
			}else{
				me["reverse.left"].setColor(1,1,0);
			}
		}else{
			me["reverse.left"].hide();
		}
		if(rev_pos1>0){
			me["reverse.right"].show();
			if(rev_pos1==1){
				me["reverse.right"].setColor(0,1,0);
			}else{
				me["reverse.right"].setColor(1,1,0);
			}
		}else{
			me["reverse.right"].hide();
		}
		
		#Fuel Flow
		var ffL=getprop("/engines/engine[0]/fuel-flow_pph");
		me["FuelFlowLeft"].setText(sprintf("%s", math.round(ffL)));
		var ffR=getprop("/engines/engine[1]/fuel-flow_pph");
		me["FuelFlowRight"].setText(sprintf("%s", math.round(ffR)));
		#Oil temperature: No property available
		#Oil Pressure (property not working!)
		me["OilPressLeft"].setText(sprintf ("%s", getprop("/engines/engine/oil-psi-actual")));
		me["OilPressRight"].setText(sprintf ("%s", getprop("/engines/engine[1]/oil-psi-actual")));
		
		#ITT
		var ITTLc=getprop("/engines/engine/itt-norm")*900;
		var ITTRc=getprop("/engines/engine[1]/itt-norm")*900;
		
		me["LeftITT"].setText(sprintf("%s", math.round(ITTLc)));
		me["RightITT"].setText(sprintf("%s", math.round(ITTRc)));
		me["LeftITTNeedle"].setRotation(ITTLc*0.005);
		me["RightITTNeedle"].setRotation(ITTRc*0.005);
		
		if(ITTLc>=884){
			me["LeftITT"].setColor(1,0,0);
			me["LeftITTNeedle"].setColor(1,0,0);
		}else{
			me["LeftITT"].setColor(0,1,0);
			me["LeftITTNeedle"].setColor(0,1,0);
		}
		if(ITTRc>=884){
			me["RightITT"].setColor(1,0,0);
			me["RightITTNeedle"].setColor(1,0,0);
		}else{
			me["RightITT"].setColor(0,1,0);
			me["RightITTNeedle"].setColor(0,1,0);
		}
		
		#N2
		var N2L=getprop("/engines/engine/rpm2");
		var N2R=getprop("/engines/engine[1]/rpm2");
		me["LeftN2"].setText(sprintf("%2.1f", N2L));
		me["RightN2"].setText(sprintf("%2.1f", N2R));
		me["LeftN2Needle"].setRotation(N2L*0.0375);
		me["RightN2Needle"].setRotation(N2R*0.0375);
		
		if(N2L>99.2){
			me["LeftN2"].setColor(1,0,0);
			me["LeftN2Needle"].setColor(1,0,0);
		}else{
			me["LeftN2"].setColor(0,1,0);
			me["LeftN2Needle"].setColor(0,1,0);
		}
		if(N2R>99.2){
			me["RightN2"].setColor(1,0,0);
			me["RightN2Needle"].setColor(1,0,0);
		}else{
			me["RightN2"].setColor(0,1,0);
			me["RightN2Needle"].setColor(0,1,0);
		}
		
		#GEAR
		if(getprop("/gear/gear[0]/position-norm")==1){
			me["FrontGearText"].setText("DN");
			me["FrontGearText"].setColor(0,1,0);
			me["FrontGearBox"].setColor(0,1,0);
		}else if(getprop("/gear/gear[0]/position-norm")==0){
			me["FrontGearText"].setText("UP");
			me["FrontGearText"].setColor(0.5,1,1);
			me["FrontGearBox"].setColor(0.5,1,1);
		}else{
			me["FrontGearText"].setText("TR");
			me["FrontGearText"].setColor(1,1,0);
			me["FrontGearBox"].setColor(1,1,0);
		}
		if(getprop("/gear/gear[1]/position-norm")==1){
			me["LeftGearText"].setText("DN");
			me["LeftGearText"].setColor(0,1,0);
			me["LeftGearBox"].setColor(0,1,0);
		}else if(getprop("/gear/gear[1]/position-norm")==0){
			me["LeftGearText"].setText("UP");
			me["LeftGearText"].setColor(0.5,1,1);
			me["LeftGearBox"].setColor(0.5,1,1);
		}else{
			me["LeftGearText"].setText("TR");
			me["LeftGearText"].setColor(1,1,0);
			me["LeftGearBox"].setColor(1,1,0);
		}		
		if(getprop("/gear/gear[2]/position-norm")==1){
			me["RightGearText"].setText("DN");
			me["RightGearText"].setColor(0,1,0);
			me["RightGearBox"].setColor(0,1,0);
		}else if(getprop("/gear/gear[2]/position-norm")==0){
			me["RightGearText"].setText("UP");
			me["RightGearText"].setColor(0.5,1,1);
			me["RightGearBox"].setColor(0.5,1,1);
		}else{
			me["RightGearText"].setText("TR");
			me["RightGearText"].setColor(1,1,0);
			me["RightGearBox"].setColor(1,1,0);
		}
		
		#Flaps
		var flaps_norm=getprop("/surface-positions/flap-pos-norm");
		var flaps_bar=getprop("/instrumentation/EICAS/flaps-bar") or 0;
		if(flaps_norm>=0.177 and flaps_norm<0.444){flaps=8}else if(flaps_norm>=0.444 and flaps_norm<0.666){flaps=20}else if(flaps_norm>=0.666 and flaps_norm<1){flaps=30}else if(flaps_norm==1){flaps=45}else{flaps=0};
		
		me["FlapsDeg"].setText(sprintf("%s", flaps));
		me["flaps.bar"].setTranslation(flaps_bar*93.2,0);
		
		#Fuel
		me["FuelQtyLeft"].setText(sprintf("%s", math.round(getprop("/consumables/fuel/tank[0]/level-lbs"))));
		if(getprop("/consumables/fuel/tank[2]/level-lbs")==0){
			me["FuelQtyCenter"].setColor(1,1,1);
		}else{
			me["FuelQtyCenter"].setColor(0,1,0);
		}
		me["FuelQtyCenter"].setText(sprintf("%s", math.round(getprop("/consumables/fuel/tank[2]/level-lbs"))));
		me["FuelQtyRight"].setText(sprintf("%s", math.round(getprop("/consumables/fuel/tank[1]/level-lbs"))));
		me["FuelQtyTotal"].setText(sprintf("%s", math.round(getprop("/consumables/fuel/total-fuel-lbs"))));
		
		
		#Message area
		me["message1"].setText(getprop("/instrumentation/EICAS/messages/message[1]"));
		me["message2"].setText(getprop("/instrumentation/EICAS/messages/message[2]"));
		me["message3"].setText(getprop("/instrumentation/EICAS/messages/message[3]"));
		me["message4"].setText(getprop("/instrumentation/EICAS/messages/message[4]"));
		me["message5"].setText(getprop("/instrumentation/EICAS/messages/message[5]"));
		me["message6"].setText(getprop("/instrumentation/EICAS/messages/message[6]"));
		me["message7"].setText(getprop("/instrumentation/EICAS/messages/message[7]"));
		me["message8"].setText(getprop("/instrumentation/EICAS/messages/message[8]"));
		me["message9"].setText(getprop("/instrumentation/EICAS/messages/message[9]"));
		me["message10"].setText(getprop("/instrumentation/EICAS/messages/message[10]"));
		me["message11"].setText(getprop("/instrumentation/EICAS/messages/message[11]"));
		me["message12"].setText(getprop("/instrumentation/EICAS/messages/message[12]"));
		
		settimer(func me.update(), 0.02);
		
	},
};

var canvas_EICAS_status = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EICAS_status , canvas_EICAS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["ApuRPM","ApuRPMNeedle","ApuEGT","ApuEGTNeedle","ApuDoor","AilTrim","RudTrim","StabTrim","StabTrimText"];
	},
	update: func() {
	
		#APU
		var rpm=getprop("/engines/engine[2]/rpm");
		me["ApuRPM"].setText(sprintf("%2.1f", rpm));
		me["ApuRPMNeedle"].setRotation(rpm*0.0375);
		if(rpm<=100){
			me["ApuRPM"].setColor(0,1,0);
			me["ApuRPMNeedle"].setColor(0,1,0);
		}else if(rpm<=106){
			me["ApuRPM"].setColor(1,1,0);
			me["ApuRPMNeedle"].setColor(1,1,0);
		}else{
			me["ApuRPM"].setColor(1,0,0);
			me["ApuRPMNeedle"].setColor(1,0,0);
		}
		var egt=getprop("/engines/apu/egt-degc");
		me["ApuEGT"].setText(sprintf("%2.1f", egt));
		me["ApuEGTNeedle"].setRotation(egt*0.00323);   #230 degrees 712°C
		if(egt<=712){
			me["ApuEGT"].setColor(0,1,0);
			me["ApuEGTNeedle"].setColor(0,1,0);
		}else if(egt<=742){
			me["ApuEGT"].setColor(1,1,0);
			me["ApuEGTNeedle"].setColor(1,1,0);
		}else{
			me["ApuEGT"].setColor(1,0,0);
			me["ApuEGTNeedle"].setColor(1,0,0);
		}
		
		var APUdoor=getprop("/engines/apu/door-msg");
		if(APUdoor=="OPEN"){
			me["ApuDoor"].setText("DOOR OPEN");
			me["ApuDoor"].setColor(1,1,1);
		}else if(APUdoor=="CLSD"){
			me["ApuDoor"].setText("DOOR CLSD");
			me["ApuDoor"].setColor(1,1,1);
		}else{
			me["ApuDoor"].setText("DOOR ---");
			me["ApuDoor"].setColor(1,1,0);
		}
			
		#TRIM
		#Aileron Trim
		me["AilTrim"].setRotation(getprop("/controls/flight/aileron-trim")*(-1.2));
		#Rudder Trim
		me["RudTrim"].setRotation(getprop("/controls/flight/rudder-trim")*(-1.2));
		#Stab Trim
		me["StabTrim"].setTranslation(0,getprop("/controls/flight/elevator-trim")*75);
		me["StabTrimText"].setTranslation(0, getprop("/controls/flight/elevator-trim")*75);
		me["StabTrimText"].setText(sprintf("%s", math.round(getprop("/controls/flight/elevator-trim")*15)));
		if(getprop("/controls/flight/elevator-trim")<0.5 and getprop("/controls/flight/elevator-trim")>-0.5){
			me["StabTrim"].setColor(0,1,0);
			me["StabTrimText"].setColor(0,1,0);
		}else{
			me["StabTrim"].setColor(1,1,1);
			me["StabTrimText"].setColor(1,1,1);
		}
		
		
		
		settimer(func me.update(), 0.02);
		
	},
};

var canvas_EICAS_fuel = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EICAS_fuel , canvas_EICAS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		
		
		
		settimer(func me.update(), 0.02);
		
	},
};

var canvas_EICAS_ecs = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EICAS_ecs , canvas_EICAS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		
		
		
		settimer(func me.update(), 0.02);
		
	},
};


var canvas_EICAS_fctl = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EICAS_fctl , canvas_EICAS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["flaps.deg.1","flaps.deg.2","aileronl.deg","aileronl.ind","aileronr.deg","aileronr.ind","rudder.deg","rudder.ind"];
	},
	update: func() {
		
		var flaps_deg=math.round((getprop("/surface-positions/flap-pos-norm") or 0)*45);
		me["flaps.deg.1"].setText(sprintf("%2d", flaps_deg));
		me["flaps.deg.2"].setText(sprintf("%2d", flaps_deg));
		
		var aileron_l=-1*(getprop("/surface-positions/left-aileron-pos-norm") or 0);
		if(aileron_l>0){
			aileron_l=aileron_l*24;
		}else{
			aileron_l=aileron_l*20;
		}
		me["aileronl.deg"].setText(sprintf("%2d", math.round(aileron_l)));
		me["aileronl.ind"].setTranslation(0,-aileron_l*3.76);
		
		var aileron_r=-1*(getprop("/surface-positions/right-aileron-pos-norm") or 0);
		if(aileron_r>0){
			aileron_r=aileron_r*24;
		}else{
			aileron_r=aileron_r*20;
		}
		me["aileronr.deg"].setText(sprintf("%2d", math.round(aileron_r)));
		me["aileronr.ind"].setTranslation(0,-aileron_r*3.76);
		
		var rudder = getprop("/surface-positions/rudder-pos-norm") or 0;
		rudder=rudder*33;
		me["rudder.deg"].setText(sprintf("%2d", math.round(rudder)));
		me["rudder.ind"].setTranslation(rudder*116.5,0);
		
		
		settimer(func me.update(), 0.02);
		
	},
};



var canvas_EICAS_doors = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EICAS_doors , canvas_EICAS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["passenger.txt","passenger.smbl","service.txt","service.smbl","avbay.txt","avbay.smbl","emer.l.text","emer.l.smbl","emer.r.txt","emer.r.smbl","cargo.txt","cargo.smbl"];
	},
	update: func() {
		
		if((getprop("/sim/model/door-positions/pax-left/position-norm") or 0)==0){
			me["passenger.txt"].setColor(0,1,0);
			me["passenger.smbl"].setColor(0,1,0);
		}else{
			me["passenger.txt"].setColor(1,0,0);
			me["passenger.smbl"].setColor(1,0,0);
		}
		if((getprop("/sim/model/door-positions/pax-right/position-norm") or 0)==0){
			me["service.txt"].setColor(0,1,0);
			me["service.smbl"].setColor(0,1,0);
		}else{
			me["service.txt"].setColor(1,1,0);
			me["service.smbl"].setColor(1,1,0);
		}
		
		
		settimer(func me.update(), 0.02);
		
	},
};


var canvas_EICAS_hydraulics = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EICAS_hydraulics , canvas_EICAS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Hydraulic1.pct","Hydraulic2.pct","Hydraulic3.pct","Hydraulic1.degc","Hydraulic2.degc","Hydraulic3.degc","Hydraulic1.psi","Hydraulic2.psi","Hydraulic3.psi","rudder","HYD1.ind","HYD2.ind","HYD3.ind","elevator","nwsteer","aileron","landinggear","lsplron","rsplron","lrsplron","fltsplr1","fltsplr2","outbdgndsplr","inbdgndsplr","ibbrakes.psi","obbrakes.psi","ENG1","ENG2","HYD1.lines","HYD2.lines","HYD3.lines","ENG1.pump","ENG2.pump","pump.1B","pump.2B","pump.3A","pump.3B"];
	},
	update: func() {
		
		var quantity1=getprop("/systems/hydraulic/system[0]/quantity-percent") or 0;
		var quantity2=getprop("/systems/hydraulic/system[1]/quantity-percent") or 0;
		var quantity3=getprop("/systems/hydraulic/system[2]/quantity-percent") or 0;
		
		me["Hydraulic1.pct"].setText(sprintf("%3d", quantity1));
		me["Hydraulic2.pct"].setText(sprintf("%3d", quantity2));
		me["Hydraulic3.pct"].setText(sprintf("%3d", quantity3));
		
		me["HYD1.ind"].setTranslation(0,(100-quantity1)*1.55);
		me["HYD2.ind"].setTranslation(0,(100-quantity2)*1.55);
		me["HYD3.ind"].setTranslation(0,(100-quantity3)*1.55);
		
		#Set colors based on quantity
		if(quantity1>=45 and quantity1<=85){
			me["Hydraulic1.pct"].setColor(0,1,0);
			me["HYD1.ind"].setColor(0,1,0);
		}else{
			me["Hydraulic1.pct"].setColor(1,1,0);
			me["HYD1.ind"].setColor(1,1,0);
		}
		
		if(quantity2>=45 and quantity2<=85){
			me["Hydraulic2.pct"].setColor(0,1,0);
			me["HYD2.ind"].setColor(0,1,0);
		}else{
			me["Hydraulic2.pct"].setColor(1,1,0);
			me["HYD2.ind"].setColor(1,1,0);
		}
		
		if(quantity3>=45 and quantity3<=85){
			me["Hydraulic3.pct"].setColor(0,1,0);
			me["HYD3.ind"].setColor(0,1,0);
		}else{
			me["Hydraulic3.pct"].setColor(1,1,0);
			me["HYD3.ind"].setColor(1,1,0);
		}
		
		
		var temp1=getprop("/systems/hydraulic/system[0]/temperature-degc") or 0;
		var temp2=getprop("/systems/hydraulic/system[1]/temperature-degc") or 0;
		var temp3=getprop("/systems/hydraulic/system[2]/temperature-degc") or 0;
		
		me["Hydraulic1.degc"].setText(sprintf("%3d", temp1));
		me["Hydraulic2.degc"].setText(sprintf("%3d", temp2));
		me["Hydraulic3.degc"].setText(sprintf("%3d", temp3));
		
		#Set colors based on temp
		if(temp1<96){
			me["Hydraulic1.degc"].setColor(0,1,0);
		}else{
			me["Hydraulic1.degc"].setColor(1,1,0);
		}
		if(temp2<96){
			me["Hydraulic2.degc"].setColor(0,1,0);
		}else{
			me["Hydraulic2.degc"].setColor(1,1,0);
		}
		if(temp3<96){
			me["Hydraulic3.degc"].setColor(0,1,0);
		}else{
			me["Hydraulic3.degc"].setColor(1,1,0);
		}
		
		var press1=getprop("/systems/hydraulic/system[0]/value") or 0;
		var press2=getprop("/systems/hydraulic/system[1]/value") or 0;
		var press3=getprop("/systems/hydraulic/system[2]/value") or 0;
		
		me["Hydraulic1.psi"].setText(sprintf("%4d", press1));
		me["Hydraulic2.psi"].setText(sprintf("%4d", press2));
		me["Hydraulic3.psi"].setText(sprintf("%4d", press3));
		
		#Set colors based on pressure
		if(press1>1800 and press1<=3200){
			me["Hydraulic1.psi"].setColor(0,1,0);
			me["HYD1.lines"].show();
		}else if(press1>3200){
			me["Hydraulic1.psi"].setColor(1,1,1);
			me["HYD1.lines"].hide();
		}else{
			me["Hydraulic1.psi"].setColor(1,1,0);
			me["HYD1.lines"].hide();
		}
		if(press2>1800){
			me["Hydraulic2.psi"].setColor(0,1,0);
			me["HYD2.lines"].show();
		}else if(press2>3200){
			me["Hydraulic2.psi"].setColor(1,1,1);
			me["HYD2.lines"].hide();
		}else{
			me["Hydraulic2.psi"].setColor(1,1,0);
			me["HYD2.lines"].hide();
		}
		if(press3>1800){
			me["Hydraulic3.psi"].setColor(0,1,0);
			me["HYD3.lines"].show();
		}else if(press3>3200){
			me["Hydraulic3.psi"].setColor(1,1,1);
			me["HYD3.lines"].hide();
		}else{
			me["Hydraulic3.psi"].setColor(1,1,0);
			me["HYD3.lines"].hide();
		}
		
		#Engines
		var ENG1_running=getprop("/engines/engine[0]/running-nasal") or 0;
		var ENG1_pump=getprop("/systems/hydraulic/system[0]/pump-a-running") or 0;
		if(ENG1_running==1){
			me["ENG1"].setColor(0.25,0.75,0.75);
			if(ENG1_pump==1){
				me["ENG1.pump"].setColor(0,1,0);
			}else{
				me["ENG1.pump"].setColor(1,1,0);
			}
		}else{
			me["ENG1"].setColor(1,1,1);
			me["ENG1.pump"].setColor(1,1,1);
		}
		var ENG2_running=getprop("/engines/engine[1]/running-nasal") or 0;
		var ENG2_pump=getprop("/systems/hydraulic/system[1]/pump-a-running") or 0;
		if(ENG2_running==1){
			me["ENG2"].setColor(0.25,0.75,0.75);
			if(ENG2_pump==1){
				me["ENG2.pump"].setColor(0,1,0);
			}else{
				me["ENG2.pump"].setColor(1,1,0);
			}
		}else{
			me["ENG2"].setColor(1,1,1);
			me["ENG2.pump"].setColor(1,1,1);
		}
		
		#Set pump colors
		if((getprop("/systems/hydraulic/system/pump-b-running") or 0)==1){
			me["pump.1B"].setColor(0,1,0);
		}else{
			me["pump.1B"].setColor(1,1,1);
		}
		if((getprop("/systems/hydraulic/system[1]/pump-b-running") or 0)==1){
			me["pump.2B"].setColor(0,1,0);
		}else{
			me["pump.2B"].setColor(1,1,1);
		}
		if((getprop("/systems/hydraulic/system[2]/pump-a-running") or 0)==1){
			me["pump.3A"].setColor(0,1,0);
		}else{
			me["pump.3A"].setColor(1,1,1);
		}
		if((getprop("/systems/hydraulic/system[2]/pump-b-running") or 0)==1){
			me["pump.3B"].setColor(0,1,0);
		}else{
			me["pump.3B"].setColor(1,1,1);
		}
		
		#Inboard Brakes
		var ibbrakes=(getprop("/systems/hydraulic/outputs/ib-brakes") or 0)*(getprop("/systems/hydraulic/system[2]/value") or 0);
		me["ibbrakes.psi"].setText(sprintf("%4d", ibbrakes));
		if(ibbrakes>=1000 and ibbrakes<=3200){
			me["ibbrakes.psi"].setColor(0,1,0);
		}else if(ibbrakes<1000){
			me["ibbrakes.psi"].setColor(1,1,0);
		}else{
			me["ibbrakes.psi"].setColor(1,1,1);
		}
			
		#Outboard Brakes
		var obbrakes=(getprop("/systems/hydraulic/outputs/ob-brakes") or 0)*(getprop("/systems/hydraulic/system[1]/value") or 0);
		me["obbrakes.psi"].setText(sprintf("%4d", obbrakes));
		if(obbrakes>=1000 and obbrakes<=3200){
			me["obbrakes.psi"].setColor(0,1,0);
		}else if(obbrakes<1000){
			me["obbrakes.psi"].setColor(1,1,0);
		}else{
			me["obbrakes.psi"].setColor(1,1,1);
		}
		
		#set system name's colors based on powered/not powered
		#Rudder
		if((getprop("/systems/hydraulic/outputs/rudder") or 0)==1){
			me["rudder"].setColor(1,1,1);
		}else{
			me["rudder"].setColor(1,1,0);
		}
		#Elevator
		if((getprop("/systems/hydraulic/outputs/elevator") or 0)==1){
			me["elevator"].setColor(1,1,1);
		}else{
			me["elevator"].setColor(1,1,0);
		}
		#Aileron
		if((getprop("/systems/hydraulic/outputs/aileron") or 0)==1){
			me["aileron"].setColor(1,1,1);
		}else{
			me["aileron"].setColor(1,1,0);
		}
		#Landing Gear
		if((getprop("/systems/hydraulic/outputs/landing-gear") or 0)==1){
			me["landinggear"].setColor(1,1,1);
		}else{
			me["landinggear"].setColor(1,1,0);
		}
		#NW Steering
		if((getprop("/systems/hydraulic/outputs/nwsteering") or 0)==1){
			me["nwsteer"].setColor(1,1,1);
		}else{
			me["nwsteer"].setColor(1,1,0);
		}
		#Left Spoileron
		if((getprop("/systems/hydraulic/outputs/l-spoileron") or 0)==1){
			me["lsplron"].setColor(1,1,1);
		}else{
			me["lsplron"].setColor(1,1,0);
		}
		#Right Spoileron
		if((getprop("/systems/hydraulic/outputs/r-spoileron") or 0)==1){
			me["rsplron"].setColor(1,1,1);
		}else{
			me["rsplron"].setColor(1,1,0);
		}
		#Left and Right Spoileron
		if((getprop("/systems/hydraulic/outputs/lr-spoileron") or 0)==1){
			me["lrsplron"].setColor(1,1,1);
		}else{
			me["lrsplron"].setColor(1,1,0);
		}
		#Outboard Ground Spoiler
		if((getprop("/systems/hydraulic/outputs/ob-ground-spoiler") or 0)==1){
			me["outbdgndsplr"].setColor(1,1,1);
		}else{
			me["outbdgndsplr"].setColor(1,1,0);
		}
		#Inboard Ground Spoiler
		if((getprop("/systems/hydraulic/outputs/ib-ground-spoiler") or 0)==1){
			me["inbdgndsplr"].setColor(1,1,1);
		}else{
			me["inbdgndsplr"].setColor(1,1,0);
		}
		#Flight Spoiler 1
		if((getprop("/systems/hydraulic/outputs/ob-flight-spoiler") or 0)==1){
			me["fltsplr1"].setColor(1,1,1);
		}else{
			me["fltsplr1"].setColor(1,1,0);
		}
		#Flight Spoiler 2
		if((getprop("/systems/hydraulic/outputs/ib-flight-spoiler") or 0)==1){
			me["fltsplr2"].setColor(1,1,1);
		}else{
			me["fltsplr2"].setColor(1,1,0);
		}
		
		
		
		
		
		
		settimer(func me.update(), 0.02);
		
	},
};

var canvas_EICAS_electrical = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EICAS_electrical , canvas_EICAS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["APU.Volts","APU.Freq","Gen1.Freq","Gen1.Volts","Gen2.Freq","Gen2.Volts","APU","APU.gen","ENG1","ENG1.gen","ENG2","ENG2.gen","ADG.complete","ADG.Volts","ADG.Freq","ADG.gen","ADG.bus","EXT.complete","APU.Line","Gen1.Line","Gen2.Line","EXT.Line","ESS.bus","BUS1","BUS2","UTIL1.bus","UTIL2.bus","SERV.bus","EXT.Freq","EXT.Volts","EXT.gen","EXT.bus","Segment.1","Segment.2","Segment.3","Segment.4","ADG.Line","ADG.bus2","UTIL1.Line","UTIL2.Line","ESS.Line1","ESS.Line2"];
	},
	update: func() {
		me["APU.Volts"].setText(sprintf("%d", getprop("/systems/AC/system/apugen-value")));
		me["APU.Freq"].setText(sprintf("%d", getprop("/systems/AC/system/apugen-freq")));
		var APU_running=getprop("/engines/apu/running") or 0;
		var APU_generator=getprop("/systems/AC/system/apugen-running") or 0;
		if(APU_running==1){
			me["APU"].setColor(0.25,0.75,0.75);
			if(APU_generator==1){
				me["APU.gen"].setColor(0,1,0);
				me["APU.Line"].show();
			}else{
				me["APU.gen"].setColor(1,1,0);
				me["APU.Line"].hide();
			}
		}else if(APU_running==0){
			me["APU"].setColor(1,1,1);
			me["APU.gen"].setColor(1,1,1);
			me["APU.Line"].hide();
		}
		
		me["Gen1.Volts"].setText(sprintf("%d", getprop("/systems/AC/system/gen1-value")));
		me["Gen1.Freq"].setText(sprintf("%d", getprop("/systems/AC/system/gen1-freq")));
		var ENG1_running=getprop("/engines/engine[0]/running-nasal") or 0;
		var ENG1_generator=getprop("/systems/AC/system/gen1-running") or 0;
		if(ENG1_running==1){
			me["ENG1"].setColor(0.25,0.75,0.75);
			if(ENG1_generator==1){
				me["ENG1.gen"].setColor(0,1,0);
				me["Gen1.Line"].show();
			}else{
				me["ENG1.gen"].setColor(1,1,0);
				me["Gen1.Line"].hide();
			}
		}else if(ENG1_running==0){
			me["ENG1"].setColor(1,1,1);
			me["ENG1.gen"].setColor(1,1,1);
			me["Gen1.Line"].hide();
		}
		
		me["Gen2.Volts"].setText(sprintf("%d", getprop("/systems/AC/system/gen2-value")));
		me["Gen2.Freq"].setText(sprintf("%d", getprop("/systems/AC/system/gen2-freq")));
		var ENG2_running=getprop("/engines/engine[1]/running-nasal") or 0;
		var ENG2_generator=getprop("/systems/AC/system/gen2-running") or 0;
		if(ENG2_running==1){
			me["ENG2"].setColor(0.25,0.75,0.75);
			if(ENG2_generator==1){
				me["ENG2.gen"].setColor(0,1,0);
				me["Gen2.Line"].show();
			}else{
				me["ENG2.gen"].setColor(1,1,0);
				me["Gen2.Line"].hide();
			}
		}else if(ENG2_running==0){
			me["ENG2"].setColor(1,1,1);
			me["Gen2.Line"].hide();
		}
		
		#ADG
		if(getprop("/systems/AC/system/adg-value")>10 and getprop("/systems/AC/system/adg-freq")>300){
			me["ADG.complete"].show();
			var adg_volts=getprop("/systems/AC/system/adg-value") or 0;
			var adg_hertz=getprop("/systems/AC/system/adg-freq") or 0;
			me["ADG.Volts"].setText(sprintf("%d", adg_volts));
			me["ADG.Freq"].setText(sprintf("%d", adg_hertz));
			if(adg_volts>108 and adg_volts<130){
				me["ADG.Volts"].setColor(0,1,0);
			}else{
				me["ADG.Volts"].setColor(1,1,1);
			}
			if(adg_hertz>360 and adg_hertz<440){
				me["ADG.Freq"].setColor(0,1,0);
			}else{
				me["ADG.Freq"].setColor(1,1,1);
			}
			
			if(adg_volts>108 and adg_volts<130 and adg_hertz>360 and adg_hertz<440){
				me["ADG.gen"].setColor(0,1,0);
				me["ADG.bus"].setColor(0,1,0);
				me["ADG.bus2"].setColor(0,1,0);
				me["ADG.Line"].show();
			}else{
				me["ADG.gen"].setColor(1,1,1);
				me["ADG.bus"].setColor(1,1,1);
				me["ADG.bus2"].setColor(1,1,1);
				me["ADG.Line"].hide();
			}
		}else{
			me["ADG.complete"].hide();
		}
		
		
		#EXTERNAL		
		if(getprop("/systems/AC/system/acext-value")>10 and getprop("/systems/AC/system/acext-freq")>50){
			me["EXT.complete"].show();
			var adg_volts=getprop("/systems/AC/system/acext-value") or 0;
			var adg_hertz=getprop("/systems/AC/system/acext-freq") or 0;
			me["EXT.Volts"].setText(sprintf("%d", adg_volts));
			me["EXT.Freq"].setText(sprintf("%d", adg_hertz));
			if(adg_volts>106 and adg_volts<124){
				me["EXT.Volts"].setColor(0,1,0);
			}else{
				me["EXT.Volts"].setColor(1,1,1);
			}
			if(adg_hertz>330 and adg_hertz<430){
				me["EXT.Freq"].setColor(0,1,0);
			}else{
				me["EXT.Freq"].setColor(1,1,1);
			}
			
			if(adg_volts>106 and adg_volts<124 and adg_hertz>370 and adg_hertz<430){
				me["EXT.gen"].setColor(0,1,0);
				me["EXT.bus"].setColor(0,1,0);
				me["EXT.Line"].show();
			}else{
				me["EXT.gen"].setColor(1,1,1);
				me["EXT.bus"].setColor(1,1,1);
				me["EXT.Line"].hide();
			}
		}else{
			me["EXT.complete"].hide();
			me["EXT.Line"].hide();
		}
		
		
		#Busses
		#Essential
		if(getprop("/systems/AC/outputs/esstru1")>50 and getprop("/systems/AC/outputs/esstru2")>50){
			me["ESS.bus"].setColor(0,1,0);
			if(getprop("/systems/AC/outputs/bus1")>50 and getprop("/systems/AC/outputs/bus2")>50){
				me["ESS.Line1"].show();
				me["ESS.Line2"].show();
			}else if(getprop("/systems/AC/outputs/bus2")>50){
				me["ESS.Line1"].show();
				me["ESS.Line2"].hide();
			}else if(getprop("/systems/AC/outputs/bus1")>50){
				me["ESS.Line1"].hide();
				me["ESS.Line2"].show();
			}else{
				me["ESS.Line1"].hide();
				me["ESS.Line2"].hide();
			}
				
		}else{
			me["ESS.bus"].setColor(1,1,0);
			me["ESS.Line1"].hide();
			me["ESS.Line2"].hide();
		}
		
		
		#BUS 1
		if(getprop("/systems/AC/outputs/bus1")>50){
			me["BUS1"].setColor(0,1,0);
		}else{
			me["BUS1"].setColor(1,1,0);
		}
		#BUS2
		if(getprop("/systems/AC/outputs/bus2")>50){
			me["BUS2"].setColor(0,1,0);
		}else{
			me["BUS2"].setColor(1,1,0);
		}
		
		#UTIL BUS 1
		if(getprop("/systems/AC/outputs/bus3")>50){
			me["UTIL1.bus"].setColor(0,1,0);
			me["UTIL1.Line"].show();
		}else{
			me["UTIL1.bus"].setColor(1,1,0);
			me["UTIL1.Line"].hide();
		}
		
		
		#UTIL BUS 1
		if(getprop("/systems/AC/outputs/bus4")>50){
			me["UTIL2.bus"].setColor(0,1,0);
			me["UTIL2.Line"].show();
		}else{
			me["UTIL2.bus"].setColor(1,1,0);
			me["UTIL2.Line"].hide();
		}
		
		#SERV Bus
		if(getprop("/systems/AC/outputs/bus5")>50){
			me["SERV.bus"].setColor(0,1,0);
		}else{
			me["SERV.bus"].setColor(1,1,0);
		}
		
		#Line segments
		if(getprop("/systems/AC/outputs/bus1")>50 and getprop("/systems/AC/outputs/bus2")>50){
			me["Segment.1"].show();
			me["Segment.2"].show();
			me["Segment.3"].show();
			me["Segment.4"].show();
		}else if(getprop("/systems/AC/outputs/bus1")>50 and getprop("/systems/AC/system/gen1-running")==1){
			me["Segment.1"].show();
			me["Segment.2"].hide();
			me["Segment.3"].hide();
			me["Segment.4"].hide();
		}else if(getprop("/systems/AC/outputs/bus1")>50 and getprop("/systems/AC/system/gen2-running")==1){
			me["Segment.1"].show();
			me["Segment.2"].hide();
			me["Segment.3"].show();
			me["Segment.4"].show();
		}else if(getprop("/systems/AC/outputs/bus1")>50 and getprop("/systems/AC/system/apugen-running")==1){
			me["Segment.1"].show();
			me["Segment.2"].hide();
			me["Segment.3"].show();
			me["Segment.4"].hide();
		}else if(getprop("/systems/AC/outputs/bus2")>50 and getprop("/systems/AC/system/gen1-running")==1){
			me["Segment.1"].hide();
			me["Segment.2"].show();
			me["Segment.3"].show();
			me["Segment.4"].show();
		}else if(getprop("/systems/AC/outputs/bus2")>50 and getprop("/systems/AC/system/gen2-running")==1){
			me["Segment.1"].hide();
			me["Segment.2"].show();
			me["Segment.3"].hide();
			me["Segment.4"].hide();
		}else if(getprop("/systems/AC/outputs/bus1")>50 and getprop("/systems/AC/system/apugen-running")==1){
			me["Segment.1"].hide();
			me["Segment.2"].show();
			me["Segment.3"].hide();
			me["Segment.4"].show();
		}else{
			me["Segment.1"].hide();
			me["Segment.2"].hide();
			me["Segment.3"].hide();
			me["Segment.4"].hide();
		}
			
		
		
		
		settimer(func me.update(), 0.02);
		
	},
};

setlistener("sim/signals/fdm-initialized", func {
	EICAS_display = canvas.new({
		"name": "EICAS",
		"size": [1024, 1280],
		"view": [1024, 1280],
		"mipmapping": 1
	});
	EICAS_display.addPlacement({"node": "ScreenR"});
	
	var groupPrimary = EICAS_display.createGroup();
	var groupStatus = EICAS_display.createGroup();
	var groupElectrical = EICAS_display.createGroup();
	var groupFuel = EICAS_display.createGroup();
	var groupHydraulics = EICAS_display.createGroup();
	var groupDoors = EICAS_display.createGroup();
	var groupFCTL = EICAS_display.createGroup();
	var groupECS = EICAS_display.createGroup();

	EICAS_primary = canvas_EICAS_primary.new(groupPrimary, "Aircraft/CRJ200/Models/Instruments/EICAS/Primary.svg");
	EICAS_status = canvas_EICAS_status.new(groupStatus, "Aircraft/CRJ200/Models/Instruments/EICAS/Status.svg");
	EICAS_electrical = canvas_EICAS_electrical.new(groupElectrical, "Aircraft/CRJ200/Models/Instruments/EICAS/Electrical.svg");
	EICAS_fuel = canvas_EICAS_fuel.new(groupFuel, "Aircraft/CRJ200/Models/Instruments/EICAS/Fuel.svg");
	EICAS_hydraulics = canvas_EICAS_hydraulics.new(groupHydraulics, "Aircraft/CRJ200/Models/Instruments/EICAS/Hydraulics.svg");
	EICAS_doors = canvas_EICAS_doors.new(groupDoors, "Aircraft/CRJ200/Models/Instruments/EICAS/Doors.svg");
	EICAS_fctl = canvas_EICAS_fctl.new(groupFCTL, "Aircraft/CRJ200/Models/Instruments/EICAS/FCTL.svg");
	EICAS_ecs = canvas_EICAS_ecs.new(groupECS, "Aircraft/CRJ200/Models/Instruments/EICAS/ECS.svg");



	EICAS_primary.update();
	EICAS_status.update();
	EICAS_electrical.update();
	EICAS_fuel.update();
	EICAS_hydraulics.update();
	EICAS_doors.update();
	EICAS_fctl.update();
	EICAS_ecs.update();
	
	canvas_EICAS_base.update();
});

var showEICASL = func {
	var dlg = canvas.Window.new([512, 640], "dialog").set("resize", 1);
	dlg.setCanvas(EICAS_display);
}

var new_message = func (string,color){
	var i=0;
	var stop=0;
	while(i<12 and !stop){
		if(getprop("/instrumentation/EICAS/messages/message["~i~"]")==""){
			setprop("/instrumentation/EICAS/messages/message["~i~"]", string);
			setprop("/instrumentation/EICAS/messages/message["~i~"]-color", color);
			stop=1;
			print("message successfully added");
		}else{
			i=i+1;
			print("no");
		}
	}
	return i;
}

var destroy_message = func (number){
	setprop("/instrumentation/EICAS/messages/message["~i~"]", "");
	setprop("/instrumentation/EICAS/messages/message["~i~"]-color", "");
}
	
