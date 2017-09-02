LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY mbaccum IS
  PORT(accin : IN std_logic_vector(7 downto 0);
       ld    : IN std_logic;
       accout : OUT std_logic_vector(7 downto 0));
END mbaccum;

ARCHITECTURE one OF mbaccum IS

BEGIN
  PROCESS
  BEGIN
    WAIT UNTIL ld='1' AND ld'event;
    accout <= accin;
  END PROCESS;
END one;


-------------------------------------------------------------------------------
--  The Test Bench Entity
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY tb_mbaccum IS
END tb_mbaccum;

-------------------------------------------------------------------------------
--  The Test Bench Architecture
-------------------------------------------------------------------------------
ARCHITECTURE one OF tb_mbaccum IS

  SIGNAL accin : std_logic_vector(7 downto 0);
  SIGNAL ld : std_logic;
  SIGNAL accout : std_logic_vector(7 downto 0);
  
  COMPONENT mbaccum
  PORT(accin : IN std_logic_vector(7 downto 0);
       ld    : IN std_logic;
       accout : OUT std_logic_vector(7 downto 0));
  END COMPONENT;
  
  FOR ALL : mbaccum USE ENTITY WORK.mbaccum(one);

BEGIN
  
  a0 : mbaccum PORT MAP(accin ,ld,accout);
    
PROCESS  
  BEGIN
    
    WAIT FOR 5 ns;
    ld <= '0'; 
    WAIT FOR 20 ns;
    ld <= '1';
    WAIT FOR 80 ns;
    accin <= "01001101";
    WAIT FOR 100 ns;
    ld <= '0';
    WAIT FOR 20 ns;
    ld <= '1';
    WAIT FOR 80 ns;
    accin <= "11110001";
    ld <= '1';
    WAIT FOR 100 ns;
    ld <= '0';
    WAIT FOR 20 ns;
    ld <= '1';
    accin <= "10001111";
	  WAIT;
	  
  END PROCESS;
END one;
