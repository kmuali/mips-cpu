library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;


entity alu16 is
  port (
    S: in std_logic_vector(3-1 downto 0);
    A, B: in std_logic_vector(16-1 downto 0);
    F: out std_logic_vector(16-1 downto 0);
    C: out std_logic
  );
end entity alu16;

architecture behav of alu16 is
  component div16 is
    port (
    A, B: in std_logic_vector(16-1 downto 0);
    Q: out std_logic_vector(16-1 downto 0)
  );
  end component;
  signal add: std_logic_vector(16 downto 0);
  signal div_Q, mul, abs_A, abs_B: std_logic_vector (16-1 downto 0);
  signal mul_div_sign : std_logic;
begin
  with A(15) select
    abs_A <= A when '0',
             0-A  when others;
  with B(15) select
    abs_B <= B when '0',
             0-B  when others;
             
  add <= ('0'&A) + ('0'&B);
  C <= add(16) and not (s(0) or s(1) or s(2));
  mul <= abs_A(8-1 downto 0) * abs_B(8-1 downto 0);
  div16_1: div16 port map(abs_A, abs_B, div_Q);
  mul_div_sign <= A(15) XOR B(15);
  with S select -- function
    F <= add(F'range) when o"0",
         A - B when o"1",
         (mul_div_sign)&mul(14 downto 0) when o"2",
         (mul_div_sign)&div_Q(14 downto 0) when o"3",
         A and B when o"4",
         A or B  when o"5",
         A xor B when o"6",
         not A   when others;
end behav;
