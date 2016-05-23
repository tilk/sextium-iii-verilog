module step_clock_gen
(
	input clock,
	input pushbtn,
	output stepclock
);

	reg spushbtn1, spushbtn2, spushbtn3;
	
	assign stepclock = spushbtn2 & ~spushbtn3;

	// synchronize the push button signal to the clock
	always @(posedge clock)
	begin
		spushbtn1 <= pushbtn;
		spushbtn2 <= spushbtn1;
		spushbtn3 <= spushbtn2;
	end
		
endmodule