library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity cpu_tb is
end entity cpu_tb;


architecture tb of cpu_tb is
  component cpu is
  port (
    clk, reset: in std_logic;
    ram_L0: out std_logic_vector(16-1 downto 0)
  );
  end component;
  signal clk, reset: std_logic := '0';
  signal ram_L0 : std_logic_vector (16-1 downto 0);
begin
  cpu1: cpu port map(clk, reset, ram_L0);
  clk<=not clk after 0.25 ns;
  process
  begin
   reset <= '1';
   wait for 1 ns;
   reset <= '0';
   wait;
  end process;
end tb;
