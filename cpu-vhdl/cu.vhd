library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity cu is
  port (
    clk, executing: in std_logic;
    exe_done, PC_changed: out std_logic;
    PC_new: out std_logic_vector(8-1 downto 0);
    IR: in std_logic_vector(16-1 downto 0);
    alu_S: out std_logic_vector(3-1 downto 0);
    alu_B: out std_logic_vector(16-1 downto 0);
    alu_F: in std_logic_vector(16-1 downto 0);
    alu_C: in std_logic;
    mem_A: out std_logic_vector(8-1 downto 0);
    mem_E: out std_logic;
    mem_R: in std_logic_vector(16-1 downto 0);
    reg_W: out std_logic_vector(16-1 downto 0);
    reg_WA, reg_RA1, reg_RA2: out std_logic_vector(3-1 downto 0);
    reg_R2: in std_logic_vector(16-1 downto 0);
    reg_E: out std_logic
  );
end entity cu;

architecture behav of cu is
  signal step : std_logic_vector (2-1 downto 0); -- step counter
  signal inst_oc: std_logic_vector (4-1 downto 0); -- opcode
  signal inst_rs, inst_rt, inst_rd, inst_op: std_logic_vector(3-1 downto 0);
  signal inst_RRI_imm, inst_RI_imm: std_logic_vector(16-1 downto 0);
  signal inst_RI_UJ_addr, inst_CJ_addr: std_logic_vector(8-1 downto 0);
  signal step0, step1, step2, step3: std_logic;
  signal FR: std_logic_vector (3-1 downto 0);
begin
  -- splitting instruction into meaningful parts
  inst_oc <= IR(15 downto 12);
  inst_rs <= IR(11 downto 9);
  inst_rt <= IR(8 downto 6);
  inst_rd <= IR(5 downto 3);
  inst_op <= IR(2 downto 0);
  with IR(6-1) select
    inst_RRI_imm <= "1111" & "1111" & "11" & IR(6-1 downto 0) when '1',
                    "0000" & "0000" & "00" & IR(6-1 downto 0) when others;
  with IR(9-1) select
    inst_RI_imm <= "1111" & "111" & IR(9-1 downto 0) when '1',
                   "0000" & "000" & IR(9-1 downto 0) when others;
  inst_RI_UJ_addr <= IR(8-1 downto 0); -- RI and uncondtional jump address
  inst_CJ_addr <= "00" & IR(6-1 downto 0); -- conditional jump address


  step0 <= not step(0) and not step(1);
  step1 <= step(0) and not step(1);
  step2 <= not step(0) and step(1);
  step3 <= step(0) and step(1);


  with inst_oc select
    alu_B <= reg_R2 when x"1" | x"A" | x"B" | x"C", -- arith RRR and cond jumping
             inst_RRI_imm  when others; -- arith RRI

  with inst_oc select
    alu_S <= inst_op when x"1",
             o"0" when x"2", -- add inst_RRI_imm
             inst_op(alu_S'range) when x"4" | x"5" | x"6", -- and, or, xor inst_RRI_imm
             o"1" when others; -- sub inst_RRI_imm, jumping comparasions xA xB xC

  with inst_oc select
    reg_W <= mem_R when x"8", -- load mem
             inst_RI_imm when x"7", -- load imm
             alu_F when others; -- arith all types 

  with inst_oc select
    reg_WA <= inst_rd when x"1", -- arith RRR
              inst_rs when x"7" | x"8", -- load imm, load mem
              inst_rt when others; -- arith RRI

  with inst_oc select
    PC_new <= inst_RI_UJ_addr when x"F",
             inst_CJ_addr when others;

  mem_A <= inst_RI_UJ_addr;

  reg_RA1 <= inst_rs;
  reg_RA2 <= inst_rt;

  with inst_oc select
    mem_E <= '1' when x"9",
             '0' when others;

  with inst_oc select
    reg_E <= step2 when x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" | x"8",
             '0' when others;

  with inst_oc select
    PC_changed <= step3 and FR(0) when x"A", -- equal
                  step3 and not FR(2) and not FR(0) when x"B", -- greater (not equal nor less)
                  step3 and FR(2) when x"C", -- less
                  FR(1) when x"D", -- carry
                  FR(0) when x"E", -- zero
                  '1' when x"F",
                  '0' when others;

  with inst_oc select
    exe_done <= step3 when x"A" | x"B" | x"C",
                step1 when x"D" | x"E" | x"F",
                step2 when others;

  process (clk)
  begin
    if rising_edge (clk) then
      if executing = '1' then
        step <= step + 1; -- count steps
      else
        step <= "00";
      end if;
      case inst_oc is
       when x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"A" | x"B" | x"C" => -- arith and cond jump
         case alu_F is
           when x"0000" => FR(0) <= '1';
           when others =>  FR(0) <= '0';
         end case;
         FR(1) <= alu_C;
         FR(2) <= alu_F(15);
       when others =>
         -- do not update FR otherwise
      end case;
    end if;
  end process;
end behav;
