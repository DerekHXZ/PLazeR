/*
 * Seven-segment LED emulator
 *
 * Stephen A. Edwards, Columbia University
 */

module VGA_LED_Emulator(
 input logic 	    clk50, reset,
 input logic [614399:0] image,
 output logic [7:0] VGA_R, VGA_G, VGA_B,
 output logic 	     VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);
 
byte im[320*240];
byte blurred_im[320*240];

/*
 * 640 X 480 VGA timing for a 50 MHz clock: one pixel every other cycle
 * 
 * HCOUNT 1599 0             1279       1599 0
 *             _______________              ________
 * ___________|    Video      |____________|  Video
 * 
 * 
 * |SYNC| BP |<-- HACTIVE -->|FP|SYNC| BP |<-- HACTIVE
 *       _______________________      _____________
 * |____|       VGA_HS          |____|
 */
   // Parameters for hcount
   parameter HACTIVE      = 11'd 1280,
             HFRONT_PORCH = 11'd 32,
             HSYNC        = 11'd 192,
             HBACK_PORCH  = 11'd 96,   
             HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC + HBACK_PORCH; // 1600
   
   // Parameters for vcount
   parameter VACTIVE      = 10'd 480,
             VFRONT_PORCH = 10'd 10,
             VSYNC        = 10'd 2,
             VBACK_PORCH  = 10'd 33,
             VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC + VBACK_PORCH; // 525

   logic [10:0]			     hcount; // Horizontal counter
                                             // Hcount[10:1] indicates pixel column (0-639)
   logic 			     endOfLine;
   
   always_ff @(posedge clk50 or posedge reset)
     if (reset)          hcount <= 0;
     else if (endOfLine) hcount <= 0;
     else  	         hcount <= hcount + 11'd 1;

   assign endOfLine = hcount == HTOTAL - 1;

   // Vertical counter
   logic [9:0] 			     vcount;
   logic 			     endOfField;
   
   always_ff @(posedge clk50 or posedge reset)
     if (reset)          vcount <= 0;
     else if (endOfLine)
       if (endOfField)   vcount <= 0;
       else              vcount <= vcount + 10'd 1;

   assign endOfField = vcount == VTOTAL - 1;

   // Horizontal sync: from 0x520 to 0x5DF (0x57F)
   // 101 0010 0000 to 101 1101 1111
   assign VGA_HS = !( (hcount[10:8] == 3'b101) & !(hcount[7:5] == 3'b111));
   assign VGA_VS = !( vcount[9:1] == (VACTIVE + VFRONT_PORCH) / 2);

   assign VGA_SYNC_n = 1; // For adding sync to video signals; not used for VGA
   
   // Horizontal active: 0 to 1279     Vertical active: 0 to 479
   // 101 0000 0000  1280	       01 1110 0000  480
   // 110 0011 1111  1599	       10 0000 1100  524
   assign VGA_BLANK_n = !( hcount[10] & (hcount[9] | hcount[8]) ) &
			!( vcount[9] | (vcount[8:5] == 4'b1111) );   

   /* VGA_CLK is 25 MHz
    *             __    __    __
    * clk50    __|  |__|  |__|
    *        
    *             _____       __
    * hcount[0]__|     |_____|
    */
   assign VGA_CLK = hcount[0]; // 25 MHz clock: pixel latched on rising edge
	
	genvar i, j;
	generate
	begin
		for(i = 0; i < 320; i+=1) begin: init_i
			for(j = 0; j < 240; j+=1) begin: init_j
			always_comb begin
				im[i*j] <= image[i*j*8+7 : i*j*8];
			end
		end
		end
		end
	endgenerate
	
	logic [19:0] index;
	assign index = vcount * hcount[10:1];
	
	
	//Gaussian blur
	genvar di, dj;
	generate
	begin
		for(i = 0; i < 320; i+=1) begin: init_i
			for(j = 0; j < 240; j+=1) begin: init_j
				real val = 0, wsum = 0;
				for(di = -7; di <= 7; di+=1) begin: init_di
					for(dj = -7; dj <= 7; dj+=1) begin: init_dj
						int x = i + di, y = j + dj;
						always_comb begin
						if (x < 0) x = 0;
						if (x > 319) x = 319;
						if (y < 0) y = 0;
						if (y > 319) y = 319;
						end
						
						int dsq = di * di + dj * dj;
						real w = exp(-dsq / 2.0) / 6.28;
						
						always_comb begin
						val += im[index] * w;
						wsum += w;
						end
					end
				end
						
				always_comb begin
					blurred_im[index] <= round(val/wsum);
				end
			end
		end
	end
	endgenerate
	
	
	logic 			     pixel;
	assign pixel = (vcount < 240) && (hcount[10:1] < 320) && (blurred_im[index] >= 128);
   
   always_comb begin
      {VGA_R, VGA_G, VGA_B} = {8'h0, 8'h0, 8'h0}; // Black
      if (pixel)
			{VGA_R, VGA_G, VGA_B} = {8'h00, 8'h00, 8'hff}; // Blue
   end
   
endmodule
