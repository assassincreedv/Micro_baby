LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY mb_2 IS
  PORT(clk : IN std_logic;
       reset : IN std_logic);
END mb_2;

ARCHITECTURE one OF mb_2 IS
  -- declare components that make up MicroBaby
  ------------------------------------------------------
  COMPONENT clkdrv IS
    PORT(mclk : OUT std_logic;
         clk  : OUT std_logic);
  END COMPONENT;
  FOR all : clkdrv USE ENTITY WORK.clkdrv(one);
  ------------------------------------------------------
  COMPONENT mem264 IS
    PORT (rw,ce : IN std_logic;
          addr  : IN std_logic_vector (7 downto 0);
          data  : INOUT std_logic_vector (7 downto 0));  
  END COMPONENT;
  FOR all : mem264 USE ENTITY WORK.mem264(one);
  ------------------------------------------------------
  COMPONENT mbctl IS
    PORT(stld : OUT std_logic;
         ldcmpl : IN std_logic;
         Dbus : IN std_logic_vector(7 downto 0);
         addr : OUT std_logic_vector(7 downto 0);
         rst : IN std_logic;
         clk,mclk : IN std_logic;
         rw,ice : OUT std_logic;
         dce : OUT std_logic;
         Aal,Bbu,Bmltch,Ldacc,Dracc,AddSub,Arlo : OUT std_logic;
         Csel : OUT std_logic_vector(1 downto 0);
         Funct : OUT std_logic_vector(3 downto 0);
         C,N,Z : IN std_logic;
         CtlCout : OUT std_logic);
  END COMPONENT;
  FOR all : mbctl USE ENTITY WORK.mbctl(one);
  ------------------------------------------------------
  COMPONENT bstrpld IS
    PORT(stld : IN std_logic;
	 rw,ice,dce : OUT std_logic;
         addr : OUT std_logic_vector (7 downto 0);
         data : OUT std_logic_vector (7 downto 0);
	 ldcmpl : OUT std_logic);
  END COMPONENT;
  FOR all : bstrpld USE ENTITY WORK.bstrpld(one);
  ------------------------------------------------------
  COMPONENT mbdp IS
  PORT (Dbus : INOUT std_logic_vector(7 downto 0);
        Fun : IN std_logic_vector(3 downto 0);
        AddSub : IN std_logic;
        Cin : IN std_logic;
        Arlo : IN std_logic;
        Csel : IN std_logic_vector(1 downto 0);
        DrAcc : IN std_logic;
        Aal : IN std_logic;
        Bbu : IN std_logic;
        Bmltch : IN std_logic;
        Ldacc : IN std_logic;
        Cout,N,Z : OUT std_logic);    
  END COMPONENT;
  FOR all : mbdp USE ENTITY WORK.mbdp(one);
  ------------------------------------------------------
  SIGNAL sclk,smclk : std_logic;
  SIGNAL stld,ldcmpl,rst,rw,ice,dce : std_logic := '0';
  SIGNAL Dbus,addr : std_logic_vector(7 downto 0) := "ZZZZZZZZ";
  SIGNAL Aal,Bbu,Ldacc,Dracc,AddSub,Arlo,Bmltch :  std_logic:='0';
  SIGNAL Csel : std_logic_vector(1 downto 0);
  SIGNAL Cin,Cout,N,Z : std_logic := '0';    --for datapath
  SIGNAL Funct : std_logic_vector(3 downto 0) := "0000";
BEGIN
  ck1  : clkdrv PORT MAP (smclk,sclk);
  ctlr : mbctl PORT MAP (stld,ldcmpl,Dbus,addr,rst,sclk,smclk,rw,ice,dce,Aal,Bbu,Bmltch,Ldacc,Dracc,AddSub,Arlo,Csel,Funct,Cout,N,Z,Cin);
  ldr  : bstrpld PORT MAP (stld,rw,ice,dce,addr,Dbus,ldcmpl);
  dm   : mem264 PORT MAP (rw,dce,addr,Dbus);
  im   : mem264 PORT MAP (rw,ice,addr,Dbus);
  dp   : mbdp PORT MAP (Dbus,Funct,AddSub,Cin,Arlo,Csel,Dracc,Aal,Bbu,Bmltch,Ldacc,Cout,N,Z);

  rst <= '1', '0' AFTER 20 ns, '1' AFTER 1000 ns;

END one;