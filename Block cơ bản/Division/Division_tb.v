`define N_TESTS 100000

module division_tb;

	reg clk = 0;
	reg [31:0] a;
	reg [31:0] b;
	
	wire [31:0] res;
	wire exception;

	reg [31:0] expected_res;

	reg [95:0] testVector [`N_TESTS-1:0];

	reg test_stop_enable;

	integer mcd;
	integer test_n = 0;
	integer pass   = 0;
	integer error  = 0;

	division DUT(a,b,exception,res);

	always #5 clk = ~clk;

	initial  
	begin 
		$readmemh("Test.txt", testVector);
		mcd = $fopen("Error_Results.txt");
	end 

	always @(posedge clk) 
	begin
			{a,b,expected_res} = testVector[test_n];
			test_n = test_n + 1'b1;

			#2;
			if (res[31:12] == expected_res[31:12])
				begin
					//$fdisplay (mcd,"TestPassed Test Number -> %d",test_n);
					pass = pass + 1'b1;
				end

			if (res[31:12] != expected_res[31:12])
				begin
					$fdisplay (mcd,"Test Failed Expected res = %h,Obtained res = %h,Test Number-> %d",expected_res,res,test_n);
					$display ("Zero Division Error or some other error",mcd,"Test Failed Expected res = %h,Obtained res = %h,Test Number-> %d",expected_res,res,test_n);
					error = error + 1'b1;
				end
			
			if (test_n >= `N_TESTS) 
			begin
				$fdisplay(mcd,"Completed %d tests, %d passes and %d fails.", test_n, pass, error);
				test_stop_enable = 1'b1;
			end
	end

always @(posedge test_stop_enable)
begin
$fclose(mcd);
$finish;
end

endmodule
