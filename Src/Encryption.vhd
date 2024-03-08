--Github-Copilot was not used
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Encryption is
  Port (
  clr : IN STD_LOGIC;
  clk : IN STD_LOGIC;
  din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  din_valid : IN STD_LOGIC;
  dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  dout_ready : OUT STD_LOGIC);
end Encryption;

architecture Behavioral of Encryption is

--Round Counter
SIGNAL i_cnt : STD_LOGIC_VECTOR(3 DOWNTO 0);

--For Block A
SIGNAL ab_xor : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_rot : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_pre : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);

--For Block B
SIGNAL ba_xor : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_rot : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_pre : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);

-- S-key Declaration
TYPE ROM IS ARRAY(0 TO 25) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
CONSTANT skey : ROM:=(X"00000000", X"00000000", X"46F8E8C5",
X"460C6085", X"70F83B8A", X"284B8303", X"513E1454", X"F621ED22",
X"3125065D", X"11A83A5D", X"D427686B", X"713AD82D", X"4B792F99",
X"2799A4DD", X"A7901C49", X"DEDE871A", X"36C03196", X"A7EFC249",
X"61A78BB8", X"3B0A1D2B", X"4DBFCA76", X"AE162167", X"30D76B0A",
X"43192304", X"F6CC1431", X"65046380");

-- FSM State Declaration
TYPE StateType IS (ST_IDLE, ST_PRE_ROUND, ST_ROUND_OP, ST_READY);
SIGNAL state: StateType;

begin
-- Combinational Logic

-- For Block A
ab_xor <= a_reg XOR b_reg;
-- Data Dependent Left Rotate
WITH b_reg(4 DOWNTO 0) SELECT
    a_rot <= ab_xor(30 DOWNTO 0) & ab_xor(31) WHEN "00001",
    ab_xor(29 DOWNTO 0) & ab_xor(31 DOWNTO 30) WHEN "00010",
    ab_xor(28 DOWNTO 0) & ab_xor(31 DOWNTO 29) WHEN "00011",
    ab_xor(27 DOWNTO 0) & ab_xor(31 DOWNTO 28) WHEN "00100",
    ab_xor(26 DOWNTO 0) & ab_xor(31 DOWNTO 27) WHEN "00101",
    ab_xor(25 DOWNTO 0) & ab_xor(31 DOWNTO 26) WHEN "00110",
    ab_xor(24 DOWNTO 0) & ab_xor(31 DOWNTO 25) WHEN "00111",
    ab_xor(23 DOWNTO 0) & ab_xor(31 DOWNTO 24) WHEN "01000",
    ab_xor(22 DOWNTO 0) & ab_xor(31 DOWNTO 23) WHEN "01001",
    ab_xor(21 DOWNTO 0) & ab_xor(31 DOWNTO 22) WHEN "01010",
    ab_xor(20 DOWNTO 0) & ab_xor(31 DOWNTO 21) WHEN "01011",
    ab_xor(19 DOWNTO 0) & ab_xor(31 DOWNTO 20) WHEN "01100",
    ab_xor(18 DOWNTO 0) & ab_xor(31 DOWNTO 19) WHEN "01101",
    ab_xor(17 DOWNTO 0) & ab_xor(31 DOWNTO 18) WHEN "01110",
    ab_xor(16 DOWNTO 0) & ab_xor(31 DOWNTO 17) WHEN "01111",
    ab_xor(15 DOWNTO 0) & ab_xor(31 DOWNTO 16) WHEN "10000",
    ab_xor(14 DOWNTO 0) & ab_xor(31 DOWNTO 15) WHEN "10001",
    ab_xor(13 DOWNTO 0) & ab_xor(31 DOWNTO 14) WHEN "10010",
    ab_xor(12 DOWNTO 0) & ab_xor(31 DOWNTO 13) WHEN "10011",
    ab_xor(11 DOWNTO 0) & ab_xor(31 DOWNTO 12) WHEN "10100",
    ab_xor(10 DOWNTO 0) & ab_xor(31 DOWNTO 11) WHEN "10101",
    ab_xor(9 DOWNTO 0) & ab_xor(31 DOWNTO 10) WHEN "10110",
    ab_xor(8 DOWNTO 0) & ab_xor(31 DOWNTO 9) WHEN "10111",
    ab_xor(7 DOWNTO 0) & ab_xor(31 DOWNTO 8) WHEN "11000",
    ab_xor(6 DOWNTO 0) & ab_xor(31 DOWNTO 7) WHEN "11001",
    ab_xor(5 DOWNTO 0) & ab_xor(31 DOWNTO 6) WHEN "11010",
    ab_xor(4 DOWNTO 0) & ab_xor(31 DOWNTO 5) WHEN "11011",
    ab_xor(3 DOWNTO 0) & ab_xor(31 DOWNTO 4) WHEN "11100",
    ab_xor(2 DOWNTO 0) & ab_xor(31 DOWNTO 3) WHEN "11101",
    ab_xor(1 DOWNTO 0) & ab_xor(31 DOWNTO 2) WHEN "11110",
    ab_xor(0) & ab_xor(31 DOWNTO 1) WHEN "11111",
    ab_xor WHEN OTHERS;
a_pre <= din(63 DOWNTO 32) + skey(0); -- A = A + S[0]
a <= a_rot + skey(CONV_INTEGER(i_cnt & '0')); -- S[2*i]
 
 -- For Block B
 
ba_xor <= b_reg XOR a;
-- Data Dependent Left Rotate
WITH a(4 DOWNTO 0) SELECT
    b_rot <= ba_xor(30 DOWNTO 0) & ba_xor(31) WHEN "00001",
    ba_xor(29 DOWNTO 0) & ba_xor(31 DOWNTO 30) WHEN "00010",
    ba_xor(28 DOWNTO 0) & ba_xor(31 DOWNTO 29) WHEN "00011",
    ba_xor(27 DOWNTO 0) & ba_xor(31 DOWNTO 28) WHEN "00100",
    ba_xor(26 DOWNTO 0) & ba_xor(31 DOWNTO 27) WHEN "00101",
    ba_xor(25 DOWNTO 0) & ba_xor(31 DOWNTO 26) WHEN "00110",
    ba_xor(24 DOWNTO 0) & ba_xor(31 DOWNTO 25) WHEN "00111",
    ba_xor(23 DOWNTO 0) & ba_xor(31 DOWNTO 24) WHEN "01000",
    ba_xor(22 DOWNTO 0) & ba_xor(31 DOWNTO 23) WHEN "01001",
    ba_xor(21 DOWNTO 0) & ba_xor(31 DOWNTO 22) WHEN "01010",
    ba_xor(20 DOWNTO 0) & ba_xor(31 DOWNTO 21) WHEN "01011",
    ba_xor(19 DOWNTO 0) & ba_xor(31 DOWNTO 20) WHEN "01100",
    ba_xor(18 DOWNTO 0) & ba_xor(31 DOWNTO 19) WHEN "01101",
    ba_xor(17 DOWNTO 0) & ba_xor(31 DOWNTO 18) WHEN "01110",
    ba_xor(16 DOWNTO 0) & ba_xor(31 DOWNTO 17) WHEN "01111",
    ba_xor(15 DOWNTO 0) & ba_xor(31 DOWNTO 16) WHEN "10000",
    ba_xor(14 DOWNTO 0) & ba_xor(31 DOWNTO 15) WHEN "10001",
    ba_xor(13 DOWNTO 0) & ba_xor(31 DOWNTO 14) WHEN "10010",
    ba_xor(12 DOWNTO 0) & ba_xor(31 DOWNTO 13) WHEN "10011",
    ba_xor(11 DOWNTO 0) & ba_xor(31 DOWNTO 12) WHEN "10100",
    ba_xor(10 DOWNTO 0) & ba_xor(31 DOWNTO 11) WHEN "10101",
    ba_xor(9 DOWNTO 0) & ba_xor(31 DOWNTO 10) WHEN "10110",
    ba_xor(8 DOWNTO 0) & ba_xor(31 DOWNTO 9) WHEN "10111",
    ba_xor(7 DOWNTO 0) & ba_xor(31 DOWNTO 8) WHEN "11000",
    ba_xor(6 DOWNTO 0) & ba_xor(31 DOWNTO 7) WHEN "11001",
    ba_xor(5 DOWNTO 0) & ba_xor(31 DOWNTO 6) WHEN "11010",
    ba_xor(4 DOWNTO 0) & ba_xor(31 DOWNTO 5) WHEN "11011",
    ba_xor(3 DOWNTO 0) & ba_xor(31 DOWNTO 4) WHEN "11100",
    ba_xor(2 DOWNTO 0) & ba_xor(31 DOWNTO 3) WHEN "11101",
    ba_xor(1 DOWNTO 0) & ba_xor(31 DOWNTO 2) WHEN "11110",
    ba_xor(0) & ba_xor(31 DOWNTO 1) WHEN "11111",
    ba_xor WHEN OTHERS;
b_pre <= din(31 DOWNTO 0) + skey(1); -- B = B + S[1]     
b <= b_rot + skey(CONV_INTEGER(i_cnt & '1')); -- S[2*i + 1]

-- Sequential Circuit for Block A
process(clr, clk)begin
    IF(clr = '0') THEN
        a_reg <= (OTHERS=>'0');
    ELSIF(clk'EVENT AND clk = '1') THEN
        IF(state = ST_PRE_ROUND) THEN 
            a_reg <= a_pre;
        ELSIF(state = ST_ROUND_OP) THEN 
            a_reg <= a; 
        END IF;
    END IF;
end process;

-- Sequential Circuit for Block B
process(clr, clk)begin
    IF(clr = '0') THEN
        b_reg <= (OTHERS=>'0');
    ELSIF(clk'EVENT AND clk = '1') THEN
        IF(state = ST_PRE_ROUND) THEN 
            b_reg <= b_pre;
        ELSIF(state = ST_ROUND_OP) THEN 
            b_reg <= b; 
        END IF;
    END IF;
end process;

-- FSM
process(clr, clk)begin
    IF(clr = '0') THEN
        state <= ST_IDLE;
    ELSIF(clk'EVENT AND clk = '1') THEN
        CASE state IS
            WHEN ST_IDLE => IF(din_valid = '1') THEN state <= ST_PRE_ROUND; END IF;
            WHEN ST_PRE_ROUND => state <= ST_ROUND_OP;
            WHEN ST_ROUND_OP => IF(i_cnt="1100") THEN state <= ST_READY; END IF;
            WHEN ST_READY => state <= ST_IDLE;
        END CASE;
    END IF;
end process;

-- Round Counter
process(clr, clk) begin
    IF(clr = '0') THEN
        i_cnt<="0001";
    ELSIF(clk'EVENT AND clk = '1') THEN
        IF(state=ST_ROUND_OP) THEN
            IF(i_cnt="1100") THEN 
                i_cnt<="0001";
            ELSE 
                i_cnt<=i_cnt+'1'; 
            END IF;
        END IF;
    END IF;
end process;

dout <= a_reg & b_reg;
  WITH state SELECT
    dout_ready <= '1' WHEN ST_READY,
               '0' WHEN OTHERS;
end Behavioral;



















