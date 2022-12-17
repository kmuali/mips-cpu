library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

-- 16-bit unsigned divider
-- using iterative subtraction with MUXs
-- designed by @kmuali: Karim M. Ali in 16-12-2022

entity div16 is
  port (
    A, B: in std_logic_vector(16-1 downto 0);
    Q: out std_logic_vector(16-1 downto 0)
  );
end entity div16;


architecture behav of div16 is
  type mat is array(0 to 15) of std_logic_vector(16 downto 0);
  signal top, diff: mat;
begin


  top(0) <= x"0000"&A(15);
  diff(0) <= top(0) - ("0"&B);

  gsub: for i in 1 to 15 generate
    top(i)(16) <= '0';
    top(i)(0) <= A(15-i);
    with diff(i - 1)(16) select
      top(i)(15 downto 1) <= diff(i - 1)(14 downto 0) when '0',
                             top(i - 1)(14 downto 0) when others;
    diff(i) <= top(i) - ("0"&B);
    end generate gsub;
  gQ: for i in 0 to 15 generate
    Q(15 - i) <= NOT diff(i)(16);
  end generate gQ;

end behav;
