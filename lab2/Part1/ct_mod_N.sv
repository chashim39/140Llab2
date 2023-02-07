// CSE140L  
// What does this do? 
// When does "z" go high? 
// if rst -> time unit set to 0
// if enable -> time unit is equal to (current time unit + 1) modulo max of time unit 60 or 13
// else -> keep time unit the same
// z = carry out -> set z to 1 if 59 or 12, allows for next digit to roll over at the same time as the previous digit, 0 if next doesnt need to be rolled over as well
module ct_mod_N #(parameter N=60)(
  input clk, rst, en,
  output logic[6:0] ct_out,
  output logic      z);

  always_ff @(posedge clk)
    if(rst)
      ct_out <= 0;
    else if(en)
      ct_out <= (ct_out+'b1)%N;	  // modulo operator
    else
      ct_out <= ct_out;
   
  always_comb z = ct_out==(N-'b1);   // always @(*)   // always @(ct_out)

endmodule



