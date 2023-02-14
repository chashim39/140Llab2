// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module top_level_lab2_part2(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
	      Minadv,
	      Hrsadv,
        Dayadv,
	      Alarmon,
	      Pulse,		  // assume 1/sec.			   
// 6 decimal digit display (7 segment)
  output[6:0] S1disp, S0disp, 	   // 2-digit seconds display
              M1disp, M0disp, 
              H1disp, H0disp,
              DayLED,
  output logic AMorPM,            // Added by Arpita 
  output logic Buzz);	           // alarm sounds
  
//... Fill in the logic to display part 2 requrements
  logic [6:0] TSec, TMin, THrs, TDay;   // time 
  logic       TPm;                // time PM
  logic [6:0] AMin, AHrs;         // alarm setting
  logic       APm;                // alarm PM
   
     
  logic[6:0] Min, Hrs, Days;                     // drive Min and Hr displays
  logic Smax, Mmax, Hmax, Dmax,          // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, TPmen, AMen, AHen, AHmax, AMmax, APmen;    // respective counter enables
  logic         Buzz1;             // intermediate Buzz signal
  logic Den;  //day enable

   // be sure to set parameters on ct_mod_N modules
   // seconds counter runs continuously, but stalls when Timeset is on 
   ct_mod_N #(.N()) Sct(
        .clk(Pulse), .rst(Reset), .en(!Timeset), .ct_out(TSec), .z(Smax)
   );

   // minutes counter -- runs at either 1/sec or 1/60sec
   // make the appropriate connections. Make sure you use
   // a consistent clock signal. Do not use logic signals as clocks 
   // (EVER IN THIS CLASS)
   ct_mod_N #(.N()) Mct(
    .clk(Pulse), .rst(Reset), .en(TMen), .ct_out(TMin), .z(Mmax)
   );

   // hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N #(.N(12)) Hct(                          
        .clk(Pulse), .rst(Reset), .en(THen), .ct_out(THrs), .z(Hmax)
   );

   // AM/PM state  --  runs at 1/12 sec or 1/12hrs
  regce TPMct(.out(TPm), .inp(!TPm), .en(TPmen),
               .clk(Pulse), .rst(Reset));

  ct_mod_N #(.N(7)) DayCount(
    .clk(Pulse), .rst(Reset), .en(Den), .ct_out(TDay), .z(Dmax)
   );



// alarm set registers -- either hold or advance 1/sec
  ct_mod_N #(.N()) Mreg(
    .clk(Pulse), .rst(Reset), .en(AMen), .ct_out(AMin), .z(AMmax)
   ); 

  ct_mod_N #(.N(12)) Hreg(          
    .clk(Pulse), .rst(Reset), .en(AHen), .ct_out(AHrs), .z(AHmax)
  );
  

   // alarm AM/PM state 
   regce APMReg(.out(APm), .inp(!APm), .en(APmen),
               .clk(Pulse), .rst(Reset));


   // display drivers (2 digits each, 6 digits total)
   lcd_int Sdisp(
    .bin_in    (TSec)  ,
        .Segment1  (S1disp),
        .Segment0  (S0disp)
   );

   lcd_int Mdisp(
    .bin_in    (Min) ,
        .Segment1  (M1disp),
        .Segment0  (M0disp)
        );

  lcd_int Hdisp(
    .bin_in    (Hrs),
        .Segment1  (H1disp),
        .Segment0  (H0disp)
        );

   // counter enable control logic
   // create some logic for the various *en signals (e.g. TMen)
  always_comb begin
    if (Timeset) begin
      TMen <= Minadv;
      THen <= Hrsadv;
      TPmen <= (Hmax & Hrsadv);
      Den <= Dayadv;
    end else begin
      TMen <= Smax;
      THen <= (Mmax & Smax);
      TPmen <= (Hmax & Mmax & Smax);
      Den <= (Hmax & Mmax & Smax & TPm);
    end

    if (Alarmset) begin
      AMen <= Minadv;
      AHen <= Hrsadv;
      APmen <= (Hrsadv & AHmax);
    end else begin
      AMen <= AMen;
      AHen <= AHen;
      APmen <= APmen;
    end

  end
   
   // display select logic (decide what to send to the seven segment outputs) 
  always_comb begin
    if (Alarmset) begin
      Min <= AMin;
      if (AHrs == 0) begin
        Hrs <= 12;
      end else begin
        Hrs <= AHrs;
      end
    end else begin
      Min <= TMin;
      if (THrs == 0) begin
        Hrs <= 12;
      end else begin
        Hrs <= THrs;
      end
    end 
   end 
   alarm a1(
           .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .tpm(TPm), .apm(APm), .buzz(Buzz1)
           );

  
   // generate AMorPM signal (what are the sources for this LED?)/
   always_comb begin
     if (!Alarmset) begin
      AMorPM <= TPm;
     end else begin
      AMorPM <= APm;
     end
   end

  encoder dayLEDEncoder (.dayin(TDay), .dayout(DayLED));

  assign Buzz = Alarmon ? (Buzz | Buzz1) : 0;
endmodule

module encoder(
  input[6:0] dayin,
  output logic [6:0] dayout);

  always_comb begin
  case(dayin)
      7'b0000000 : dayout <= 7'b1000000;
      7'b0000001 : dayout <= 7'b0100000;
      7'b0000010 : dayout <= 7'b0010000;
      7'b0000011 : dayout <= 7'b0001000;
      7'b0000100 : dayout <= 7'b0000100;
      7'b0000101 : dayout <= 7'b0000010;
      7'b0000110 : dayout <= 7'b0000001;
      default : dayout <= 7'b0000000;
    endcase
  end
endmodule