 `timescale 1ns / 1ps

module pid_control2(
    input  clk,
    input  rst_n,
    input  [15:0] setpoint,
    input  [15:0] feedback,
    input  [15:0] Kp,
    input  [15:0] Ki,
    input  [15:0] Kd,
    input  [15:0] clk_times,
    output reg [15:0] control_signal
);
  
    // Internal signals
    
    reg [15:0] prev_error = 16'h0000;
    reg [15:0] integral = 32'h00000000;
    reg [15:0] derivative = 16'h0000;
    
    // Clock COUNT for sampling rate
    reg [15:0] clk_count = 0;
    reg sampling_flag = 0;

    always @(posedge clk or negedge rst_n) begin
    //$display("Clock trigered");
        if (~rst_n)
            clk_count <= 16'h0000;
        else if (clk_count == clk_times) begin // clk_prescaler determines the sampling rate, thus sampling rate would be clk freq/clk_prescaler
            clk_count <= 16'h0000;
            
            sampling_flag <= 1;
        end else begin
            clk_count <= clk_count + 1;
            sampling_flag <= 0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
    
        if (~rst_n) begin
            // Reset logic generally specific to application
        end 
        else if (sampling_flag) begin
                      
            // PID Calculation
            integral <=(Ki * (setpoint - feedback));//error*dt(but at 1 clock cycle)
            derivative <= Kd * ((setpoint - feedback) - prev_error);//(error-prevoius)*dt rate of change of error
            // Calculate control signal
            control_signal = (Kp * (setpoint - feedback)) + integral + derivative; 
            prev_error <= (setpoint - feedback);// Update previous error term to feed it for derrivative term.
        end
    end

endmodule
