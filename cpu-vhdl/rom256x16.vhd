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
       -- [ALERT] Made program ../sum_from_1_to_n.asm
       when x"00" => D <= "0111000000000000"; -- li   $0, 0
       when x"01" => D <= "0111001000000001"; -- li   $1, 1
       when x"02" => D <= "0111010000001010"; -- li   $2, 10
       when x"03" => D <= "0001000001000000"; -- add  $0, $1, $0
       when x"04" => D <= "1010001010000111"; -- beq  $1, $2, 7
       when x"05" => D <= "0010001001000001"; -- addi $1, $1, $1
       when x"06" => D <= "1111000000000011"; -- br   3
       when x"07" => D <= "1001000000000000"; -- sm   $0, 0
       when others => D <= x"0000";
       end case; 
    end if;
  end process;
end behav;
