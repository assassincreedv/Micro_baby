LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.mbspt.all;
ENTITY PCunit IS
  PORT (pc : OUT std_logic_vector(7 downto 0);
        fixval : IN std_logic_vector(7 downto 0);
        pcsel,ldnewpc : IN std_logic;
        rst : IN std_logic);
END PCunit;

ARCHITECTURE one OF pcunit IS
  SIGNAL incrout,pcint,muxout : std_logic_vector(7 downto 0);
   
BEGIN
  -- The loadable Program Counter Register
  PROCESS(ldnewpc,muxout,rst)
  BEGIN
    IF rst='0' THEN pcint <= "00000000";
    ELSIF ldnewpc='1' AND ldnewpc'event THEN pcint <= muxout;
    END IF;
  END PROCESS;

  --Icrement PCint value
  incrout <= bin8_inc(pcint);
 
  --internal mux of new PC value
  muxout <= incrout WHEN pcsel='1' ELSE fixval;

  --Drive pc output
  pc <= pcint;
  
END one;

-------------------------------------------------------------------------------
--  The Test Bench Architecture
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY tb_PCunit IS
END tb_PCunit;
-------------------------------------------------------------------------------
--  The Test Bench Architecture
-------------------------------------------------------------------------------
ARCHITECTURE one OF tb_PCunit IS

  SIGNAL pc : std_logic_vector(7 downto 0);
  SIGNAL fixval : std_logic_vector(7 downto 0);
  SIGNAL pcsel,ldnewpc : std_logic;
  SIGNAL rst : std_logic;
  
COMPONENT PCunit
    PORT (pc : OUT std_logic_vector(7 downto 0);
          fixval : IN std_logic_vector(7 downto 0);
          pcsel,ldnewpc : IN std_logic;
          rst : IN std_logic);
END COMPONENT;
  FOR ALL : PCunit USE ENTITY WORK.PCunit(one);
  

BEGIN
  
  U0: PCunit PORT MAP(pc,fixval,pcsel,ldnewpc,rst);
    
PROCESS
  
    PROCEDURE newpc IS
    BEGIN
      WAIT FOR 20 ns;
      ldnewpc <= '1';
      WAIT FOR 20 ns;
      ldnewpc <= '0';
      WAIT FOR 20 ns;
    END newpc;
    
    PROCEDURE pc_con IS
    BEGIN
      fixval <= "00000010";      
      newpc;
      fixval <= "00000100";
      newpc;
      fixval <= "00001000";
      newpc;
      fixval <= "00010000";
      newpc;
      fixval <= "00100000";
      newpc;
      fixval <= "01000000";
      newpc;
      fixval <= "10000000";
      newpc;
    END pc_con;
    
  BEGIN
    
    WAIT FOR 100 ns;
    pc_con;
    rst <= '0'; 
    WAIT FOR 10 ns;
    rst <= '1';
    WAIT FOR 100 ns;
    pcsel <= '1';
    pc_con;
    pcsel <= '0';
    pc_con;
    WAIT;
	  
  END PROCESS;

END one;
