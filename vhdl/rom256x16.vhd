library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;


entity rom256x16 is
  port (
    clk: in std_logic;
    A: in std_logic_vector(8-1 downto 0);
    D: out std_logic_vector(16-1 downto 0)
  );
end entity rom256x16;


architecture behav of rom256x16 is
begin
  process (clk)
  begin
    if rising_edge(clk) then
       case A is
      ----- add numbers from 1 to 10 and store sum at mem[0]
      -- when x"01" => D <= x"7"&o"1"&o"000"; -- sum
      -- when x"02" => D <= x"7"&o"2"&o"001";
      -- when x"03" => D <= x"7"&o"3"&o"012"; -- end point
      -- when x"04" => D <= x"1"&o"121"&o"0";
      -- when x"05" => D <= x"9"&o"1000";
      -- when x"06" => D <= x"A"&o"23"&o"44";
      -- when x"07" => D <= x"2"&o"22"&o"01";
      -- when x"08" => D <= x"F"&o"0004";

      -- calc sum from 1 to 10 and store ans to M[0]
       --  when x"00" => D <= "0111000000000000";
       --  when x"01" => D <= "0111001000000001";
       --  when x"02" => D <= "0111010000001010";
       --  when x"03" => D <= "0001000001000000";
       --  when x"04" => D <= "1010001010000111";
       --  when x"05" => D <= "0010001001000001";
       --  when x"06" => D <= "1111000000000011";
       --  when x"07" => D <= "1001000000000000";
       --  when others => D <= x"0000";

         -- calc 3 to power 4 and store ans to M[0]
       --   when x"00" => D <= "0111000000000001";
       --   when x"01" => D <= "0111001000000011";
       --   when x"02" => D <= "0111010000000100";
       --   when x"03" => D <= "0111011000000001";
       --   when x"04" => D <= "1100010011001000";
       --   when x"05" => D <= "0001000001000010";
       --   when x"06" => D <= "0011010010000001";
       --   when x"07" => D <= "1111000000000100";
       --   when x"08" => D <= "1001000000000000";
       --   when others => D <= x"0000";

         -- sqrt of 200 for ex
    --     when x"00" => D <= "0111000011001000"; -- sqrt
   --   when x"01" => D <= "1001000000000000";
   --   when x"02" => D <= "1000000000000000";
   --   when x"03" => D <= "0111001000010100";
   --   when x"04" => D <= "0111010001100100";
   --   when x"05" => D <= "0111110000000010";
   --   when x"06" => D <= "0001010010011010";
   ----   when x"07" => D <= "0001011000011001";
   ----   when x"08" => D <= "0001011110011011";
   ----   when x"09" => D <= "0001011010011011";
   ----   when x"0a" => D <= "0001010011010001";
    --  when x"0b" => D <= "1001010000000001";
    --  when x"0c" => D <= "0011001001000001";
    --  when x"0d" => D <= "1110000000001111";
    --  when x"0e" => D <= "1111000000000110";
    --  when others => D <= x"0000";
    --
      -- circle area
when x"00" => D <= "0111000000000011";
when x"01" => D <= "1001000000000000";
when x"02" => D <= "1000000000000000";
when x"03" => D <= "0111001000010110";
when x"04" => D <= "0111010000000111";
when x"05" => D <= "0001000000000010";
when x"06" => D <= "0001000001000010";
when x"07" => D <= "0001000010000011";
when x"08" => D <= "1001000000000001";
when others => D <= x"0000";

       end case; 
    end if;
  end process;
end behav;
