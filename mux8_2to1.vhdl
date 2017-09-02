LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY mux8_2to1 IS
  PORT(minl,minr : IN std_logic_vector(7 downto 0);
       msel      : IN std_logic;
       mout      : OUT std_logic_vector(7 downto 0));
END mux8_2to1;

ARCHITECTURE one OF mux8_2to1 IS
BEGIN
  mout <= minl WHEN msel='1' ELSE minr;
END one;


-------------------------------------------------------------------------------
--  The Test Bench Entity
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY tb_mux8_2to1 IS
END tb_mux8_2to1;

-------------------------------------------------------------------------------
--  The Test Bench Architecture
-------------------------------------------------------------------------------
ARCHITECTURE one of tb_mux8_2to1 IS

  SIGNAL minl,minr : std_logic_vector(7 downto 0);
  SIGNAL msel : std_logic;
  SIGNAL mout : std_logic_vector(7 downto 0);
  
  COMPONENT mux8_2to1
    PORT(minl,minr : IN std_logic_vector(7 downto 0);
         msel : IN std_logic;
         mout : OUT std_logic_vector(7 downto 0));
  END COMPONENT;
  
  FOR ALL : mux8_2to1 USE ENTITY WORK.mux8_2to1(one);
  
BEGIN
  
  a0 : mux8_2to1 PORT MAP (minl,minr,msel,mout);
    
PROCESS
  BEGIN
    WAIT for 5 ns;
    minl <= "00110000";
    WAIT FOR 20 ns;
    minr <= "11001111";
    WAIT FOR 80 ns;
    msel <= '0'; 
    WAIT FOR 100 ns;
    msel <= '1'; 
    WAIT FOR 100 ns;
    minl <= "00001011";
    minr <= "11110010";
    msel <= '0'; 
    WAIT FOR 100 ns;
    msel <= '1';
	  WAIT;
	  
  END PROCESS;

END one;
