library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_multiplier is
    -- Testbench entities do not have ports
end entity tb_multiplier;

architecture sim of tb_multiplier is

    -- Component Declaration for the Unit Under Test (UUT)
    component multiplier
        port(
            a_signed   : in  signed(3 downto 0);
            b_unsigned : in  unsigned(7 downto 0);
            result_out : out signed(15 downto 0)
        );
    end component;

    -- Signals to connect to the UUT
    signal a_in  : signed(3 downto 0)   := (others => '0');
    signal b_in  : unsigned(7 downto 0) := (others => '0');
    signal r_out : signed(15 downto 0);

    -- Simulation delay constant
    constant T_DELAY : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : multiplier
        port map(
            a_signed   => a_in,
            b_unsigned => b_in,
            result_out => r_out
        );

    -- Stimulus Process
    stim_proc : process
        variable v_a_int    : integer;
        variable v_b_int    : integer;
        variable v_expected : integer;
    begin
        report "Starting Exhaustive Simulation..." severity note;

        -- Loop through all possible values for A (Signed 4-bit: -8 to 7)
        for i in -8 to 7 loop
            v_a_int := i;
            a_in    <= to_signed(v_a_int, 4);

            -- Loop through all possible values for B (Unsigned 8-bit: 0 to 255)
            for j in 0 to 255 loop
                v_b_int := j;
                b_in    <= to_unsigned(v_b_int, 8);

                -- Wait for the result to propagate
                wait for T_DELAY;

                -- Calculate the expected result theoretically
                v_expected := v_a_int * v_b_int;

                -- Self-Checking: Compare UUT output with expected integer calculation
                assert to_integer(r_out) = v_expected
                report "Error mismatch! " & "A: " & integer'image(v_a_int) & " * B: " & integer'image(v_b_int) & " = Expected: " & integer'image(v_expected) & " | Got: " & integer'image(to_integer(r_out))
                severity error;

            end loop;
        end loop;

        -- If the simulation reaches this point without assertions stopping it
        report "Simulation Completed Successfully! All 4096 cases passed." severity note;
        wait;                           -- Stop the process indefinitely
    end process;

end architecture sim;
