`timescale 1ns/10ps
module dec_i2c (
    input logic clk,        // Clock 10ns
    input logic reset,      // Reset assíncrono ativo alto
    input logic sda,
    input logic scl,
    input logic pronto,  // Entrada de dados
    input logic [6:0] endereco_local,
    output logic [6:0] endereco_recebido,  // Seleção do registrador
    output logic operacao,
    output logic escrita,
    output logic stop        // Habilita gravação de dados   
);

    // Registradores de 8 bits
    logic [6:0] addr_ff = 0;

    assign endereco_recebido = addr_ff;

    reg [7:0] state = 1;
    
    // State encodings
    parameter [7:0]
    s1 = 7'b0000001,
    s2 = 7'b0000010,
    s3 = 7'b0000100,
    s4 = 7'b0001000,
    s5 = 7'b0010000,
    s6 = 7'b0100000,
    s7 = 7'b1000000;

    logic start_cond = 0, stop_cond, sobe_scl = 0;

    logic sobe_scl_aux = 0, start_cond_aux = 0;

    always @(negedge sda) begin      
        if (pronto) begin
            if (scl) begin
                start_cond_aux <= 1;
            end
        end
    end

    always @(start_cond or stop_cond) begin
        if (start_cond) operacao <= 1;
        if (stop_cond) begin 
            operacao <=0;
            stop <=1;
        end else stop <=0;    
    end

    always @(posedge scl) begin
        if (operacao) begin
        case (state)
            s1: begin
            addr_ff[6] <= sda;
            state <= s2;
            end
            s2: begin
            addr_ff[5] <= sda;
            state <= s3;
            end
            s3: begin
            addr_ff[4] <= sda;
            state <= s4;
            end
            s4: begin
            addr_ff[3] <= sda;
            state <= s5;
            end
            s5: begin
            addr_ff[2] <= sda;
            state <= s6;
            end
            s6: begin
            addr_ff[1] <= sda;
            state <= s7;
            end
            s7: begin
            addr_ff[0] <= sda;
            operacao <= 0;
            state <= s1;
            end
            default:
            state <= s1;
        endcase
        end
        sobe_scl_aux = 1;

    end

    always @(posedge clk) begin
        if (sobe_scl_aux) begin
            sobe_scl <=1;
            sobe_scl_aux <=0;
        end else sobe_scl <=0;

        if (start_cond_aux) begin
            start_cond <=1;
            start_cond_aux <=0;
        end else start_cond <=0;
    end

    // always_ff @(negedge reset) begin
    //     if (!reset) begin
    //         regs <= '{default: '0};
    //     end
    // end
    

endmodule