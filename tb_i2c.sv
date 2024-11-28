`timescale 1ns/10ps
module tb;
reg sda, scl;
reg [7:0] dado;
logic clk, pronto;

dec_i2c dut(.clk(clk), .reset(), .sda(sda), .scl(scl), .pronto(pronto),
 .endereco_local(dado), .endereco_recebido(), .operacao(), .escrita(), .stop());

// Geração do clock
initial clk = 0;
always #5 clk = ~clk; // Clock com período de 10 ns

// Geração do scl
initial scl = 0;
always #50 scl = ~scl; // Clock com período de 10 ns

initial begin
    pronto = 1;
    dado = 7'b1001000;
    sda = 1;
    #60;
    sda = 0;
    #10;
    for (int i = 6; i >= 0; i--) begin
        sda = dado[i];          // Configura bit no sda
        #100;
    end
    sda = 0;
    #10;
    sda = 1;
    #100;
    $finish();
end

endmodule
