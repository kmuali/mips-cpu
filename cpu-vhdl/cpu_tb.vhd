library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity cpu_tb is
end entity cpu_tb;


architecture tb of cpu_tb is
  component cpu is
  port (
    clk, reset, pause: std_logic
  );
  end component;
  signal clk, reset, pause : std_logic := '0';
begin
  cpu1: cpu port map(clk, reset, pause);
  clk<=not clk after 0.25 ns;
  process
  begin
   reset <= '1';
   wait for 1 ns;
   reset <= '0';
   wait;
  end process;
end tb;
