// CSE140L  
// see Structural Diagram in Lab2 Part 3assignment writeup
// fill in missing connections and parameters
module top_level_lab2_part3(
  input Reset,
        Timeset,    // manual buttons
        Alarmset,   //  (five total)
        Minadv,
        Hrsadv,
        Dayadv,
        Monthadv,
        Dateadv,
        Alarmon,
        Pulse,      // assume 1/sec.
        DorT,
// 6 decimal digit display (7 segment)
  output[6:0] S1disp, S0disp,       // 2-digit  display
              MD1disp, MD0disp,    // 2 digit display  minutes/date
              HM1disp, HM0disp,     // 2-digit display hours/month
              DayLED,             // day of week LED
   // date display
  output logic AMorPM,              
  output logic Buzz);            // alarm sounds


//... Fill in with part3 implementation
  logic [6:0] TSec, TMin, THrs, TDay, TDate, TMonth;   // time 
  logic       TPm;                // time PM
  logic [6:0] AMin, AHrs;         // alarm setting
  logic       APm;                // alarm PM
   
     
  logic[6:0] Min, Hrs, Day, Date, Month;                     // drive Min and Hr displays
  logic[6:0] MDDisplays, HMDisplays, tempS0disp, tempS1disp;     //temp 2-digit display
  logic Smax, Mmax, Hmax, Daymax, DateMax, MonthMax,         // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, TPmen, AMen, AHen, AHmax, AMmax, APmen, Dayen, Dateen, Monthen;    // respective counter enables
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
    .clk(Pulse), .rst(Reset), .en(Dayen), .ct_out(TDay), .z(Daymax) 
   );

  ct_mod_D DateCount(
    .clk(Pulse), .rst(Reset), .en(Dateen), .TMo0(TMonth), .ct_out(TDate), .z(DateMax)
  );
  
  ct_mod_N #(.N(12)) MonthCount(
    .clk(Pulse), .rst(Reset), .en(Monthen), .ct_out(TMonth), .z(MonthMax)
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
    .Segment1  (tempS1disp),
    .Segment0  (tempS0disp)
   );

   lcd_int Mdisp(
    .bin_in    (MDDisplays) ,
    .Segment1  (MD1disp),
    .Segment0  (MD0disp)
    );

  lcd_int Hdisp(
    .bin_in    (HMDisplays),
    .Segment1  (HM1disp),
    .Segment0  (HM0disp)
    );

  // assign MDDisplays[6:0] = DorT ? Date: Min;  //broken
  // assign HMDisplays[6:0] = DorT ? Month: Hrs;

  displayEncoder de1(.DorT(DorT), .Min(Min), .Hrs(Hrs), .Date(Date), .Month(Month), .MDDisplays(MDDisplays), .HMDisplays(HMDisplays));

  secondEncoder s1(.DorT(DorT), .tempS0disp(tempS0disp), .tempS1disp(tempS1disp), .S1disp(S1disp), .S0disp(S0disp));
  

   // counter enable control logic
   // create some logic for the various *en signals (e.g. TMen)
  always_comb begin
    if (Timeset) begin
      TMen <= Minadv;
      THen <= Hrsadv;
      TPmen <= (Hmax & Hrsadv);
      Dayen <= Dayadv;
      Dateen <= Dateadv;
      Monthen <= Monthadv;
    end else begin
      TMen <= Smax;
      THen <= (Mmax & Smax);
      TPmen <= (Hmax & Mmax & Smax);
      Dayen <= (Hmax & Mmax & Smax & TPm);
      Dateen <= (Hmax & Mmax & Smax & TPm);
      Monthen <= (Hmax & Mmax & Smax & TPm & DateMax);
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
    
    Month <= TMonth + 1;
    Date <= TDate + 1;
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

  dayEncoder dayLEDEncoder (.dayin(TDay), .dayout(DayLED));

  assign Buzz = Alarmon ? (Buzz | Buzz1) : 0;
endmodule

module dayEncoder(
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

module secondEncoder(
  input DorT,
  input[6:0] tempS1disp, tempS0disp,
  output logic [6:0] S1disp, S0disp);

  always_comb begin
    if (DorT) begin
      S1disp <= 7'b1111111;
      S0disp <= 7'b1111111;
    end else begin
      S1disp <= tempS1disp;
      S0disp <= tempS0disp;
    end
  end
endmodule

module displayEncoder(
  input DorT,
  input[6:0] Min, Hrs, Date, Month,
  output logic [6:0] MDDisplays, HMDisplays);

  always_comb begin
    if (DorT) begin
      MDDisplays = Date;
      HMDisplays = Month;
    end else begin
      MDDisplays = Min;
      HMDisplays = Hrs;
    end
  end
endmodule

