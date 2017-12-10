setlistener("/controls/gear/brake-parking", func{
	if(getprop("/controls/gear/brake-parking")==1){
		number=canvas_eicas.new_message("PARKING BRAKE","green");
	}else if(number!=nil){
		canvas_eicas.destroy_message(number);
		number=nil;
	}
});
