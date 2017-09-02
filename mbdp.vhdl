LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY mbdp IS
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
END mbdp;

ARCHITECTURE one OF mbdp IS
  -- declare and configure components
  COMPONENT mbalu IS
   PORT(A,B : IN std_logic_vector(7 downto 0);
        res : OUT std_logic_vector(7 downto 0);
        cin : IN std_logic;
        Fun : IN std_logic_vector(3 downto 0);
        Csel : IN std_logic_vector(1 downto 0);
        Arlo : IN std_logic;
        AddSub : IN std_logic;
        Cout,N,Z : OUT std_logic);
  END COMPONENT;
  FOR all : mbalu USE ENTITY WORK.mbalu(one);
  ------------------------------------------------------
  COMPONENT mbaccum IS
    PORT(accin : IN std_logic_vector(7 downto 0);
         ld    : IN std_logic;
         accout : OUT std_logic_vector(7 downto 0));
  END COMPONENT;
  FOR all : mbaccum USE ENTITY WORK.mbaccum(one);
  ------------------------------------------------------
  COMPONENT mux8_2to1 IS
    PORT(minl,minr : IN std_logic_vector(7 downto 0);
         msel      : IN std_logic;
         mout      : OUT std_logic_vector(7 downto 0));
  END COMPONENT;
  FOR all : mux8_2to1 USE ENTITY WORK.mux8_2to1(one);
  ------------------------------------------------------
  COMPONENT busdr8 IS
    PORT(din : IN std_logic_vector(7 downto 0);
         drive : IN std_logic;
         dout : OUT std_logic_vector(7 downto 0));
  END COMPONENT;
  FOR all : busdr8 USE ENTITY WORK.busdr8(one);
  ------------------------------------------------------  
  SIGNAL amuxtoacc : std_logic_vector(7 downto 0);
  SIGNAL accout,bmuxout,alures,bmlout : std_logic_vector(7 downto 0);
  SIGNAL zero : std_logic_vector(7 downto 0) := "00000000";
  
BEGIN
  alu : mbalu PORT MAP (accout,bmlout,alures,Cin,Fun,Csel,Arlo,AddSub,Cout,N,Z);
  acc : mbaccum PORT MAP (amuxtoacc,Ldacc,accout);
  m1  : mux8_2to1 PORT MAP (alures,Dbus,Aal,amuxtoacc);
  m2  : mux8_2to1 PORT MAP (zero,Dbus,Bbu,bmuxout);
  bml : mbaccum PORT MAP (bmuxout,bmltch,bmlout);
  bd1 : busdr8 PORT MAP (accout,DrAcc,Dbus);
END one;



LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY tb_mbdp IS
END tb_mbdp;

ARCHITECTURE one OF tb_mbdp IS
-- declare DUT
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
  FOR all : mbdp USE ENTITY work.mbdp(one);

-- declare hookup signals
  SIGNAL dbus : std_logic_vector(7 downto 0);
  SIGNAL addsub,cin,arlo,cout,n,z: std_logic;
  SIGNAL csel : std_logic_vector(1 downto 0);
  SIGNAL fun : std_logic_vector(3 downto 0);
  SIGNAL bmltch,aal,bbu,ldacc,dracc : std_logic;

  BEGIN
  -- hook up DUT
  U0 : mbdp PORT MAP (dbus,fun,addsub,cin,arlo,csel,dracc,aal,bbu,bmltch,ldacc,cout,n,z);
  PROCESS
  BEGIN    
  --CYC ST
  -- set up intiail vectors and control signals - this cycle load accumulator and the bmlch with 0
  dbus <= "ZZZZZZZZ"; addsub <= '0';  cin <= '0'; arlo <= '1'; csel <= "10"; fun <= "1110";
  bmltch <= '0'; aal <= '0'; bbu <= '0'; ldacc <= '0'; dracc <= '0';
  WAIT FOR 10 ns;
  dbus <= "10101010"; aal <= '1'; bmltch <= '1';
  WAIT FOR 10 ns;
  ldacc <= '1';
  WAIT FOR 60 ns;
  dbus <= "ZZZZZZZZ";  aal <= '0'; ldacc <= '0'; bmltch <= '0';
  WAIT FOR 20 ns;
--
  --CYC ST
  -- set up intiail vectors and control signals - this cycle drive the accumulator onto the bus
  dbus <= "ZZZZZZZZ"; addsub <= '0';  cin <= '0'; arlo <= '1'; csel <= "10"; fun <= "1110";
  bmltch <= '0'; aal <= '0'; bbu <= '0'; ldacc <= '0'; dracc <= '0';
  WAIT FOR 10 ns;
  dracc <= '1'; aal <= '1'; bmltch <= '1';
  WAIT FOR 10 ns;
  -- ldacc <= '1';
  WAIT FOR 60 ns;
  dbus <= "ZZZZZZZZ"; dracc <= '0'; aal <= '0'; ldacc <= '0'; bmltch <= '0';
  WAIT FOR 20 ns;
--
  --CYC ST
  -- set up intiail vectors and control signals - this cycle adds a b input of 00001111 to the acc
  dbus <= "ZZZZZZZZ"; addsub <= '0';  cin <= '0'; arlo <= '1'; csel <= "10"; fun <= "1110";
  bmltch <= '0'; aal <= '0'; bbu <= '0'; ldacc <= '0'; dracc <= '0';
  WAIT FOR 10 ns;
  dbus <= "00001111"; bbu <= '1';
  WAIT FOR 10 ns;
  bmltch <= '1';  -- ldacc <= '1';
  WAIT FOR 60 ns;
  dbus <= "ZZZZZZZZ"; dracc <= '0'; aal <= '0'; ldacc <= '1', '0' after 10 ns; bmltch <= '0';
  WAIT FOR 20 ns;
--
  --CYC ST
  -- set up intiail vectors and control signals - this cycle drive the accumulator onto the bus
  dbus <= "ZZZZZZZZ"; addsub <= '0';  cin <= '0'; arlo <= '1'; csel <= "10"; fun <= "1110";
  bmltch <= '0'; aal <= '0'; bbu <= '0'; ldacc <= '0'; dracc <= '0';
  WAIT FOR 10 ns;
  dracc <= '1'; aal <= '1'; bmltch <= '1';
  WAIT FOR 10 ns;
  -- ldacc <= '1';
  WAIT FOR 60 ns;
  dbus <= "ZZZZZZZZ"; dracc <= '0'; aal <= '0'; ldacc <= '0'; bmltch <= '0';
  WAIT FOR 20 ns;
--
  --CYC ST
  -- set up intiail vectors and control signals - this cycle is a logical a OR b input of 00001111 to the acc
  dbus <= "ZZZZZZZZ"; addsub <= '0';  cin <= '0'; arlo <= '0'; csel <= "10"; fun <= "1110";
  bmltch  <= '0'; aal <= '0'; bbu <= '0'; ldacc <= '0'; dracc <= '0';
  WAIT FOR 10 ns;
  dbus <= "00001111"; bbu <= '1';
  WAIT FOR 10 ns;
  bmltch <= '1';  -- ldacc <= '1';
  WAIT FOR 60 ns;
  dbus <= "ZZZZZZZZ"; dracc <= '0'; aal <= '0'; ldacc <= '1', '0' after 10 ns; bmltch <= '0';
  WAIT FOR 20 ns;
--
  --CYC ST
  -- set up intiail vectors and control signals - this cycle drive the accumulator onto the bus
  dbus <= "ZZZZZZZZ"; addsub <= '0';  cin <= '0'; arlo <= '1'; csel <= "10"; fun <= "1110";
  bmltch <= '0'; aal <= '0'; bbu <= '0'; ldacc <= '0'; dracc <= '0';
  WAIT FOR 10 ns;
  dracc <= '1'; aal <= '1'; bmltch <= '1';
  WAIT FOR 10 ns;
  -- ldacc <= '1';
  WAIT FOR 60 ns;
  dbus <= "ZZZZZZZZ"; dracc <= '0'; aal <= '0'; ldacc <= '0'; bmltch <= '0';
  WAIT FOR 20 ns;

  WAIT FOR 100 ns;
  WAIT;
  END PROCESS;

END one;
