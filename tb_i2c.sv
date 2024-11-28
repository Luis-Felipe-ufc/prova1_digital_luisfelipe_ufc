`timescale 1ns/10ps
module tb;
reg sda, scl;
reg [7:0] dado;
logic clk, pronto;
parameter SCL_PERIOD = 100;

dec_i2c dut(.clk(clk), .reset(), .sda(sda), .scl(scl), .pronto(pronto),
 .endereco_local(dado), .endereco_recebido(), .operacao(), .escrita(), .stop());

// Geração do clock
initial clk = 0;
always #5 clk = ~clk; // Clock com período de 10 ns

initial
begin
        pronto = 1;
        sda = 1;  // sinal do i2c
        scl = 0;  // sinal do i2c
        dado = 7'b1001000; // Exemplo de dado para envio
        #(SCL_PERIOD *2);
        scl = 1;
        #(SCL_PERIOD / 2);
        scl = 0;
        #(SCL_PERIOD / 2);
        scl = 1;
        
        // START condition (sda: HIGH -> LOW quando scl está em HIGH)
        #(SCL_PERIOD / 2);
        sda = 0;
        #(SCL_PERIOD / 2);
        
        // Envio do byte de dados (*8* (7) bits, MSB primeiro)
        for (int i = 6; i >= 0; i--) begin
            scl = 0;                     // Baixa scl para preparar dados
            #(SCL_PERIOD / 3);
            
            sda = dado[i];          // Configura bit no sda
            #(SCL_PERIOD / 3);
            scl = 1;                     // Pulso de clock
            #(SCL_PERIOD / 3);
        end
        
        // Bit de ACK/NACK (do slave)
        scl = 0;                         // Baixa scl para preparar o ACK
        #(SCL_PERIOD / 3);
        sda = 0;                       // ACK/NACK no sda
        #(SCL_PERIOD / 3);
        scl = 1;                         // Pulso de clock para ACK
        #(SCL_PERIOD / 3);
        scl = 0;

        // STOP condition (sda: LOW -> HIGH quando scl está em HIGH)
        sda = 0;
        #(SCL_PERIOD / 2);
        scl = 1;
        #(SCL_PERIOD / 2);
        sda = 1;
    
        #(SCL_PERIOD *5);
        // Finalização da simulação
        $finish;

end


initial
begin
    $display("Comecou o teste");
    $dumpfile("test.vcd");
    $dumpvars(0,tb);    
    $timeformat(-9, 2, " ns", 20);
    end

endmodule
