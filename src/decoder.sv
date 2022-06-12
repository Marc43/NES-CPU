module decoder_t
(
    input logic clk_i,
    input logic rstn_i,

    input logic [BYTE-1:0] opcode_i,
    input logic [(2*BYTE)-1:0] data_i,

    output reg_id_t reg_addr_o,
    output logic we_o

);

    /*
     * The decoder is divided into the
     * groups strategy defined here:
     *
     *  - https://llx.com/Neil/a2/opcodes.html
     *
     */

    addressing_mode_t addressing_mode;
    reg_id_t reg_addr;
    logic we;

    always_comb begin : decode_opcode
        if (!rstn_i) begin
            we_o = 0;
        end
        else begin
            // Group one
            if (opcode_i[`C_END:`C_START] == 2'b01) begin
                we = 1;
                reg_addr = A_REG; 

                case (opcode_i[`A_END:`A_START]) 
                    ORA: begin
                        // TODO Set ALU op
                    end
                    AND: begin
                        // TODO Set ALU op
                    end
                    EOR: begin
                        // TODO Set ALU op
                    end
                    ADC: begin
                        // TODO Set ALU op
                    end
                    STA: begin
                        // TODO Set ALU op
                    end
                    LDA: begin
                        // TODO Set ALU op
                    end
                    CMP: begin
                        we = 0;
                        // TODO Set ALU op
                    end
                    SBC: begin
                        // TODO Set ALU op
                    end
                endcase
                
                case (opcode_i[`B_END:`B_START])
                    G1_IND1_X:  addressing_mode = INDIRECT1_X;
                    G1_ZPG:     addressing_mode = ZERO_PAGE;
                    G1_IMM:     addressing_mode = IMMEDIATE;       
                    G1_ABS:     addressing_mode = ABSOLUTE;       
                    G1_IND2_Y:  addressing_mode = INDIRECT2_Y;
                    G1_ZPG_X:   addressing_mode = ZERO_PAGE_X;
                    G1_ABS_Y:   addressing_mode = ABSOLUTE_Y;
                    G1_ABS_X:   addressing_mode = ABSOLUTE_X;  
                endcase            
            end
            // Group two
            else if (opcode_i[`C_END:`C_START] == 2'b10) begin

            end
            // Group three
            else if (opcode_i[`C_END:`C_START] == 2'b00) begin

            end
        end

        always_comb begin : compute_data_to_operate
            if (!rstn_i) begin

            end
            else begin
                // Depending on the addressing mode
                // Compute the data that will be 
                // used by the datapath
                //
                // The most cycle consuming case will be the
                // indirect. Not really sure how that will work.

            end
        end


    end

endmodule : decoder_t
