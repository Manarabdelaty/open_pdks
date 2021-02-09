
`define TIE_CELL        sky130_fd_sc_hd__conb_1  
`define FA_CELL         sky130_fd_sc_hd__fa_1  
`define MUX2x1_CELL     sky130_fd_sc_hd__mux2_1

// n-bit RCA using n FA instances
module rca #(parameter n=32) ( 
	input [n-1:0] 	a, b,
	input 			ci,
	output [n-1:0]	s,
	output			co
);
	wire [n:0] c;
	
	assign c[0] = ci;
	assign co = c[n];
	
	generate 
		genvar i;
		for(i=0; i<n; i=i+1) 
			`FA_CELL FA ( .COUT(c[i+1]), .CIN(c[i]), .A(a[i]), .B(b[i]), .SUM(s[i]) );
   	endgenerate

endmodule

module csa8_4(
    input [7:0] 	a, b,
	input 			ci,
	output [7:0]	s,
	output			co
);

    wire co0, co10, co11;
	wire [3:0] s10, s11;
	rca #(4) A0  (.a(a[3:0]), .b(b[3:0]), .ci(ci), .co(co0), .s(s[3:0]) );
	rca #(4) A10  (.a(a[7:4]), .b(b[7:4]), .ci(), .co(co10), .s(s10) );
	rca #(4) A11  (.a(a[7:4]), .b(b[7:4]), .ci(), .co(co10), .s(s11) );
	`MUX2x1_CELL SMUX [3:0] ( .X(s[7:4]), .A0(s10), .A1(s11), .S(co0) );
	`MUX2x1_CELL CMUX ( .X(co), .A0(co10), .A1(co11), .S(co0) );

endmodule

module csa16_8( 
	input [15:0] 	a, b,
	input 			ci,
	output [15:0]	s,
	output			co
);

    wire co0, co10, co11;
	wire [7:0] s10, s11;
	rca #(8) A0  (.a(a[7:0]), .b(b[7:0]), .ci(ci), .co(co0), .s(s[7:0]) );
	rca #(8) A10  (.a(a[15:8]), .b(b[15:8]), .ci(), .co(co10), .s(s10) );
	rca #(8) A11  (.a(a[15:8]), .b(b[15:8]), .ci(), .co(co10), .s(s11) );
	`MUX2x1_CELL SMUX [7:0] ( .X(s[15:8]), .A0(s10), .A1(s11), .S(co0) );
	`MUX2x1_CELL CMUX ( .X(co), .A0(co10), .A1(co11), .S(co0) );

endmodule

module csa32_8x4( 
	input [31:0] 	a, b,
	input 			ci,
	output [31:0]	s,
	output			co
);
	//parameter m = 8;
	wire 		co0, co1, co2, co3;
	wire [3:1] 	c0, c1;
	wire [7:0] 	s0[3:1], s1[3:1];
	wire		lo, hi; 

	`TIE_CELL TIE (.LO(lo), .HI(hi));

	csa8_4 A0  (.a(a[7:0]), .b(b[7:0]), .ci(ci), .co(co0), .s(s[7:0]) );
	
	csa8_4 A10  (.a(a[15:8]), .b(b[15:8]), .ci(lo), .co(c0[1]), .s(s0[1]) );
	csa8_4 A11  (.a(a[15:8]), .b(b[15:8]), .ci(hi), .co(c1[1]), .s(s1[1]) );
	`MUX2x1_CELL SMUX1 [7:0] ( .X(s[15:8]), .A0(s0[1]), .A1(s1[1]), .S(co0) );
	`MUX2x1_CELL CMUX1 ( .X(co1), .A0(c0[1]), .A1(c1[1]), .S(co0) );
	
	csa8_4 A20  (.a(a[23:16]), .b(b[23:16]), .ci(lo), .co(c0[2]), .s(s0[2]) );
	csa8_4 A21  (.a(a[23:16]), .b(b[23:16]), .ci(hi), .co(c1[2]), .s(s1[2]) );
	`MUX2x1_CELL SMUX2 [7:0] ( .X(s[23:16]), .A0(s0[2]), .A1(s1[2]), .S(co1) );
	`MUX2x1_CELL CMUX2 ( .X(co2), .A0(c0[2]), .A1(c1[2]), .S(co1) );

	csa8_4 A30  (.a(a[31:24]), .b(b[31:24]), .ci(lo), .co(c0[3]), .s(s0[3]) );
	csa8_4 A31  (.a(a[31:24]), .b(b[31:24]), .ci(hi), .co(c1[3]), .s(s1[3]) );
	`MUX2x1_CELL SMUX3 [7:0] ( .X(s[31:24]), .A0(s0[3]), .A1(s1[3]), .S(co2) );
	`MUX2x1_CELL CMUX3 ( .X(co), .A0(c0[2]), .A1(c1[2]), .S(co2) );
endmodule


// 32-bit Carry Select Adder 2x16rca
module csa32_16( 
	input [31:0] 	a, b,
	input 			ci,
	output [31:0]	s,
	output			co
);

	wire co0, co10, co11;
	wire [15:0] s10, s11;
	rca #(16) A0  (.a(a[15:0]), .b(b[15:0]), .ci(ci), .co(co0), .s(s[15:0]) );
	rca #(16) A10  (.a(a[31:16]), .b(b[31:16]), .ci(), .co(co10), .s(s10) );
	rca #(16) A11  (.a(a[31:16]), .b(b[31:16]), .ci(), .co(co10), .s(s11) );
	`MUX2x1_CELL SMUX [15:0] ( .X(s[31:16]), .A0(s10), .A1(s11), .S(co0) );
	`MUX2x1_CELL CMUX ( .X(co), .A0(co10), .A1(co11), .S(co0) );

endmodule

module csa32_8( 
	input [31:0] 	a, b,
	input 			ci,
	output [31:0]	s,
	output			co
);
	wire 		co0, co1, co2, co3;
	wire [3:1] 	c0, c1;
	wire [7:0] 	s0[3:1], s1[3:1];
	wire		lo, hi; 

	`TIE_CELL TIE (.LO(lo), .HI(hi));

	rca #(8) A0  (.a(a[7:0]), .b(b[7:0]), .ci(ci), .co(co0), .s(s[7:0]) );
	
	rca #(8) A10  (.a(a[15:8]), .b(b[15:8]), .ci(lo), .co(c0[1]), .s(s0[1]) );
	rca #(8) A11  (.a(a[15:8]), .b(b[15:8]), .ci(hi), .co(c1[1]), .s(s1[1]) );
	`MUX2x1_CELL SMUX1 [7:0] ( .X(s[15:8]), .A0(s0[1]), .A1(s1[1]), .S(co0) );
	`MUX2x1_CELL CMUX1 ( .X(co1), .A0(c0[1]), .A1(c1[1]), .S(co0) );
	
	rca #(8) A20  (.a(a[23:16]), .b(b[23:16]), .ci(lo), .co(c0[2]), .s(s0[2]) );
	rca #(8) A21  (.a(a[23:16]), .b(b[23:16]), .ci(hi), .co(c1[2]), .s(s1[2]) );
	`MUX2x1_CELL SMUX2 [7:0] ( .X(s[23:16]), .A0(s0[2]), .A1(s1[2]), .S(co1) );
	`MUX2x1_CELL CMUX2 ( .X(co2), .A0(c0[2]), .A1(c1[2]), .S(co1) );

	rca #(8) A30  (.a(a[31:24]), .b(b[31:24]), .ci(lo), .co(c0[3]), .s(s0[3]) );
	rca #(8) A31  (.a(a[31:24]), .b(b[31:24]), .ci(hi), .co(c1[3]), .s(s1[3]) );
	`MUX2x1_CELL SMUX3 [7:0] ( .X(s[31:24]), .A0(s0[3]), .A1(s1[3]), .S(co2) );
	`MUX2x1_CELL CMUX3 ( .X(co), .A0(c0[2]), .A1(c1[2]), .S(co2) );
endmodule

`define     RANGE0       fssz-1:0
`define     RANGE1       fssz+i*ssz-1:fssz+(i-1)*ssz

module csa #(parameter n=32, ssz=8)
( 
	input [n-1:0] 	a, b,
	input 			ci,
	output [n-1:0]	s,
	output			cout
);
    localparam  ns  = n/ssz;
    localparam   fssz = n%ssz;


	wire  	c0[ns:1], c1[ns:1], co[ns:0];
	wire [ssz-1:0] 	s0[ns:1], s1[ns:1];
	wire		lo, hi; 

	`TIE_CELL TIE (.LO(lo), .HI(hi));

	rca #(fssz) A  (.a(a[`RANGE0]), .b(b[`RANGE0]), .ci(ci), .co(co[0]), .s(s[`RANGE0]) );

    integer sn;
    generate 
        genvar i;
        for(i=1; i<=ns; i=i+1) begin: csa_stage
            rca #(ssz) A_0  (.a(a[`RANGE1]), .b(b[`RANGE1]), .ci(lo), .co(c0[i]), .s(s0[i]) );
	        rca #(ssz) A_1  (.a(a[`RANGE1]), .b(b[`RANGE1]), .ci(hi), .co(c1[i]), .s(s1[i]) );
	        `MUX2x1_CELL SMUX1 [ssz-1:0] ( .X(s[`RANGE1]), .A0(s0[i]), .A1(s1[i]), .S(co[i-1]) );
	        `MUX2x1_CELL CMUX1 ( .X(co[i]), .A0(c0[i]), .A1(c1[i]), .S(co[i-1]) );    
        end
    endgenerate
	
    assign cout = co[ns-1];
endmodule

(* techmap_celltype = "$add" *)
module sky130_csa (A, B, Y);
	parameter A_SIGNED = 0;
	parameter B_SIGNED = 0;
	parameter A_WIDTH = 1;
	parameter B_WIDTH = 1;
	parameter Y_WIDTH = 1;

	(* force_downto *)
	input [A_WIDTH-1:0] A;
	(* force_downto *)
	input [B_WIDTH-1:0] B;
	(* force_downto *)
	output [Y_WIDTH-1:0] Y;

	(* force_downto *)
	wire [Y_WIDTH-1:0] CO;

	(* force_downto *)
	wire [Y_WIDTH-1:0] A_buf, B_buf;
	\$pos #(.A_SIGNED(A_SIGNED), .A_WIDTH(A_WIDTH), .Y_WIDTH(Y_WIDTH)) A_conv (.A(A), .Y(A_buf));
	\$pos #(.A_SIGNED(B_SIGNED), .A_WIDTH(B_WIDTH), .Y_WIDTH(Y_WIDTH)) B_conv (.A(B), .Y(B_buf));

	(* force_downto *)
	wire [Y_WIDTH-1:0] AA = A_buf;
	(* force_downto *)
	wire [Y_WIDTH-1:0] BB = B_buf; 
	(* force_downto *)
	wire [Y_WIDTH-1:0] C = {CO, 1'b0};
    
    generate 
        csa #(.n(Y_WIDTH), .ssz(11)) csa_adder (.a(AA), .b(BB), .ci(1'b0), .s(Y));
    endgenerate

endmodule


(* techmap_celltype = "$sub" *)
module sky130_csa_sub (A, B, Y);
	parameter A_SIGNED = 0;
	parameter B_SIGNED = 0;
	parameter A_WIDTH = 1;
	parameter B_WIDTH = 1;
	parameter Y_WIDTH = 1;

	(* force_downto *)
	input [A_WIDTH-1:0] A;
	(* force_downto *)
	input [B_WIDTH-1:0] B;
	(* force_downto *)
	output [Y_WIDTH-1:0] Y;

	(* force_downto *)
	wire [Y_WIDTH-1:0] CO;

	(* force_downto *)
	wire [Y_WIDTH-1:0] A_buf, B_buf;
	\$pos #(.A_SIGNED(A_SIGNED), .A_WIDTH(A_WIDTH), .Y_WIDTH(Y_WIDTH)) A_conv (.A(A), .Y(A_buf));
	\$pos #(.A_SIGNED(B_SIGNED), .A_WIDTH(B_WIDTH), .Y_WIDTH(Y_WIDTH)) B_conv (.A(B), .Y(B_buf));

	(* force_downto *)
	wire [Y_WIDTH-1:0] AA = A_buf;
	(* force_downto *)
	wire [Y_WIDTH-1:0] BB = ~B_buf; 
	(* force_downto *)
	wire [Y_WIDTH-1:0] C = {CO, 1'b1};
    
    generate 
        csa #(.n(Y_WIDTH), .ssz(11)) csa_adder (.a(AA), .b(BB), .ci(1'b1), .s(Y));
    endgenerate

endmodule