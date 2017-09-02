LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY busdr8 IS
  PORT(din : IN std_logic_vector(7 downto 0);
       drive : IN std_logic;
       dout : OUT std_logic_vector(7 downto 0));
END busdr8;

ARCHITECTURE one OF busdr8 IS
BEGIN
  dout <= din WHEN drive='1' ELSE "ZZZZZZZZ";
END one;

-------------------------------------------------------------------------------
--  The Test Bench Entity
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY tb_busdr8 IS
END tb_busdr8;

-------------------------------------------------------------------------------
--  The Test Bench Architecture
-------------------------------------------------------------------------------
ARCHITECTURE one OF tb_busdr8 IS

  SIGNAL din : std_logic_vector(7 downto 0);
  SIGNAL drive : std_logic;
  SIGNAL dout : std_logic_vector(7 downto 0);
  
  COMPONENT busdr8
    PORT(din : IN std_logic_vector(7 downto 0);
         drive : IN std_logic;
         dout : OUT std_logic_vector(7 downto 0));
  END COMPONENT;
  FOR ALL : busdr8 USE ENTITY WORK.busdr8(one);
  

BEGIN
  
  a0 : busdr8 PORT MAP (din,drive,dout);
    
PROCESS
  BEGIN
    
    WAIT FOR 5 ns;
    drive <= '1';
    WAIT FOR 100 ns;
    din <= "11100111";
    WAIT FOR 100 ns;
    drive <= '0';
    WAIT FOR 100 ns;
    din <= "01001111";
    drive <= '1';
	  WAIT;
	  
  END PROCESS;
END one;

