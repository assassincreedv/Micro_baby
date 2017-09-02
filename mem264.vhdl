LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.mbspt.all;
ENTITY mem264 IS
  PORT (rw,ce : IN std_logic;
        addr  : IN std_logic_vector (7 downto 0);
        data  : INOUT std_logic_vector (7 downto 0));  
END mem264;

ARCHITECTURE one OF mem264 IS
  
BEGIN

PROCESS (rw,ce,addr,data)
  TYPE memwd IS ARRAY (0 to 255) of std_logic_vector (7 downto 0);
  VARIABLE mem : memwd;
  VARIABLE iaddr : integer;
BEGIN
  IF (ce = '1') THEN
    IF (rw = '1') THEN --rw high so a write
      iaddr := bin8_2_int(addr);
      mem(iaddr) := data; 
    ELSE
      iaddr := bin8_2_int(addr);
      data <= mem(iaddr);
    END IF;
  ELSE
    data <= "ZZZZZZZZ";
  END IF;
END PROCESS;  
  
END one;


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY tb_mem264 IS
END tb_mem264;

ARCHITECTURE one OF tb_mem264 IS
  SIGNAL rw, ce : std_logic;
  SIGNAL addr : std_logic_vector (7 downto 0);
  SIGNAL data : std_logic_vector (7 downto 0); 
  
  COMPONENT mem264
    PORT (rw,ce : IN std_logic;
          addr  : IN std_logic_vector (7 downto 0);
          data  : INOUT std_logic_vector (7 downto 0));  
  END COMPONENT;
  FOR ALL: mem264 USE ENTITY WORK.mem264(one);

BEGIN
tb: mem264 PORT MAP (rw, ce, addr, data);

PROCESS
BEGIN
  WAIT FOR 10 ns;
ce <= '0';
rw <= '1';
addr <= "00000010";
WAIT FOR 100 ns;
addr <= "ZZZZZZZZ";
data <= "ZZZZZZZZ";
WAIT FOR 20 ns;
rw <= '0';
addr <= "00000010";
WAIT FOR 100 ns;
addr <= "ZZZZZZZZ";
data <= "ZZZZZZZZ";
WAIT FOR 20 ns;
--write
ce <= '1';
rw <= '1';
addr <= "01000010";
data <= "10001100";
WAIT FOR 100 ns;
addr <= "ZZZZZZZZ";
data <= "ZZZZZZZZ";
WAIT FOR 20 ns;
--read
rw <= '0';
addr <= "01000010";
WAIT FOR 100 ns;
addr <= "ZZZZZZZZ";
WAIT;
END PROCESS;
END one;

 