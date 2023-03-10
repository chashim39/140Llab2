// task which drives six consecutive 7=segment displays
// CSE140L  Lab 2 
// $display performs a return / new line feed; $write does not

function string getLEDstr(input logic [9:0] v);
   begin
      automatic string outStr = "";
      for (int i=9; i>=0; i--) begin
	 outStr = v[i] ? {outStr, "# "} : {outStr, "_ "};
      end
      outStr = outStr.substr(0, outStr.len()-2);
      outStr = {"[", outStr, "]"};
      
      return outStr;
   end
endfunction


task display_tb(
		input logic [9:0] leds,
		input [6:0] seg_d,
		seg_e, seg_f, seg_g, seg_h, seg_i
  );
   begin
      

      $display("\n%s", getLEDstr(.v(leds)));
 // segment A
      if(~seg_d[ 0 ]) $write(" _ ");
      else         $write("   ");
      $write(" ");
      if(~seg_e[ 0 ]) $write(" _ ");
      else         $write("   ");
      $write("  ");
      if(~seg_f[ 0 ]) $write(" _ ");
      else         $write("   ");
      $write(" ");
      if(~seg_g[ 0 ]) $write(" _ ");
      else         $write("   ");
      $write("  ");
      if(~seg_h[ 0 ]) $write(" _ ");
      else         $write("   ");
      $write(" ");
      if(~seg_i[ 0 ]) $write(" _ ");
      else         $write("   ");
      $display();

 // segments FGB
      if(~seg_d[ 5 ]) $write("|");
      else $write(" ");
      if(~seg_d[ 6 ]) $write("_");
      else $write(" ");
      if(~seg_d[ 1 ]) $write("|");
      else $write(" ");
      $write(" ");

      if(~seg_e[ 5 ]) $write("|");
      else $write(" ");
      if(~seg_e[ 6 ]) $write("_");
      else $write(" ");
      if(~seg_e[ 1 ]) $write("|");
      else $write(" ");
      $write("  ");

      if(~seg_f[ 5 ]) $write("|");
      else $write(" ");
      if(~seg_f[ 6 ]) $write("_");
      else $write(" ");
      if(~seg_f[ 1 ]) $write("|");
      else $write(" ");
      $write(" ");

      if(~seg_g[ 5 ]) $write("|");
      else $write(" ");
      if(~seg_g[ 6 ]) $write("_");
      else $write(" ");
      if(~seg_g[ 1 ]) $write("|");
      else $write(" ");
      $write("  ");

      if(~seg_h[ 5 ]) $write("|");
      else $write(" ");
      if(~seg_h[ 6 ]) $write("_");
      else $write(" ");
      if(~seg_h[ 1 ]) $write("|");
      else $write(" ");
      $write(" ");

      if(~seg_i[ 5 ]) $write("|");
      else $write(" ");
      if(~seg_i[ 6 ]) $write("_");
      else $write(" ");
      if(~seg_i[ 1 ]) $write("|");
      else $write(" ");
      $display();

  // segments EDC
      if(~seg_d[ 4 ]) $write("|");
      else $write(" ");
      if(~seg_d[3]) $write("_");
      else $write(" ");
      if(~seg_d[ 2 ]) $write("|");
      else $write(" ");
      $write(" ");

      if(~seg_e[ 4 ]) $write("|");
      else $write(" ");
      if(~seg_e[3]) $write("_");
      else $write(" ");
      if(~seg_e[ 2 ]) $write("|");
      else $write(" ");
      $write("  ");

      if(~seg_f[ 4 ]) $write("|");
      else $write(" ");
      if(~seg_f[3]) $write("_");
      else $write(" ");
      if(~seg_f[ 2 ]) $write("|");
      else $write(" ");
      $write(" ");

      if(~seg_g[ 4 ]) $write("|");
      else $write(" ");
      if(~seg_g[3]) $write("_");
      else $write(" ");
      if(~seg_g[ 2 ]) $write("|");
      else $write(" ");
      $write("  ");

      if(~seg_h[ 4 ]) $write("|");
      else $write(" ");
      if(~seg_h[3]) $write("_");
      else $write(" ");
      if(~seg_h[ 2 ]) $write("|");
      else $write(" ");
      $write(" ");

      if(~seg_i[ 4 ]) $write("|");
      else $write(" ");
      if(~seg_i[3]) $write("_");
      else $write(" ");
      if(~seg_i[ 2 ]) $write("|");
      else $write(" ");
      $display();
   end
endtask
