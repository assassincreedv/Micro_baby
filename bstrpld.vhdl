LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE std.textio.all;
USE WORK.mbspt.all;
ENTITY bstrpld IS
  PORT (stld : IN std_logic;
	rw,ice,dce : OUT std_logic;
        addr : OUT std_logic_vector (7 downto 0);
        data : OUT std_logic_vector (7 downto 0);
	ldcmpl : OUT std_logic);
END bstrpld;

ARCHITECTURE one OF bstrpld IS

BEGIN
  PROCESS
    FILE data_mem : TEXT;
    FILE prog_mem : TEXT;
    VARIABLE cur_line : LINE;
    VARIABLE blkaddr : integer;
    VARIABLE byteval : bit_vector(7 downto 0);
    VARIABLE bytevalsl : std_logic_vector(7 downto 0);
    VARIABLE calcaddr : integer;
    VARIABLE stdlogaddr : std_logic_vector(7 downto 0);
  BEGIN
    ldcmpl <= '0';
    WAIT UNTIL stld='1';
    ------------------------------------------------------------
    --  FIRST LOAD THE program MEMORY from file "progmem"
    ------------------------------------------------------------
    file_open(prog_mem,"progmem",read_mode);
    rw <= '1'; --memory set up to read busses
    ice <= '0';  dce <= '0';   -- disable the memory chips
    WAIT FOR 100 ns;
    FOR O IN 0 to 15 LOOP
      READLINE(prog_mem,cur_line);
      READ(cur_line,blkaddr);
      READLINE(prog_mem,cur_line);
      FOR f1 IN 0 to 7 LOOP
        READ(cur_line,byteval);
        calcaddr := blkaddr*16 + f1;
        stdlogaddr := int_slog8(calcaddr);
        WAIT FOR 10 ns;
        data <= To_StdLogicVector(byteval);
        addr <= stdlogaddr;
        WAIT FOR 10 ns;
        ice <= '1';
        WAIT FOR 20 ns;
        ice <= '0';
        WAIT FOR 10 ns;
      END LOOP;  
      READLINE(prog_mem,cur_line);
      FOR f2 IN 0 to 7 LOOP
        READ(cur_line,byteval);
        calcaddr := blkaddr*16 + 8 + f2;
        stdlogaddr := int_slog8(calcaddr);
        WAIT FOR 10 ns;
        data <= To_StdLogicVector(byteval);
        addr <= stdlogaddr;
        WAIT FOR 10 ns;
        ice <= '1';
        WAIT FOR 20 ns;
        ice <= '0';
        WAIT FOR 10 ns;
      END LOOP;
    END LOOP;
    WAIT FOR 50 ns;
    file_close(prog_mem);
    ------------------------------------------------------------
    --  NEXT LOAD THE data MEMORY from file "datamem"
    ------------------------------------------------------------
    file_open(data_mem,"datamem",read_mode);
    rw <= '1'; --memory set up to read busses
    ice <= '0';  dce <= '0';   -- disable the memory chips
    WAIT FOR 100 ns;
    FOR O IN 0 to 15 LOOP
      READLINE(data_mem,cur_line);
      READ(cur_line,blkaddr);
      READLINE(data_mem,cur_line);
      FOR f1 IN 0 to 7 LOOP
        READ(cur_line,byteval);
        calcaddr := blkaddr*16 + f1;
        stdlogaddr := int_slog8(calcaddr);
        WAIT FOR 10 ns;
        data <= To_StdLogicVector(byteval);
        addr <= stdlogaddr;
        WAIT FOR 10 ns;
        dce <= '1';
        WAIT FOR 20 ns;
        dce <= '0';
        WAIT FOR 10 ns;
      END LOOP;  
      READLINE(data_mem,cur_line);
      FOR f2 IN 0 to 7 LOOP
        READ(cur_line,byteval);
        calcaddr := blkaddr*16 + 8 + f2;
        stdlogaddr := int_slog8(calcaddr);
        WAIT FOR 10 ns;
        data <= To_StdLogicVector(byteval);
        addr <= stdlogaddr;
        WAIT FOR 10 ns;
        dce <= '1';
        WAIT FOR 20 ns;
        dce <= '0';
        WAIT FOR 10 ns;
      END LOOP;
    END LOOP;
    WAIT FOR 50 ns;
    file_close(data_mem);
    ldcmpl <= '1';
    rw <= 'Z';
    ice <= 'Z';
    dce <= 'Z';
    data <= "ZZZZZZZZ";
    addr <= "ZZZZZZZZ";
    WAIT FOR 100 ns;
    WAIT ON stld;
  END PROCESS;
END one;


-------------------------------------------------------------------------------
--  The Test Bench Entity
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY tb_bstrpld IS
END tb_bstrpld;

-------------------------------------------------------------------------------
--  The Test Bench Architecture
-------------------------------------------------------------------------------
ARCHITECTURE one OF tb_bstrpld IS

  SIGNAL stld : std_logic;
  SIGNAL rw,ice,dce : std_logic;
  SIGNAL addr : std_logic_vector (7 downto 0);
  SIGNAL data : std_logic_vector (7 downto 0);
  SIGNAL ldcmpl : std_logic;
  
  COMPONENT bstrpld
    PORT (stld : IN std_logic;
	        rw,ice,dce : OUT std_logic;
          addr : OUT std_logic_vector (7 downto 0);
          data : OUT std_logic_vector (7 downto 0);
        	 ldcmpl : OUT std_logic);
  END COMPONENT;
  FOR ALL : bstrpld USE ENTITY WORK.bstrpld(one);

BEGIN
  
  g0 : bstrpld PORT MAP (stld,rw,ice,dce,addr,data,ldcmpl);

PROCESS
  BEGIN
    
    WAIT FOR 100 ns;
    stld <= '0';
    WAIT FOR 100 ns;
    stld <= '1';
	  WAIT;
	  
  END PROCESS;
    
END one;



