module CRC #(parameter DATA_WD  = 8) (
input  wire  DATA,Active,
input  wire  CLK,RST,
output reg   CRC,Valid
);

reg [7:0] Register;

parameter  [7:0] Taps = 8'b01000100; // flag @ 1 (EVENT)
localparam [7:0] SEED = 8'hD8;

integer I;

wire FeedBack;
assign FeedBack = DATA ^ Register[0];

reg  [5:0] counter =0; // up to 32 bits
reg        counter_end=0;


always @ (posedge CLK , negedge RST)
  begin 
    if(!RST)
       begin
         Register <= SEED;
	 CRC <= 1'b0;
	 Valid <= 1'b0;
         counter <= 'b0;
         counter_end <= 'b1;
       end

    else if(Active)
       begin
 	 Valid <= 1'b0;  
         counter <= 'b0;
         counter_end <= 'b0;      
         Register[7] <= FeedBack;
          for (I=6; I>=0; I=I-1)
           begin 
	    if (Taps[I] == 1) 
	      Register[I] <= Register[I+1] ^ FeedBack; 
	    else 
	      Register[I] <= Register[I+1];
           end
            /*
	Register[7] <= Feedback;
        Register[6] <= Register[7] ^ Feedback;
	Register[5] <= Register[6] 
	Register[4] <= Register[5]
	Register[3] <= Register[4]
	Register[2] <= Register[3] ^ Feedback;
	Register[1] <= Register[2]
	    */
       end

    else if(!counter_end)
       begin
	 {Register[6:0],CRC} <= Register ;
	 Valid <= 1'b1;
	/*
	CRC <= Register[0]
	Register[0] <= Register[1]
	Register[1] <= Register[2]
	Register[2] <= Register[3]
	Register[3] <= Register[4]
	Register[4] <= Register[5]
	Register[5] <= Register[6]
	Register[6] <= Register[7]
	*/
         if(counter == DATA_WD)
            begin
             counter_end <= 'b1;
	     Valid <= 1'b0;
            end
         else 
             counter = counter +'b1;
       end
    else 
        Valid <= 1'b0;
  end
endmodule 