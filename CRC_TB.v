`timescale 1ns/1ps
module CRC_TB ();

/************************ Parameter ************************/
parameter Register_WD = 8 ;
parameter Clock_PERIOD = 100 ;
parameter Test_Cases = 10 ;


/************************ TB signals ************************/
reg   Active_TB,DATA_TB;
reg   CLK_TB,RST_TB;
wire  Valid_TB,CRC_TB;


/************************ Memories ************************/
reg  [Register_WD-1:0] DATA_h      [Test_Cases-1:0];
reg  [Register_WD-1:0] Expec_Out_h [Test_Cases-1:0];


/************************ Clock Generator ************************/
always #(Clock_PERIOD/2)  CLK_TB = ~ CLK_TB;


/***************************************** ************ *****************************************/
/***************************************** Instantation *****************************************/
/***************************************** ************ *****************************************/
CRC #( .DATA_WD(Register_WD) )  DUT
(
.CLK(CLK_TB),
.RST(RST_TB),
.DATA(DATA_TB),
.Active(Active_TB),
.CRC(CRC_TB),
.Valid(Valid_TB)
);

/***************************************** *********** *****************************************/
/***************************************** * Initial * *****************************************/
/***************************************** *********** *****************************************/
integer   Operation ;

initial
  begin
   $dumpfile("CRC_DUMP.vcd") ;       
   $dumpvars; 
   
   $readmemh("DATA_h.txt", DATA_h);
   $readmemh("Expec_Out_h.txt", Expec_Out_h);

/************************ Initialize ************************/
   Initialize() ;
   RESET () ; //reset

/************************ Test Cases ************************/
 for (Operation=0; Operation<Test_Cases; Operation=Operation+1)
  begin
   DATA_IN(DATA_h[Operation]) ;   
   CRC_OUT(Expec_Out_h[Operation],Operation) ;   
   RESET () ;        
  end

   #100
   $finish ;
  end


/***************************************** ***** *****************************************/
/***************************************** Tasks *****************************************/
/***************************************** ***** *****************************************/

/************************ Signals Initialization ************************/
task Initialize ;
  begin
   CLK_TB  = 'b0;  
   RST_TB =  'b0;
   Active_TB = 'b0;
   DATA_TB =  'b0;
  end
endtask

/************************ RESET ************************/
task RESET ;
  begin
    RST_TB =  'b1;
   #(Clock_PERIOD)
    RST_TB  = 'b0;
   #(Clock_PERIOD)
    RST_TB  = 'b1;
  end
endtask

/************************ DATA INPUT ************************/
task DATA_IN ;
 input [Register_WD-1:0] data_in;
 integer i ;
  begin
    #(Clock_PERIOD/2);
    Active_TB = 1'b1;
    for(i=0; i<Register_WD; i=i+1)
       begin
         DATA_TB = data_in[i];
         #(Clock_PERIOD);  
       end
   Active_TB = 1'b0; 
  end
endtask

/************************ CRC OUTPUT ************************/
task CRC_OUT ;
 input [Register_WD-1:0] Expec_Out_h ;
 input integer           Oper_Num ; 

 integer i ;
 
 reg [Register_WD-1:0]  crc_out ;

 begin  
    @(posedge Valid_TB)
    for(i=0; i<Register_WD; i=i+1)
       begin
        #(Clock_PERIOD) ;
        crc_out[i] = CRC_TB ;
       end
   if(crc_out == Expec_Out_h) 
     begin
       $display("Test Case %d is succeeded",Oper_Num+1);
     end
   else
     begin
       $display("Test Case %d is failed", Oper_Num+1);
     end
 end
endtask
/***********************************************************************************/
/***********************************************************************************/
/***********************************************************************************/
endmodule 